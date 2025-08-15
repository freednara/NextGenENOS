// Check Cart__c object schema
Schema.DescribeSObjectResult cartDescribe = Cart__c.SObjectType.getDescribe();
System.debug('Cart__c fields: ' + cartDescribe.fields.getMap().keySet());

// Check if specific fields exist
Map<String, Schema.SObjectField> fieldMap = cartDescribe.fields.getMap();
System.debug('Contact field exists: ' + fieldMap.containsKey('Contact__c'));
System.debug('Status field exists: ' + fieldMap.containsKey('Status__c'));
System.debug('Account field exists: ' + fieldMap.containsKey('Account__c'));

// List all field names
for(String fieldName : fieldMap.keySet()) {
    System.debug('Field: ' + fieldName);
}
