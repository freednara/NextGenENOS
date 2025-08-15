// Simple test script to verify CartController read methods
try {
    System.debug('=== Testing ENOS_CartController.getCartItemCount() ===');
    
    // Test getting cart item count
    Decimal cartCount = ENOS_CartController.getCartItemCount();
    System.debug('getCartItemCount() returned: ' + cartCount);
    
    System.debug('=== Testing ENOS_CartController.getCartItems() ===');
    
    // Test getting cart items
    List<Cart_Item__c> cartItems = ENOS_CartController.getCartItems();
    System.debug('getCartItems() returned ' + cartItems.size() + ' items');
    
    System.debug('=== Test completed successfully! ===');
    
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
