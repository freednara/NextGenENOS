// Test the getProducts method from ENOS_ProductController
// Run this in Developer Console or via SF CLI

try {
    System.debug('=== Testing ENOS_ProductController.getProducts() ===');
    
    // Test the method
    List<Product2> products = ENOS_ProductController.getProducts();
    
    System.debug('Method executed successfully');
    System.debug('Number of products returned: ' + (products != null ? String.valueOf(products.size()) : 'null'));
    
    if (products != null && products.size() > 0) {
        System.debug('First product: ' + products[0].Name);
        System.debug('All products:');
        for (Product2 prod : products) {
            System.debug('- ' + prod.Name + ' (' + prod.ProductCode + ')');
        }
    } else {
        System.debug('No products returned or null result');
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
