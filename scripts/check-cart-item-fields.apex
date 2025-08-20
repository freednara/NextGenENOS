// Check Cart_Item__c object fields
try {
    System.debug('🔍 Checking Cart_Item__c object fields...');
    
    // Get the object describe result
    Schema.DescribeSObjectResult cartItemDescribe = Schema.SObjectType.Cart_Item__c;
    System.debug('✅ Cart_Item__c object: ' + cartItemDescribe.getLabel() + ' (' + cartItemDescribe.getName() + ')');
    
    // Get all fields
    Map<String, Schema.SObjectField> cartItemFields = cartItemDescribe.fields.getMap();
    System.debug('📊 Cart_Item__c has ' + cartItemFields.size() + ' total fields:');
    
    // List all fields with their types
    for (String fieldName : cartItemFields.keySet()) {
        Schema.DescribeFieldResult fieldDescribe = cartItemFields.get(fieldName).getDescribe();
        System.debug('  ' + fieldName + ' (' + fieldDescribe.getType() + ') - Label: ' + fieldDescribe.getLabel());
    }
    
    // Check specific fields we need
    List<String> requiredFields = new List<String>{'Cart__c', 'Product__c', 'Quantity__c', 'Unit_Price__c', 'Line_Total__c'};
    System.debug('🔍 Checking required Cart_Item__c fields:');
    
    for (String fieldName : requiredFields) {
        if (cartItemFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDescribe = cartItemFields.get(fieldName).getDescribe();
            System.debug('  ✅ ' + fieldName + ' exists - Type: ' + fieldDescribe.getType() + ', Label: ' + fieldDescribe.getLabel());
        } else {
            System.debug('  ❌ ' + fieldName + ' does not exist');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking Cart_Item__c fields: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
