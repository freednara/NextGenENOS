// Check Cart__c fields
System.debug('=== CHECKING CART__C FIELDS ===');

try {
    Schema.DescribeSObjectResult cartDesc = Schema.SObjectType.Cart__c;
    Map<String, Schema.SObjectField> fieldMap = cartDesc.fields.getMap();
    
    System.debug('📊 Available Cart__c fields:');
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDesc = field.getDescribe();
        
        System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ') - Required: ' + fieldDesc.isNillable());
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking Cart__c: ' + e.getMessage());
}

System.debug('=== CART FIELD CHECK COMPLETE ===');




