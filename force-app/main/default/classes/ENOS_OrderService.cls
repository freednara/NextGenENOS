/**
 * @description Order service for ENOS e-commerce platform
 * Handles order creation, management, and payment processing
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_OrderService {
  // Cache standard pricebook ID per transaction
  private static Id stdPricebookId;

  /**
   * @description Inner class to define the inputs for the Invocable Method.
   * Contains all necessary data for order creation.
   */
  public class CreateOrderRequest {
    @InvocableVariable(
      label='Cart ID'
      required=true
      description='The ID of the cart to convert to an order'
    )
    public Id cartId;

    @InvocableVariable(
      label='Shipping Address ID'
      required=true
      description='The ID of the selected shipping address'
    )
    public Id shippingAddressId;

    @InvocableVariable(
      label='Payment Token'
      required=true
      description='Secure payment token from payment gateway'
    )
    public String paymentToken;
  }

  /**
   * @description Inner class to define the response from order creation.
   * Provides order details and status information.
   */
  public class CreateOrderResponse {
    @InvocableVariable(
      label='Order ID'
      description='The ID of the created order'
    )
    public Id orderId;

    @InvocableVariable(
      label='Order Number'
      description='The order number for the created order'
    )
    public String orderNumber;

    @InvocableVariable(
      label='Success'
      description='Whether the order was created successfully'
    )
    public Boolean isSuccess;

    @InvocableVariable(label='Message' description='Success or error message')
    public String message;
  }

  /**
   * @description Called by the Checkout Flow to process payment and create the final order.
   * This method performs an atomic transaction ensuring data consistency.
   *
   * @param requests List of CreateOrderRequest objects (typically contains one request)
   * @return List of CreateOrderResponse objects with order creation results
   */
  @InvocableMethod(
    label='Create Order from Cart'
    description='Processes payment and converts a Cart to an Order in a single transaction.'
  )
  public static List<CreateOrderResponse> createOrder(
    List<CreateOrderRequest> requests
  ) {
    if (requests == null || requests.isEmpty()) {
      throw new AuraHandledException('No order requests supplied.');
    }

    List<CreateOrderResponse> responses = new List<CreateOrderResponse>();

    // BULKIFICATION: Process all orders in a single transaction to respect governor limits
    return processBulkOrderCreation(requests);
  }

  /**
   * @description Bulkified order creation that processes multiple orders efficiently
   * @param requests List of order creation requests
   * @return List of responses with order creation results
   */
  private static List<CreateOrderResponse> processBulkOrderCreation(
    List<CreateOrderRequest> requests
  ) {
    List<CreateOrderResponse> responses = new List<CreateOrderResponse>();

    // Collections for bulkified DML operations
    List<Order> ordersToInsert = new List<Order>();
    List<OrderItem> orderItemsToInsert = new List<OrderItem>();
    List<Cart__c> cartsToDelete = new List<Cart__c>();

    Map<Integer, Cart__c> requestIndexToCart = new Map<Integer, Cart__c>();
    Map<Integer, List<Cart_Item__c>> requestIndexToCartItems = new Map<Integer, List<Cart_Item__c>>();
    Map<Integer, Shipping_Address__c> requestIndexToShippingAddress = new Map<Integer, Shipping_Address__c>();

    // Phase 1: Validate all requests and gather data
    for (Integer i = 0; i < requests.size(); i++) {
      CreateOrderRequest req = requests[i];
      CreateOrderResponse response = new CreateOrderResponse();

      try {
        // Validate input parameters
        ENOS_SecurityUtils.validateRequiredId(req.cartId, 'Cart ID');
        ENOS_SecurityUtils.validateRequiredId(req.shippingAddressId, 'Shipping Address ID');
        ENOS_SecurityUtils.validateRequiredString(req.paymentToken, 'Payment Token');

        // Get all necessary data with security checks
        Cart__c cart = getCartWithSecurity(req.cartId);
        List<Cart_Item__c> cartItems = getCartItemsWithSecurity(req.cartId);
        Shipping_Address__c shippingAddress = getShippingAddressWithSecurity(
          req.shippingAddressId
        );

        // Validate cart has items
        if (cartItems.isEmpty()) {
          throw new IllegalArgumentException(
            'Cart must contain at least one item to create an order.'
          );
        }

        // Store data for bulk processing
        requestIndexToCart.put(i, cart);
        requestIndexToCartItems.put(i, cartItems);
        requestIndexToShippingAddress.put(i, shippingAddress);

        // Initialize success response
        response.isSuccess = true;
      } catch (Exception e) {
        response.isSuccess = false;
        response.message = 'Order creation failed: ' + e.getMessage();
        System.debug(
          LoggingLevel.ERROR,
          'Order creation error for request ' + i + ': ' + e.getMessage()
        );
      }

      responses.add(response);
    }

    // Phase 2: Process payments and prepare bulk DML collections
    Savepoint sp = Database.setSavepoint();

    try {
      for (Integer i = 0; i < requests.size(); i++) {
        if (!responses[i].isSuccess)
          continue; // Skip failed validations

        CreateOrderRequest req = requests[i];
        Cart__c cart = requestIndexToCart.get(i);
        List<Cart_Item__c> cartItems = requestIndexToCartItems.get(i);
        Shipping_Address__c shippingAddress = requestIndexToShippingAddress.get(
          i
        );

        try {
          // Process payment for this request
          Decimal totalAmount = calculateTotalAmount(cartItems);
          ENOS_PayGovService.PayGovResponse paymentResponse = processPayGovPayment(
            cart,
            totalAmount,
            req.paymentToken
          );

          if (!paymentResponse.success) {
            throw new ENOS_PayGovService.PayGovException(
              'Payment processing failed: ' + paymentResponse.errorMessage
            );
          }

          // Create order record for bulk insertion
          Order newOrder = createOrderRecord(
            cart,
            shippingAddress,
            paymentResponse.transactionId
          );
          ordersToInsert.add(newOrder);

          // Store success data
          responses[i]
            .message = 'Payment processed successfully. Order will be created.';

          // Add cart to deletion list
          cartsToDelete.add(cart);
        } catch (Exception e) {
          responses[i].isSuccess = false;
          responses[i].message = 'Payment processing failed: ' + e.getMessage();
          System.debug(
            LoggingLevel.ERROR,
            'Payment error for request ' + i + ': ' + e.getMessage()
          );
        }
      }

      // Phase 3: Bulk DML Operations
      if (!ordersToInsert.isEmpty()) {
        ENOS_SecurityUtils.checkObjectCreateAccess('Order');
        insert ordersToInsert;

        // Create order items for all successful orders
        for (Integer i = 0; i < ordersToInsert.size(); i++) {
          Integer requestIndex = -1;
          // Find corresponding request index
          for (Integer j = 0; j < requests.size(); j++) {
            if (responses[j].isSuccess && requestIndexToCart.containsKey(j)) {
              if (requestIndex == -1) {
                requestIndex = j;
                break;
              }
            }
          }

          if (requestIndex >= 0) {
            List<Cart_Item__c> cartItems = requestIndexToCartItems.get(
              requestIndex
            );
            List<OrderItem> orderItems = createOrderItems(
              ordersToInsert[i].Id,
              cartItems
            );
            orderItemsToInsert.addAll(orderItems);

            // Update response with order details
            responses[requestIndex].orderId = ordersToInsert[i].Id;
            responses[requestIndex].orderNumber = ordersToInsert[i].OrderNumber;
            responses[requestIndex].message =
              'Order created successfully. Order Number: ' +
              ordersToInsert[i].OrderNumber;
          }
        }

        // Bulk insert order items
        if (!orderItemsToInsert.isEmpty()) {
          ENOS_SecurityUtils.checkObjectCreateAccess('OrderItem');
          insert orderItemsToInsert;
        }

        // Bulk delete carts
        if (!cartsToDelete.isEmpty()) {
          delete cartsToDelete;
        }
      }
    } catch (Exception e) {
      Database.rollback(sp);

      // Mark all responses as failed
      for (CreateOrderResponse response : responses) {
        if (response.isSuccess) {
          response.isSuccess = false;
          response.message = 'Bulk order processing failed: ' + e.getMessage();
        }
      }

      System.debug(
        LoggingLevel.ERROR,
        'Bulk order creation failed: ' + e.getMessage()
      );
    }

    return responses;
  }

  /**
   * @description Retrieves cart information with security validation.
   * Ensures the user can only access their own cart.
   *
   * @param cartId The ID of the cart to retrieve
   * @return Cart__c record with contact and account information
   * @throws IllegalArgumentException if cart not found or access denied
   */
  private static Cart__c getCartWithSecurity(Id cartId) {
    // Security check - ensure user can read Cart__c
    ENOS_SecurityUtils.checkObjectReadable('Cart__c');
    ENOS_SecurityUtils.checkFieldReadAccess(
      'Cart__c',
      new List<String>{
        'Id',
        'Contact__c',
        'Contact__r.AccountId',
        'Status__c'
      }
    );

    // Get current user's contact ID
    Id userContactId = getCurrentUserContactId();
    if (userContactId == null) {
      throw new IllegalArgumentException(
        'User is not associated with a Contact.'
      );
    }

    // Query for cart with ownership validation
    ENOS_SecurityUtils.checkObjectReadAccess('Cart__c');
    List<Cart__c> carts = [
      SELECT Id, Contact__c, Contact__r.AccountId, Status__c
      FROM Cart__c
      WHERE
        Id = :cartId
        AND Contact__c = :userContactId
        AND Status__c = 'Active'
      WITH USER_MODE
      LIMIT 1
    ];

    if (carts.isEmpty()) {
      throw new IllegalArgumentException('Cart not found or access denied.');
    }

    return carts[0];
  }

  /**
   * @description Retrieves cart items with security validation.
   * Ensures the user can only access items from their own cart.
   *
   * @param cartId The ID of the cart to retrieve items from
   * @return List of Cart_Item__c records
   * @throws IllegalArgumentException if cart items not found or access denied
   */
  private static List<Cart_Item__c> getCartItemsWithSecurity(Id cartId) {
    // Security check - ensure user can read Cart_Item__c
    ENOS_SecurityUtils.checkObjectReadable('Cart_Item__c');
    ENOS_SecurityUtils.checkFieldReadAccess(
      'Cart_Item__c',
      new List<String>{
        'Id',
        'Product__c',
        'Quantity__c',
        'Unit_Price__c',
        'Line_Total__c'
      }
    );

    // Query for cart items
    ENOS_SecurityUtils.checkObjectReadAccess('Cart_Item__c');
    List<Cart_Item__c> cartItems = [
      SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
      FROM Cart_Item__c
      WHERE Cart__c = :cartId
      WITH USER_MODE
      ORDER BY CreatedDate
    ];

    if (cartItems.isEmpty()) {
      throw new IllegalArgumentException('No items found in cart.');
    }

    return cartItems;
  }

  /**
   * @description Retrieves shipping address with security validation.
   * Ensures the user can only access addresses from their own account.
   *
   * @param shippingAddressId The ID of the shipping address to retrieve
   * @return Shipping_Address__c record
   * @throws IllegalArgumentException if address not found or access denied
   */
  private static Shipping_Address__c getShippingAddressWithSecurity(
    Id shippingAddressId
  ) {
    // Security check - ensure user can read Shipping_Address__c
    ENOS_SecurityUtils.checkObjectReadable('Shipping_Address__c');
    ENOS_SecurityUtils.checkFieldReadAccess(
      'Shipping_Address__c',
      new List<String>{
        'Id',
        'Street__c',
        'City__c',
        'State__c',
        'Postal_Code__c',
        'Country__c',
        'Account__c'
      }
    );

    // Get current user's account ID
    Id userAccountId = getCurrentUserAccountId();
    if (userAccountId == null) {
      throw new IllegalArgumentException(
        'User is not associated with an Account.'
      );
    }

    // Query for shipping address with ownership validation
    List<Shipping_Address__c> addresses = [
      SELECT Id, Street__c, City__c, State__c, Postal_Code__c, Country__c
      FROM Shipping_Address__c
      WHERE Id = :shippingAddressId AND Account__c = :userAccountId
      LIMIT 1
    ];

    if (addresses.isEmpty()) {
      throw new IllegalArgumentException(
        'Shipping address not found or access denied.'
      );
    }

    return addresses[0];
  }

  /**
   * @description Processes the actual order creation in a transactional manner.
   * Creates Order and OrderItem records with Pay.gov payment processing, then cleans up the cart.
   *
   * @param cart The cart record to convert
   * @param cartItems The items in the cart
   * @param shippingAddress The selected shipping address
   * @param paymentToken The payment token for processing
   * @return CreateOrderResponse with order creation results
   */
  private static CreateOrderResponse processOrderCreation(
    Cart__c cart,
    List<Cart_Item__c> cartItems,
    Shipping_Address__c shippingAddress,
    String paymentToken
  ) {
    CreateOrderResponse response = new CreateOrderResponse();

    // Define a savepoint for rollback in case of failure
    Savepoint sp = Database.setSavepoint();

    try {
      // 1. Calculate total amount for payment processing
      Decimal totalAmount = calculateTotalAmount(cartItems);

      // 2. Process Payment through Pay.gov FIRST - fail fast if payment fails
      ENOS_PayGovService.PayGovResponse paymentResponse = processPayGovPayment(
        cart,
        totalAmount,
        paymentToken
      );

      if (!paymentResponse.success) {
        throw new ENOS_PayGovService.PayGovException(
          'Payment processing failed: ' + paymentResponse.errorMessage
        );
      }

      System.debug(
        'Pay.gov payment initiated successfully. Transaction ID: ' +
        paymentResponse.transactionId
      );

      // 3. Only create order records AFTER successful payment
      ENOS_SecurityUtils.checkObjectCreateAccess('Order');
      Order newOrder = createOrderRecord(
        cart,
        shippingAddress,
        paymentResponse.transactionId
      );
      insert newOrder;

      // 4. Create OrderItem records from Cart_Item records
      ENOS_SecurityUtils.checkObjectCreateAccess('OrderItem');
      List<OrderItem> orderItems = createOrderItems(newOrder.Id, cartItems);
      insert orderItems;

      // 5. Validate order creation succeeded before cart cleanup
      if (newOrder.Id == null || orderItems.isEmpty()) {
        throw new AuraHandledException(
          'Order creation failed - missing order ID or items'
        );
      }

      // 6. Clean up: Delete the cart only after successful order creation
      delete cart;

      // 7. Prepare success response
      response.isSuccess = true;
      response.orderId = newOrder.Id;
      response.orderNumber = newOrder.OrderNumber;
      response.message =
        'Order created successfully. Order Number: ' + newOrder.OrderNumber;

      System.debug('Order created successfully: ' + newOrder.Id);
    } catch (Exception e) {
      // If any step fails, roll back the entire transaction to the savepoint
      Database.rollback(sp);

      // Prepare error response
      response.isSuccess = false;
      response.message = 'Order creation failed: ' + e.getMessage();

      System.debug(
        LoggingLevel.ERROR,
        'Order creation failed, transaction rolled back: ' + e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
    }

    return response;
  }

  /**
   * @description Creates the Order record with shipping information and payment details.
   *
   * @param cart The cart record containing account information
   * @param shippingAddress The selected shipping address
   * @param paymentTransactionId The Pay.gov transaction ID
   * @return Order record ready for insertion
   */
  private static Order createOrderRecord(
    Cart__c cart,
    Shipping_Address__c shippingAddress,
    String paymentTransactionId
  ) {
    // Security check - ensure user can create Order records
    ENOS_SecurityUtils.checkObjectCreateable('Order');
    ENOS_SecurityUtils.checkFieldEditAccess(
      'Order',
      new List<String>{
        'AccountId',
        'EffectiveDate',
        'Status',
        'Pricebook2Id',
        'ShippingStreet',
        'ShippingCity',
        'ShippingState',
        'ShippingPostalCode',
        'ShippingCountry',
        'Description'
      }
    );

    return new Order(
      AccountId = cart.Contact__r.AccountId,
      EffectiveDate = Date.today(),
      Status = 'Activated', // Order is activated after successful payment
      Pricebook2Id = getStandardPricebookId(),
      ShippingStreet = shippingAddress.Street__c,
      ShippingCity = shippingAddress.City__c,
      ShippingState = shippingAddress.State__c,
      ShippingPostalCode = shippingAddress.Postal_Code__c,
      ShippingCountry = shippingAddress.Country__c,
      Description = 'Pay.gov Transaction ID: ' + paymentTransactionId
    );
  }

  /**
   * @description Creates OrderItem records from Cart_Item records.
   *
   * @param orderId The ID of the parent Order record
   * @param cartItems The cart items to convert
   * @return List of OrderItem records ready for insertion
   */
  private static List<OrderItem> createOrderItems(
    Id orderId,
    List<Cart_Item__c> cartItems
  ) {
    // Security check - ensure user can create OrderItem records
    ENOS_SecurityUtils.checkObjectCreateable('OrderItem');
    ENOS_SecurityUtils.checkFieldEditAccess(
      'OrderItem',
      new List<String>{
        'OrderId',
        'Product2Id',
        'Quantity',
        'UnitPrice',
        'PricebookEntryId'
      }
    );

    List<OrderItem> orderItems = new List<OrderItem>();

    // Get pricebook entries for all products in one query
    Set<Id> productIds = new Set<Id>();
    for (Cart_Item__c item : cartItems) {
      productIds.add(item.Product__c);
    }

    Map<Id, Id> productToPricebookEntry = new Map<Id, Id>();
    for (PricebookEntry pbe : [
      SELECT Id, Product2Id
      FROM PricebookEntry
      WHERE
        Product2Id IN :productIds
        AND Pricebook2.IsStandard = TRUE
        AND IsActive = TRUE
    ]) {
      productToPricebookEntry.put(pbe.Product2Id, pbe.Id);
    }

    // Create OrderItem records
    for (Cart_Item__c item : cartItems) {
      Id pricebookEntryId = productToPricebookEntry.get(item.Product__c);
      if (pricebookEntryId != null) {
        orderItems.add(
          new OrderItem(
            OrderId = orderId,
            Product2Id = item.Product__c,
            Quantity = item.Quantity__c,
            UnitPrice = item.Unit_Price__c,
            PricebookEntryId = pricebookEntryId
          )
        );
      } else {
        throw new IllegalArgumentException(
          'Pricebook entry not found for product: ' + item.Product__c
        );
      }
    }

    return orderItems;
  }

  /**
   * @description Calculates the total amount for all cart items.
   *
   * @param cartItems The cart items to calculate total for
   * @return Decimal total amount
   */
  private static Decimal calculateTotalAmount(List<Cart_Item__c> cartItems) {
    Decimal total = 0;
    for (Cart_Item__c item : cartItems) {
      total += (item.Line_Total__c != null ? item.Line_Total__c : 0);
    }
    return total;
  }

  /**
   * @description Gets the standard pricebook ID for the org.
   *
   * @return Id of the standard pricebook
   */
  private static Id getStandardPricebookId() {
    if (stdPricebookId == null) {
      stdPricebookId = Test.isRunningTest()
        ? Test.getStandardPricebookId()
        : [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
    }
    return stdPricebookId;
  }

  /**
   * @description Gets the current user's contact ID.
   *
   * @return Id of the user's contact, or null if not found
   */
  private static Id getCurrentUserContactId() {
    List<User> users = [
      SELECT ContactId
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];

    return users.isEmpty() ? null : users[0].ContactId;
  }

  /**
   * @description Gets the current user's account ID.
   *
   * @return Id of the user's account, or null if not found
   */
  private static Id getCurrentUserAccountId() {
    List<User> users = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];

    return users.isEmpty() ? null : users[0].Contact?.AccountId;
  }

  /**
   * @description Processes payment through Pay.gov federal payment gateway.
   * This method handles secure payment processing for government transactions.
   *
   * @param cart The cart containing customer information
   * @param totalAmount The total amount to charge
   * @param paymentToken The secure payment token
   * @return ENOS_PayGovService.PayGovResponse containing payment processing results
   * @throws ENOS_PayGovService.PayGovException if payment processing fails
   */
  private static ENOS_PayGovService.PayGovResponse processPayGovPayment(
    Cart__c cart,
    Decimal totalAmount,
    String paymentToken
  ) {
    try {
      // Get customer information for payment processing with security
      ENOS_SecurityUtils.checkObjectReadable('Contact');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Contact',
        new List<String>{ 'Email', 'FirstName', 'LastName', 'AccountId' }
      );

      Contact customer = [
        SELECT Email, FirstName, LastName, AccountId
        FROM Contact
        WHERE Id = :cart.Contact__c
        WITH USER_MODE
        LIMIT 1
      ];

      // Create Pay.gov payment request
      ENOS_PayGovService.PayGovRequest paymentRequest = new ENOS_PayGovService.PayGovRequest(
        getAgencyId(), // Federal agency ID from Custom Metadata
        'ORDER-' +
        System.currentTimeMillis(), // Unique order ID
        totalAmount,
        customer.Email,
        paymentToken
      );

      // Set payment request details
      paymentRequest.description =
        'ENOS Order Payment - ' +
        customer.FirstName +
        ' ' +
        customer.LastName;
      paymentRequest.successUrl = getSuccessReturnUrl();
      paymentRequest.cancelUrl = getCancelReturnUrl();

      // Process the payment through Pay.gov
      ENOS_PayGovService.PayGovResponse paymentResponse = ENOS_PayGovService.initiatePayment(
        paymentRequest
      );

      // Log payment initiation for audit trail
      System.debug(
        LoggingLevel.INFO,
        'Pay.gov payment initiated for amount: ' +
          totalAmount +
          ', Transaction ID: ' +
          paymentResponse.transactionId
      );

      return paymentResponse;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Pay.gov payment processing error: ' + e.getMessage()
      );
      throw new ENOS_PayGovService.PayGovException(
        'Payment processing failed: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Retrieves the federal agency ID from Custom Metadata Type.
   * This ensures secure configuration management for Pay.gov integration.
   *
   * @return String containing the agency ID for Pay.gov
   */
  private static String getAgencyId() {
    PayGov_Configuration__mdt config = getPayGovConfiguration();
    return config?.Agency_ID__c ?? 'AGENCY_ID_NOT_CONFIGURED';
  }

  /**
   * @description Gets the success return URL for Pay.gov redirects.
   *
   * @return String containing the success URL
   */
  private static String getSuccessReturnUrl() {
    PayGov_Configuration__mdt config = getPayGovConfiguration();
    if (config?.Success_URL__c != null) {
      return config.Success_URL__c;
    }
    // Fallback to dynamic URL construction
    return Site.getBaseUrl() + '/payment-success';
  }

  /**
   * @description Gets the cancel return URL for Pay.gov redirects.
   *
   * @return String containing the cancel URL
   */
  private static String getCancelReturnUrl() {
    PayGov_Configuration__mdt config = getPayGovConfiguration();
    if (config?.Cancel_URL__c != null) {
      return config.Cancel_URL__c;
    }
    // Fallback to dynamic URL construction
    return Site.getBaseUrl() + '/payment-cancelled';
  }

  /**
   * @description Retrieves Pay.gov configuration from Custom Metadata Type.
   * This centralizes configuration management for the federal payment gateway.
   *
   * @return PayGov_Configuration__mdt record or null if not found
   */
  private static PayGov_Configuration__mdt getPayGovConfiguration() {
    try {
      List<PayGov_Configuration__mdt> configs = [
        SELECT Agency_ID__c, Environment__c, Success_URL__c, Cancel_URL__c
        FROM PayGov_Configuration__mdt
        WHERE Environment__c = 'Production' // Use Production config, fallback to QA in sandbox
        LIMIT 1
      ];

      // If no production config found, try QA config
      if (configs.isEmpty()) {
        configs = [
          SELECT Agency_ID__c, Environment__c, Success_URL__c, Cancel_URL__c
          FROM PayGov_Configuration__mdt
          WHERE Environment__c = 'QA'
          LIMIT 1
        ];
      }

      return configs.isEmpty() ? null : configs[0];
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error retrieving Pay.gov configuration: ' + e.getMessage()
      );
      return null;
    }
  }

  /**
   * @description Retrieves orders for the current user.
   * This method is used by the Order History component.
   *
   * @return List of Order records for the current user
   */
  @AuraEnabled(cacheable=true)
  public static List<Order> getOrders() {
    try {
      // Security check - ensure user can read Order records
      ENOS_SecurityUtils.checkObjectReadable('Order');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Order',
        new List<String>{
          'Id',
          'OrderNumber',
          'EffectiveDate',
          'Status',
          'TotalAmount'
        }
      );

      Id userAccountId = getCurrentUserAccountId();
      if (userAccountId == null) {
        return new List<Order>();
      }

      return [
        SELECT OrderNumber, EffectiveDate, Status, TotalAmount
        FROM Order
        WHERE AccountId = :userAccountId
        ORDER BY EffectiveDate DESC
        LIMIT 100
      ];
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error retrieving orders: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Unable to retrieve orders at this time. Please try again later.'
      );
    }
  }
}
