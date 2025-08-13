// Test script to verify CartController functionality
try {
    System.debug('=== Testing CartController.getCartItemCount() ===');
    
    // Test getting cart item count
    Decimal cartCount = CartController.getCartItemCount();
    System.debug('getCartItemCount() returned: ' + cartCount);
    
    System.debug('=== Testing CartController.getCartItems() ===');
    
    // Test getting cart items
    List<Cart_Item__c> cartItems = CartController.getCartItems();
    System.debug('getCartItems() returned ' + cartItems.size() + ' items');
    
    System.debug('=== Testing CartController.addItemToCart() ===');
    
    // Get a test product to add to cart
    List<Product2> products = [SELECT Id, Name FROM Product2 WHERE IsActive = true LIMIT 1];
    if(products.size() > 0) {
        Id productId = products[0].Id;
        System.debug('Adding product to cart: ' + products[0].Name);
        
        // Add to cart
        CartController.addItemToCart(productId, 2);
        System.debug('Product added to cart successfully');
        
        // Check updated cart count
        Decimal newCartCount = CartController.getCartItemCount();
        System.debug('New cart count: ' + newCartCount);
    }
    
    System.debug('=== Test completed successfully! ===');
    
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
