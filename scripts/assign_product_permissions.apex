// Assign ENOSCommunity permission set to current user
// This grants access to the custom product fields and community functionality

try {
    System.debug('🔐 Assigning ENOS Community permissions...');
    
    // Get the permission set ID
    PermissionSet communityPermSet = [
        SELECT Id, Name, Label 
        FROM PermissionSet 
        WHERE Name = 'ENOSCommunity' 
        LIMIT 1
    ];
    
    System.debug('✅ Found permission set: ' + communityPermSet.Label + ' (ID: ' + communityPermSet.Id + ')');
    
    // Check if already assigned
    List<PermissionSetAssignment> existingAssignments = [
        SELECT Id, PermissionSetId, AssigneeId 
        FROM PermissionSetAssignment 
        WHERE PermissionSetId = :communityPermSet.Id 
        AND AssigneeId = :UserInfo.getUserId()
    ];
    
    if (!existingAssignments.isEmpty()) {
        System.debug('ℹ️ Permission set already assigned to current user');
        return;
    }
    
    // Assign the permission set
    PermissionSetAssignment newAssignment = new PermissionSetAssignment(
        PermissionSetId = communityPermSet.Id,
        AssigneeId = UserInfo.getUserId()
    );
    
    insert newAssignment;
    
    System.debug('✅ Successfully assigned ENOSCommunity permission set to current user');
    System.debug('  Assignment ID: ' + newAssignment.Id);
    
    // Verify the assignment
    List<PermissionSetAssignment> verifyAssignments = [
        SELECT Id, PermissionSet.Name, Assignee.Name 
        FROM PermissionSetAssignment 
        WHERE PermissionSetId = :communityPermSet.Id 
        AND AssigneeId = :UserInfo.getUserId()
    ];
    
    if (!verifyAssignments.isEmpty()) {
        System.debug('✅ Permission set assignment verified:');
        System.debug('  Permission Set: ' + verifyAssignments[0].PermissionSet.Name);
        System.debug('  Assigned to: ' + verifyAssignments[0].Assignee.Name);
    }
    
} catch (Exception e) {
    System.debug('❌ Error assigning permission set: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
