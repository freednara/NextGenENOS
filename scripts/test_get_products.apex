// Test the getProducts method to see what's failing
// This will help debug why the LWC can't load products

try {
    System.debug('🚀 Testing ENOS_ProductController.getProducts()...');
    
    // Test the basic getProducts method
    System.debug('📋 Testing getProducts()...');
    List<Product2> products = ENOS_ProductController.getProducts();
    
    if (products != null) {
        System.debug('✅ getProducts() successful!');
        System.debug('  Product count: ' + products.size());
        
        if (products.size() > 0) {
            Product2 firstProduct = products[0];
            System.debug('  First product: ' + firstProduct.Name + ' (ID: ' + firstProduct.Id + ')');
            System.debug('  Product fields: ' + firstProduct);
        }
    } else {
        System.debug('❌ getProducts() returned null');
    }
    
    // Test the getProductsWithPricing method
    System.debug('💰 Testing getProductsWithPricing()...');
    List<ENOS_ProductController.ProductWithPricing> productsWithPricing = 
        ENOS_ProductController.getProductsWithPricing();
    
    if (productsWithPricing != null) {
        System.debug('✅ getProductsWithPricing() successful!');
        System.debug('  Product count: ' + productsWithPricing.size());
        
        if (productsWithPricing.size() > 0) {
            ENOS_ProductController.ProductWithPricing firstProduct = productsWithPricing[0];
            System.debug('  First product: ' + firstProduct.productName + ' (ID: ' + firstProduct.productId + ')');
            System.debug('  Price: ' + firstProduct.price);
        }
    } else {
        System.debug('❌ getProductsWithPricing() returned null');
    }
    
    // Test the getProductsDynamic method
    System.debug('🔧 Testing getProductsDynamic()...');
    List<Object> dynamicProducts = ENOS_ProductController.getProductsDynamic(
        new List<String>{'Name', 'Description', 'Family', 'IsActive'}, 
        'IsActive = true', 
        'Name ASC', 
        100
    );
    
    if (dynamicProducts != null) {
        System.debug('✅ getProductsDynamic() successful!');
        System.debug('  Product count: ' + dynamicProducts.size());
    } else {
        System.debug('❌ getProductsDynamic() returned null');
    }
    
    System.debug('🎉 Product loading test completed!');
    
} catch (Exception e) {
    System.debug('❌ Error testing product loading: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
