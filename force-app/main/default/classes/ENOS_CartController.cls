/**
 * @description Controller to handle all server-side logic related to shopping cart operations.
 *
 * This controller implements the SecurityUtils pattern to ensure 100% FLS/CRUD
 * compliance. Every method checks permissions before executing business logic.
 *
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class ENOS_CartController {
  /**
   * @description Adds a specified quantity of a product to the current user's active cart.
   * This method handles the complete cart logic: finding/creating the user's active cart,
   * checking for existing items, and either updating quantities or creating new line items.
   *
   * Security: Uses SecurityUtils to validate all CRUD permissions before any data operations.
   * This ensures compliance with AppExchange standards and prevents unauthorized access.
   *
   * @param productId The ID of the Product2 to add to the cart.
   * @param quantity The quantity to add (must be greater than 0).
   * @throws AuraHandledException if the user lacks permissions, product is not found, or operation fails.
   *
   * @example
   * // In LWC: addItemToCart({ productId: 'a0B1234567890ABC', quantity: 2 })
   * // This will add 2 units of the specified product to the user's cart.
   */
  @AuraEnabled
  public static void addItemToCart(Id productId, Integer quantity) {
    try {
      // 1. Input validation for security and data integrity
      ENOS_SecurityUtils.validateRequiredId(productId, 'Product ID');
      ENOS_SecurityUtils.validatePositiveInteger(quantity, 'Quantity', 1);

      // 2. Security Checks for all objects we will touch
      // Check create permissions for Cart__c (in case we need to create a new cart)
      ENOS_SecurityUtils.checkObjectCreateable('Cart__c');

      // Check create permissions for Cart_Item__c (for new line items)
      ENOS_SecurityUtils.checkObjectCreateable('Cart_Item__c');

      // Check update permissions for Cart_Item__c (for quantity updates)
      ENOS_SecurityUtils.checkObjectUpdateable('Cart_Item__c');

      // Check read permissions for the objects we'll query
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart__c',
        new List<String>{ 'Id', 'Contact__c', 'Status__c' }
      );

      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart_Item__c',
        new List<String>{ 'Id', 'Quantity__c', 'Cart__c', 'Product__c' }
      );

      ENOS_SecurityUtils.checkObjectReadable('PricebookEntry');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'PricebookEntry',
        new List<String>{ 'UnitPrice', 'Product2Id', 'IsActive' }
      );

      // 3. Find the Contact ID of the logged-in user
      // This ensures users can only access their own cart data
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        throw new AuraHandledException(
          'User is not associated with a Contact. Please contact your administrator.'
        );
      }

      // 4. Find or create the user's active cart
      Cart__c activeCart = findOrCreateActiveCart(userContactId);

      // 5. Find the price for the item from the standard price book
      Decimal itemPrice = getProductPrice(productId);
      if (itemPrice == null) {
        throw new AuraHandledException(
          'Product pricing is not available. Please contact customer support.'
        );
      }

      // 6. Check if this item is already in the cart and handle accordingly
      handleCartItemAddition(activeCart.Id, productId, quantity, itemPrice);

      // 7. Log successful cart addition for monitoring and analytics
      System.debug(
        'Successfully added ' +
          quantity +
          ' units of product ' +
          productId +
          ' to cart ' +
          activeCart.Id
      );
    } catch (SecurityException e) {
      ENOS_SecurityUtils.handleSecurityException('ENOS_CartController.addItemToCart', e);
    } catch (AuraHandledException e) {
      throw e;
    } catch (Exception e) {
      ENOS_SecurityUtils.handleUnexpectedException('ENOS_CartController.addItemToCart', e);
    }
  }

  /**
   * @description Retrieves the current user's active cart with all line items.
   * This method is used to display the cart contents in the shopping cart component.
   *
   * Security: Implements the same security pattern as addItemToCart.
   *
   * @return CartWrapper containing the cart and its line items with product information.
   * @throws AuraHandledException if the user lacks permissions or operation fails.
   */
  @AuraEnabled(cacheable=true)
  public static CartWrapper getCurrentUserCart() {
    try {
      // 1. Security checks for read operations - using batch validation
      ENOS_SecurityUtils.validateCartAccess();

      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart__c',
        new List<String>{
          'Id',
          'Contact__c',
          'Status__c',
          'Subtotal__c',
          'Total_Items__c'
        }
      );

      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart_Item__c',
        new List<String>{
          'Id',
          'Quantity__c',
          'Unit_Price__c',
          'Line_Total__c',
          'Product__c'
        }
      );

      ENOS_SecurityUtils.checkFieldReadAccess(
        'Product2',
        new List<String>{ 'Id', 'Name', 'Image_URL__c' }
      );

      // 2. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        throw new AuraHandledException(
          'User is not associated with a Contact.'
        );
      }

      // 3. Query for active cart with line items
      List<Cart__c> carts = [
        SELECT
          Id,
          Status__c,
          Subtotal__c,
          Total_Items__c,
          (
            SELECT
              Id,
              Quantity__c,
              Unit_Price__c,
              Line_Total__c,
              Product__r.Id,
              Product__r.Name,
              Product__r.Image_URL__c
            FROM Cart_Items__r
            ORDER BY CreatedDate
          )
        FROM Cart__c
        WHERE Contact__c = :userContactId AND Status__c = 'Active'
        LIMIT 1
      ];

      if (carts.isEmpty()) {
        // Return empty cart wrapper
        return new CartWrapper(null, new List<CartItemWrapper>(), 0, 0);
      }

      Cart__c cart = carts[0];
      List<CartItemWrapper> cartItems = new List<CartItemWrapper>();

      // Convert Cart_Item__c records to wrapper objects
      for (Cart_Item__c item : cart.Cart_Items__r) {
        cartItems.add(
          new CartItemWrapper(
            item.Id,
            item.Product__r.Id,
            item.Product__r.Name,
            item.Product__r.Image_URL__c,
            item.Quantity__c,
            item.Unit_Price__c,
            item.Line_Total__c
          )
        );
      }

      return new CartWrapper(
        cart.Id,
        cartItems,
        cart.Subtotal__c,
        cart.Total_Items__c
      );
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ENOS_CartController.getCurrentUserCart(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to view your cart. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ENOS_CartController.getCurrentUserCart(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to load cart at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Updates the quantity of an existing cart item.
   * This method allows users to modify quantities of items already in their cart.
   *
   * Security: Implements the same security pattern as other methods.
   *
   * @param cartItemId The ID of the Cart_Item__c record to update.
   * @param newQuantity The new quantity for the cart item.
   * @throws AuraHandledException if the user lacks permissions or operation fails.
   */
  @AuraEnabled
  public static void updateCartItemQuantity(
    Id cartItemId,
    Integer newQuantity
  ) {
    try {
      // 1. Input validation
      if (cartItemId == null) {
        throw new AuraHandledException('Cart item ID is required.');
      }

      if (newQuantity == null || newQuantity < 1) {
        throw new AuraHandledException('Quantity must be at least 1.');
      }

      // 2. Security checks
      ENOS_SecurityUtils.checkObjectUpdateable('Cart_Item__c');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart_Item__c',
        new List<String>{ 'Id', 'Quantity__c', 'Cart__c', 'Contact__c' }
      );

      // 3. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        throw new AuraHandledException(
          'User is not associated with a Contact.'
        );
      }

      // 4. Query for the cart item and verify ownership
      List<Cart_Item__c> cartItems = [
        SELECT Id, Quantity__c, Cart__r.Contact__c
        FROM Cart_Item__c
        WHERE Id = :cartItemId AND Cart__r.Contact__c = :userContactId
        LIMIT 1
      ];

      if (cartItems.isEmpty()) {
        throw new AuraHandledException('Cart item not found or access denied.');
      }

      // 5. Update the quantity
      Cart_Item__c cartItem = cartItems[0];
      cartItem.Quantity__c = newQuantity;
      update cartItem;

      System.debug(
        'Successfully updated cart item ' +
          cartItemId +
          ' quantity to ' +
          newQuantity
      );
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ENOS_CartController.updateCartItemQuantity(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to update your cart. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ENOS_CartController.updateCartItemQuantity(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to update cart item at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Removes an item from the user's cart.
   * This method allows users to delete items they no longer want.
   *
   * Security: Implements the same security pattern as other methods.
   *
   * @param cartItemId The ID of the Cart_Item__c record to remove.
   * @throws AuraHandledException if the user lacks permissions or operation fails.
   */
  @AuraEnabled
  public static void removeCartItem(Id cartItemId) {
    try {
      // 1. Input validation
      if (cartItemId == null) {
        throw new AuraHandledException('Cart item ID is required.');
      }

      // 2. Security checks
      ENOS_SecurityUtils.checkObjectDeletable('Cart_Item__c');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart_Item__c',
        new List<String>{ 'Id', 'Cart__c', 'Contact__c' }
      );

      // 3. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        throw new AuraHandledException(
          'User is not associated with a Contact.'
        );
      }

      // 4. Query for the cart item and verify ownership
      List<Cart_Item__c> cartItems = [
        SELECT Id, Cart__r.Contact__c
        FROM Cart_Item__c
        WHERE Id = :cartItemId AND Cart__r.Contact__c = :userContactId
        LIMIT 1
      ];

      if (cartItems.isEmpty()) {
        throw new AuraHandledException('Cart item not found or access denied.');
      }

      // 5. Delete the cart item
      delete cartItems[0];

      System.debug('Successfully removed cart item ' + cartItemId);
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ENOS_CartController.removeCartItem(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to remove items from your cart. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ENOS_CartController.removeCartItem(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to remove cart item at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Gets the total number of items in the current user's active cart.
   * This method is used by the Mini Cart component to display the cart item count.
   *
   * Security: Implements the same security pattern as other methods.
   *
   * @return The total number of items in the user's active cart, or 0 if no cart exists.
   * @throws AuraHandledException if the user lacks permissions or operation fails.
   */
  @AuraEnabled(cacheable=true)
  public static Decimal getCartItemCount() {
    try {
      // 1. Security checks for read operations
      ENOS_SecurityUtils.checkObjectReadable('Cart__c');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart__c',
        new List<String>{ 'Id', 'Contact__c', 'Status__c', 'Total_Items__c' }
      );

      // 2. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        return 0;
      }

      // 3. Query for active cart and return item count
      List<Cart__c> carts = [
        SELECT Total_Items__c
        FROM Cart__c
        WHERE Contact__c = :userContactId AND Status__c = 'Active'
        LIMIT 1
      ];

      if (carts.isEmpty() || carts[0].Total_Items__c == null) {
        return 0;
      }

      return carts[0].Total_Items__c;
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ENOS_CartController.getCartItemCount(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to view your cart. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ENOS_CartController.getCartItemCount(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to retrieve cart information at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Gets all line items for the current user's active cart.
   * This method is used by the Full Cart component to display cart contents.
   *
   * Security: Implements the same security pattern as other methods.
   *
   * @return A list of Cart_Item__c records with product information.
   * @throws AuraHandledException if the user lacks permissions or operation fails.
   */
  @AuraEnabled(cacheable=true)
  public static List<Cart_Item__c> getCartItems() {
    try {
      // 1. Security checks for read operations
      ENOS_SecurityUtils.checkObjectReadable('Cart_Item__c');
      ENOS_SecurityUtils.checkObjectReadable('Product2');

      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart_Item__c',
        new List<String>{
          'Id',
          'Quantity__c',
          'Unit_Price__c',
          'Line_Total__c',
          'Cart__c'
        }
      );

      ENOS_SecurityUtils.checkFieldReadAccess(
        'Product2',
        new List<String>{ 'Id', 'Name', 'Image_URL__c' }
      );

      // 2. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        return new List<Cart_Item__c>();
      }

      // 3. Query for cart items with product information
      return [
        SELECT
          Id,
          Product__r.Name,
          Product__r.Image_URL__c,
          Quantity__c,
          Unit_Price__c,
          Line_Total__c
        FROM Cart_Item__c
        WHERE
          Cart__r.Contact__c = :userContactId
          AND Cart__r.Status__c = 'Active'
        ORDER BY CreatedDate
      ];
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ENOS_CartController.getCartItems(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to view your cart. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ENOS_CartController.getCartItems(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to retrieve cart items at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Updates the quantity of an item in the cart.
   * If quantity is 0 or negative, the item is automatically removed.
   *
   * Security: Implements the same security pattern as other methods.
   *
   * @param cartItemId The ID of the Cart_Item__c record to update.
   * @param quantity The new quantity for the cart item.
   * @throws AuraHandledException if the user lacks permissions or operation fails.
   */
  @AuraEnabled
  public static void updateItemQuantity(Id cartItemId, Integer quantity) {
    try {
      // 1. Input validation
      if (cartItemId == null) {
        throw new AuraHandledException('Cart item ID is required.');
      }

      if (quantity == null) {
        throw new AuraHandledException('Quantity is required.');
      }

      // 2. If quantity is 0 or negative, remove the item
      if (quantity <= 0) {
        deleteCartItem(cartItemId);
        return;
      }

      // 3. Security checks for update operations
      ENOS_SecurityUtils.checkObjectUpdateable('Cart_Item__c');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart_Item__c',
        new List<String>{ 'Id', 'Quantity__c', 'Cart__c', 'Contact__c' }
      );

      // 4. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        throw new AuraHandledException(
          'User is not associated with a Contact.'
        );
      }

      // 5. Query for the cart item and verify ownership
      List<Cart_Item__c> cartItems = [
        SELECT Id, Quantity__c, Cart__r.Contact__c
        FROM Cart_Item__c
        WHERE Id = :cartItemId AND Cart__r.Contact__c = :userContactId
        LIMIT 1
      ];

      if (cartItems.isEmpty()) {
        throw new AuraHandledException('Cart item not found or access denied.');
      }

      // 6. Update the quantity
      Cart_Item__c cartItem = cartItems[0];
      cartItem.Quantity__c = quantity;
      update cartItem;

      System.debug(
        'Successfully updated cart item ' +
          cartItemId +
          ' quantity to ' +
          quantity
      );
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ENOS_CartController.updateItemQuantity(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to update your cart. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ENOS_CartController.updateItemQuantity(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to update cart item at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Bulk adds multiple items to cart in one transaction
   * @param cartItems List of items to add with productId and quantity
   * @throws AuraHandledException if operation fails
   */
  @AuraEnabled
  public static void addItemsToCartBulk(List<CartItemRequest> cartItems) {
    try {
      if (cartItems == null || cartItems.isEmpty()) {
        throw new AuraHandledException('No items provided to add to cart.');
      }

      // Security checks
      ENOS_SecurityUtils.checkObjectCreateable('Cart__c');
      ENOS_SecurityUtils.checkObjectCreateable('Cart_Item__c');
      ENOS_SecurityUtils.checkObjectUpdateable('Cart_Item__c');

      // Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        throw new AuraHandledException(
          'User is not associated with a Contact.'
        );
      }

      // Find or create active cart
      Cart__c activeCart = findOrCreateActiveCart(userContactId);

      // Collect all product IDs for bulk price lookup
      Set<Id> productIds = new Set<Id>();
      for (CartItemRequest item : cartItems) {
        if (item.productId != null) {
          productIds.add(item.productId);
        }
      }

      // Bulk get prices for all products
      Map<Id, Decimal> productPrices = getBulkProductPrices(productIds);

      // Get existing cart items for this cart
      Map<Id, Cart_Item__c> existingItems = new Map<Id, Cart_Item__c>();
      for (Cart_Item__c item : [
        SELECT Id, Product__c, Quantity__c
        FROM Cart_Item__c
        WHERE Cart__c = :activeCart.Id AND Product__c IN :productIds
      ]) {
        existingItems.put(item.Product__c, item);
      }

      List<Cart_Item__c> itemsToInsert = new List<Cart_Item__c>();
      List<Cart_Item__c> itemsToUpdate = new List<Cart_Item__c>();

      // Process each request
      for (CartItemRequest request : cartItems) {
        if (
          request.productId == null ||
          request.quantity == null ||
          request.quantity <= 0
        ) {
          continue; // Skip invalid requests
        }

        Decimal price = productPrices.get(request.productId);
        if (price == null) {
          continue; // Skip products without pricing
        }

        if (existingItems.containsKey(request.productId)) {
          // Update existing item
          Cart_Item__c existing = existingItems.get(request.productId);
          existing.Quantity__c += request.quantity;
          itemsToUpdate.add(existing);
        } else {
          // Create new item
          itemsToInsert.add(
            new Cart_Item__c(
              Cart__c = activeCart.Id,
              Product__c = request.productId,
              Quantity__c = request.quantity,
              Unit_Price__c = price
            )
          );
        }
      }

      // Perform bulk DML operations
      if (!itemsToInsert.isEmpty()) {
        insert itemsToInsert;
      }
      if (!itemsToUpdate.isEmpty()) {
        update itemsToUpdate;
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error in bulk cart operation: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Unable to add items to cart: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Removes an item from the cart.
   * This method allows users to delete items they no longer want.
   *
   * Security: Implements the same security pattern as other methods.
   *
   * @param cartItemId The ID of the Cart_Item__c record to remove.
   * @throws AuraHandledException if the user lacks permissions or operation fails.
   */
  @AuraEnabled
  public static void deleteCartItem(Id cartItemId) {
    try {
      // 1. Input validation
      if (cartItemId == null) {
        throw new AuraHandledException('Cart item ID is required.');
      }

      // 2. Security checks
      ENOS_SecurityUtils.checkObjectDeletable('Cart_Item__c');
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Cart_Item__c',
        new List<String>{ 'Id', 'Cart__c', 'Contact__c' }
      );

      // 3. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        throw new AuraHandledException(
          'User is not associated with a Contact.'
        );
      }

      // 4. Query for the cart item and verify ownership
      List<Cart_Item__c> cartItems = [
        SELECT Id, Cart__r.Contact__c
        FROM Cart_Item__c
        WHERE Id = :cartItemId AND Cart__r.Contact__c = :userContactId
        LIMIT 1
      ];

      if (cartItems.isEmpty()) {
        throw new AuraHandledException('Cart item not found or access denied.');
      }

      // 5. Delete the cart item
      delete cartItems[0];

      System.debug('Successfully removed cart item ' + cartItemId);
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ENOS_CartController.deleteCartItem(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to remove items from your cart. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ENOS_CartController.deleteCartItem(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to remove cart item at this time. Please try again later.'
      );
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /**
   * @description Gets the Contact ID for the currently logged-in user.
   * This method ensures users can only access their own cart data.
   *
   * @return The Contact ID associated with the current user, or null if not found.
   * @throws AuraHandledException if the user lookup fails.
   */
  private static Id getCurrentUserContactId() {
    try {
      List<User> users = [
        SELECT ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
      ];

      if (users.isEmpty() || users[0].ContactId == null) {
        return null;
      }

      return users[0].ContactId;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error getting current user contact ID: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Unable to identify current user. Please try again later.'
      );
    }
  }

  /**
   * @description Finds or creates an active cart for the specified user.
   * This method ensures every user has exactly one active cart.
   *
   * @param userContactId The Contact ID of the user.
   * @return The active Cart__c record for the user.
   * @throws AuraHandledException if cart creation fails.
   */
  private static Cart__c findOrCreateActiveCart(Id userContactId) {
    try {
      // Look for existing active cart
      List<Cart__c> carts = [
        SELECT Id
        FROM Cart__c
        WHERE Contact__c = :userContactId AND Status__c = 'Active'
        LIMIT 1
      ];

      if (!carts.isEmpty()) {
        return carts[0];
      }

      // Create new active cart if none exists
      Cart__c newCart = new Cart__c(
        Contact__c = userContactId,
        Status__c = 'Active'
      );
      insert newCart;

      return newCart;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error finding/creating active cart: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Unable to access or create shopping cart. Please try again later.'
      );
    }
  }

  /**
   * @description Gets the price for a product from the standard price book.
   * This method retrieves the current pricing for cart calculations.
   *
   * @param productId The ID of the Product2 record.
   * @return The unit price from the standard price book, or null if not found.
   * @throws AuraHandledException if price lookup fails.
   */
  private static Decimal getProductPrice(Id productId) {
    try {
      List<PricebookEntry> priceEntries = [
        SELECT UnitPrice
        FROM PricebookEntry
        WHERE
          Product2Id = :productId
          AND Pricebook2.IsStandard = TRUE
          AND IsActive = TRUE
        LIMIT 1
      ];

      if (priceEntries.isEmpty()) {
        return null;
      }

      return priceEntries[0].UnitPrice;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error getting product price: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Unable to retrieve product pricing. Please try again later.'
      );
    }
  }

  /**
   * @description Gets prices for multiple products in bulk
   * @param productIds Set of product IDs to get prices for
   * @return Map of product ID to unit price
   */
  private static Map<Id, Decimal> getBulkProductPrices(Set<Id> productIds) {
    Map<Id, Decimal> priceMap = new Map<Id, Decimal>();

    if (productIds.isEmpty()) {
      return priceMap;
    }

    try {
      List<PricebookEntry> priceEntries = [
        SELECT Product2Id, UnitPrice
        FROM PricebookEntry
        WHERE
          Product2Id IN :productIds
          AND Pricebook2.IsStandard = TRUE
          AND IsActive = TRUE
      ];

      for (PricebookEntry entry : priceEntries) {
        priceMap.put(entry.Product2Id, entry.UnitPrice);
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error getting bulk product prices: ' + e.getMessage()
      );
    }

    return priceMap;
  }

  /**
   * @description Handles the addition of items to the cart.
   * This method either creates new cart items or updates existing ones.
   *
   * @param cartId The ID of the Cart__c record.
   * @param productId The ID of the Product2 record.
   * @param quantity The quantity to add.
   * @param unitPrice The unit price of the product.
   * @throws AuraHandledException if the operation fails.
   */
  private static void handleCartItemAddition(
    Id cartId,
    Id productId,
    Integer quantity,
    Decimal unitPrice
  ) {
    try {
      // Check if item already exists in cart
      List<Cart_Item__c> existingItems = [
        SELECT Id, Quantity__c
        FROM Cart_Item__c
        WHERE Cart__c = :cartId AND Product__c = :productId
        LIMIT 1
      ];

      if (existingItems.isEmpty()) {
        // Create new cart item
        Cart_Item__c newItem = new Cart_Item__c(
          Cart__c = cartId,
          Product__c = productId,
          Quantity__c = quantity,
          Unit_Price__c = unitPrice
        );
        insert newItem;
      } else {
        // Update existing item quantity
        Cart_Item__c existingItem = existingItems[0];
        existingItem.Quantity__c += quantity;
        update existingItem;
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error handling cart item addition: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Unable to add item to cart. Please try again later.'
      );
    }
  }

  // ============================================================================
  // WRAPPER CLASSES FOR DATA TRANSFER
  // ============================================================================

  /**
   * @description Wrapper class for cart data returned to LWC components.
   * This class provides a clean interface for transferring cart information.
   */
  public class CartWrapper {
    @AuraEnabled
    public Id cartId;
    @AuraEnabled
    public List<CartItemWrapper> cartItems;
    @AuraEnabled
    public Decimal subtotal;
    @AuraEnabled
    public Decimal totalItems;

    public CartWrapper(
      Id cartId,
      List<CartItemWrapper> cartItems,
      Decimal subtotal,
      Decimal totalItems
    ) {
      this.cartId = cartId;
      this.cartItems = cartItems;
      this.subtotal = subtotal;
      this.totalItems = totalItems;
    }
  }

  /**
   * @description Wrapper class for individual cart item data.
   * This class provides product information along with cart item details.
   */
  public class CartItemWrapper {
    @AuraEnabled
    public Id cartItemId;
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String productImageUrl;
    @AuraEnabled
    public Decimal quantity;
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public Decimal lineTotal;

    public CartItemWrapper(
      Id cartItemId,
      Id productId,
      String productName,
      String productImageUrl,
      Decimal quantity,
      Decimal unitPrice,
      Decimal lineTotal
    ) {
      this.cartItemId = cartItemId;
      this.productId = productId;
      this.productName = productName;
      this.productImageUrl = productImageUrl;
      this.quantity = quantity;
      this.unitPrice = unitPrice;
      this.lineTotal = lineTotal;
    }
  }

  /**
   * @description Wrapper class for bulk cart item requests
   */
  public class CartItemRequest {
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public Integer quantity;

    public CartItemRequest() {
    }

    public CartItemRequest(Id productId, Integer quantity) {
      this.productId = productId;
      this.quantity = quantity;
    }
  }

  // ============================================================================
  // DYNAMIC APEX METHODS
  // ============================================================================

  /**
   * @description Retrieves cart items using dynamic field selection
   * @param fields List of fields to select (if null, uses default fields)
   * @param limitClause Maximum number of records to return
   * @return List of Cart_Item__c records with selected fields
   * @throws AuraHandledException if dynamic query fails
   */
  @AuraEnabled(cacheable=true)
  public static List<Cart_Item__c> getCartItemsDynamic(List<String> fields, Integer limitClause) {
    try {
      // 1. Security validation using dynamic methods
      ENOS_SecurityUtils.checkDynamicObjectAccess('Cart_Item__c', 'read');
      
      // 2. Use default fields if none specified
      if (fields == null || fields.isEmpty()) {
        fields = new List<String>{
          'Id', 'Quantity__c', 'Unit_Price__c', 'Line_Total__c', 'Product__c'
        };
      }
      
      // 3. Validate field access
      ENOS_SecurityUtils.checkDynamicFieldAccess('Cart_Item__c', fields);
      
      // 4. Get current user's contact ID
      Id userContactId = getCurrentUserContactId();
      if (userContactId == null) {
        return new List<Cart_Item__c>();
      }
      
      // 5. Build dynamic WHERE clause
      String whereClause = 'Cart__r.Contact__c = \'' + userContactId + '\' AND Cart__r.Status__c = \'Active\'';
      
      // 6. Execute dynamic query
      List<SObject> results = ENOS_DynamicUtils.executeDynamicQuery(
        'Cart_Item__c', 
        fields, 
        whereClause, 
        'CreatedDate DESC', 
        limitClause
      );
      
      // 7. Cast results to Cart_Item__c
      List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
      for (SObject obj : results) {
        cartItems.add((Cart_Item__c) obj);
      }
      
      return cartItems;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Dynamic query failed in ENOS_CartController.getCartItemsDynamic(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'Dynamic cart query failed: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Gets cart metadata information dynamically
   * @return Map containing object and field metadata
   * @throws AuraHandledException if metadata retrieval fails
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getCartMetadata() {
    try {
      // 1. Security validation
      ENOS_SecurityUtils.checkDynamicObjectAccess('Cart_Item__c', 'read');
      
      // 2. Get object metadata
      Schema.DescribeSObjectResult objectDesc = ENOS_DynamicUtils.getObjectMetadata('Cart_Item__c');
      
      // 3. Get accessible fields
      List<String> readableFields = ENOS_SecurityUtils.getDynamicAccessibleFields('Cart_Item__c', 'read');
      List<String> editableFields = ENOS_SecurityUtils.getDynamicAccessibleFields('Cart_Item__c', 'edit');
      
      // 4. Build metadata response
      Map<String, Object> metadata = new Map<String, Object>();
      metadata.put('objectName', objectDesc.getName());
      metadata.put('objectLabel', objectDesc.getLabel());
      metadata.put('readableFields', readableFields);
      metadata.put('editableFields', editableFields);
      metadata.put('totalFields', readableFields.size());
      
      return metadata;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Metadata retrieval failed in ENOS_CartController.getCartMetadata(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'Cart metadata retrieval failed: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Creates cart item dynamically with field validation
   * @param fieldValues Map of field names to values
   * @return The created Cart_Item__c record
   * @throws AuraHandledException if creation fails
   */
  @AuraEnabled
  public static Cart_Item__c createCartItemDynamic(Map<String, Object> fieldValues) {
    try {
      // 1. Security validation
      ENOS_SecurityUtils.checkDynamicObjectAccess('Cart_Item__c', 'create');
      
      // 2. Validate required fields
      if (!fieldValues.containsKey('Cart__c') || !fieldValues.containsKey('Product__c') || !fieldValues.containsKey('Quantity__c')) {
        throw new AuraHandledException('Required fields missing: Cart__c, Product__c, and Quantity__c are required.');
      }
      
      // 3. Create record dynamically
      SObject newRecord = ENOS_DynamicUtils.createDynamicRecord('Cart_Item__c', fieldValues);
      
      // 4. Cast and return
      return (Cart_Item__c) newRecord;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Dynamic cart item creation failed: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Cart item creation failed: ' + e.getMessage()
      );
    }
  }
}
