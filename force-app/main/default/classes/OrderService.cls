/**
 * @description Service class for handling order creation and management.
 *
 * This class provides transactional order creation from cart data,
 * including payment processing and comprehensive order management.
 *
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class OrderService {
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

    for (CreateOrderRequest req : requests) {
      CreateOrderResponse response = new CreateOrderResponse();

      try {
        // 1. Validate input parameters
        if (
          req.cartId == null ||
          req.shippingAddressId == null ||
          String.isBlank(req.paymentToken)
        ) {
          throw new IllegalArgumentException(
            'All required parameters must be provided: Cart ID, Shipping Address ID, and Payment Token.'
          );
        }

        // 2. Get all necessary data with security checks
        Cart__c cart = getCartWithSecurity(req.cartId);
        List<Cart_Item__c> cartItems = getCartItemsWithSecurity(req.cartId);
        Shipping_Address__c shippingAddress = getShippingAddressWithSecurity(
          req.shippingAddressId
        );

        // 3. Validate cart has items
        if (cartItems.isEmpty()) {
          throw new IllegalArgumentException(
            'Cart must contain at least one item to create an order.'
          );
        }

        // 4. Process the order creation transaction
        response = processOrderCreation(
          cart,
          cartItems,
          shippingAddress,
          req.paymentToken
        );
      } catch (IllegalArgumentException e) {
        response.isSuccess = false;
        response.message = e.getMessage();
      } catch (Exception e) {
        // Create error response
        response.isSuccess = false;
        response.message = 'Order creation failed: ' + e.getMessage();
        System.debug(
          LoggingLevel.ERROR,
          'Order creation error: ' + e.getMessage()
        );
        System.debug(
          LoggingLevel.ERROR,
          'Stack trace: ' + e.getStackTraceString()
        );
      }

      responses.add(response);
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
    SecurityUtils.checkObjectReadable('Cart__c');
    SecurityUtils.checkFieldReadAccess(
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
    List<Cart__c> carts = [
      SELECT Id, Contact__c, Contact__r.AccountId, Status__c
      FROM Cart__c
      WHERE
        Id = :cartId
        AND Contact__c = :userContactId
        AND Status__c = 'Active'
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
    SecurityUtils.checkObjectReadable('Cart_Item__c');
    SecurityUtils.checkFieldReadAccess(
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
    List<Cart_Item__c> cartItems = [
      SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
      FROM Cart_Item__c
      WHERE Cart__c = :cartId
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
    SecurityUtils.checkObjectReadable('Shipping_Address__c');
    SecurityUtils.checkFieldReadAccess(
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
   * Creates Order and OrderItem records, then cleans up the cart.
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
      // 1. Process Payment (In a real scenario, this would be a callout to Stripe, etc.)
      // For now, we simulate success. If this failed, it would throw an exception.
      System.debug('Processing payment with token: ' + paymentToken);

      // TODO: Implement actual payment gateway callout here
      // Example: PaymentGateway.processPayment(paymentToken, calculateTotalAmount(cartItems));

      // 2. Create the Order record
      Order newOrder = createOrderRecord(cart, shippingAddress);
      insert newOrder;

      // 3. Create OrderItem records from Cart_Item records
      List<OrderItem> orderItems = createOrderItems(newOrder.Id, cartItems);
      insert orderItems;

      // 4. Clean up: Delete the cart (this will cascade delete the cart items)
      delete cart;

      // 5. Prepare success response
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
   * @description Creates the Order record with shipping information.
   *
   * @param cart The cart record containing account information
   * @param shippingAddress The selected shipping address
   * @return Order record ready for insertion
   */
  private static Order createOrderRecord(
    Cart__c cart,
    Shipping_Address__c shippingAddress
  ) {
    // Security check - ensure user can create Order records
    SecurityUtils.checkObjectCreateable('Order');
    SecurityUtils.checkFieldEditAccess(
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
        'ShippingCountry'
      }
    );

    return new Order(
      AccountId = cart.Contact__r.AccountId,
      EffectiveDate = Date.today(),
      Status = 'Draft', // Can be changed to 'Activated' based on business requirements
      Pricebook2Id = getStandardPricebookId(),
      ShippingStreet = shippingAddress.Street__c,
      ShippingCity = shippingAddress.City__c,
      ShippingState = shippingAddress.State__c,
      ShippingPostalCode = shippingAddress.Postal_Code__c,
      ShippingCountry = shippingAddress.Country__c
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
    SecurityUtils.checkObjectCreateable('OrderItem');
    SecurityUtils.checkFieldEditAccess(
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
   * @description Retrieves orders for the current user.
   * This method is used by the Order History component.
   *
   * @return List of Order records for the current user
   */
  @AuraEnabled(cacheable=true)
  public static List<Order> getOrders() {
    try {
      // Security check - ensure user can read Order records
      SecurityUtils.checkObjectReadable('Order');
      SecurityUtils.checkFieldReadAccess(
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
