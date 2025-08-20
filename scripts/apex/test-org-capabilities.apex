// Test org capabilities and available objects/fields
System.debug('=== TESTING ORG CAPABILITIES ===');

try {
    // Check what objects are available
    Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    System.debug('📊 Total objects in org: ' + globalDescribe.size());
    
    // Check if Product2 exists and what fields it has
    if (globalDescribe.containsKey('Product2')) {
        Schema.SObjectType productType = globalDescribe.get('Product2');
        Schema.DescribeSObjectResult productDesc = productType.getDescribe();
        
        System.debug('✅ Product2 object exists');
        System.debug('  Label: ' + productDesc.getLabel());
        System.debug('  Is Custom: ' + productDesc.isCustom());
        System.debug('  Is Accessible: ' + productDesc.isAccessible());
        System.debug('  Is Createable: ' + productDesc.isCreateable());
        System.debug('  Is Updateable: ' + productDesc.isUpdateable());
        
        // Get all fields
        Map<String, Schema.SObjectField> fieldMap = productDesc.fields.getMap();
        System.debug('📊 Total fields on Product2: ' + fieldMap.size());
        
        // List all fields
        System.debug('🔍 All fields on Product2:');
        for (String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            
            System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ') - Custom: ' + fieldDesc.isCustom() + ' - Accessible: ' + fieldDesc.isAccessible());
        }
        
        // Try to create a simple product
        System.debug('🔍 Testing Product2 creation...');
        try {
            Product2 testProduct = new Product2(
                Name = 'Test Product - ENOS',
                ProductCode = 'TEST-001',
                Description = 'Test product for ENOS validation',
                IsActive = true,
                Family = 'Electronics'
            );
            
            System.debug('✅ Test product object created successfully');
            System.debug('  Name: ' + testProduct.Name);
            System.debug('  ProductCode: ' + testProduct.ProductCode);
            System.debug('  IsActive: ' + testProduct.IsActive);
            System.debug('  Family: ' + testProduct.Family);
            
        } catch (Exception e) {
            System.debug('❌ Error creating Product2 object: ' + e.getMessage());
        }
        
    } else {
        System.debug('❌ Product2 object not found');
    }
    
    // Check what custom objects we have
    System.debug('🔍 Custom objects found:');
    Integer customObjectCount = 0;
    for (String objectName : globalDescribe.keySet()) {
        Schema.SObjectType objectType = globalDescribe.get(objectName);
        Schema.DescribeSObjectResult objectDesc = objectType.getDescribe();
        
        if (objectDesc.isCustom()) {
            customObjectCount++;
            if (customObjectCount <= 10) { // Limit output
                System.debug('  - ' + objectName + ' (Label: ' + objectDesc.getLabel() + ')');
            }
        }
    }
    System.debug('📊 Total custom objects: ' + customObjectCount);
    
} catch (Exception e) {
    System.debug('❌ Error testing org capabilities: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== ORG CAPABILITIES TEST COMPLETE ===');




