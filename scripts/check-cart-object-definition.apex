// Check Cart__c object definition to see what fields are actually available
try {
    System.debug('🔍 Checking Cart__c object definition...');
    
    // Get the object describe result
    Schema.DescribeSObjectResult cartDescribe = Schema.SObjectType.Cart__c;
    System.debug('✅ Cart__c object: ' + cartDescribe.getLabel() + ' (' + cartDescribe.getName() + ')');
    
    // Get all fields
    Map<String, Schema.SObjectField> cartFields = cartDescribe.fields.getMap();
    System.debug('📊 Cart__c has ' + cartFields.size() + ' total fields:');
    
    // List all fields with their types
    for (String fieldName : cartFields.keySet()) {
        Schema.DescribeFieldResult fieldDescribe = cartFields.get(fieldName).getDescribe();
        System.debug('  ' + fieldName + ' (' + fieldDescribe.getType() + ') - Label: ' + fieldDescribe.getLabel());
    }
    
    // Check specific custom fields we need
    List<String> requiredFields = new List<String>{'Contact__c', 'Created_Date__c', 'Guest_Session_Id__c', 'Subtotal__c', 'Total_Items__c'};
    System.debug('🔍 Checking required custom fields:');
    
    for (String fieldName : requiredFields) {
        if (cartFields.containsKey(fieldName)) {
            Schema.DescribeFieldResult fieldDescribe = cartFields.get(fieldName).getDescribe();
            System.debug('  ✅ ' + fieldName + ' exists - Type: ' + fieldDescribe.getType() + ', Label: ' + fieldDescribe.getLabel());
        } else {
            System.debug('  ❌ ' + fieldName + ' does not exist');
        }
    }
    
    // Try to get field describe for a specific field
    System.debug('🧪 Testing field access for Contact__c...');
    try {
        Schema.SObjectField contactField = cartFields.get('Contact__c');
        if (contactField != null) {
            Schema.DescribeFieldResult contactFieldDescribe = contactField.getDescribe();
            System.debug('✅ Contact__c field accessible: ' + contactFieldDescribe.getLabel());
        } else {
            System.debug('❌ Contact__c field not found in field map');
        }
    } catch (Exception e) {
        System.debug('❌ Error accessing Contact__c field: ' + e.getMessage());
    }
    
    // Check if we can query the fields directly
    System.debug('🧪 Testing direct field query...');
    try {
        List<Cart__c> testCarts = [SELECT Id, Name, Status__c FROM Cart__c LIMIT 1];
        System.debug('✅ Basic Cart__c query successful');
        
        if (!testCarts.isEmpty()) {
            Cart__c testCart = testCarts[0];
            System.debug('🔍 Sample cart: ' + testCart.Name + ' - Status: ' + testCart.Status__c);
        }
        
    } catch (Exception e) {
        System.debug('❌ Basic Cart__c query failed: ' + e.getMessage());
    }
    
    // Try to create a Cart__c record with minimal fields
    System.debug('🧪 Testing Cart__c record creation...');
    try {
        Cart__c testCart = new Cart__c(
            Status__c = 'Active'
        );
        
        // Insert the cart
        insert testCart;
        System.debug('✅ Cart__c record created with ID: ' + testCart.Id);
        
        // Clean up
        delete testCart;
        System.debug('✅ Test record cleaned up');
        
    } catch (Exception e) {
        System.debug('❌ Cart__c creation failed: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking Cart__c object definition: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
