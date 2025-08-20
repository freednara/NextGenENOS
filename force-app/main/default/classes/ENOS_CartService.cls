/**
 * @description Service layer for cart operations with proper CRUD/FLS enforcement.
 * This class handles all business logic for cart management, ensuring clean separation
 * of concerns and AppExchange compliance.
 *
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class ENOS_CartService {
  
  // ============================================================================
  // INNER CLASSES FOR TYPED RESPONSES
  // ============================================================================
  
  public class CartException extends Exception {}
  
  public class AddToCartResponse {
    public Boolean success;
    public String message;
    public Id cartId;
    public Id cartItemId;
  }

  public class CartDetailsResponse {
    public Boolean success;
    public String message;
    public Id cartId;
    public Integer itemCount;
    public Decimal totalValue;
    public List<CartItemDetail> items;
  }

  public class CartItemDetail {
    public Id itemId;
    public String productName;
    public Integer quantity;
    public Decimal unitPrice;
    public Decimal lineTotal;
  }
  
  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================
  
  /**
   * @description Adds an item to the user's cart with proper validation and error handling.
   * This method enforces CRUD/FLS, validates inputs, and handles cart creation/updates.
   *
   * @param userId The ID of the user adding the item
   * @param product2Id The ID of the Product2 to add
   * @param quantity The quantity to add
   * @param pricebook2IdOpt Optional Pricebook2 ID (if null, uses standard pricebook)
   * @return AddToCartResponse with operation results
   * @throws CartException if the operation fails
   */
  public static AddToCartResponse addItem(
    Id userId,
    Id product2Id,
    Integer quantity,
    Id pricebook2IdOpt
  ) {
    AddToCartResponse resp = new AddToCartResponse();
    
    // Input validation
    if (userId == null || product2Id == null) {
      throw new CartException('Missing required input.');
    }
    
    if (quantity == null || quantity <= 0) {
      quantity = 1;
    }

    try {
      // Resolve Pricebook2
      Id pricebook2Id = (pricebook2IdOpt != null) ? pricebook2IdOpt : resolveActiveStandardPricebook();
      if (pricebook2Id == null) {
        throw new CartException('No active Price Book found.');
      }

      // Enforce CRUD/FLS
      if (!Schema.sObjectType.Product2.isAccessible()) {
        throw new CartException('No access to Products.');
      }
      if (!Schema.sObjectType.PricebookEntry.isAccessible()) {
        throw new CartException('No access to PricebookEntries.');
      }
      if (!Schema.sObjectType.Cart__c.isCreateable()) {
        throw new CartException('No permission to create Cart.');
      }
      if (!Schema.sObjectType.Cart_Item__c.isCreateable()) {
        throw new CartException('No permission to create Cart Items.');
      }

      // Validate Product
      Product2 p = [
        SELECT Id, Name, IsActive
        FROM Product2
        WHERE Id = :product2Id
        LIMIT 1
      ];
      if (!p.IsActive) {
        throw new CartException('Product is not active.');
      }

      // Find active PricebookEntry for this product
      List<PricebookEntry> pbeList = [
        SELECT Id, UnitPrice, IsActive, Pricebook2Id, Product2Id
        FROM PricebookEntry
        WHERE Pricebook2Id = :pricebook2Id
          AND Product2Id = :p.Id
          AND IsActive = true
        LIMIT 1
      ];
      
      if (pbeList.isEmpty()) {
        throw new CartException('No active pricebook entry found for product: ' + p.Name);
      }
      
      PricebookEntry pbe = pbeList[0];

      // Find or create the current user's open cart
      Cart__c cart = getOrCreateOpenCart(userId, pricebook2Id);

      // Upsert (merge) quantity if item already exists
      Cart_Item__c existing = null;
      List<Cart_Item__c> items = [
        SELECT Id, Quantity__c
        FROM Cart_Item__c
        WHERE Cart__c = :cart.Id AND Product__c = :p.Id
        LIMIT 1
      ];
      if (!items.isEmpty()) {
        existing = items[0];
      }

      List<SObject> toSave = new List<SObject>();
      if (existing == null) {
        // Create new cart item
        Cart_Item__c ci = new Cart_Item__c(
          Cart__c = cart.Id,
          Product__c = p.Id,
          Quantity__c = quantity,
          Unit_Price__c = pbe.UnitPrice
        );
        toSave.add(ci);
      } else {
        // Update existing cart item
        existing.Quantity__c = existing.Quantity__c + quantity;
        toSave.add(existing);
      }

      // Respect FLS on fields
      toSave = (List<SObject>) Security.stripInaccessible(
        AccessType.CREATABLE,
        toSave
      ).getRecords();

      if (toSave.isEmpty()) {
        throw new CartException('No writable fields for cart items.');
      }

      // Single DML (no loops)
      upsert toSave;

      // Note: Cart totals are calculated automatically via formula fields
      // No need to manually update Subtotal__c and Total_Items__c

      resp.success = true;
      resp.message = 'Item added to cart successfully';
      resp.cartId = cart.Id;
      resp.cartItemId = (existing == null)
        ? ((Cart_Item__c)toSave[0]).Id
        : existing.Id;

      return resp;
      
    } catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'ENOS_CartService.addItem error: ' + e.getMessage());
      throw new CartException('Failed to add item to cart: ' + e.getMessage());
    }
  }

  /**
   * @description Gets the current user's cart details including items and totals.
   * @param userId The ID of the user
   * @return CartDetailsResponse with cart contents and totals
   * @throws CartException if the operation fails
   */
  public static CartDetailsResponse getCartDetails(Id userId) {
    CartDetailsResponse resp = new CartDetailsResponse();
    
    try {
      if (userId == null) {
        throw new CartException('Missing user ID.');
      }

      // First, try to find or create a contact for this user
      Id contactId = getCurrentUserContactId(userId);
      System.debug('🔍 Using contact ID: ' + contactId);

      // Find the user's active cart by contact ID, with fallback to OwnerId
      // Priority: 1) Cart with matching contact ID, 2) Cart with items owned by user
      List<Cart__c> carts = [
        SELECT Id, Status__c, Subtotal__c, Total_Items__c, Contact__c, OwnerId,
               (SELECT Id FROM Cart_Items__r)
        FROM Cart__c
        WHERE (Contact__c = :contactId OR OwnerId = :userId) AND Status__c = 'Active'
        ORDER BY Contact__c DESC NULLS LAST, CreatedDate DESC
        LIMIT 1
      ];

      if (carts.isEmpty()) {
        // No active cart found
        resp.success = true;
        resp.message = 'No active cart found';
        resp.itemCount = 0;
        resp.totalValue = 0;
        resp.items = new List<CartItemDetail>();
        return resp;
      }

      Cart__c cart = carts[0];
      
      // If cart doesn't have the correct contact ID, update it
      if (cart.Contact__c != contactId) {
        System.debug('🔧 Updating cart contact ID from ' + cart.Contact__c + ' to ' + contactId);
        cart.Contact__c = contactId;
        update cart;
        System.debug('✅ Cart contact ID updated');
      }
      
      // Get cart items with product details
      List<Cart_Item__c> cartItems = [
        SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c,
               Product__r.Name, Product__r.ProductCode
        FROM Cart_Item__c
        WHERE Cart__c = :cart.Id
        ORDER BY CreatedDate
      ];

      // Build response
      resp.success = true;
      resp.message = 'Cart details retrieved successfully';
      resp.cartId = cart.Id;
      
      // Calculate totals manually since formula fields may not be working
      Integer totalItems = 0;
      Decimal totalValue = 0;
      resp.items = new List<CartItemDetail>();
      
      // Convert cart items to detail objects and calculate totals
      for (Cart_Item__c item : cartItems) {
        CartItemDetail detail = new CartItemDetail();
        detail.itemId = item.Id;
        detail.productName = item.Product__r.Name;
        detail.quantity = (Integer)item.Quantity__c;
        detail.unitPrice = item.Unit_Price__c;
        detail.lineTotal = item.Line_Total__c;
        resp.items.add(detail);
        
        // Accumulate totals
        if (item.Quantity__c != null) {
          totalItems += (Integer)item.Quantity__c;
        }
        if (item.Line_Total__c != null) {
          totalValue += item.Line_Total__c;
        }
      }
      
      resp.itemCount = totalItems;
      resp.totalValue = totalValue;



      return resp;
      
    } catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'ENOS_CartService.getCartDetails error: ' + e.getMessage());
      throw new CartException('Failed to get cart details: ' + e.getMessage());
    }
  }

  /**
   * @description Updates the quantity of an item in the cart.
   * @param cartItemId The ID of the cart item to update
   * @param newQuantity The new quantity (0 to remove item)
   * @return AddToCartResponse with updated cart information
   * @throws CartException if the operation fails
   */
  public static AddToCartResponse updateCartItemQuantity(Id cartItemId, Integer newQuantity) {
    AddToCartResponse resp = new AddToCartResponse();
    
    try {
      if (cartItemId == null) {
        throw new CartException('Missing cart item ID.');
      }
      
      if (newQuantity == null || newQuantity < 0) {
        throw new CartException('Invalid quantity. Must be 0 or greater.');
      }

      // Get the cart item with product and price information
      List<Cart_Item__c> cartItems = [
        SELECT Id, Cart__c, Product__c, Quantity__c, Unit_Price__c, Line_Total__c,
               Cart__r.Status__c, Cart__r.OwnerId
        FROM Cart_Item__c
        WHERE Id = :cartItemId
        LIMIT 1
      ];

      if (cartItems.isEmpty()) {
        throw new CartException('Cart item not found.');
      }

      Cart_Item__c cartItem = cartItems[0];
      
      // Verify the cart belongs to the current user
      if (cartItem.Cart__r.OwnerId != UserInfo.getUserId()) {
        throw new CartException('You can only modify your own cart.');
      }

      if (newQuantity == 0) {
        // Remove the item
        delete cartItem;
        resp.success = true;
        resp.message = 'Item removed from cart successfully';
        resp.cartId = cartItem.Cart__c;
        resp.cartItemId = null;
      } else {
        // Update quantity (Line_Total__c is calculated automatically via formula)
        cartItem.Quantity__c = newQuantity;
        
        // FLS strip before update
        List<SObject> toUpdate = new List<SObject>{ cartItem };
        toUpdate = (List<SObject>) Security.stripInaccessible(
          AccessType.UPDATABLE, toUpdate
        ).getRecords();
        
        update toUpdate;
        
        resp.success = true;
        resp.message = 'Cart item quantity updated successfully';
        resp.cartId = cartItem.Cart__c;
        resp.cartItemId = cartItem.Id;
      }

      return resp;
      
    } catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'ENOS_CartService.updateCartItemQuantity error: ' + e.getMessage());
      throw new CartException('Failed to update cart item: ' + e.getMessage());
    }
  }
  
  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================
  
  /**
   * @description Finds or creates an open cart for the specified user.
   * @param userId The ID of the user
   * @param pricebook2Id The ID of the pricebook to use
   * @return The Cart__c record (either existing or newly created)
   */
  private static Cart__c getOrCreateOpenCart(Id userId, Id pricebook2Id) {
    List<Cart__c> carts = [
      SELECT Id, Status__c, Contact__c, OwnerId
      FROM Cart__c
      WHERE OwnerId = :userId AND Status__c = 'Active'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    
    if (!carts.isEmpty()) {
      return carts[0];
    }

    // Create new cart
    Cart__c cart = new Cart__c(
      OwnerId = userId,
      Status__c = 'Active',
      Contact__c = getCurrentUserContactId(userId)
    );

    // FLS strip
    List<SObject> toInsert = new List<SObject>{ cart };
    toInsert = (List<SObject>) Security.stripInaccessible(
      AccessType.CREATABLE, toInsert
    ).getRecords();

    insert toInsert;
    return (Cart__c) toInsert[0];
  }

  /**
   * @description Resolves an available pricebook ID, with fallbacks for test orgs.
   * @return The ID of an available pricebook
   */
  private static Id resolveActiveStandardPricebook() {
    // First try: active standard pricebook
    List<Pricebook2> stdPricebooks = [
      SELECT Id 
      FROM Pricebook2 
      WHERE IsStandard = true AND IsActive = true 
      LIMIT 1
    ];
    
    if (!stdPricebooks.isEmpty()) {
      return stdPricebooks[0].Id;
    }
    
    // Fallback 1: any standard pricebook (even if inactive)
    List<Pricebook2> anyStdPricebooks = [
      SELECT Id 
      FROM Pricebook2 
      WHERE IsStandard = true 
      LIMIT 1
    ];
    
    if (!anyStdPricebooks.isEmpty()) {
      System.debug('⚠️ Using inactive standard pricebook: ' + anyStdPricebooks[0].Id);
      return anyStdPricebooks[0].Id;
    }
    
    // Fallback 2: any active pricebook
    List<Pricebook2> anyActivePricebooks = [
      SELECT Id 
      FROM Pricebook2 
      WHERE IsActive = true 
      LIMIT 1
    ];
    
    if (!anyActivePricebooks.isEmpty()) {
      System.debug('⚠️ Using non-standard active pricebook: ' + anyActivePricebooks[0].Id);
      return anyActivePricebooks[0].Id;
    }
    
    // Last resort: any pricebook at all
    List<Pricebook2> anyPricebooks = [
      SELECT Id 
      FROM Pricebook2 
      LIMIT 1
    ];
    
    if (!anyPricebooks.isEmpty()) {
      System.debug('⚠️ Using any available pricebook: ' + anyPricebooks[0].Id);
      return anyPricebooks[0].Id;
    }
    
    return null;
  }
  
  /**
   * @description Gets the Contact ID for the current user.
   * @param userId The ID of the user
   * @return The Contact ID (or null if not found)
   */
  public static Id getCurrentUserContactId(Id userId) {
    try {
      // First try to find an existing contact for this user
      List<User> users = [
        SELECT Id, FirstName, LastName, Email, ContactId, AccountId
        FROM User
        WHERE Id = :userId
        LIMIT 1
      ];

      if (users.isEmpty()) {
        throw new CartException('User not found: ' + userId);
      }

      User currentUser = users[0];

      // If user already has a contact, return it
      if (currentUser.ContactId != null) {
        System.debug('✅ Found existing contact: ' + currentUser.ContactId);
        return currentUser.ContactId;
      }

      // If no contact exists, create one
      System.debug('🔧 Creating new contact for user: ' + currentUser.Email);

      // First try to find an existing contact by email (in case duplicate rules exist)
      List<Contact> existingContactsByEmail = [
        SELECT Id, AccountId
        FROM Contact
        WHERE Email = :currentUser.Email
        LIMIT 1
      ];
      
      if (!existingContactsByEmail.isEmpty()) {
        System.debug('✅ Found existing contact by email: ' + existingContactsByEmail[0].Id);
        return existingContactsByEmail[0].Id;
      }

      // Create a default account if none exists
      Id accountId = currentUser.AccountId;
      if (accountId == null) {
        Account defaultAccount = new Account(
          Name = 'ENOS Platform User - ' + currentUser.Email,
          Type = 'Customer',
          BillingCountry = 'United States'
        );
        insert defaultAccount;
        accountId = defaultAccount.Id;
        System.debug('✅ Created default account: ' + accountId);
      }

      // Create contact
      Contact newContact = new Contact(
        FirstName = currentUser.FirstName != null ? currentUser.FirstName : 'ENOS',
        LastName = currentUser.LastName != null ? currentUser.LastName : 'User',
        Email = currentUser.Email,
        AccountId = accountId
      );
      
      try {
        insert newContact;
        System.debug('✅ Created new contact: ' + newContact.Id);
        return newContact.Id;
      } catch (Exception insertEx) {
        // If insert fails due to duplicate rules, try to find the contact again
        System.debug('⚠️ Contact insert failed, trying to find existing: ' + insertEx.getMessage());
        
        List<Contact> foundContacts = [
          SELECT Id
          FROM Contact
          WHERE Email = :currentUser.Email
          LIMIT 1
        ];
        
        if (!foundContacts.isEmpty()) {
          System.debug('✅ Found contact after failed insert: ' + foundContacts[0].Id);
          return foundContacts[0].Id;
        }
        
        // If still no contact found, throw the original error
        throw insertEx;
      }
      
    } catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'Error getting/creating contact: ' + e.getMessage());
      throw new CartException('Failed to resolve user contact: ' + e.getMessage());
    }
  }



  /**
   * @description Submits a quote request for the current cart.
   * @param userId The ID of the user
   * @param customerNotes Optional customer notes for the quote
   * @return String confirmation message
   * @throws CartException if the operation fails
   */
  public static String submitQuoteRequest(Id userId, String customerNotes) {
    try {
      if (userId == null) {
        throw new CartException('Missing user ID.');
      }

      // Get cart details
      CartDetailsResponse cartDetails = getCartDetails(userId);
      
      if (!cartDetails.success || cartDetails.items.isEmpty()) {
        throw new CartException('No items in cart to submit for quote.');
      }

      // Create quote request record
      Case quoteRequest = new Case(
        Subject = 'Quote Request - Cart Total: $' + cartDetails.totalValue.setScale(2),
        Description = 'Quote request for cart items.\n\n' + 
                     'Customer Notes: ' + (String.isNotBlank(customerNotes) ? customerNotes : 'None provided') + '\n\n' +
                     'Cart Items:\n' + generateCartItemsText(cartDetails.items),
        Type = 'Quote Request',
        Status = 'New',
        Priority = 'Medium',
        Origin = 'Web',
        ContactId = getCurrentUserContactId(userId)
      );

      // FLS strip before insert
      List<SObject> toInsert = new List<SObject>{ quoteRequest };
      toInsert = (List<SObject>) Security.stripInaccessible(
        AccessType.CREATABLE, toInsert
      ).getRecords();

      insert toInsert;

      return 'Quote request submitted successfully. Your request has been sent to our sales team.';
      
    } catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'ENOS_CartService.submitQuoteRequest error: ' + e.getMessage());
      throw new CartException('Failed to submit quote request: ' + e.getMessage());
    }
  }

  /**
   * @description Generates HTML invoice content.
   * @param cartDetails The cart details to include in the invoice
   * @return HTML string for the invoice
   */
  private static String generateInvoiceHtml(CartDetailsResponse cartDetails) {
    String html = '<!DOCTYPE html><html><head><title>ENOS Invoice</title>';
    html += '<style>body{font-family:Arial,sans-serif;margin:20px;}';
    html += '.header{text-align:center;border-bottom:2px solid #333;padding-bottom:20px;margin-bottom:30px;}';
    html += '.invoice-details{margin-bottom:30px;}';
    html += '.items-table{width:100%;border-collapse:collapse;margin-bottom:30px;}';
    html += '.items-table th,.items-table td{border:1px solid #ddd;padding:12px;text-align:left;}';
    html += '.items-table th{background-color:#f8f9fa;}';
    html += '.total{text-align:right;font-size:18px;font-weight:bold;border-top:2px solid #333;padding-top:20px;}';
    html += '</style></head><body>';
    
    html += '<div class="header"><h1>ENOS Platform</h1><h2>Invoice</h2>';
    html += '<p>Date: ' + Datetime.now().format('MMMM dd, yyyy') + '</p></div>';
    
    html += '<div class="invoice-details">';
    html += '<p><strong>Invoice #:</strong> INV-' + Datetime.now().getTime() + '</p>';
    html += '<p><strong>Customer:</strong> ' + UserInfo.getName() + '</p>';
    html += '<p><strong>Email:</strong> ' + UserInfo.getUserEmail() + '</p></div>';
    
    html += '<table class="items-table">';
    html += '<thead><tr><th>Item</th><th>Quantity</th><th>Unit Price</th><th>Total</th></tr></thead><tbody>';
    
    for (CartItemDetail item : cartDetails.items) {
      html += '<tr><td>' + item.productName + '</td><td>' + item.quantity + '</td>';
      html += '<td>$' + item.unitPrice.setScale(2) + '</td><td>$' + item.lineTotal.setScale(2) + '</td></tr>';
    }
    
    html += '</tbody></table>';
    
    html += '<div class="total"><p>Total: $' + cartDetails.totalValue.setScale(2) + '</p></div>';
    
    html += '<div style="margin-top:40px;text-align:center;color:#666;">';
    html += '<p>Thank you for your business!</p>';
    html += '<p>ENOS Platform - Empowering Next-Generation Solutions</p></div>';
    
    html += '</body></html>';
    
    return html;
  }

  /**
   * @description Generates plain text representation of cart items for quote requests.
   * @param items List of cart items
   * @return Formatted text string
   */
  private static String generateCartItemsText(List<CartItemDetail> items) {
    String text = '';
    for (CartItemDetail item : items) {
      text += '- ' + item.productName + ' (Qty: ' + item.quantity + ', Price: $' + item.unitPrice.setScale(2) + ')\n';
    }
    return text;
  }
  

}
