// ========================================
// TEST PRODUCT2 CUSTOM FIELDS QUERY
// NextGenENOS ENOS Application
// ========================================
// This script tests querying the Product2 custom fields directly

System.debug('=== TESTING PRODUCT2 CUSTOM FIELDS QUERY ===');

try {
    // Try to query the custom fields directly
    System.debug('🔍 Testing direct query with custom fields...');
    
    List<Product2> products = [
        SELECT Id, Name, ProductCode, Description, IsActive, Family,
               Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c
        FROM Product2 
        LIMIT 5
    ];
    
    System.debug('✅ Query successful: ' + products.size() + ' products found');
    
    if (!products.isEmpty()) {
        for (Product2 product : products) {
            System.debug('  - ' + product.Name + ' (Code: ' + product.ProductCode + ')');
            System.debug('    Stock: ' + product.Stock_Quantity__c);
            System.debug('    Top Seller: ' + product.Is_Top_Seller__c);
            System.debug('    Image: ' + product.Image_URL__c);
        }
    } else {
        System.debug('ℹ️ No products found - this is expected in a new org');
    }
    
    // Try to create a test product to verify field access
    System.debug('🔍 Testing field access by creating a test product...');
    
    Product2 testProduct = new Product2(
        Name = 'Test Product - ENOS',
        ProductCode = 'TEST-001',
        Description = 'Test product for ENOS validation',
        IsActive = true,
        Family = 'Electronics',
        Stock_Quantity__c = 100,
        Is_Top_Seller__c = false,
        Image_URL__c = 'https://example.com/test-image.jpg'
    );
    
    System.debug('✅ Test product object created successfully');
    System.debug('  Name: ' + testProduct.Name);
    System.debug('  Stock: ' + testProduct.Stock_Quantity__c);
    System.debug('  Top Seller: ' + testProduct.Is_Top_Seller__c);
    System.debug('  Image: ' + testProduct.Image_URL__c);
    
    // Try to insert it
    try {
        insert testProduct;
        System.debug('✅ Test product inserted successfully with ID: ' + testProduct.Id);
        
        // Query it back to verify
        Product2 insertedProduct = [
            SELECT Id, Name, ProductCode, Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c
            FROM Product2 
            WHERE Id = :testProduct.Id
        ];
        
        System.debug('✅ Product retrieved successfully:');
        System.debug('  Name: ' + insertedProduct.Name);
        System.debug('  Stock: ' + insertedProduct.Stock_Quantity__c);
        System.debug('  Top Seller: ' + insertedProduct.Is_Top_Seller__c);
        System.debug('  Image: ' + insertedProduct.Image_URL__c);
        
        // Clean up
        delete insertedProduct;
        System.debug('✅ Test product cleaned up');
        
    } catch (Exception e) {
        System.debug('❌ Error inserting test product: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
} catch (Exception e) {
    System.debug('❌ Error in Product2 custom fields test: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== PRODUCT2 CUSTOM FIELDS TEST COMPLETE ===');




