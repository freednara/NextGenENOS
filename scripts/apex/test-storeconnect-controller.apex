// Test the StoreConnectController.getProducts method
// Run this in Developer Console or via SF CLI

try {
    System.debug('=== Testing StoreConnectController.getProducts() ===');
    
    // Test basic product retrieval
    StoreConnectController.ProductCatalogResult result = StoreConnectController.getProducts('', '', 0, 10, false);
    
    System.debug('Method executed successfully');
    System.debug('Number of products returned: ' + (result != null ? String.valueOf(result.products.size()) : 'null'));
    System.debug('Total count: ' + (result != null ? String.valueOf(result.totalCount) : 'null'));
    
    if (result != null && result.products != null && result.products.size() > 0) {
        System.debug('First product: ' + result.products[0].Name);
        System.debug('All products:');
        for (Product2 prod : result.products) {
            System.debug('- ' + prod.Name + ' (' + prod.ProductCode + ')');
        }
    } else {
        System.debug('No products returned or null result');
    }
    
    // Test search functionality
    System.debug('=== Testing search functionality ===');
    StoreConnectController.ProductCatalogResult searchResult = StoreConnectController.getProducts('Camera', '', 0, 10, false);
    System.debug('Search results count: ' + (searchResult != null ? String.valueOf(searchResult.products.size()) : 'null'));
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
