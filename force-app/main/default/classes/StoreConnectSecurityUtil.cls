/**
 * @description Enhanced security utility class for StoreConnect application
 * Provides additional security methods beyond the base SecurityUtils class
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class StoreConnectSecurityUtil {
    // Cache global describes for performance
    private static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
    private static final Map<String, Schema.DescribeSObjectResult> DESCRIBE_CACHE =
        new Map<String, Schema.DescribeSObjectResult>();

    /**
     * @description Custom exception for security violations
     */
    public class SecurityException extends Exception {}

    /**
     * Retrieves and caches describe information for an object
     */
    private static Schema.DescribeSObjectResult getDescribe(String objectName) {
        if (!DESCRIBE_CACHE.containsKey(objectName)) {
            Schema.SObjectType objType = GLOBAL_DESCRIBE.get(objectName);
            if (objType == null) {
                return null;
            }
            DESCRIBE_CACHE.put(objectName, objType.getDescribe());
        }
        return DESCRIBE_CACHE.get(objectName);
    }
    
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
     * @description Determines if a field potentially contains PII and therefore should be encrypted
     * @param fieldName API name of the field
     * @param objectName API name of the object
     * @return Boolean indicating if encryption is recommended
     */
    public static Boolean requiresEncryption(String fieldName, String objectName) {
        if (String.isBlank(fieldName) || String.isBlank(objectName)) {
            return false;
        }

        Schema.DescribeSObjectResult describeResult = getDescribe(objectName);
        if (describeResult == null) {
            throw new SecurityException('Invalid object: ' + objectName);
        }

        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        if (!fieldMap.containsKey(fieldName)) {
            throw new SecurityException('Invalid field: ' + fieldName);
        }

        Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
        String fieldNameUpper = fieldName.toUpperCase();
        String fieldLabelUpper = fieldDesc.getLabel() != null ? fieldDesc.getLabel().toUpperCase() : '';

        List<String> piiKeywords = new List<String>{
            'EMAIL', 'SSN', 'SOCIAL', 'PHONE', 'ADDRESS', 'NAME', 'DOB', 'BIRTH'
        };

        for (String keyword : piiKeywords) {
            if (fieldNameUpper.contains(keyword) || fieldLabelUpper.contains(keyword)) {
                return true;
            }
        }
        return false;
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

        String objectName = records[0].getSObjectType().getDescribe().getName();
        for (SObject record : records) {
            if (record.getSObjectType().getDescribe().getName() != objectName) {
                throw new SecurityException('All records must be of the same SObject type');
            }
        }

        switch on operation.toUpperCase() {
            when 'CREATE' {
                SecurityUtils.checkObjectCreateable(objectName);
            }
            when 'READ' {
                SecurityUtils.checkObjectReadable(objectName);
            }
            when 'UPDATE' {
                SecurityUtils.checkObjectUpdateable(objectName);
            }
            when 'DELETE' {
                SecurityUtils.checkObjectDeletable(objectName);
            }
            when else {
                throw new SecurityException('Invalid operation: ' + operation);
            }
        }

        if (!operation.equalsIgnoreCase('CREATE')) {
            Set<Id> recordIds = new Set<Id>();
            for (SObject rec : records) {
                if (rec.Id != null) {
                    recordIds.add(rec.Id);
                }
            }
            if (!recordIds.isEmpty()) {
                String query =
                    'SELECT Id FROM ' +
                    objectName +
                    ' WHERE Id IN :recordIds WITH SECURITY_ENFORCED';
                Set<Id> accessibleIds =
                    new Map<Id, SObject>(Database.query(query)).keySet();
                if (accessibleIds.size() != recordIds.size()) {
                    throw new SecurityException(
                        'Security Error: One or more records are not accessible.'
                    );
                }
            }
        }
    }
}