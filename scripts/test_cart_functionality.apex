// Test cart functionality by calling the Apex method directly
// This verifies that the LWC-Apex integration will work

try {
    // Get current user info
    Id currentUserId = UserInfo.getUserId();
    System.debug('Current User ID: ' + currentUserId);
    
    // Get a test product
    Product2 testProduct = [
        SELECT Id, Name, Family 
        FROM Product2 
        WHERE IsActive = true 
        LIMIT 1
    ];
    System.debug('Test Product: ' + testProduct.Name + ' (ID: ' + testProduct.Id + ')');
    
    // Get the Standard Price Book ID
    Id standardPricebookId = [
        SELECT Id 
        FROM Pricebook2 
        WHERE IsStandard = true AND IsActive = true 
        LIMIT 1
    ].Id;
    System.debug('Standard Price Book ID: ' + standardPricebookId);
    
    // Test the addToCart method
    System.debug('Testing ENOS_ProductController.addToCart...');
    
    // Call the method with the correct parameters
    ENOS_ProductController.AddToCartResult result = 
        ENOS_ProductController.addToCart(testProduct.Id, standardPricebookId, 2);
    
    if (result != null && result.success) {
        System.debug('✅ Add to cart successful!');
        System.debug('  Cart ID: ' + result.cartId);
        System.debug('  Cart Item ID: ' + result.cartItemId);
        System.debug('  Message: ' + result.message);
        
        // Verify the cart was created
        Cart__c cart = [SELECT Id, Contact__c, Total_Items__c FROM Cart__c WHERE Id = :result.cartId];
        System.debug('Cart verification:');
        System.debug('  Cart ID: ' + cart.Id);
        System.debug('  Contact: ' + cart.Contact__c);
        System.debug('  Total Items: ' + cart.Total_Items__c);
        
        // Verify the cart item was created
        Cart_Item__c cartItem = [SELECT Id, Product__c, Quantity__c, Unit_Price__c FROM Cart_Item__c WHERE Id = :result.cartItemId];
        System.debug('Cart Item verification:');
        System.debug('  Item ID: ' + cartItem.Id);
        System.debug('  Product: ' + cartItem.Product__c);
        System.debug('  Quantity: ' + cartItem.Quantity__c);
        System.debug('  Unit Price: ' + cartItem.Unit_Price__c);
        
    } else {
        System.debug('❌ Add to cart failed');
        if (result != null) {
            System.debug('  Message: ' + result.message);
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error testing cart functionality: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
