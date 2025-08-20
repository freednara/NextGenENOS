// Check the custom fields on sample products
// This will help identify why the top sellers filter isn't working

try {
    System.debug('🔍 Checking sample product custom fields...');
    
    // Query all products with their custom fields
    List<Product2> products = [
        SELECT Id, Name, Family, IsActive, 
               Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c
        FROM Product2 
        WHERE IsActive = true 
        ORDER BY Name
    ];
    
    System.debug('📊 Found ' + products.size() + ' products:');
    
    for (Product2 product : products) {
        System.debug('  Product: ' + product.Name);
        System.debug('    Family: ' + product.Family);
        System.debug('    Stock_Quantity__c: ' + product.Stock_Quantity__c);
        System.debug('    Is_Top_Seller__c: ' + product.Is_Top_Seller__c);
        System.debug('    Image_URL__c: ' + product.Image_URL__c);
        System.debug('    ---');
    }
    
    // Check if any products are marked as top sellers
    List<Product2> topSellers = [
        SELECT Id, Name, Is_Top_Seller__c 
        FROM Product2 
        WHERE IsActive = true AND Is_Top_Seller__c = true
    ];
    
    System.debug('🏆 Top sellers found: ' + topSellers.size());
    for (Product2 topSeller : topSellers) {
        System.debug('  Top Seller: ' + topSeller.Name + ' (Is_Top_Seller__c: ' + topSeller.Is_Top_Seller__c + ')');
    }
    
    System.debug('🎉 Product field check completed!');
    
} catch (Exception e) {
    System.debug('❌ Error checking product fields: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
