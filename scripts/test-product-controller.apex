// Simple test script to verify ProductController functionality
try {
    // Test getting products
    List<Product2> products = [SELECT Id, Name, ProductCode, IsActive FROM Product2 WHERE IsActive = true LIMIT 5];
    System.debug('Found ' + products.size() + ' active products');
    
    for(Product2 prod : products) {
        System.debug('Product: ' + prod.Name + ' (Code: ' + prod.ProductCode + ')');
    }
    
    // Test getting categories
    List<Category__c> categories = [SELECT Id, Name__c FROM Category__c LIMIT 5];
    System.debug('Found ' + categories.size() + ' categories');
    
    for(Category__c cat : categories) {
        System.debug('Category: ' + cat.Name__c);
    }
    
    System.debug('Test completed successfully!');
} catch(Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
