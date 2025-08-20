// Test simplified cart functionality that works with available fields
try {
    System.debug('🧪 Testing simplified cart functionality...');
    
    // Get current user info
    String currentUserId = UserInfo.getUserId();
    System.debug('✅ Current User ID: ' + currentUserId);
    
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
        
        if ((Boolean) result1.get('success')) {
            System.debug('🎉 Cart item added successfully!');
            System.debug('  Cart ID: ' + result1.get('cartId'));
            System.debug('  Cart Item ID: ' + result1.get('cartItemId'));
            System.debug('  Quantity: ' + result1.get('quantity'));
        } else {
            System.debug('❌ Cart item addition failed: ' + result1.get('message'));
        }
        
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
        
        if (result2 instanceof ENOS_ProductController.CartItemResult) {
            ENOS_ProductController.CartItemResult cartResult = (ENOS_ProductController.CartItemResult) result2;
            if (cartResult.success) {
                System.debug('🎉 ProductController cart addition successful!');
                System.debug('  Cart Item: ' + cartResult.cartItem);
            } else {
                System.debug('❌ ProductController cart addition failed: ' + cartResult.message);
            }
        }
        
    } catch (Exception e) {
        System.debug('❌ ProductController call failed: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
    // Test 3: Check if user has an active cart
    System.debug('🧪 Test 3: Check user active cart');
    try {
        List<Cart__c> userCarts = [
            SELECT Id, Status__c, OwnerId, CreatedDate
            FROM Cart__c 
            WHERE OwnerId = :currentUserId 
            AND Status__c = 'Active'
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
        
        System.debug('✅ User has ' + userCarts.size() + ' active carts');
        for (Cart__c cart : userCarts) {
            System.debug('  Cart ID: ' + cart.Id + ', Status: ' + cart.Status__c + ', Created: ' + cart.CreatedDate);
        }
        
        // Check cart items
        if (!userCarts.isEmpty()) {
            List<Cart_Item__c> cartItems = [
                SELECT Id, Product__c, Quantity__c, Unit_Price__c
                FROM Cart_Item__c
                WHERE Cart__c = :userCarts[0].Id
            ];
            
            System.debug('📦 Cart has ' + cartItems.size() + ' items');
            for (Cart_Item__c item : cartItems) {
                System.debug('  Item: Product=' + item.Product__c + ', Qty=' + item.Quantity__c + ', Price=' + item.Unit_Price__c);
            }
        }
        
    } catch (Exception e) {
        System.debug('❌ Cart check failed: ' + e.getMessage());
    }
    
    System.debug('🎉 Simplified cart functionality testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during cart testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
