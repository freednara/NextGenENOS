// Check current user permissions and field visibility
try {
    System.debug('🔍 Checking current user permissions and field visibility...');
    
    // Get current user info
    String currentUserId = UserInfo.getUserId();
    System.debug('✅ Current User ID: ' + currentUserId);
    
    // Get current user details
    User currentUser = [SELECT Id, Username, Profile.Name, UserRole.Name FROM User WHERE Id = :currentUserId LIMIT 1];
    System.debug('✅ Current User: ' + currentUser.Username);
    System.debug('✅ Profile: ' + currentUser.Profile.Name);
    System.debug('✅ User Role: ' + (currentUser.UserRole != null ? currentUser.UserRole.Name : 'None'));
    
    // Check if user has the ENOS permission set
    List<PermissionSetAssignment> permissionSets = [
        SELECT PermissionSet.Name, PermissionSet.Label 
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUserId
    ];
    
    System.debug('📊 User has ' + permissionSets.size() + ' permission sets:');
    for (PermissionSetAssignment psa : permissionSets) {
        System.debug('  ' + psa.PermissionSet.Label + ' (' + psa.PermissionSet.Name + ')');
    }
    
    // Check if ENOS permission set is assigned
    Boolean hasEnosPermissions = false;
    for (PermissionSetAssignment psa : permissionSets) {
        if (psa.PermissionSet.Name.contains('ENOS')) {
            hasEnosPermissions = true;
            System.debug('✅ User has ENOS permission set: ' + psa.PermissionSet.Name);
        }
    }
    
    if (!hasEnosPermissions) {
        System.debug('⚠️ User does not have ENOS permission set assigned');
        System.debug('💡 This might be why the custom fields are not accessible');
    }
    
    // Check if user can see Cart__c object
    try {
        Schema.DescribeSObjectResult cartDescribe = Schema.SObjectType.Cart__c;
        System.debug('✅ Cart__c object is accessible: ' + cartDescribe.isAccessible());
        System.debug('✅ Cart__c object is createable: ' + cartDescribe.isCreateable());
        System.debug('✅ Cart__c object is updateable: ' + cartDescribe.isUpdateable());
        System.debug('✅ Cart__c object is deletable: ' + cartDescribe.isDeletable());
    } catch (Exception e) {
        System.debug('❌ Cart__c object not accessible: ' + e.getMessage());
    }
    
    // Try to get field describe information
    try {
        Map<String, Schema.SObjectField> cartFields = Schema.SObjectType.Cart__c.fields.getMap();
        System.debug('📊 Cart__c has ' + cartFields.size() + ' fields:');
        
        for (String fieldName : cartFields.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = cartFields.get(fieldName).getDescribe();
            System.debug('  ' + fieldName + ' (' + fieldDescribe.getType() + ') - Accessible: ' + fieldDescribe.isAccessible() + ', Createable: ' + fieldDescribe.isCreateable());
        }
        
    } catch (Exception e) {
        System.debug('❌ Could not get field describe: ' + e.getMessage());
    }
    
    // Check if we can create a simple Cart__c record
    try {
        Cart__c testCart = new Cart__c(
            Status__c = 'Active'
        );
        System.debug('✅ Can create Cart__c record with Status__c');
        
        // Try to insert
        insert testCart;
        System.debug('✅ Successfully inserted Cart__c record with ID: ' + testCart.Id);
        
        // Clean up
        delete testCart;
        System.debug('✅ Test record cleaned up');
        
    } catch (Exception e) {
        System.debug('❌ Cart__c creation failed: ' + e.getMessage());
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking user permissions: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
