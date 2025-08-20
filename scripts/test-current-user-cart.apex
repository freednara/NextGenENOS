// Test current user cart functionality
// This will verify that the cart system now works with authenticated users

try {
    System.debug('🧪 Testing current user cart functionality...');
    
    // Get current user info
    String currentUserId = UserInfo.getUserId();
    System.debug('✅ Current User ID: ' + currentUserId);
    
    // Get current user's contact ID
    User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId LIMIT 1];
    System.debug('✅ Current User Contact ID: ' + currentUser.ContactId);
    
    if (currentUser.ContactId == null) {
        System.debug('⚠️ Warning: Current user has no Contact ID - this may cause cart issues');
        System.debug('💡 Solution: Ensure the user has a Contact record associated');
    } else {
        System.debug('✅ Current user has Contact ID: ' + currentUser.ContactId);
        
        // Get a test product
        List<Product2> testProducts = [
            SELECT Id, Name, ProductCode 
            FROM Product2 
            WHERE IsActive = true 
            LIMIT 1
        ];
        
        if (testProducts.isEmpty()) {
            System.debug('❌ No test products found');
            return;
        }
        
        Product2 testProduct = testProducts[0];
        System.debug('✅ Test product: ' + testProduct.Name + ' (ID: ' + testProduct.Id + ')');
        
        // Test 1: Direct call to ENOS_CartController.addItemToCart
        System.debug('🧪 Test 1: Direct call to ENOS_CartController.addItemToCart');
        try {
            Map<String, Object> result1 = ENOS_CartController.addItemToCart(testProduct.Id, 1);
            System.debug('✅ Direct call successful: ' + result1);
        } catch (Exception e) {
            System.debug('❌ Direct call failed: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        // Test 2: Call through ENOS_ProductController.addToCart
        System.debug('🧪 Test 2: Call through ENOS_ProductController.addToCart');
        try {
            // Convert Id to String to simulate LWC behavior
            String productIdAsString = String.valueOf(testProduct.Id);
            System.debug('🔄 Converting Id to String: ' + productIdAsString);
            
            // Call the method that the LWC is calling
            Object result2 = ENOS_ProductController.addToCart(productIdAsString, 1);
            System.debug('✅ ProductController call successful: ' + result2);
            
        } catch (Exception e) {
            System.debug('❌ ProductController call failed: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        // Test 3: Check if user has an active cart
        System.debug('🧪 Test 3: Check user active cart');
        try {
            List<Cart__c> userCarts = [
                SELECT Id, Status__c, Contact__c, Created_Date__c
                FROM Cart__c 
                WHERE Contact__c = :currentUser.ContactId 
                AND Status__c = 'Active'
                ORDER BY Created_Date__c DESC
                LIMIT 5
            ];
            
            System.debug('✅ User has ' + userCarts.size() + ' active carts');
            for (Cart__c cart : userCarts) {
                System.debug('  Cart ID: ' + cart.Id + ', Status: ' + cart.Status__c + ', Created: ' + cart.Created_Date__c);
            }
            
        } catch (Exception e) {
            System.debug('❌ Cart check failed: ' + e.getMessage());
        }
    }
    
    System.debug('🎉 Current user cart functionality testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during cart testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
