// Test ProductController methods
try {
    System.debug('🧪 Testing ProductController methods...');
    
    // Test 1: getProducts with correct parameters
    System.debug('🧪 Test 1: getProducts method');
    try {
        List<Product2> products = ENOS_ProductController.getProducts(
            10,    // pageSize
            1,     // pageNumber
            null,  // searchTerm
            null,  // familyFilter
            'Name', // sortBy
            'ASC'   // sortDirection
        );
        
        System.debug('✅ getProducts successful: ' + products.size() + ' products returned');
        if (!products.isEmpty()) {
            System.debug('  First product: ' + products[0].Name + ' (ID: ' + products[0].Id + ')');
        }
        
    } catch (Exception e) {
        System.debug('❌ getProducts failed: ' + e.getMessage());
    }
    
    // Test 2: getProductCount
    System.debug('🧪 Test 2: getProductCount method');
    try {
        Integer productCount = ENOS_ProductController.getProductCount(null, null);
        System.debug('✅ getProductCount successful: ' + productCount + ' total products');
        
    } catch (Exception e) {
        System.debug('❌ getProductCount failed: ' + e.getMessage());
    }
    
    // Test 3: addToCart
    System.debug('🧪 Test 3: addToCart method');
    try {
        // Get a test product first
        List<Product2> testProducts = [
            SELECT Id, Name, ProductCode 
            FROM Product2 
            WHERE IsActive = true 
            LIMIT 1
        ];
        
        if (!testProducts.isEmpty()) {
            String productId = String.valueOf(testProducts[0].Id);
            System.debug('🔄 Testing addToCart with product: ' + testProducts[0].Name);
            
            Object result = ENOS_ProductController.addToCart(productId, 1);
            System.debug('✅ addToCart successful: ' + result);
            
        } else {
            System.debug('❌ No test products available for addToCart test');
        }
        
    } catch (Exception e) {
        System.debug('❌ addToCart failed: ' + e.getMessage());
    }
    
    System.debug('🎉 ProductController testing completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during ProductController testing: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
