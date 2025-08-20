// Test Product2 custom fields directly
System.debug('=== TESTING PRODUCT2 CUSTOM FIELDS DIRECTLY ===');

try {
    // Try to create a product with the custom fields directly
    System.debug('🔧 Creating Product2 with custom fields...');
    
    Product2 testProduct = new Product2(
        Name = 'Test Product - Direct Field Test',
        ProductCode = 'TEST-DIRECT-001',
        Description = 'Testing direct field access',
        IsActive = true,
        Family = 'Electronics',
        Stock_Quantity__c = 100,
        Is_Top_Seller__c = false,
        Image_URL__c = 'https://example.com/test-direct.jpg'
    );
    
    System.debug('✅ Product2 object created with custom fields:');
    System.debug('  Name: ' + testProduct.Name);
    System.debug('  Stock_Quantity__c: ' + testProduct.Stock_Quantity__c);
    System.debug('  Is_Top_Seller__c: ' + testProduct.Is_Top_Seller__c);
    System.debug('  Image_URL__c: ' + testProduct.Image_URL__c);
    
    // Try to insert it
    try {
        insert testProduct;
        System.debug('✅ Product2 inserted successfully with ID: ' + testProduct.Id);
        
        // Query it back to verify
        Product2 insertedProduct = [
            SELECT Id, Name, Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c
            FROM Product2 
            WHERE Id = :testProduct.Id
        ];
        
        System.debug('✅ Product2 retrieved successfully:');
        System.debug('  Name: ' + insertedProduct.Name);
        System.debug('  Stock_Quantity__c: ' + insertedProduct.Stock_Quantity__c);
        System.debug('  Is_Top_Seller__c: ' + insertedProduct.Is_Top_Seller__c);
        System.debug('  Image_URL__c: ' + insertedProduct.Image_URL__c);
        
        // Clean up
        delete insertedProduct;
        System.debug('✅ Test product cleaned up');
        
    } catch (Exception e) {
        System.debug('❌ Error inserting Product2: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
} catch (Exception e) {
    System.debug('❌ Error creating Product2 with custom fields: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    
    // Try to get more details about what's available
    try {
        Schema.DescribeSObjectResult productDesc = Schema.SObjectType.Product2;
        Map<String, Schema.SObjectField> fieldMap = productDesc.fields.getMap();
        
        System.debug('📊 Available Product2 fields:');
        for (String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            
            if (fieldDesc.isCustom()) {
                System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ') - Custom: ' + fieldDesc.isCustom());
            }
        }
    } catch (Exception descEx) {
        System.debug('❌ Error describing Product2: ' + descEx.getMessage());
    }
}

System.debug('=== DIRECT FIELD TEST COMPLETE ===');




