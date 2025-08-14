/**
 * @description Test class for CartController
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@IsTest
private class CartControllerTest {
  /**
   * @description Test data setup method
   */
  @TestSetup
  static void setupTestData() {
    // Create test data using utility class (includes test user)
    StoreConnectTestUtils.TestDataContainer testData = StoreConnectTestUtils.createStoreConnectTestData();
  }

  /**
   * @description Test adding item to cart - positive case
   */
  @IsTest
  static void testAddItemToCart_Success() {
    // Get test data
    User testUser = [
      SELECT Id, ContactId
      FROM User
      WHERE Email = 'storeuser@test.com'
      LIMIT 1
    ];
    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST001'
      LIMIT 1
    ];

    Test.startTest();
    System.runAs(testUser) {
      // Add item to cart
      CartController.addItemToCart(testProduct.Id, 2);
    }
    Test.stopTest();

    // Verify cart was created
    List<Cart__c> carts = [
      SELECT Id, Contact__c, Status__c
      FROM Cart__c
      WHERE Contact__c = :testUser.ContactId
    ];
    System.assertEquals(1, carts.size(), 'One cart should be created');
    System.assertEquals(
      'Active',
      carts[0].Status__c,
      'Cart status should be Active'
    );

    // Verify cart item was created
    List<Cart_Item__c> cartItems = [
      SELECT Id, Product__c, Quantity__c, Unit_Price__c
      FROM Cart_Item__c
      WHERE Cart__c = :carts[0].Id
    ];
    System.assertEquals(1, cartItems.size(), 'One cart item should be created');
    System.assertEquals(
      testProduct.Id,
      cartItems[0].Product__c,
      'Product should match'
    );
    System.assertEquals(2, cartItems[0].Quantity__c, 'Quantity should be 2');
    System.assertEquals(
      25.00,
      cartItems[0].Unit_Price__c,
      'Unit price should match pricebook entry'
    );
  }

  /**
   * @description Test adding item to existing cart with same product (quantity update)
   */
  @IsTest
  static void testAddItemToCart_UpdateQuantity() {
    // Get test data
    User testUser = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'john.doe.test@storeconnect.com'
      LIMIT 1
    ];
    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST-001'
      LIMIT 1
    ];

    Test.startTest();
    System.runAs(testUser) {
      // Add item to cart twice
      CartController.addItemToCart(testProduct.Id, 2);
      CartController.addItemToCart(testProduct.Id, 3);
    }
    Test.stopTest();

    // Verify only one cart item exists with updated quantity
    List<Cart__c> carts = [
      SELECT Id
      FROM Cart__c
      WHERE Contact__c = :testUser.ContactId
    ];
    List<Cart_Item__c> cartItems = [
      SELECT Id, Quantity__c
      FROM Cart_Item__c
      WHERE Cart__c = :carts[0].Id
    ];
    System.assertEquals(1, cartItems.size(), 'Only one cart item should exist');
    System.assertEquals(
      5,
      cartItems[0].Quantity__c,
      'Quantity should be updated to 5 (2+3)'
    );
  }

  /**
   * @description Test adding item to cart with invalid parameters
   */
  @IsTest
  static void testAddItemToCart_InvalidParameters() {
    User testUser = [
      SELECT Id
      FROM User
      WHERE Username = 'john.doe.test@storeconnect.com'
      LIMIT 1
    ];
    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST-001'
      LIMIT 1
    ];

    Test.startTest();
    System.runAs(testUser) {
      // Test null product ID
      try {
        CartController.addItemToCart(null, 1);
        System.assert(false, 'Exception should be thrown for null product ID');
      } catch (AuraHandledException e) {
        System.assert(
          e.getMessage().contains('Product ID is required'),
          'Correct error message for null product ID'
        );
      }

      // Test zero quantity
      try {
        CartController.addItemToCart(testProduct.Id, 0);
        System.assert(false, 'Exception should be thrown for zero quantity');
      } catch (AuraHandledException e) {
        System.assert(
          e.getMessage().contains('Quantity must be at least 1'),
          'Correct error message for zero quantity'
        );
      }

      // Test negative quantity
      try {
        CartController.addItemToCart(testProduct.Id, -1);
        System.assert(
          false,
          'Exception should be thrown for negative quantity'
        );
      } catch (AuraHandledException e) {
        System.assert(
          e.getMessage().contains('Quantity must be at least 1'),
          'Correct error message for negative quantity'
        );
      }
    }
    Test.stopTest();
  }

  /**
   * @description Test getting current user cart
   */
  @IsTest
  static void testGetCurrentUserCart_Success() {
    // Setup cart with items
    User testUser = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'john.doe.test@storeconnect.com'
      LIMIT 1
    ];
    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST-001'
      LIMIT 1
    ];

    System.runAs(testUser) {
      CartController.addItemToCart(testProduct.Id, 3);
    }

    Test.startTest();
    System.runAs(testUser) {
      CartController.CartWrapper result = CartController.getCurrentUserCart();

      System.assertNotEquals(null, result, 'Cart wrapper should not be null');
      System.assertNotEquals(null, result.cartId, 'Cart ID should not be null');
      System.assertEquals(
        1,
        result.cartItems.size(),
        'Should have one cart item'
      );
      System.assertEquals(
        testProduct.Id,
        result.cartItems[0].productId,
        'Product ID should match'
      );
      System.assertEquals(
        3,
        result.cartItems[0].quantity,
        'Quantity should be 3'
      );
    }
    Test.stopTest();
  }

  /**
   * @description Test getting cart item count
   */
  @IsTest
  static void testGetCartItemCount() {
    User testUser = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'john.doe.test@storeconnect.com'
      LIMIT 1
    ];
    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST-001'
      LIMIT 1
    ];

    Test.startTest();
    System.runAs(testUser) {
      // Test empty cart
      Decimal emptyCount = CartController.getCartItemCount();
      System.assertEquals(0, emptyCount, 'Empty cart should return 0 items');

      // Add items and test count
      CartController.addItemToCart(testProduct.Id, 3);
    }
    Test.stopTest();

    // Note: Total_Items__c would need to be calculated by triggers or process builder
    // For now, this tests the method doesn't throw exceptions
  }

  /**
   * @description Test updating cart item quantity
   */
  @IsTest
  static void testUpdateCartItemQuantity_Success() {
    // Setup cart with items
    User testUser = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'john.doe.test@storeconnect.com'
      LIMIT 1
    ];
    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST-001'
      LIMIT 1
    ];

    System.runAs(testUser) {
      CartController.addItemToCart(testProduct.Id, 2);
    }

    // Get cart item ID
    Cart_Item__c cartItem = [SELECT Id FROM Cart_Item__c LIMIT 1];

    Test.startTest();
    System.runAs(testUser) {
      CartController.updateCartItemQuantity(cartItem.Id, 5);
    }
    Test.stopTest();

    // Verify quantity was updated
    Cart_Item__c updatedItem = [
      SELECT Id, Quantity__c
      FROM Cart_Item__c
      WHERE Id = :cartItem.Id
    ];
    System.assertEquals(
      5,
      updatedItem.Quantity__c,
      'Quantity should be updated to 5'
    );
  }

  /**
   * @description Test removing cart item
   */
  @IsTest
  static void testRemoveCartItem_Success() {
    // Setup cart with items
    User testUser = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'john.doe.test@storeconnect.com'
      LIMIT 1
    ];
    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST-001'
      LIMIT 1
    ];

    System.runAs(testUser) {
      CartController.addItemToCart(testProduct.Id, 2);
    }

    // Get cart item ID
    Cart_Item__c cartItem = [SELECT Id FROM Cart_Item__c LIMIT 1];

    Test.startTest();
    System.runAs(testUser) {
      CartController.removeCartItem(cartItem.Id);
    }
    Test.stopTest();

    // Verify item was removed
    List<Cart_Item__c> remainingItems = [
      SELECT Id
      FROM Cart_Item__c
      WHERE Id = :cartItem.Id
    ];
    System.assertEquals(
      0,
      remainingItems.size(),
      'Cart item should be removed'
    );
  }

  /**
   * @description Test security - user without proper permissions
   */
  @IsTest
  static void testSecurityPermissions() {
    // Create user with minimal permissions
    Profile minimalProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Minimum Access - Salesforce'
      LIMIT 1
    ];
    User limitedUser = new User(
      FirstName = 'Limited',
      LastName = 'User',
      Email = 'limited@test.com',
      Username = 'limited.user.test@storeconnect.com',
      Alias = 'luser',
      TimeZoneSidKey = 'America/New_York',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = minimalProfile.Id
    );
    insert limitedUser;

    Product2 testProduct = [
      SELECT Id
      FROM Product2
      WHERE ProductCode = 'TEST-001'
      LIMIT 1
    ];

    Test.startTest();
    System.runAs(limitedUser) {
      try {
        CartController.addItemToCart(testProduct.Id, 1);
        System.assert(false, 'Security exception should be thrown');
      } catch (AuraHandledException e) {
        System.assert(
          e.getMessage().contains('permission'),
          'Should throw permission-related error'
        );
      }
    }
    Test.stopTest();
  }

  /**
   * @description Test cart operations with multiple products
   */
  @IsTest
  static void testMultipleProducts() {
    User testUser = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'john.doe.test@storeconnect.com'
      LIMIT 1
    ];
    List<Product2> testProducts = [
      SELECT Id
      FROM Product2
      ORDER BY ProductCode
    ];

    Test.startTest();
    System.runAs(testUser) {
      // Add multiple different products
      CartController.addItemToCart(testProducts[0].Id, 2);
      CartController.addItemToCart(testProducts[1].Id, 3);
    }
    Test.stopTest();

    // Verify both products are in cart
    Cart__c cart = [
      SELECT Id
      FROM Cart__c
      WHERE Contact__c = :testUser.ContactId
      LIMIT 1
    ];
    List<Cart_Item__c> cartItems = [
      SELECT Id, Product__c, Quantity__c
      FROM Cart_Item__c
      WHERE Cart__c = :cart.Id
      ORDER BY Product__c
    ];

    System.assertEquals(
      2,
      cartItems.size(),
      'Should have two different cart items'
    );
    System.assertEquals(
      testProducts[0].Id,
      cartItems[0].Product__c,
      'First product should match'
    );
    System.assertEquals(
      2,
      cartItems[0].Quantity__c,
      'First product quantity should be 2'
    );
    System.assertEquals(
      testProducts[1].Id,
      cartItems[1].Product__c,
      'Second product should match'
    );
    System.assertEquals(
      3,
      cartItems[1].Quantity__c,
      'Second product quantity should be 3'
    );
  }
}
