// Comprehensive check of all Product2 object fields
// This will show us exactly what fields exist and their types

try {
    System.debug('🔍 Comprehensive Product2 object field check...');
    
    // Get the describe result for Product2
    Schema.DescribeSObjectResult product2Describe = Product2.SObjectType.getDescribe();
    
    System.debug('📊 Product2 object details:');
    System.debug('  Label: ' + product2Describe.getLabel());
    System.debug('  API Name: ' + product2Describe.getName());
    System.debug('  Is Custom: ' + product2Describe.isCustom());
    System.debug('  Is Accessible: ' + product2Describe.isAccessible());
    System.debug('  Is Createable: ' + product2Describe.isCreateable());
    System.debug('  Is Updateable: ' + product2Describe.isUpdateable());
    
    // Get all fields
    Map<String, Schema.SObjectField> fieldMap = product2Describe.fields.getMap();
    System.debug('📋 Total fields found: ' + fieldMap.size());
    
    // Check for specific fields we need
    System.debug('🎯 Checking specific fields we need:');
    
    // Standard fields
    System.debug('  Name: ' + (fieldMap.containsKey('Name') ? '✅ EXISTS' : '❌ MISSING'));
    System.debug('  Description: ' + (fieldMap.containsKey('Description') ? '✅ EXISTS' : '❌ MISSING'));
    System.debug('  Family: ' + (fieldMap.containsKey('Family') ? '✅ EXISTS' : '❌ MISSING'));
    System.debug('  IsActive: ' + (fieldMap.containsKey('IsActive') ? '✅ EXISTS' : '❌ MISSING'));
    System.debug('  ProductCode: ' + (fieldMap.containsKey('ProductCode') ? '✅ EXISTS' : '❌ MISSING'));
    
    // Custom fields we're looking for
    System.debug('  Stock_Quantity__c: ' + (fieldMap.containsKey('Stock_Quantity__c') ? '✅ EXISTS' : '❌ MISSING'));
    System.debug('  Is_Top_Seller__c: ' + (fieldMap.containsKey('Is_Top_Seller__c') ? '✅ EXISTS' : '❌ MISSING'));
    System.debug('  Image_URL__c: ' + (fieldMap.containsKey('Image_URL__c') ? '✅ EXISTS' : '❌ MISSING'));
    
    // List all custom fields
    System.debug('🏷️ All custom fields (ending with __c):');
    List<String> customFields = new List<String>();
    
    for (String fieldName : fieldMap.keySet()) {
        if (fieldName.endsWith('__c')) {
            customFields.add(fieldName);
        }
    }
    
    if (customFields.isEmpty()) {
        System.debug('  No custom fields found');
    } else {
        for (String customField : customFields) {
            Schema.SObjectField field = fieldMap.get(customField);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            System.debug('  ' + customField + ' (Type: ' + fieldDescribe.getType() + ', Required: ' + !fieldDescribe.isNillable() + ')');
        }
    }
    
    // List some standard fields for reference
    System.debug('📋 Some standard fields available:');
    List<String> standardFields = new List<String>();
    
    for (String fieldName : fieldMap.keySet()) {
        if (!fieldName.endsWith('__c') && fieldName != 'Id' && fieldName != 'CreatedDate' && fieldName != 'LastModifiedDate') {
            standardFields.add(fieldName);
        }
    }
    
    // Show first 20 standard fields
    Integer count = 0;
    for (String standardField : standardFields) {
        if (count < 20) {
            System.debug('  ' + standardField);
            count++;
        } else {
            System.debug('  ... and ' + (standardFields.size() - 20) + ' more');
            break;
        }
    }
    
    System.debug('🎉 Comprehensive field check completed!');
    
} catch (Exception e) {
    System.debug('❌ Error during field check: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
