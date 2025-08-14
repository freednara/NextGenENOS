/**
 * @description Enhanced security utility class for StoreConnect application
 * Provides additional security methods beyond the base SecurityUtils class
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class StoreConnectSecurityUtil {
    
    /**
     * @description Custom exception for security violations
     */
    public class SecurityException extends Exception {}
    
    /**
     * @description Sanitizes user input to prevent XSS and injection attacks
     * @param input The input string to sanitize
     * @param maxLength Maximum allowed length for the input
     * @return Sanitized string safe for use
     */
    public static String sanitizeInput(String input, Integer maxLength) {
        if (String.isBlank(input)) {
            return input;
        }
        
        // Remove potentially dangerous characters
        String sanitized = input.replaceAll('[<>"\']', '');
        
        // Trim to maximum length
        if (maxLength != null && sanitized.length() > maxLength) {
            sanitized = sanitized.substring(0, maxLength);
        }
        
        // Escape single quotes for SOQL safety
        return String.escapeSingleQuotes(sanitized);
    }
    
    /**
     * @description Checks if current user has read permission on object
     * @param objectName API name of the object
     * @return Boolean indicating read permission
     */
    public static Boolean hasReadPermission(String objectName) {
        try {
            SecurityUtils.checkObjectReadable(objectName);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * @description Checks if current user has create permission on object
     * @param objectName API name of the object
     * @return Boolean indicating create permission
     */
    public static Boolean hasCreatePermission(String objectName) {
        try {
            SecurityUtils.checkObjectCreateable(objectName);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * @description Validates record access for bulk operations
     * @param records List of records to validate
     * @param operation Type of operation (CREATE, READ, UPDATE, DELETE)
     */
    public static void validateRecordAccess(List<SObject> records, String operation) {
        if (records == null || records.isEmpty()) {
            return;
        }
        
        String objectType = records[0].getSObjectType().getDescribe().getName();
        
        switch on operation.toUpperCase() {
            when 'CREATE' {
                SecurityUtils.checkObjectCreateable(objectType);
            }
            when 'READ' {
                SecurityUtils.checkObjectReadable(objectType);
            }
            when 'UPDATE' {
                SecurityUtils.checkObjectUpdateable(objectType);
            }
            when 'DELETE' {
                SecurityUtils.checkObjectDeletable(objectType);
            }
            when else {
                throw new SecurityException('Invalid operation: ' + operation);
            }
        }
    }
}