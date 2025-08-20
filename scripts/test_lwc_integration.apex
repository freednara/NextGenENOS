// Test LWC Integration with Apex methods
try {
    System.debug('🧪 Testing LWC Integration...');
    
    // Test 1: Verify all required Apex methods are accessible
    System.debug('🧪 Test 1: Verify Apex method accessibility');
    
    // Test getProducts method
    try {
        List<Product2> products = ENOS_ProductController.getProducts(5, 1, null, null, 'Name', 'ASC');
        System.debug('✅ getProducts: ' + products.size() + ' products returned');
    } catch (Exception e) {
        System.debug('❌ getProducts failed: ' + e.getMessage());
    }
    
    // Test getCartDetails method
    try {
        Object cartDetails = ENOS_ProductController.getCartDetails();
        System.debug('✅ getCartDetails: ' + cartDetails);
    } catch (Exception e) {
        System.debug('❌ getCartDetails failed: ' + e.getMessage());
    }
    
    // Test addToCart method
    try {
        // Get a test product
        List<Product2> testProducts = [
            SELECT Id, Name, ProductCode 
            FROM Product2 
            WHERE IsActive = true 
            LIMIT 1
        ];
        
        if (!testProducts.isEmpty()) {
            String productId = String.valueOf(testProducts[0].Id);
            Object addResult = ENOS_ProductController.addToCart(productId, 1);
            System.debug('✅ addToCart: ' + addResult);
        }
    } catch (Exception e) {
        System.debug('❌ addToCart failed: ' + e.getMessage());
    }
    
    // Test 2: Check if user has active cart
    System.debug('🧪 Test 2: Check user cart status');
    try {
        String currentUserId = UserInfo.getUserId();
        List<Cart__c> userCarts = [
            SELECT Id, Status__c, OwnerId, Subtotal__c
            FROM Cart__c 
            WHERE OwnerId = :currentUserId 
            AND Status__c = 'Active'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (!userCarts.isEmpty()) {
            Cart__c userCart = userCarts[0];
            System.debug('✅ User has active cart: ' + userCart.Id);
            System.debug('  Status: ' + userCart.Status__c);
            System.debug('  Subtotal: ' + userCart.Subtotal__c);
            
            // Check cart items
            List<Cart_Item__c> cartItems = [
                SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
                FROM Cart_Item__c
                WHERE Cart__c = :userCart.Id
            ];
            
            System.debug('✅ Cart contains ' + cartItems.size() + ' items');
            for (Cart_Item__c item : cartItems) {
                System.debug('  Item: Product=' + item.Product__c + ', Qty=' + item.Quantity__c);
            }
            
        } else {
            System.debug('❌ User has no active cart');
        }
        
    } catch (Exception e) {
        System.debug('❌ Cart status check failed: ' + e.getMessage());
    }
    
    System.debug('🎉 LWC Integration testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during LWC Integration testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
