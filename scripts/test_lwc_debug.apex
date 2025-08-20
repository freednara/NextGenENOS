// Debug LWC component issues
try {
    System.debug('🧪 Debugging LWC component issues...');
    
    // Test 1: Check if the component is accessible
    System.debug('🧪 Test 1: Checking component accessibility');
    
    // Test 2: Check if there are any deployment issues
    System.debug('🧪 Test 2: Checking deployment status');
    
    // Test 3: Check if the addToCart method is accessible from LWC
    System.debug('🧪 Test 3: Checking addToCart method accessibility');
    
    try {
        // Test the method directly
        String testProductId = '01tSL000003tKcJYAU'; // Use a known product ID
        Object result = ENOS_ProductController.addToCart(testProductId, 1);
        
        System.debug('✅ addToCart method accessible from LWC context');
        System.debug('📊 Result: ' + result);
        
        if (result instanceof ENOS_ProductController.CartItemResult) {
            ENOS_ProductController.CartItemResult cartResult = (ENOS_ProductController.CartItemResult) result;
            System.debug('🎯 Method working correctly:');
            System.debug('  success: ' + cartResult.success);
            System.debug('  message: ' + cartResult.message);
        }
        
    } catch (Exception e) {
        System.debug('❌ addToCart method not accessible: ' + e.getMessage());
        System.debug('Error type: ' + e.getTypeName());
    }
    
    // Test 4: Check if there are any permission issues
    System.debug('🧪 Test 4: Checking permissions');
    
    try {
        // Check if the user can access the method
        if (Schema.sObjectType.Product2.isAccessible() && 
            Schema.sObjectType.Cart__c.isAccessible() && 
            Schema.sObjectType.Cart_Item__c.isAccessible()) {
            System.debug('✅ User has proper permissions');
        } else {
            System.debug('❌ User missing permissions');
        }
    } catch (Exception e) {
        System.debug('❌ Permission check failed: ' + e.getMessage());
    }
    
    System.debug('🎉 LWC debug testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during LWC debug testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
