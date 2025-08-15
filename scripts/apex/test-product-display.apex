// Test Product Display Functionality
System.debug('Testing product display functionality...');

// Test ENOS_ProductController (used by ProductBrowser)
try {
    List<Product2> productsFromController = ENOS_ProductController.getProducts();
    System.debug('✅ ENOS_ProductController.getProducts() returned: ' + productsFromController.size() + ' products');
    
    for(Product2 p : productsFromController) {
        System.debug('  - ' + p.Name + ' (' + p.ProductCode + ')');
        if(p.PricebookEntries != null && !p.PricebookEntries.isEmpty()) {
            System.debug('    Price: $' + p.PricebookEntries[0].UnitPrice);
        }
    }
} catch (Exception e) {
    System.debug('❌ ENOS_ProductController error: ' + e.getMessage());
}

System.debug('');

// Test ENOSController (used by ProductCatalog)
try {
    List<Product2> productsFromENOS = ENOSController.getAllProducts();
    System.debug('✅ ENOSController.getAllProducts() returned: ' + productsFromENOS.size() + ' products');
    
    for(Product2 p : productsFromENOS) {
        System.debug('  - ' + p.Name + ' (' + p.ProductCode + ') Family: ' + p.Family);
    }
} catch (Exception e) {
    System.debug('❌ ENOSController error: ' + e.getMessage());
}

System.debug('');

// Test search functionality
try {
    List<Product2> searchResults = ENOS_ProductController.searchProducts('Audio');
    System.debug('✅ Search for "Audio" returned: ' + searchResults.size() + ' products');
    
    for(Product2 p : searchResults) {
        System.debug('  - ' + p.Name);
    }
} catch (Exception e) {
    System.debug('❌ Search error: ' + e.getMessage());
}

System.debug('');

// Test with Product2 custom fields
try {
    List<Product2> productsWithCustomFields = [
        SELECT Id, Name, ProductCode, Family, Is_Top_Seller__c, Stock_Quantity__c, Image_URL__c
        FROM Product2 
        WHERE IsActive = true 
        WITH SECURITY_ENFORCED
        LIMIT 5
    ];
    
    System.debug('✅ Products with custom fields: ' + productsWithCustomFields.size());
    for(Product2 p : productsWithCustomFields) {
        System.debug('  - ' + p.Name + ' | Stock: ' + p.Stock_Quantity__c + ' | Top Seller: ' + p.Is_Top_Seller__c);
    }
} catch (Exception e) {
    System.debug('❌ Custom fields error: ' + e.getMessage());
}

System.debug('');
System.debug('🎉 Product display functionality test complete!');
System.debug('Both ProductBrowser and ProductCatalog should now work correctly.');
