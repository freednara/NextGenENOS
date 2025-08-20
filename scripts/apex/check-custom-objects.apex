// ========================================
// CHECK CUSTOM OBJECTS SCRIPT
// NextGenENOS ENOS Application
// ========================================
// This script checks what custom objects are available

System.debug('=== CHECKING CUSTOM OBJECTS ===');

try {
    // Get all objects
    Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    System.debug('📊 Total objects in org: ' + globalDescribe.size());
    
    // List custom objects
    System.debug('🔍 Custom objects found:');
    for (String objectName : globalDescribe.keySet()) {
        Schema.SObjectType objectType = globalDescribe.get(objectName);
        Schema.DescribeSObjectResult objectDesc = objectType.getDescribe();
        
        if (objectDesc.isCustom()) {
            System.debug('  - ' + objectName + ' (Label: ' + objectDesc.getLabel() + ')');
            
            // Get fields for this custom object
            Map<String, Schema.SObjectField> fieldMap = objectDesc.fields.getMap();
            System.debug('    Fields: ' + fieldMap.size());
            
            // List custom fields
            for (String fieldName : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                
                if (fieldDesc.isCustom()) {
                    System.debug('      - ' + fieldName + ' (' + fieldDesc.getType() + ')');
                }
            }
        }
    }
    
    // Check specific ENOS objects we expect
    String[] expectedObjects = new String[]{'Cart__c', 'Cart_Item__c', 'Category__c', 'Shipping_Address__c'};
    System.debug('🔍 Checking expected ENOS objects:');
    
    for (String objectName : expectedObjects) {
        if (globalDescribe.containsKey(objectName)) {
            Schema.SObjectType objectType = globalDescribe.get(objectName);
            Schema.DescribeSObjectResult objectDesc = objectType.getDescribe();
            System.debug('  ✅ ' + objectName + ' exists (Label: ' + objectDesc.getLabel() + ')');
            
            // Get fields for this object
            Map<String, Schema.SObjectField> fieldMap = objectDesc.fields.getMap();
            System.debug('    Fields: ' + fieldMap.size());
            
            // List all fields
            for (String fieldName : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                System.debug('      - ' + fieldName + ' (' + fieldDesc.getType() + ') - Custom: ' + fieldDesc.isCustom());
            }
        } else {
            System.debug('  ❌ ' + objectName + ' NOT FOUND');
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking custom objects: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== CUSTOM OBJECTS CHECK COMPLETE ===');




