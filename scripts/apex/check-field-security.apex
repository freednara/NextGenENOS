// Check field-level security for Product2 custom fields
System.debug('=== CHECKING FIELD-LEVEL SECURITY ===');

try {
    // Get the current user's profile
    User currentUser = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    System.debug('👤 Current User Profile: ' + currentUser.Profile.Name + ' (ID: ' + currentUser.ProfileId + ')');
    
    // Check if the custom fields exist and are accessible
    Schema.DescribeSObjectResult productDesc = Schema.SObjectType.Product2;
    Map<String, Schema.SObjectField> fieldMap = productDesc.fields.getMap();
    
    System.debug('📊 Product2 Field Analysis:');
    
    // Check the specific custom fields we need
    List<String> requiredFields = new List<String>{
        'Stock_Quantity__c',
        'Is_Top_Seller__c', 
        'Image_URL__c'
    };
    
    for (String fieldName : requiredFields) {
        if (fieldMap.containsKey(fieldName)) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            
            System.debug('✅ ' + fieldName + ' EXISTS:');
            System.debug('  - Type: ' + fieldDesc.getType());
            System.debug('  - Custom: ' + fieldDesc.isCustom());
            System.debug('  - Accessible: ' + fieldDesc.isAccessible());
            System.debug('  - Createable: ' + fieldDesc.isCreateable());
            System.debug('  - Updateable: ' + fieldDesc.isUpdateable());
            System.debug('  - Required: ' + fieldDesc.isNillable());
            
            // Check field-level security
            try {
                // Try to create a test product with this field
                Product2 testProduct = new Product2(
                    Name = 'Security Test Product',
                    ProductCode = 'SEC-TEST-001',
                    Description = 'Testing field access',
                    IsActive = true
                );
                
                // Try to set the custom field
                Object fieldValue;
                if (fieldDesc.getType() == Schema.DisplayType.BOOLEAN) {
                    fieldValue = false;
                } else if (fieldDesc.getType() == Schema.DisplayType.DOUBLE || fieldDesc.getType() == Schema.DisplayType.INTEGER) {
                    fieldValue = 100;
                } else {
                    fieldValue = 'test-value';
                }
                testProduct.put(fieldName, fieldValue);
                
                System.debug('  - Field can be set: ✅ YES');
                
            } catch (Exception e) {
                System.debug('  - Field can be set: ❌ NO - ' + e.getMessage());
            }
            
        } else {
            System.debug('❌ ' + fieldName + ' MISSING from Product2');
        }
    }
    
    // Check if we can query these fields
    try {
        System.debug('🔍 Testing SOQL query with custom fields...');
        List<Product2> testQuery = [
            SELECT Id, Name, Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c 
            FROM Product2 
            LIMIT 1
        ];
        System.debug('✅ SOQL query successful - fields are queryable');
        
    } catch (Exception e) {
        System.debug('❌ SOQL query failed: ' + e.getMessage());
    }
    
    // Check profile field permissions
    System.debug('🔍 Checking Profile Field Permissions...');
    
    // Get all profiles
    List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator', 'ENOS Profile', 'Standard User')];
    
    for (Profile profile : profiles) {
        System.debug('📋 Profile: ' + profile.Name + ' (ID: ' + profile.Id + ')');
        
        // Check if this profile has field permissions for our custom fields
        try {
            List<FieldPermissions> fieldPerms = [
                SELECT Id, Field, Parent.Profile.Name, PermissionsRead, PermissionsEdit
                FROM FieldPermissions 
                WHERE Parent.ProfileId = :profile.Id 
                AND Field LIKE 'Product2.%'
                ORDER BY Field
            ];
            
            if (!fieldPerms.isEmpty()) {
                for (FieldPermissions fp : fieldPerms) {
                    System.debug('  - ' + fp.Field + ': Read=' + fp.PermissionsRead + ', Edit=' + fp.PermissionsEdit);
                }
            } else {
                System.debug('  - No explicit field permissions found (using default)');
            }
            
        } catch (Exception e) {
            System.debug('  - Error checking field permissions: ' + e.getMessage());
        }
    }
    
} catch (Exception e) {
    System.debug('❌ Error in field security check: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== FIELD-LEVEL SECURITY CHECK COMPLETE ===');
