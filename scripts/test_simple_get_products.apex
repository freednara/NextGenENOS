// Simple test to check if getProducts method works
// This will help identify what's failing

try {
    System.debug('🚀 Testing simple getProducts()...');
    
    // Test the basic getProducts method
    System.debug('📋 Calling ENOS_ProductController.getProducts()...');
    List<Product2> products = ENOS_ProductController.getProducts();
    
    if (products != null) {
        System.debug('✅ getProducts() successful!');
        System.debug('  Product count: ' + products.size());
        
        if (products.size() > 0) {
            Product2 firstProduct = products[0];
            System.debug('  First product: ' + firstProduct.Name + ' (ID: ' + firstProduct.Id + ')');
            System.debug('  Family: ' + firstProduct.Family);
            System.debug('  IsActive: ' + firstProduct.IsActive);
        }
    } else {
        System.debug('❌ getProducts() returned null');
    }
    
    System.debug('🎉 Simple product loading test completed!');
    
} catch (Exception e) {
    System.debug('❌ Error testing product loading: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
