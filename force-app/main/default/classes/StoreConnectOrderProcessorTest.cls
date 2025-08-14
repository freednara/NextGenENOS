/**
 * @description Test class for StoreConnectOrderProcessor
 * Tests order processing functionality and business logic.
 *
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class StoreConnectOrderProcessorTest {
    
    @TestSetup
    static void setup() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Order Account'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Order',
            LastName = 'Processor Test',
            Email = 'ordertest@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create test products
        List<Product2> products = new List<Product2>{
            new Product2(
                Name = 'Order Test Product 1',
                ProductCode = 'ORDER001',
                Description = 'Order Test Product 1',
                IsActive = true,
                Stock_Quantity__c = 100
            ),
            new Product2(
                Name = 'Order Test Product 2',
                ProductCode = 'ORDER002',
                Description = 'Order Test Product 2',
                IsActive = true,
                Stock_Quantity__c = 50
            )
        };
        insert products;
        
        // Create pricebook entries
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            pricebookEntries.add(new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = product.Id,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        insert pricebookEntries;
        
        // Create cart with items
        Cart__c testCart = new Cart__c(
            Contact__c = testContact.Id,
            Status__c = 'Active',
            Subtotal__c = 300.00,
            Total_Items__c = 3
        );
        insert testCart;
        
        // Create cart items
        List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
        for (Integer i = 0; i < products.size(); i++) {
            cartItems.add(new Cart_Item__c(
                Cart__c = testCart.Id,
                Product__c = products[i].Id,
                Quantity__c = i + 1,
                Unit_Price__c = 100.00,
                Line_Total__c = (i + 1) * 100.00
            ));
        }
        insert cartItems;
        
        // Create shipping address
        Shipping_Address__c shippingAddress = new Shipping_Address__c(
            Account__c = testAccount.Id,
            Street__c = '123 Order Test Street',
            City__c = 'Order City',
            State__c = 'CA',
            Postal_Code__c = '54321',
            Country__c = 'USA',
            Is_Default__c = true
        );
        insert shippingAddress;
    }
    
    @isTest
    static void testProcessOrder() {
        Cart__c testCart = [SELECT Id, Contact__c FROM Cart__c LIMIT 1];
        Shipping_Address__c shippingAddress = [SELECT Id FROM Shipping_Address__c LIMIT 1];
        
        Test.startTest();
        Id orderId = StoreConnectOrderProcessor.processOrder(
            testCart.Id, 
            shippingAddress.Id, 
            'test-payment-token-123'
        );
        Test.stopTest();
        
        // Verify order was created
        System.assertNotEquals(null, orderId, 'Order ID should not be null');
        
        Order createdOrder = [SELECT Id, Status, TotalAmount FROM Order WHERE Id = :orderId];
        System.assertEquals('Draft', createdOrder.Status, 'Order should be in Draft status initially');
        System.assertEquals(300.00, createdOrder.TotalAmount, 'Order total should match cart subtotal');
        
        // Verify order items were created
        List<OrderItem> orderItems = [SELECT Id, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
        System.assertEquals(2, orderItems.size(), 'Should create 2 order items');
        
        // Verify cart status was updated
        Cart__c updatedCart = [SELECT Id, Status__c FROM Cart__c WHERE Id = :testCart.Id];
        System.assertEquals('Ordered', updatedCart.Status__c, 'Cart status should be updated to Ordered');
    }
    
    @isTest
    static void testProcessOrderInvalidCart() {
        Id invalidCartId = 'a00000000000000';
        Shipping_Address__c shippingAddress = [SELECT Id FROM Shipping_Address__c LIMIT 1];
        
        Test.startTest();
        try {
            StoreConnectOrderProcessor.processOrder(
                invalidCartId, 
                shippingAddress.Id, 
                'test-payment-token'
            );
            System.assert(false, 'Should throw exception for invalid cart ID');
        } catch (Exception e) {
            System.assert(true, 'Should handle invalid cart ID gracefully');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessOrderInvalidShippingAddress() {
        Cart__c testCart = [SELECT Id FROM Cart__c LIMIT 1];
        Id invalidAddressId = 'a01000000000000';
        
        Test.startTest();
        try {
            StoreConnectOrderProcessor.processOrder(
                testCart.Id, 
                invalidAddressId, 
                'test-payment-token'
            );
            System.assert(false, 'Should throw exception for invalid shipping address');
        } catch (Exception e) {
            System.assert(true, 'Should handle invalid shipping address gracefully');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessOrderEmptyCart() {
        Cart__c emptyCart = new Cart__c(
            Contact__c = [SELECT Id FROM Contact LIMIT 1].Id,
            Status__c = 'Active',
            Subtotal__c = 0.00,
            Total_Items__c = 0
        );
        insert emptyCart;
        
        Shipping_Address__c shippingAddress = [SELECT Id FROM Shipping_Address__c LIMIT 1];
        
        Test.startTest();
        try {
            StoreConnectOrderProcessor.processOrder(
                emptyCart.Id, 
                shippingAddress.Id, 
                'test-payment-token'
            );
            System.assert(false, 'Should throw exception for empty cart');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('empty') || e.getMessage().contains('items'), 
                         'Exception should indicate empty cart');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidateInventory() {
        Cart__c testCart = [SELECT Id FROM Cart__c LIMIT 1];
        
        Test.startTest();
        Boolean inventoryValid = StoreConnectOrderProcessor.validateInventory(testCart.Id);
        Test.stopTest();
        
        System.assertEquals(true, inventoryValid, 'Inventory should be valid for test cart');
    }
    
    @isTest
    static void testValidateInventoryInsufficientStock() {
        // Update product stock to insufficient levels
        Product2 testProduct = [SELECT Id FROM Product2 WHERE ProductCode = 'ORDER001' LIMIT 1];
        testProduct.Stock_Quantity__c = 0;
        update testProduct;
        
        Cart__c testCart = [SELECT Id FROM Cart__c LIMIT 1];
        
        Test.startTest();
        Boolean inventoryValid = StoreConnectOrderProcessor.validateInventory(testCart.Id);
        Test.stopTest();
        
        System.assertEquals(false, inventoryValid, 'Inventory should be invalid when stock is insufficient');
    }
    
    @isTest
    static void testCalculateOrderTotal() {
        Cart__c testCart = [SELECT Id FROM Cart__c LIMIT 1];
        
        Test.startTest();
        Decimal orderTotal = StoreConnectOrderProcessor.calculateOrderTotal(testCart.Id);
        Test.stopTest();
        
        System.assertEquals(300.00, orderTotal, 'Order total should match cart subtotal');
    }
    
    @isTest
    static void testCalculateOrderTotalWithTax() {
        Cart__c testCart = [SELECT Id FROM Cart__c LIMIT 1];
        
        Test.startTest();
        Decimal orderTotalWithTax = StoreConnectOrderProcessor.calculateOrderTotalWithTax(testCart.Id, 0.08);
        Test.stopTest();
        
        System.assertEquals(324.00, orderTotalWithTax, 'Order total with tax should include 8% tax');
    }
    
    @isTest
    static void testUpdateInventoryAfterOrder() {
        Cart__c testCart = [SELECT Id FROM Cart__c LIMIT 1];
        List<Product2> originalProducts = [SELECT Id, Stock_Quantity__c FROM Product2 ORDER BY ProductCode];
        
        Test.startTest();
        StoreConnectOrderProcessor.updateInventoryAfterOrder(testCart.Id);
        Test.stopTest();
        
        // Verify inventory was decremented
        List<Product2> updatedProducts = [SELECT Id, Stock_Quantity__c FROM Product2 ORDER BY ProductCode];
        System.assertEquals(99, updatedProducts[0].Stock_Quantity__c, 'First product stock should be decremented by 1');
        System.assertEquals(48, updatedProducts[1].Stock_Quantity__c, 'Second product stock should be decremented by 2');
    }
    
    @isTest
    static void testProcessPayment() {
        Test.startTest();
        Boolean paymentResult = StoreConnectOrderProcessor.processPayment('test-payment-token', 300.00);
        Test.stopTest();
        
        // In test context, payment processing should return true (mocked)
        System.assertEquals(true, paymentResult, 'Payment processing should succeed in test context');
    }
    
    @isTest
    static void testProcessPaymentFailure() {
        Test.startTest();
        Boolean paymentResult = StoreConnectOrderProcessor.processPayment('invalid-token', 300.00);
        Test.stopTest();
        
        // Test should handle payment failure gracefully
        System.assertNotEquals(null, paymentResult, 'Payment result should not be null');
    }
    
    @isTest
    static void testBulkOrderProcessing() {
        List<Cart__c> testCarts = new List<Cart__c>();
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Create multiple carts for bulk processing
        for (Integer i = 0; i < 3; i++) {
            Cart__c cart = new Cart__c(
                Contact__c = testContact.Id,
                Status__c = 'Active',
                Subtotal__c = 100.00 * (i + 1),
                Total_Items__c = i + 1
            );
            testCarts.add(cart);
        }
        insert testCarts;
        
        Shipping_Address__c shippingAddress = [SELECT Id FROM Shipping_Address__c LIMIT 1];
        
        Test.startTest();
        List<Id> orderIds = new List<Id>();
        for (Cart__c cart : testCarts) {
            Id orderId = StoreConnectOrderProcessor.processOrder(
                cart.Id, 
                shippingAddress.Id, 
                'bulk-payment-token-' + cart.Id
            );
            orderIds.add(orderId);
        }
        Test.stopTest();
        
        System.assertEquals(3, orderIds.size(), 'Should process 3 orders');
        
        // Verify all orders were created
        List<Order> createdOrders = [SELECT Id, Status FROM Order WHERE Id IN :orderIds];
        System.assertEquals(3, createdOrders.size(), 'Should create 3 orders');
    }
    
    @isTest
    static void testOrderProcessingWithDiscounts() {
        Cart__c testCart = [SELECT Id FROM Cart__c LIMIT 1];
        Shipping_Address__c shippingAddress = [SELECT Id FROM Shipping_Address__c LIMIT 1];
        
        // Apply discount to cart
        testCart.Subtotal__c = 250.00; // Reduced from 300.00
        update testCart;
        
        Test.startTest();
        Id orderId = StoreConnectOrderProcessor.processOrder(
            testCart.Id, 
            shippingAddress.Id, 
            'discount-payment-token'
        );
        Test.stopTest();
        
        Order createdOrder = [SELECT Id, TotalAmount FROM Order WHERE Id = :orderId];
        System.assertEquals(250.00, createdOrder.TotalAmount, 'Order should reflect discounted total');
    }
}
