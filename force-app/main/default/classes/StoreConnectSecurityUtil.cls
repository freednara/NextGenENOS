/**
 * @description Security utility class for StoreConnect application
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-16
 * 
 * This class provides centralized security enforcement for all CRUD/FLS operations
 * and SOQL injection prevention. It follows AppExchange security review standards.
 */
public with sharing class StoreConnectSecurityUtil {

    private static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
    private static final Map<String, Schema.DescribeSObjectResult> DESCRIBE_CACHE =
        new Map<String, Schema.DescribeSObjectResult>();
    private static final Map<String, Map<String, Schema.SObjectField>> FIELD_MAP_CACHE =
        new Map<String, Map<String, Schema.SObjectField>>();

    // Private constructor to prevent instantiation
    private StoreConnectSecurityUtil() {}

    private static Schema.DescribeSObjectResult getDescribe(String objectName) {
        if (!DESCRIBE_CACHE.containsKey(objectName)) {
            Schema.SObjectType sObjectType = GLOBAL_DESCRIBE.get(objectName);
            if (sObjectType == null) {
                return null;
            }
            DESCRIBE_CACHE.put(objectName, sObjectType.getDescribe());
        }
        return DESCRIBE_CACHE.get(objectName);
    }

    private static Map<String, Schema.SObjectField> getFieldMap(String objectName) {
        if (!FIELD_MAP_CACHE.containsKey(objectName)) {
            Schema.DescribeSObjectResult describeResult = getDescribe(objectName);
            if (describeResult == null) {
                return null;
            }
            FIELD_MAP_CACHE.put(objectName, describeResult.fields.getMap());
        }
        return FIELD_MAP_CACHE.get(objectName);
    }
    
    /**
     * @description Checks if the current user has Create permission on the specified object
     * @param objectName The API name of the object to check
     * @return Boolean indicating if user has Create permission
     * @throws SecurityException if permission check fails
     */
    public static Boolean hasCreatePermission(String objectName) {
        try {
            Schema.DescribeSObjectResult describeResult = getDescribe(objectName);
            if (describeResult == null) {
                throw new SecurityException('Invalid object name: ' + objectName);
            }
            return describeResult.isCreateable();
        } catch (Exception e) {
            throw new SecurityException('Failed to check Create permission for ' + objectName + ': ' + e.getMessage());
        }
    }
    
    /**
     * @description Checks if the current user has Read permission on the specified object
     * @param objectName The API name of the object to check
     * @return Boolean indicating if user has Read permission
     * @throws SecurityException if permission check fails
     */
    public static Boolean hasReadPermission(String objectName) {
        try {
            Schema.DescribeSObjectResult describeResult = getDescribe(objectName);
            if (describeResult == null) {
                throw new SecurityException('Invalid object name: ' + objectName);
            }
            return describeResult.isAccessible();
        } catch (Exception e) {
            throw new SecurityException('Failed to check Read permission for ' + objectName + ': ' + e.getMessage());
        }
    }
    
    /**
     * @description Checks if the current user has Update permission on the specified object
     * @param objectName The API name of the object to check
     * @return Boolean indicating if user has Update permission
     * @throws SecurityException if permission check fails
     */
    public static Boolean hasUpdatePermission(String objectName) {
        try {
            Schema.DescribeSObjectResult describeResult = getDescribe(objectName);
            if (describeResult == null) {
                throw new SecurityException('Invalid object name: ' + objectName);
            }
            return describeResult.isUpdateable();
        } catch (Exception e) {
            throw new SecurityException('Failed to check Update permission for ' + objectName + ': ' + e.getMessage());
        }
    }
    
    /**
     * @description Checks if the current user has Delete permission on the specified object
     * @param objectName The API name of the object to check
     * @return Boolean indicating if user has Delete permission
     * @throws SecurityException if permission check fails
     */
    public static Boolean hasDeletePermission(String objectName) {
        try {
            Schema.DescribeSObjectResult describeResult = getDescribe(objectName);
            if (describeResult == null) {
                throw new SecurityException('Invalid object name: ' + objectName);
            }
            return describeResult.isDeletable();
        } catch (Exception e) {
            throw new SecurityException('Failed to check Delete permission for ' + objectName + ': ' + e.getMessage());
        }
    }
    
    /**
     * @description Checks if the current user has Read permission on the specified field
     * @param objectName The API name of the object containing the field
     * @param fieldName The API name of the field to check
     * @return Boolean indicating if user has Read permission on the field
     * @throws SecurityException if permission check fails
     */
    public static Boolean hasFieldReadPermission(String objectName, String fieldName) {
        try {
            Map<String, Schema.SObjectField> fieldMap = getFieldMap(objectName);
            if (fieldMap == null) {
                throw new SecurityException('Invalid object name: ' + objectName);
            }
            
            if (!fieldMap.containsKey(fieldName)) {
                throw new SecurityException('Invalid field name: ' + fieldName + ' on object: ' + objectName);
            }
            
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            return fieldDescribe.isAccessible();
        } catch (Exception e) {
            throw new SecurityException('Failed to check field Read permission for ' + objectName + '.' + fieldName + ': ' + e.getMessage());
        }
    }
    
    /**
     * @description Checks if the current user has Edit permission on the specified field
     * @param objectName The API name of the object containing the field
     * @param fieldName The API name of the field to check
     * @return Boolean indicating if user has Edit permission on the field
     * @throws SecurityException if permission check fails
     */
    public static Boolean hasFieldEditPermission(String objectName, String fieldName) {
        try {
            Map<String, Schema.SObjectField> fieldMap = getFieldMap(objectName);
            if (fieldMap == null) {
                throw new SecurityException('Invalid object name: ' + objectName);
            }
            
            if (!fieldMap.containsKey(fieldName)) {
                throw new SecurityException('Invalid field name: ' + fieldName + ' on object: ' + objectName);
            }
            
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            
            return fieldDescribe.isUpdateable();
        } catch (Exception e) {
            throw new SecurityException('Failed to check field Edit permission for ' + objectName + '.' + fieldName + ': ' + e.getMessage());
        }
    }
    
    /**
     * @description Validates and sanitizes input to prevent SOQL injection
     * @param input The user input to validate
     * @param maxLength Maximum allowed length for the input
     * @return Sanitized input string
     * @throws SecurityException if input contains dangerous characters or exceeds length
     */
    public static String sanitizeInput(String input, Integer maxLength) {
        if (String.isBlank(input)) {
            return '';
        }
        
        if (input.length() > maxLength) {
            throw new SecurityException('Input exceeds maximum allowed length of ' + maxLength + ' characters');
        }
        
        // Remove any potentially dangerous characters that could be used in SOQL injection
        String sanitized = input.replaceAll('[;\'"]', '');
        
        // Additional validation for search terms
        if (sanitized.contains('SELECT') || sanitized.contains('FROM') || sanitized.contains('WHERE')) {
            throw new SecurityException('Input contains forbidden SQL keywords');
        }
        
        return sanitized;
    }
    
    /**
     * @description Validates that a list of records can be accessed by the current user
     * @param records List of SObject records to validate
     * @param operation The operation being performed (CREATE, READ, UPDATE, DELETE)
     * @throws SecurityException if user lacks permission for the operation
     */
    public static void validateRecordAccess(List<SObject> records, String operation) {
        if (records == null || records.isEmpty()) {
            return;
        }
        
        String objectName = records[0].getSObjectType().getDescribe().getName();
        
        switch on operation.toUpperCase() {
            when 'CREATE' {
                if (!hasCreatePermission(objectName)) {
                    throw new SecurityException('User lacks Create permission on ' + objectName);
                }
            }
            when 'READ' {
                if (!hasReadPermission(objectName)) {
                    throw new SecurityException('User lacks Read permission on ' + objectName);
                }
            }
            when 'UPDATE' {
                if (!hasUpdatePermission(objectName)) {
                    throw new SecurityException('User lacks Update permission on ' + objectName);
                }
            }
            when 'DELETE' {
                if (!hasDeletePermission(objectName)) {
                    throw new SecurityException('User lacks Delete permission on ' + objectName);
                }
            }
            when else {
                throw new SecurityException('Invalid operation specified: ' + operation);
            }
        }
    }
    
    /**
     * @description Custom exception class for security violations
     */
    public class SecurityException extends Exception {}
    
    // ============================================================================
    // PLACEHOLDER METHODS FOR FUTURE FLS/CRUD CHECKS
    // These methods will be implemented as specific security requirements are defined
    // ============================================================================
    
    /**
     * @description Placeholder method for future field-level security validation
     * @param objectName The API name of the object
     * @param fieldNames List of field API names to validate
     * @param operation The operation being performed (READ, EDIT)
     * @return Boolean indicating if all fields are accessible
     * @throws SecurityException if validation fails
     */
    public static Boolean validateFieldAccess(String objectName, List<String> fieldNames, String operation) {
        if (String.isBlank(objectName) || fieldNames == null || fieldNames.isEmpty()) {
            return true;
        }

        for (String fieldName : fieldNames) {
            Boolean hasAccess = operation == 'EDIT'
                ? hasFieldEditPermission(objectName, fieldName)
                : hasFieldReadPermission(objectName, fieldName);
            if (!hasAccess) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * @description Placeholder method for future record-level security validation
     * @param records List of SObject records to validate
     * @param sharingModel The sharing model to enforce
     * @return Boolean indicating if records are accessible
     * @throws SecurityException if validation fails
     */
    public static Boolean validateRecordSharing(List<SObject> records, String sharingModel) {
        // Placeholder implementation relying on built-in sharing
        return true;
    }
    
    /**
     * @description Placeholder method for future data encryption validation
     * @param fieldName The API name of the field to check
     * @param objectName The API name of the object containing the field
     * @return Boolean indicating if field requires encryption
     */
    public static Boolean requiresEncryption(String fieldName, String objectName) {
        // TODO: Implement encryption requirement validation
        // This will include:
        // - PII field identification
        // - Encryption policy enforcement
        // - Compliance requirement checking
        return false; // Placeholder return
    }
    
    /**
     * @description Placeholder method for future audit logging
     * @param operation The operation being performed
     * @param objectName The object being accessed
     * @param recordId The record ID being accessed
     * @param userId The user performing the operation
     */
    public static void logSecurityAudit(String operation, String objectName, Id recordId, Id userId) {
        // TODO: Implement comprehensive security audit logging
        // This will include:
        // - Operation tracking
        // - User activity logging
        // - Compliance reporting
        System.debug('Security audit logging not yet implemented');
    }
}
