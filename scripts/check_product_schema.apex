// Check what fields are actually available on Product2
// This will help identify which custom fields exist

try {
    System.debug('🔍 Checking Product2 object schema...');
    
    // Get the describe result for Product2
    Schema.DescribeSObjectResult product2Describe = Product2.SObjectType.getDescribe();
    
    System.debug('📊 Product2 object fields:');
    
    // Get all fields
    Map<String, Schema.SObjectField> fieldMap = product2Describe.fields.getMap();
    
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        
        // Only show custom fields (those ending with __c)
        if (fieldName.endsWith('__c')) {
            System.debug('  Custom Field: ' + fieldName + ' (Type: ' + fieldDescribe.getType() + ', Required: ' + fieldDescribe.isNillable() + ')');
        }
    }
    
    // Also check standard fields we're using
    System.debug('📋 Standard fields we\'re using:');
    System.debug('  Name: ' + fieldMap.containsKey('Name'));
    System.debug('  Description: ' + fieldMap.containsKey('Description'));
    System.debug('  Family: ' + fieldMap.containsKey('Family'));
    System.debug('  IsActive: ' + fieldMap.containsKey('IsActive'));
    System.debug('  ProductCode: ' + fieldMap.containsKey('ProductCode'));
    
    System.debug('🎉 Product2 schema check completed!');
    
} catch (Exception e) {
    System.debug('❌ Error checking Product2 schema: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
