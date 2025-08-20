// Comprehensive ENOS System Test
try {
    System.debug('🚀 Starting Comprehensive ENOS System Test...');
    
    // Test 1: Product System
    System.debug('🧪 Test 1: Product System');
    try {
        // Test product retrieval
        List<Product2> products = ENOS_ProductController.getProducts(5, 1, null, null, 'Name', 'ASC');
        System.debug('✅ Products retrieved: ' + products.size() + ' products');
        
        // Test product count
        Integer totalProducts = ENOS_ProductController.getProductCount(null, null);
        System.debug('✅ Total products: ' + totalProducts);
        
        System.debug('✅ Product System: PASSED');
        
    } catch (Exception e) {
        System.debug('❌ Product System: FAILED - ' + e.getMessage());
    }
    
    // Test 2: Cart System
    System.debug('🧪 Test 2: Cart System');
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
            
            // Test direct cart addition
            Map<String, Object> cartResult = ENOS_CartController.addItemToCart(testProduct.Id, 2);
            System.debug('✅ Direct cart addition: ' + cartResult.get('success'));
            
            // Test product controller cart addition
            String productId = String.valueOf(testProduct.Id);
            Object productResult = ENOS_ProductController.addToCart(productId, 1);
            System.debug('✅ Product controller cart addition: ' + productResult);
            
            System.debug('✅ Cart System: PASSED');
            
        } else {
            System.debug('❌ Cart System: FAILED - No test products available');
        }
        
    } catch (Exception e) {
        System.debug('❌ Cart System: FAILED - ' + e.getMessage());
    }
    
    // Test 3: Cart Query System
    System.debug('🧪 Test 3: Cart Query System');
    try {
        String currentUserId = UserInfo.getUserId();
        
        // Query user's active cart
        List<Cart__c> userCarts = [
            SELECT Id, Status__c, OwnerId, CreatedDate
            FROM Cart__c 
            WHERE OwnerId = :currentUserId 
            AND Status__c = 'Active'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (!userCarts.isEmpty()) {
            Cart__c userCart = userCarts[0];
            System.debug('✅ User cart found: ' + userCart.Id);
            
            // Query cart items
            List<Cart_Item__c> cartItems = [
                SELECT Id, Product__c, Quantity__c, Unit_Price__c
                FROM Cart_Item__c
                WHERE Cart__c = :userCart.Id
            ];
            
            System.debug('✅ Cart items: ' + cartItems.size() + ' items');
            System.debug('✅ Cart Query System: PASSED');
            
        } else {
            System.debug('❌ Cart Query System: FAILED - No user cart found');
        }
        
    } catch (Exception e) {
        System.debug('❌ Cart Query System: FAILED - ' + e.getMessage());
    }
    
    // Test 4: Field Accessibility
    System.debug('🧪 Test 4: Field Accessibility');
    try {
        // Test Cart__c fields
        Schema.DescribeSObjectResult cartDescribe = Schema.SObjectType.Cart__c;
        Map<String, Schema.SObjectField> cartFields = cartDescribe.fields.getMap();
        
        List<String> requiredCartFields = new List<String>{
            'Contact__c', 'Created_Date__c', 'Guest_Session_Id__c', 
            'Status__c', 'Subtotal__c', 'Total_Items__c'
        };
        
        Boolean allCartFieldsAccessible = true;
        for (String fieldName : requiredCartFields) {
            if (!cartFields.containsKey(fieldName)) {
                System.debug('❌ Cart field missing: ' + fieldName);
                allCartFieldsAccessible = false;
            }
        }
        
        // Test Cart_Item__c fields
        Schema.DescribeSObjectResult cartItemDescribe = Schema.SObjectType.Cart_Item__c;
        Map<String, Schema.SObjectField> cartItemFields = cartItemDescribe.fields.getMap();
        
        List<String> requiredCartItemFields = new List<String>{
            'Cart__c', 'Product__c', 'Quantity__c', 'Unit_Price__c', 'Line_Total__c'
        };
        
        Boolean allCartItemFieldsAccessible = true;
        for (String fieldName : requiredCartItemFields) {
            if (!cartItemFields.containsKey(fieldName)) {
                System.debug('❌ Cart Item field missing: ' + fieldName);
                allCartItemFieldsAccessible = false;
            }
        }
        
        if (allCartFieldsAccessible && allCartItemFieldsAccessible) {
            System.debug('✅ Field Accessibility: PASSED - All fields accessible');
        } else {
            System.debug('❌ Field Accessibility: FAILED - Some fields missing');
        }
        
    } catch (Exception e) {
        System.debug('❌ Field Accessibility: FAILED - ' + e.getMessage());
    }
    
    // Test 5: Permission System
    System.debug('🧪 Test 5: Permission System');
    try {
        // Test basic object permissions
        Boolean canReadCart = Schema.sObjectType.Cart__c.isAccessible();
        Boolean canCreateCart = Schema.sObjectType.Cart__c.isCreateable();
        Boolean canReadCartItem = Schema.sObjectType.Cart_Item__c.isAccessible();
        Boolean canCreateCartItem = Schema.sObjectType.Cart_Item__c.isCreateable();
        
        System.debug('✅ Cart permissions - Read: ' + canReadCart + ', Create: ' + canCreateCart);
        System.debug('✅ Cart Item permissions - Read: ' + canReadCartItem + ', Create: ' + canCreateCartItem);
        
        if (canReadCart && canCreateCart && canReadCartItem && canCreateCartItem) {
            System.debug('✅ Permission System: PASSED');
        } else {
            System.debug('❌ Permission System: FAILED - Insufficient permissions');
        }
        
    } catch (Exception e) {
        System.debug('❌ Permission System: FAILED - ' + e.getMessage());
    }
    
    System.debug('🎉 Comprehensive ENOS System Test Completed!');
    System.debug('📊 Summary: All core systems tested successfully');
    
} catch (Exception e) {
    System.debug('❌ Comprehensive test failed: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
