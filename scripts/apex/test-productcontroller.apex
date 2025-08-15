// Test ENOS_ProductController for ProductBrowser
System.debug('Testing ENOS_ProductController for ProductBrowser component...');

try {
    List<Product2> products = ENOS_ProductController.getProducts();
    System.debug('✅ ENOS_ProductController.getProducts() returned: ' + products.size() + ' products');
    
    for(Product2 p : products) {
        System.debug('- ' + p.Name + ' (Family: ' + p.Family + ')');
        if(p.PricebookEntries != null && !p.PricebookEntries.isEmpty()) {
            System.debug('  Price: $' + p.PricebookEntries[0].UnitPrice);
        }
    }
    
    System.debug('');
    System.debug('🎉 ENOS_ProductController is working perfectly!');
    System.debug('ProductBrowser component should be able to call this method successfully.');
    
} catch (Exception e) {
    System.debug('❌ Error with ENOS_ProductController: ' + e.getMessage());
}
