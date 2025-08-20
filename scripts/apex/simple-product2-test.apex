// Simple test to check Product2 custom fields
System.debug('=== SIMPLE PRODUCT2 TEST ===');

try {
    // Try to access the custom fields directly
    System.debug('Testing Stock_Quantity__c field...');
    
    // Create a test product object
    Product2 testProduct = new Product2();
    testProduct.Name = 'Test Product';
    testProduct.ProductCode = 'TEST-001';
    testProduct.IsActive = true;
    
    // Try to set custom fields
    testProduct.Stock_Quantity__c = 100;
    testProduct.Is_Top_Seller__c = false;
    testProduct.Image_URL__c = 'https://example.com/test.jpg';
    
    System.debug('✅ Custom fields set successfully:');
    System.debug('  Stock_Quantity__c: ' + testProduct.Stock_Quantity__c);
    System.debug('  Is_Top_Seller__c: ' + testProduct.Is_Top_Seller__c);
    System.debug('  Image_URL__c: ' + testProduct.Image_URL__c);
    
    // Try to query the fields
    System.debug('Testing query with custom fields...');
    List<Product2> products = [
        SELECT Id, Name, Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c
        FROM Product2 
        LIMIT 1
    ];
    
    System.debug('✅ Query successful: ' + products.size() + ' products found');
    
} catch (Exception e) {
    System.debug('❌ Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== TEST COMPLETE ===');




