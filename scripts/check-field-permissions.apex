// Check if there are semantic differences between CREATE and UPDATE field permissions
System.debug('=== Field Permission Analysis ===');

// Test with a standard object
String testObject = 'Product2';
String testField = 'Name';

try {
    Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(testObject).getDescribe();
    Schema.DescribeFieldResult fieldDesc = objDesc.fields.getMap().get(testField).getDescribe();
    
    System.debug('Object: ' + testObject);
    System.debug('Field: ' + testField);
    System.debug('Is Createable: ' + fieldDesc.isCreateable());
    System.debug('Is Updateable: ' + fieldDesc.isUpdateable());
    System.debug('Is Accessible: ' + fieldDesc.isAccessible());
    
    // Check if CREATE and UPDATE are always the same
    if (fieldDesc.isCreateable() == fieldDesc.isUpdateable()) {
        System.debug('✅ CREATE and UPDATE permissions are IDENTICAL for ' + testField);
    } else {
        System.debug('❌ CREATE and UPDATE permissions are DIFFERENT for ' + testField);
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}

// Test with a custom object
testObject = 'Cart__c';
testField = 'Status__c';

try {
    Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(testObject).getDescribe();
    Schema.DescribeFieldResult fieldDesc = objDesc.fields.getMap().get(testField).getDescribe();
    
    System.debug('Object: ' + testObject);
    System.debug('Field: ' + testField);
    System.debug('Is Createable: ' + fieldDesc.isCreateable());
    System.debug('Is Updateable: ' + fieldDesc.isUpdateable());
    System.debug('Is Accessible: ' + fieldDesc.isAccessible());
    
    // Check if CREATE and UPDATE are always the same
    if (fieldDesc.isCreateable() == fieldDesc.isUpdateable()) {
        System.debug('✅ CREATE and UPDATE permissions are IDENTICAL for ' + testField);
    } else {
        System.debug('❌ CREATE and UPDATE permissions are DIFFERENT for ' + testField);
    }
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
}

System.debug('=== Analysis Complete ===');
