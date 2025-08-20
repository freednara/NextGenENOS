// Test View Cart functionality
try {
    System.debug('🧪 Testing View Cart functionality...');
    
    // Test 1: getCartDetails method
    System.debug('🧪 Test 1: getCartDetails method');
    try {
        Object cartDetails = ENOS_ProductController.getCartDetails();
        System.debug('✅ getCartDetails successful: ' + cartDetails);
        
        if (cartDetails != null) {
            System.debug('🎉 View Cart is working!');
        }
        
    } catch (Exception e) {
        System.debug('❌ getCartDetails failed: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
    // Test 2: Check if user has a cart
    System.debug('🧪 Test 2: Check user cart');
    try {
        String currentUserId = UserInfo.getUserId();
        System.debug('✅ Current User ID: ' + currentUserId);
        
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
            System.debug('✅ User cart found: ' + userCart.Id);
            System.debug('  Status: ' + userCart.Status__c);
            System.debug('  Subtotal: ' + userCart.Subtotal__c);
            
            // Check cart items
            List<Cart_Item__c> cartItems = [
                SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
                FROM Cart_Item__c
                WHERE Cart__c = :userCart.Id
            ];
            
            System.debug('✅ Cart has ' + cartItems.size() + ' items');
            for (Cart_Item__c item : cartItems) {
                System.debug('  Item: Product=' + item.Product__c + ', Qty=' + item.Quantity__c + ', Price=' + item.Unit_Price__c);
            }
            
        } else {
            System.debug('❌ No user cart found');
        }
        
    } catch (Exception e) {
        System.debug('❌ Cart check failed: ' + e.getMessage());
    }
    
    System.debug('🎉 View Cart testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during View Cart testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
