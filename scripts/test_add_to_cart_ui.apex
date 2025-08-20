// Test Add to Cart UI functionality
try {
    System.debug('🧪 Testing Add to Cart UI functionality...');
    
    // Test 1: addToCart method response structure
    System.debug('🧪 Test 1: addToCart method response structure');
    try {
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
            
                    // Test addProductToShoppingCart method
        String productId = String.valueOf(testProduct.Id);
        Object result = ENOS_ProductController.addProductToShoppingCart(productId, 1);
            
            System.debug('✅ addToCart result: ' + result);
            
            // Check the result structure
            if (result != null) {
                System.debug('📊 Result: ' + result);
                
                // Check if it's a CartItemResult
                if (result instanceof ENOS_ProductController.CartItemResult) {
                    ENOS_ProductController.CartItemResult cartResult = (ENOS_ProductController.CartItemResult) result;
                    
                    System.debug('🎯 CartItemResult structure:');
                    System.debug('  success: ' + cartResult.success);
                    System.debug('  message: ' + cartResult.message);
                    System.debug('  cartItem: ' + cartResult.cartItem);
                    
                    if (cartResult.success) {
                        System.debug('🎉 SUCCESS: Item added to cart!');
                        System.debug('  Message: ' + cartResult.message);
                        if (cartResult.cartItem != null) {
                            System.debug('  Cart Item ID: ' + cartResult.cartItem.Id);
                            System.debug('  Quantity: ' + cartResult.cartItem.Quantity__c);
                        }
                    } else {
                        System.debug('❌ FAILED: ' + cartResult.message);
                    }
                } else {
                    System.debug('⚠️ Result is not a CartItemResult: ' + result);
                }
            }
            
        } else {
            System.debug('❌ No test products available');
        }
        
    } catch (Exception e) {
        System.debug('❌ addToCart test failed: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
    // Test 2: Check current cart status
    System.debug('🧪 Test 2: Check current cart status');
    try {
        String currentUserId = UserInfo.getUserId();
        List<Cart__c> userCarts = [
            SELECT Id, Status__c, OwnerId, Subtotal__c
            FROM Cart__c 
            WHERE OwnerId = :currentUserId 
            AND Status__c = 'Active'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (!userCarts.isEmpty()) {
            Cart__c userCart = userCarts[0];
            System.debug('✅ User has active cart: ' + userCart.Id);
            
            // Check cart items
            List<Cart_Item__c> cartItems = [
                SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
                FROM Cart_Item__c
                WHERE Cart__c = :userCart.Id
            ];
            
            System.debug('✅ Cart contains ' + cartItems.size() + ' items');
            for (Cart_Item__c item : cartItems) {
                System.debug('  Item: Product=' + item.Product__c + ', Qty=' + item.Quantity__c);
            }
            
        } else {
            System.debug('❌ User has no active cart');
        }
        
    } catch (Exception e) {
        System.debug('❌ Cart status check failed: ' + e.getMessage());
    }
    
    System.debug('🎉 Add to Cart UI testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during Add to Cart UI testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
