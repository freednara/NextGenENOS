// Check Cart__c object schema to see the correct field names
try {
    System.debug('🔍 Checking Cart__c object schema...');
    
    // Get the describe result for Cart__c
    Schema.DescribeSObjectResult cartDescribe = Schema.SObjectType.Cart__c;
    System.debug('✅ Cart__c object is accessible: ' + cartDescribe.isAccessible());
    System.debug('✅ Cart__c object is createable: ' + cartDescribe.isCreateable());
    
    // Get all fields
    Map<String, Schema.SObjectField> cartFields = cartDescribe.fields.getMap();
    System.debug('📊 Cart__c has ' + cartFields.size() + ' fields:');
    
    for (String fieldName : cartFields.keySet()) {
        Schema.DescribeFieldResult fieldDescribe = cartFields.get(fieldName).getDescribe();
        System.debug('  ' + fieldName + ' (' + fieldDescribe.getType() + ') - Accessible: ' + fieldDescribe.isAccessible() + ', Createable: ' + fieldDescribe.isCreateable());
    }
    
    // Check specific fields we need
    List<String> importantFields = new List<String>{'Contact__c', 'ContactId', 'User__c', 'UserId', 'Status__c', 'Guest_Session_Id__c'};
    System.debug('🔍 Checking important fields:');
    
    for (String fieldName : importantFields) {
        if (cartFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDescribe = cartFields.get(fieldName).getDescribe();
            System.debug('  ✅ ' + fieldName + ' exists - Type: ' + fieldDescribe.getType() + ', Accessible: ' + fieldDescribe.isAccessible());
        } else {
            System.debug('  ❌ ' + fieldName + ' does not exist');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking Cart__c schema: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
