// Debug ProductCatalog Component Issues
System.debug('🔍 Debugging ProductCatalog Component...');

// Check if we can access getAllProducts method
try {
    List<Product2> products = ENOSController.getAllProducts();
    System.debug('✅ getAllProducts() method accessible: ' + products.size() + ' products returned');
    
    // Show first few products
    for(Integer i = 0; i < Math.min(3, products.size()); i++) {
        Product2 p = products[i];
        System.debug('  Product ' + (i+1) + ': ' + p.Name + ' (Family: ' + p.Family + ')');
        
        // Check if PricebookEntries exist
        if(p.PricebookEntries != null && !p.PricebookEntries.isEmpty()) {
            System.debug('    Has price: $' + p.PricebookEntries[0].UnitPrice);
        } else {
            System.debug('    No pricing data');
        }
    }
} catch (Exception e) {
    System.debug('❌ Error calling getAllProducts(): ' + e.getMessage());
}

System.debug('');

// Test standard Product2 query that should work for components
try {
    List<Product2> standardProducts = [
        SELECT Id, Name, ProductCode, Description, IsActive, Family
        FROM Product2 
        WHERE IsActive = true 
        WITH SECURITY_ENFORCED
        ORDER BY Name
        LIMIT 10
    ];
    
    System.debug('✅ Standard Product2 query returned: ' + standardProducts.size() + ' products');
    
    // Create a map of families (for category filtering)
    Set<String> families = new Set<String>();
    for(Product2 p : standardProducts) {
        if(String.isNotBlank(p.Family)) {
            families.add(p.Family);
        }
    }
    
    System.debug('📂 Available families for filtering: ' + families);
    
} catch (Exception e) {
    System.debug('❌ Error with standard query: ' + e.getMessage());
}

System.debug('');

// Test if the issue is with security/permissions
try {
    Boolean canReadProduct2 = Schema.sObjectType.Product2.isAccessible();
    Boolean canReadPricebook = Schema.sObjectType.PricebookEntry.isAccessible();
    
    System.debug('🔒 Product2 readable: ' + canReadProduct2);
    System.debug('🔒 PricebookEntry readable: ' + canReadPricebook);
    
} catch (Exception e) {
    System.debug('❌ Security check error: ' + e.getMessage());
}

System.debug('');
System.debug('🎯 SUMMARY:');
System.debug('If getAllProducts() works and returns products, the issue is likely:');
System.debug('1. LWC component deployment/caching');
System.debug('2. Component not calling the method correctly');  
System.debug('3. Component error handling not showing real errors');
System.debug('');
System.debug('✨ Next steps: Check browser console for JS errors when loading the component');
