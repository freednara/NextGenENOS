// Simple test script to verify CartController read methods
try {
    System.debug('=== Testing CartController.getCartItemCount() ===');
    
    // Test getting cart item count
    Decimal cartCount = CartController.getCartItemCount();
    System.debug('getCartItemCount() returned: ' + cartCount);
    
    System.debug('=== Testing CartController.getCartItems() ===');
    
    // Test getting cart items
    List<Cart_Item__c> cartItems = CartController.getCartItems();
    System.debug('getCartItems() returned ' + cartItems.size() + ' items');
    
    System.debug('=== Test completed successfully! ===');
    
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
