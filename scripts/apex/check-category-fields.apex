// Check Category__c fields
System.debug('=== CHECKING CATEGORY__C FIELDS ===');

try {
    Schema.DescribeSObjectResult categoryDesc = Schema.SObjectType.Category__c;
    Map<String, Schema.SObjectField> fieldMap = categoryDesc.fields.getMap();
    
    System.debug('📊 Available Category__c fields:');
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDesc = field.getDescribe();
        
        System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ') - Required: ' + fieldDesc.isNillable());
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking Category__c: ' + e.getMessage());
}

System.debug('=== CATEGORY FIELD CHECK COMPLETE ===');




