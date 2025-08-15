// Test script to verify ENOS_ProductController methods
try {
    System.debug('=== Testing ENOS_ProductController.getProducts() ===');
    
    // Test getting products
    List<Product2> products = ENOS_ProductController.getProducts();
    System.debug('getProducts() returned ' + products.size() + ' products');
    
    if(products.size() > 0) {
        System.debug('First product: ' + products[0].Name + ' (Code: ' + products[0].ProductCode + ')');
    }
    
    System.debug('=== Testing ENOS_ProductController.getProductById() ===');
    
    // Test getting a specific product
    if(products.size() > 0) {
        Id productId = products[0].Id;
        Product2 product = ENOS_ProductController.getProductById(productId);
        System.debug('getProductById() returned product: ' + product.Name);
    }
    
    System.debug('=== Testing ENOS_ProductController.searchProducts() ===');
    
    // Test searching products
    List<Product2> searchResults = ENOS_ProductController.searchProducts('Laptop');
    System.debug('searchProducts("Laptop") returned ' + searchResults.size() + ' products');
    
    System.debug('=== Test completed successfully! ===');
    
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
