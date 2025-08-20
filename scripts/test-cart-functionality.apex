// Test cart functionality to identify the parameter type mismatch issue
// This will help debug the "String cannot be cast to Map" error

try {
    System.debug('🧪 Testing cart functionality...');
    
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
    
    // Test 3: Check if the issue is in the guest cart method
    System.debug('🧪 Test 3: Direct call to ENOS_CartController.addItemToGuestCart');
    try {
        Map<String, Object> result3 = ENOS_CartController.addItemToGuestCart(null, testProduct.Id, 1);
        System.debug('✅ Guest cart call successful: ' + result3);
    } catch (Exception e) {
        System.debug('❌ Guest cart call failed: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
    System.debug('🎉 Cart functionality testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during cart testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
