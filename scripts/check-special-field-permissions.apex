// Check special field types for CREATE vs UPDATE permission differences
System.debug('=== Special Field Permission Analysis ===');

// Test with different field types
Map<String, String> testFields = new Map<String, String>{
    'Product2' => 'Name',
    'Product2' => 'Description', 
    'Product2' => 'ProductCode',
    'Cart__c' => 'Status__c',
    'Cart__c' => 'Contact__c',
    'Cart_Item__c' => 'Quantity__c',
    'Cart_Item__c' => 'Unit_Price__c'
};

for (String objName : testFields.keySet()) {
    String fieldName = testFields.get(objName);
    
    try {
        Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(objName).getDescribe();
        Schema.DescribeFieldResult fieldDesc = objDesc.fields.getMap().get(fieldName).getDescribe();
        
        System.debug('--- ' + objName + '.' + fieldName + ' ---');
        System.debug('Field Type: ' + fieldDesc.getType());
        System.debug('Is Createable: ' + fieldDesc.isCreateable());
        System.debug('Is Updateable: ' + fieldDesc.isUpdateable());
        System.debug('Is Accessible: ' + fieldDesc.isAccessible());
        System.debug('Is Required: ' + fieldDesc.isNillable());
        System.debug('Is Auto Number: ' + fieldDesc.isAutoNumber());
        System.debug('Is Calculated: ' + fieldDesc.isCalculated());
        
        if (fieldDesc.isCreateable() != fieldDesc.isUpdateable()) {
            System.debug('❌ DIFFERENT: CREATE vs UPDATE permissions differ!');
        } else {
            System.debug('✅ IDENTICAL: CREATE and UPDATE permissions are the same');
        }
        
    } catch (Exception e) {
        System.debug('Error with ' + objName + '.' + fieldName + ': ' + e.getMessage());
    }
}

// Test with system fields that might have restrictions
System.debug('=== System Field Analysis ===');

try {
    Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get('Product2').getDescribe();
    
    // Check Id field (should be different)
    Schema.DescribeFieldResult idField = objDesc.fields.getMap().get('Id').getDescribe();
    System.debug('Id field:');
    System.debug('  Is Createable: ' + idField.isCreateable());
    System.debug('  Is Updateable: ' + idField.isUpdateable());
    
    // Check CreatedDate field
    Schema.DescribeFieldResult createdField = objDesc.fields.getMap().get('CreatedDate').getDescribe();
    System.debug('CreatedDate field:');
    System.debug('  Is Createable: ' + createdField.isCreateable());
    System.debug('  Is Updateable: ' + createdField.isUpdateable());
    
    // Check LastModifiedDate field
    Schema.DescribeFieldResult modifiedField = objDesc.fields.getMap().get('LastModifiedDate').getDescribe();
    System.debug('LastModifiedDate field:');
    System.debug('  Is Createable: ' + modifiedField.isCreateable());
    System.debug('  Is Updateable: ' + modifiedField.isUpdateable());
    
} catch (Exception e) {
    System.debug('Error with system fields: ' + e.getMessage());
}

System.debug('=== Analysis Complete ===');
