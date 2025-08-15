/**
 * ENOS Permission Assignment Script
 * 
 * This script assigns ENOS permissions to the current user.
 * Run this in Developer Console or via SFDX CLI.
 * 
 * Usage: sf apex run --file scripts/apex/assign-enos-permissions.apex
 */

System.debug('🔧 Starting ENOS Permission Assignment...');

// Get current user
User currentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
System.debug('👤 Current User: ' + currentUser.Name + ' (Profile: ' + currentUser.Profile.Name + ')');

// Define permission sets to assign
List<String> permissionSetNames = new List<String>{
    'ENOS_Basic_Access'
};

// Find permission sets
List<PermissionSet> permissionSets = [
    SELECT Id, Name, Description 
    FROM PermissionSet 
    WHERE Name IN :permissionSetNames
];

if (permissionSets.isEmpty()) {
    System.debug('❌ No ENOS permission sets found. Please create them first.');
    System.debug('📋 Required permission sets: ' + permissionSetNames);
} else {
    System.debug('✅ Found ' + permissionSets.size() + ' permission set(s):');
    for (PermissionSet ps : permissionSets) {
        System.debug('   • ' + ps.Name + ' - ' + ps.Description);
    }
    
    // Check existing assignments
    List<PermissionSetAssignment> existingAssignments = [
        SELECT Id, PermissionSet.Name, Assignee.Name
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUser.Id 
        AND PermissionSet.Name IN :permissionSetNames
    ];
    
    if (!existingAssignments.isEmpty()) {
        System.debug('ℹ️  User already has these permission sets:');
        for (PermissionSetAssignment psa : existingAssignments) {
            System.debug('   • ' + psa.PermissionSet.Name + ' (assigned to ' + psa.Assignee.Name + ')');
        }
    }
    
    // Assign missing permission sets
    List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
    Set<String> assignedNames = new Set<String>();
    
    for (PermissionSetAssignment psa : existingAssignments) {
        assignedNames.add(psa.PermissionSet.Name);
    }
    
    for (PermissionSet ps : permissionSets) {
        if (!assignedNames.contains(ps.Name)) {
            newAssignments.add(new PermissionSetAssignment(
                AssigneeId = currentUser.Id,
                PermissionSetId = ps.Id
            ));
        }
    }
    
    if (!newAssignments.isEmpty()) {
        try {
            insert newAssignments;
            System.debug('✅ Successfully assigned ' + newAssignments.size() + ' permission set(s):');
            for (PermissionSetAssignment psa : newAssignments) {
                System.debug('   • ' + psa.PermissionSetId);
            }
        } catch (Exception e) {
            System.debug('❌ Error assigning permission sets: ' + e.getMessage());
        }
    } else {
        System.debug('ℹ️  No new permission sets to assign.');
    }
}

// Verify final permission set assignments
List<PermissionSetAssignment> finalAssignments = [
    SELECT Id, PermissionSet.Name, Assignee.Name
    FROM PermissionSetAssignment 
    WHERE AssigneeId = :currentUser.Id 
    AND PermissionSet.Name LIKE 'ENOS%'
];

System.debug('📊 Final ENOS permission set assignments:');
if (finalAssignments.isEmpty()) {
    System.debug('   • None assigned');
} else {
    for (PermissionSetAssignment psa : finalAssignments) {
        System.debug('   • ' + psa.PermissionSet.Name + ' (assigned to ' + psa.Assignee.Name + ')');
    }
}

System.debug('🎉 ENOS permission assignment complete!');
System.debug('💡 User now has access to ENOS functionality');
