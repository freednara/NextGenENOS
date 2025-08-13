/**
 * @description Comprehensive integration test suite for StoreConnect e-commerce platform
 * Tests end-to-end workflows including product browsing, cart management, and order processing
 * 
 * @author NextGenENOS Team
 * @since 2024
 */
@IsTest
public class StoreConnectIntegrationTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test profile and user
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'ENOS Community Login' LIMIT 1];
        
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Customer Account',
            Type = 'Customer'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Customer',
            Email = 'testcustomer@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Customer',
            Email = 'testcustomer@example.com',
            Username = 'testcustomer@storeconnect.test.com',
            Alias = 'tcust',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id,
            ProfileId = communityProfile.Id,
            IsActive = true
        );
        insert testUser;
        
        // Assign permission set
        PermissionSet storeConnectPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'StoreConnectCommunity' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = storeConnectPermSet.Id
        );
        insert psa;
        
        // Create test categories
        List<Category__c> categories = new List<Category__c>{
            new Category__c(Name__c = 'Electronics', Description__c = 'Electronic devices'),
            new Category__c(Name__c = 'Accessories', Description__c = 'Device accessories')
        };
        insert categories;
        
        // Create test products
        List<Product2> products = new List<Product2>();
        for (Integer i = 1; i <= 5; i++) {
            products.add(new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'TEST00' + i,
                Description = 'Test product description ' + i,
                IsActive = true,
                Category__c = categories[Math.mod(i, 2)].Id,
                Stock_Quantity__c = 100,
                Image_URL__c = 'https://example.com/product' + i + '.jpg'
            ));
        }
        insert products;
        
        // Get standard price book
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        // Create price book entries
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        for (Integer i = 0; i < products.size(); i++) {
            priceBookEntries.add(new PricebookEntry(
                Pricebook2Id = standardPriceBookId,
                Product2Id = products[i].Id,
                UnitPrice = 99.99 + (i * 10),
                IsActive = true
            ));
        }
        insert priceBookEntries;
        
        // Create shipping address
        Shipping_Address__c shippingAddress = new Shipping_Address__c(
            Account__c = testAccount.Id,
            Address_Label__c = 'Home',
            Street__c = '123 Test Street',
            City__c = 'Test City',
            State__c = 'Test State',
            Postal_Code__c = '12345',
            Country__c = 'United States'
        );
        insert shippingAddress;
    }
    
    @IsTest
    static void testEndToEndECommerceWorkflow() {
        // Get test user
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testcustomer@storeconnect.test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            
            // Step 1: Browse products
            List<Product2> allProducts = StoreConnectController.getProducts(testUser.ContactId);
            System.assertEquals(5, allProducts.size(), 'Should return all test products');
            
            // Step 2: Search for specific products
            List<Product2> searchResults = ProductController.searchProducts('Test Product 1');
            System.assertEquals(1, searchResults.size(), 'Should find the specific product');
            
            // Step 3: Get product details
            Product2 selectedProduct = ProductController.getProductById(allProducts[0].Id);
            System.assertNotEquals(null, selectedProduct, 'Should return product details');
            System.assertEquals('Test Product 1', selectedProduct.Name, 'Should return correct product');
            
            // Step 4: Add product to cart
            CartController.addItemToCart(selectedProduct.Id, 2);
            
            // Step 5: Verify cart contents
            CartController.CartData cartData = CartController.getCurrentUserCart(testUser.ContactId);
            System.assertEquals(1, cartData.cartItems.size(), 'Should have one item in cart');
            System.assertEquals(2, cartData.cartItems[0].quantity, 'Should have correct quantity');
            System.assertEquals(selectedProduct.Id, cartData.cartItems[0].productId, 'Should have correct product');
            
            // Step 6: Update cart item quantity
            String cartItemId = cartData.cartItems[0].cartItemId;
            CartController.updateCartItemQuantity(cartItemId, 3);
            
            // Verify updated quantity
            cartData = CartController.getCurrentUserCart(testUser.ContactId);
            System.assertEquals(3, cartData.cartItems[0].quantity, 'Should have updated quantity');
            
            // Step 7: Add more products to cart
            CartController.addItemToCart(allProducts[1].Id, 1);
            cartData = CartController.getCurrentUserCart(testUser.ContactId);
            System.assertEquals(2, cartData.cartItems.size(), 'Should have two items in cart');
            
            // Step 8: Get cart item count
            Decimal itemCount = CartController.getCartItemCount(testUser.ContactId);
            System.assertEquals(4, itemCount, 'Should return total item count'); // 3 + 1 = 4
            
            // Step 9: Create order
            List<Shipping_Address__c> addresses = StoreConnectController.getShippingAddresses(testUser.ContactId);
            System.assertEquals(1, addresses.size(), 'Should have one shipping address');
            
            String orderId = StoreConnectController.createOrder(testUser.ContactId, addresses[0].Id);
            System.assertNotEquals(null, orderId, 'Should create order successfully');
            
            // Step 10: Verify order history
            List<Order> orderHistory = StoreConnectController.getOrderHistory(testUser.ContactId);
            System.assertEquals(1, orderHistory.size(), 'Should have one order in history');
            System.assertEquals('Draft', orderHistory[0].Status, 'Order should be in Draft status');
            
            // Step 11: Verify cart is cleared after order creation
            cartData = CartController.getCurrentUserCart(testUser.ContactId);
            System.assertEquals(0, cartData.cartItems.size(), 'Cart should be empty after order creation');
            
            // Step 12: Remove item from cart (test with new cart)
            CartController.addItemToCart(allProducts[2].Id, 1);
            cartData = CartController.getCurrentUserCart(testUser.ContactId);
            CartController.removeCartItem(cartData.cartItems[0].cartItemId);
            
            cartData = CartController.getCurrentUserCart(testUser.ContactId);
            System.assertEquals(0, cartData.cartItems.size(), 'Cart should be empty after removal');
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testProductCatalogIntegration() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testcustomer@storeconnect.test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            
            // Test product catalog functionality
            StoreConnectController.CatalogResult catalogResult = StoreConnectController.getCatalog(
                testUser.ContactId, 0, 10, '', ''
            );
            
            System.assertEquals(5, catalogResult.totalCount, 'Should return all products');
            System.assertEquals(5, catalogResult.products.size(), 'Should return all products in first page');
            System.assertEquals(0, catalogResult.pageNumber, 'Should be first page');
            
            // Test pagination
            catalogResult = StoreConnectController.getCatalog(
                testUser.ContactId, 1, 3, '', ''
            );
            
            System.assertEquals(5, catalogResult.totalCount, 'Total count should remain same');
            System.assertEquals(2, catalogResult.products.size(), 'Should return remaining products');
            System.assertEquals(1, catalogResult.pageNumber, 'Should be second page');
            
            // Test category filtering
            Category__c electronicsCategory = [SELECT Id FROM Category__c WHERE Name__c = 'Electronics' LIMIT 1];
            catalogResult = StoreConnectController.getCatalog(
                testUser.ContactId, 0, 10, '', electronicsCategory.Id
            );
            
            System.assert(catalogResult.products.size() >= 1, 'Should return electronics products');
            for (Product2 product : catalogResult.products) {
                System.assertEquals(electronicsCategory.Id, product.Category__c, 'All products should be electronics');
            }
            
            // Test search functionality
            catalogResult = StoreConnectController.getCatalog(
                testUser.ContactId, 0, 10, 'Product 1', ''
            );
            
            System.assertEquals(1, catalogResult.products.size(), 'Should find one matching product');
            System.assert(catalogResult.products[0].Name.contains('Product 1'), 'Should contain search term');
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testSecurityAndPermissions() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testcustomer@storeconnect.test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            
            // Test that user can only access their own data
            List<Product2> products = StoreConnectController.getProducts(testUser.ContactId);
            System.assertNotEquals(null, products, 'User should be able to access products');
            
            // Test cart security - user should only see their own cart
            CartController.addItemToCart(products[0].Id, 1);
            CartController.CartData cartData = CartController.getCurrentUserCart(testUser.ContactId);
            System.assertEquals(1, cartData.cartItems.size(), 'Should see own cart items');
            
            // Test order security - user should only see their own orders
            List<Shipping_Address__c> addresses = StoreConnectController.getShippingAddresses(testUser.ContactId);
            String orderId = StoreConnectController.createOrder(testUser.ContactId, addresses[0].Id);
            
            List<Order> orderHistory = StoreConnectController.getOrderHistory(testUser.ContactId);
            System.assertEquals(1, orderHistory.size(), 'Should only see own orders');
            
            // Test shipping address security
            System.assertEquals(1, addresses.size(), 'Should only see own addresses');
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testErrorHandling() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testcustomer@storeconnect.test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            
            // Test invalid product ID
            try {
                Product2 invalidProduct = ProductController.getProductById('invalid_id');
                System.assert(false, 'Should throw exception for invalid product ID');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Invalid'), 'Should return user-friendly error message');
            }
            
            // Test invalid cart item operations
            try {
                CartController.updateCartItemQuantity('invalid_id', 5);
                System.assert(false, 'Should throw exception for invalid cart item ID');
            } catch (Exception e) {
                System.assertNotEquals(null, e.getMessage(), 'Should return error message');
            }
            
            // Test invalid order creation
            try {
                String orderId = StoreConnectController.createOrder(testUser.ContactId, 'invalid_address_id');
                System.assert(false, 'Should throw exception for invalid address ID');
            } catch (Exception e) {
                System.assertNotEquals(null, e.getMessage(), 'Should return error message');
            }
            
            // Test zero/negative quantities
            try {
                CartController.addItemToCart([SELECT Id FROM Product2 LIMIT 1].Id, 0);
                System.assert(false, 'Should not allow zero quantity');
            } catch (Exception e) {
                System.assertNotEquals(null, e.getMessage(), 'Should return error for zero quantity');
            }
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testPerformanceAndBulkOperations() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testcustomer@storeconnect.test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            
            // Test bulk cart operations
            List<Product2> products = [SELECT Id FROM Product2 LIMIT 5];
            
            // Add multiple items to cart
            for (Product2 product : products) {
                CartController.addItemToCart(product.Id, 1);
            }
            
            // Verify bulk operations don't hit governor limits
            CartController.CartData cartData = CartController.getCurrentUserCart(testUser.ContactId);
            System.assertEquals(5, cartData.cartItems.size(), 'Should handle multiple cart items');
            
            // Test bulk cart updates
            for (CartController.CartItemData item : cartData.cartItems) {
                CartController.updateCartItemQuantity(item.cartItemId, 2);
            }
            
            // Verify all updates
            cartData = CartController.getCurrentUserCart(testUser.ContactId);
            for (CartController.CartItemData item : cartData.cartItems) {
                System.assertEquals(2, item.quantity, 'All items should be updated');
            }
            
            // Test search performance with large result set
            List<Product2> searchResults = ProductController.searchProducts('Test');
            System.assert(searchResults.size() > 0, 'Should return search results efficiently');
            
            Test.stopTest();
            
            // Verify no governor limits hit
            System.assert(Limits.getQueries() < Limits.getLimitQueries(), 'Should not hit SOQL query limits');
            System.assert(Limits.getDmlStatements() < Limits.getLimitDmlStatements(), 'Should not hit DML limits');
        }
    }
    
    @IsTest
    static void testDataIntegrityAndValidation() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testcustomer@storeconnect.test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            
            Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
            
            // Test cart data integrity
            CartController.addItemToCart(testProduct.Id, 1);
            CartController.CartData cartData = CartController.getCurrentUserCart(testUser.ContactId);
            
            // Verify calculated fields
            System.assert(cartData.subtotal > 0, 'Subtotal should be calculated');
            System.assert(cartData.totalItems > 0, 'Total items should be calculated');
            
            // Test order data integrity
            List<Shipping_Address__c> addresses = StoreConnectController.getShippingAddresses(testUser.ContactId);
            String orderId = StoreConnectController.createOrder(testUser.ContactId, addresses[0].Id);
            
            // Verify order was created with correct data
            Order createdOrder = [SELECT Id, Status, TotalAmount, AccountId FROM Order WHERE Id = :orderId];
            System.assertEquals('Draft', createdOrder.Status, 'Order should be in Draft status');
            System.assert(createdOrder.TotalAmount > 0, 'Order should have total amount');
            
            // Verify order items were created
            List<OrderItem> orderItems = [SELECT Id, Product2Id, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
            System.assertEquals(1, orderItems.size(), 'Should create order items');
            System.assertEquals(testProduct.Id, orderItems[0].Product2Id, 'Should reference correct product');
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testPaymentIntegration() {
        User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'testcustomer@storeconnect.test.com' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            
            // Create an order for payment testing
            Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
            CartController.addItemToCart(testProduct.Id, 1);
            
            List<Shipping_Address__c> addresses = StoreConnectController.getShippingAddresses(testUser.ContactId);
            String orderId = StoreConnectController.createOrder(testUser.ContactId, addresses[0].Id);
            
            // Test PayGov service integration
            PayGovService.PaymentRequest paymentRequest = new PayGovService.PaymentRequest();
            paymentRequest.orderId = orderId;
            paymentRequest.amount = 99.99;
            paymentRequest.currency = 'USD';
            
            // Mock payment service call
            PayGovService.PaymentResponse response = PayGovService.processPayment(paymentRequest);
            System.assertNotEquals(null, response, 'Should return payment response');
            
            // Test order confirmation service
            OrderConfirmationService.OrderConfirmation confirmation = 
                OrderConfirmationService.sendOrderConfirmation(orderId);
            System.assertNotEquals(null, confirmation, 'Should send order confirmation');
            
            Test.stopTest();
        }
    }
}
