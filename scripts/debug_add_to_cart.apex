// Debug addToCart method call
try {
    System.debug('🧪 Debugging addToCart method call...');
    
    // Test 1: Check method signature
    System.debug('🧪 Test 1: Checking method signature');
    
    // Get a test product
    List<Product2> testProducts = [
        SELECT Id, Name, ProductCode 
        FROM Product2 
        WHERE IsActive = true 
        LIMIT 1
    ];
    
    if (!testProducts.isEmpty()) {
        Product2 testProduct = testProducts[0];
        System.debug('🔄 Testing with product: ' + testProduct.Name);
        System.debug('🔄 Product ID: ' + testProduct.Id);
        System.debug('🔄 Product ID type: Id');
        
        // Test the method directly
        String productId = String.valueOf(testProduct.Id);
        Integer quantity = 1;
        
        System.debug('🔄 Calling addToCart with:');
        System.debug('  productId: ' + productId + ' (type: String)');
        System.debug('  quantity: ' + quantity + ' (type: Integer)');
        
        // Call the method
        Object result = ENOS_ProductController.addToCart(productId, quantity);
        
        System.debug('✅ Method call successful!');
        System.debug('📊 Result: ' + result);
        System.debug('📊 Result type: ' + result);
        
        if (result instanceof ENOS_ProductController.CartItemResult) {
            ENOS_ProductController.CartItemResult cartResult = (ENOS_ProductController.CartItemResult) result;
            System.debug('🎯 CartItemResult details:');
            System.debug('  success: ' + cartResult.success);
            System.debug('  message: ' + cartResult.message);
            System.debug('  cartItem: ' + cartResult.cartItem);
        }
        
    } else {
        System.debug('❌ No test products available');
    }
    
    // Test 2: Check if there are any other methods with similar names
    System.debug('🧪 Test 2: Checking for method conflicts');
    
    // Get all methods in ENOS_ProductController
    Type controllerType = Type.forName('ENOS_ProductController');
    if (controllerType != null) {
        System.debug('✅ ENOS_ProductController class found');
        
        // List all public methods (this is limited in Apex, but we can try)
        System.debug('📋 Available methods in ENOS_ProductController:');
        System.debug('  - addToCart(String productId, Integer quantity)');
        System.debug('  - getProducts(...)');
        System.debug('  - getCartDetails()');
        System.debug('  - updateCartItemQuantity(...)');
        
    } else {
        System.debug('❌ ENOS_ProductController class not found');
    }
    
    System.debug('🎉 Debug testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during debug testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    System.debug('Error type: ' + e.getTypeName());
}
