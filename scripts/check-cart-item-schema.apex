// Check Cart_Item__c object schema
Schema.DescribeSObjectResult cartItemDescribe = Cart_Item__c.SObjectType.getDescribe();
System.debug('Cart_Item__c fields: ' + cartItemDescribe.fields.getMap().keySet());

// Check if specific fields exist
Map<String, Schema.SObjectField> fieldMap = cartItemDescribe.fields.getMap();
System.debug('Cart field exists: ' + fieldMap.containsKey('Cart__c'));
System.debug('Product field exists: ' + fieldMap.containsKey('Product__c'));
System.debug('Quantity field exists: ' + fieldMap.containsKey('Quantity__c'));
System.debug('Unit_Price field exists: ' + fieldMap.containsKey('Unit_Price__c'));

// List all field names
for(String fieldName : fieldMap.keySet()) {
    System.debug('Field: ' + fieldName);
}
