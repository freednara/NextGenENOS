// Check Product2 object fields
Schema.DescribeSObjectResult product2Describe = Product2.SObjectType.getDescribe();
Map<String, Schema.SObjectField> fieldMap = product2Describe.fields.getMap();

System.debug('=== Product2 Object Fields ===');
for(String fieldName : fieldMap.keySet()) {
    Schema.SObjectField field = fieldMap.get(fieldName);
    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
    System.debug('Field: ' + fieldName + ' | Type: ' + fieldDescribe.getType() + ' | Required: ' + fieldDescribe.isNillable());
}

// Try to create a simple Product2 record
try {
    Product2 testProd = new Product2(
        Name = 'Test Product',
        ProductCode = 'TEST-001',
        IsActive = true
    );
    insert testProd;
    System.debug('Successfully created test product: ' + testProd.Id);
    delete testProd;
} catch(Exception e) {
    System.debug('Error creating test product: ' + e.getMessage());
}
