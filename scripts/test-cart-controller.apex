// Test script to verify CartController functionality
try {
    System.debug('=== Testing ENOS_CartController.getCartItemCount() ===');
    
    // Test getting cart item count
    Decimal cartCount = ENOS_CartController.getCartItemCount();
    System.debug('getCartItemCount() returned: ' + cartCount);
    
    System.debug('=== Testing ENOS_CartController.getCartItems() ===');
    
    // Test getting cart items
    List<Cart_Item__c> cartItems = ENOS_CartController.getCartItems();
    System.debug('getCartItems() returned ' + cartItems.size() + ' items');
    
    System.debug('=== Testing ENOS_CartController.addItemToCart() ===');
    
    // Get a test product to add to cart
    List<Product2> products = [SELECT Id, Name FROM Product2 WHERE IsActive = true LIMIT 1];
    if(products.size() > 0) {
        Id productId = products[0].Id;
        System.debug('Adding product to cart: ' + products[0].Name);
        
        // Add to cart
        ENOS_CartController.addItemToCart(productId, 2);
        System.debug('Product added to cart successfully');
        
        // Check updated cart count
        Decimal newCartCount = ENOS_CartController.getCartItemCount();
        System.debug('New cart count: ' + newCartCount);
    }
    
    System.debug('=== Test completed successfully! ===');
    
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
