// Basic cart functionality test
// This verifies that the core cart methods work

try {
    System.debug('🚀 Testing basic cart functionality...');
    
    // Get a test product
    Product2 testProduct = [
        SELECT Id, Name, Family 
        FROM Product2 
        WHERE IsActive = true 
        LIMIT 1
    ];
    System.debug('✅ Test Product: ' + testProduct.Name + ' (ID: ' + testProduct.Id + ')');
    
    // Get the Standard Price Book ID
    Id standardPricebookId = [
        SELECT Id 
        FROM Pricebook2 
        WHERE IsStandard = true AND IsActive = true 
        LIMIT 1
    ].Id;
    System.debug('✅ Standard Price Book ID: ' + standardPricebookId);
    
    // Test the addToCart method
    System.debug('🛒 Testing ENOS_ProductController.addToCart...');
    
    // Call the method with the correct parameters
    ENOS_ProductController.AddToCartResult result = 
        ENOS_ProductController.addToCart(testProduct.Id, standardPricebookId, 2);
    
    if (result != null && result.success) {
        System.debug('✅ Add to cart successful!');
        System.debug('  Cart ID: ' + result.cartId);
        System.debug('  Cart Item ID: ' + result.cartItemId);
        System.debug('  Message: ' + result.message);
        
        // Test getting cart details
        System.debug('📋 Testing getCartDetails...');
        ENOS_ProductController.CartDetailsResult cartDetails = 
            ENOS_ProductController.getCartDetails();
        
        if (cartDetails != null && cartDetails.success) {
            System.debug('✅ Get cart details successful!');
            System.debug('  Cart ID: ' + cartDetails.cartId);
            System.debug('  Item Count: ' + cartDetails.itemCount);
            System.debug('  Total Value: ' + cartDetails.totalValue);
        } else {
            System.debug('❌ Get cart details failed');
        }
        
    } else {
        System.debug('❌ Add to cart failed');
        if (result != null) {
            System.debug('  Message: ' + result.message);
        }
    }
    
    System.debug('🎉 Basic cart functionality test completed!');
    
} catch (Exception e) {
    System.debug('❌ Error testing cart functionality: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
