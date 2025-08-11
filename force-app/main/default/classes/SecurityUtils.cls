/**
 * @description Utility class to centralize all FLS and CRUD security checks.
 * All methods are static and the class is non-instantiable.
 * 
 * This class ensures that Field-Level Security (FLS) and Create, Read, Update, Delete (CRUD) 
 * permissions are respected 100% of the time. This is a core requirement for passing a security review.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class SecurityUtils {

    // Private constructor to prevent instantiation of the class
    private SecurityUtils() {}

    /**
     * @description Checks if the current user has READ access to a list of fields on a given SObject.
     * Throws an AuraHandledException if access is denied for any field.
     * 
     * @param sObjectName The API name of the SObject (e.g., 'Account', 'Cart_Item__c').
     * @param fieldsToCheck A list of field API names to check.
     * @throws AuraHandledException if access is denied for any field
     * 
     * @example
     * List<String> fieldsToSecure = new List<String>{
     *     'Id', 'Quantity__c', 'Unit_Price__c', 'Line_Total__c'
     * };
     * SecurityUtils.checkFieldReadAccess('Cart_Item__c', fieldsToSecure);
     */
    public static void checkFieldReadAccess(String sObjectName, List<String> fieldsToCheck) {
        // Validate input parameters
        if (String.isBlank(sObjectName) || fieldsToCheck == null || fieldsToCheck.isEmpty()) {
            throw new AuraHandledException('Security Error: Invalid parameters provided for field access check.');
        }

        // Get the describe result for the SObject
        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

        // Get a map of all fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();

        for (String fieldName : fieldsToCheck) {
            if (fieldMap.containsKey(fieldName)) {
                // Check if the field is accessible
                if (!fieldMap.get(fieldName).getDescribe().isAccessible()) {
                    // Throw a security exception if a field is not readable.
                    // AuraHandledException is used to pass a clean error message to LWCs.
                    throw new AuraHandledException('Security Error: You do not have permission to view the ' + fieldName + ' field on ' + sObjectName);
                }
            }
        }
    }

    /**
     * @description Checks if the current user has CREATE access on a given SObject.
     * Throws an AuraHandledException if access is denied.
     * 
     * @param sObjectName The API name of the SObject.
     * @throws AuraHandledException if access is denied
     * 
     * @example
     * SecurityUtils.checkObjectCreateable('Cart_Item__c');
     */
    public static void checkObjectCreateable(String sObjectName) {
        if (String.isBlank(sObjectName)) {
            throw new AuraHandledException('Security Error: Invalid SObject name provided for create access check.');
        }

        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

        if (!sObjectDescribe.isCreateable()) {
            throw new AuraHandledException('Security Error: You do not have permission to create ' + sObjectDescribe.getLabel() + ' records.');
        }
    }

    /**
     * @description Checks if the current user has UPDATE access on a given SObject.
     * Throws an AuraHandledException if access is denied.
     * 
     * @param sObjectName The API name of the SObject.
     * @throws AuraHandledException if access is denied
     * 
     * @example
     * SecurityUtils.checkObjectUpdateable('Cart_Item__c');
     */
    public static void checkObjectUpdateable(String sObjectName) {
        if (String.isBlank(sObjectName)) {
            throw new AuraHandledException('Security Error: Invalid SObject name provided for update access check.');
        }

        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

        if (!sObjectDescribe.isUpdateable()) {
            throw new AuraHandledException('Security Error: You do not have permission to update ' + sObjectDescribe.getLabel() + ' records.');
        }
    }

    /**
     * @description Checks if the current user has DELETE access on a given SObject.
     * Throws an AuraHandledException if access is denied.
     * 
     * @param sObjectName The API name of the SObject.
     * @throws AuraHandledException if access is denied
     * 
     * @example
     * SecurityUtils.checkObjectDeletable('Cart_Item__c');
     */
    public static void checkObjectDeletable(String sObjectName) {
        if (String.isBlank(sObjectName)) {
            throw new AuraHandledException('Security Error: Invalid SObject name provided for delete access check.');
        }

        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

        if (!sObjectDescribe.isDeletable()) {
            throw new AuraHandledException('Security Error: You do not have permission to delete ' + sObjectDescribe.getLabel() + ' records.');
        }
    }

    /**
     * @description Checks if the current user has READ access on a given SObject.
     * Throws an AuraHandledException if access is denied.
     * 
     * @param sObjectName The API name of the SObject.
     * @throws AuraHandledException if access is denied
     * 
     * @example
     * SecurityUtils.checkObjectReadable('Cart_Item__c');
     */
    public static void checkObjectReadable(String sObjectName) {
        if (String.isBlank(sObjectName)) {
            throw new AuraHandledException('Security Error: Invalid SObject name provided for read access check.');
        }

        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

        if (!sObjectDescribe.isAccessible()) {
            throw new AuraHandledException('Security Error: You do not have permission to read ' + sObjectDescribe.getLabel() + ' records.');
        }
    }

    /**
     * @description Comprehensive security check for CRUD operations on a given SObject.
     * Checks create, read, update, and delete permissions in a single call.
     * 
     * @param sObjectName The API name of the SObject.
     * @param operation The CRUD operation to check ('CREATE', 'READ', 'UPDATE', 'DELETE', 'ALL').
     * @throws AuraHandledException if access is denied for any required operation
     * 
     * @example
     * SecurityUtils.checkCRUDPermissions('Cart_Item__c', 'ALL');
     * SecurityUtils.checkCRUDPermissions('Cart_Item__c', 'CREATE');
     */
    public static void checkCRUDPermissions(String sObjectName, String operation) {
        if (String.isBlank(sObjectName) || String.isBlank(operation)) {
            throw new AuraHandledException('Security Error: Invalid parameters provided for CRUD permission check.');
        }

        String upperOperation = operation.toUpperCase();
        
        switch on upperOperation {
            when 'CREATE' {
                checkObjectCreateable(sObjectName);
            }
            when 'READ' {
                checkObjectReadable(sObjectName);
            }
            when 'UPDATE' {
                checkObjectUpdateable(sObjectName);
            }
            when 'DELETE' {
                checkObjectDeletable(sObjectName);
            }
            when 'ALL' {
                checkObjectCreateable(sObjectName);
                checkObjectReadable(sObjectName);
                checkObjectUpdateable(sObjectName);
                checkObjectDeletable(sObjectName);
            }
            when else {
                throw new AuraHandledException('Security Error: Invalid operation specified. Use CREATE, READ, UPDATE, DELETE, or ALL.');
            }
        }
    }

    /**
     * @description Checks if the current user has EDIT access to a list of fields on a given SObject.
     * Throws an AuraHandledException if access is denied for any field.
     * 
     * @param sObjectName The API name of the SObject.
     * @param fieldsToCheck A list of field API names to check.
     * @throws AuraHandledException if access is denied for any field
     * 
     * @example
     * List<String> fieldsToEdit = new List<String>{
     *     'Quantity__c', 'Unit_Price__c'
     * };
     * SecurityUtils.checkFieldEditAccess('Cart_Item__c', fieldsToEdit);
     */
    public static void checkFieldEditAccess(String sObjectName, List<String> fieldsToCheck) {
        // Validate input parameters
        if (String.isBlank(sObjectName) || fieldsToCheck == null || fieldsToCheck.isEmpty()) {
            throw new AuraHandledException('Security Error: Invalid parameters provided for field edit access check.');
        }

        // Get the describe result for the SObject
        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(sObjectName).getDescribe();

        // Get a map of all fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();

        for (String fieldName : fieldsToCheck) {
            if (fieldMap.containsKey(fieldName)) {
                // Check if the field is editable
                if (!fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                    // Throw a security exception if a field is not editable.
                    throw new AuraHandledException('Security Error: You do not have permission to edit the ' + fieldName + ' field on ' + sObjectName);
                }
            }
        }
    }

    /**
     * @description Validates that a user has access to a specific record based on ownership or sharing rules.
     * This method should be called before performing operations on specific records.
     * 
     * @param recordId The ID of the record to validate access for.
     * @param sObjectName The API name of the SObject.
     * @throws AuraHandledException if access is denied
     * 
     * @example
     * SecurityUtils.validateRecordAccess(cartItemId, 'Cart_Item__c');
     */
    public static void validateRecordAccess(Id recordId, String sObjectName) {
        if (recordId == null || String.isBlank(sObjectName)) {
            throw new AuraHandledException('Security Error: Invalid record ID or SObject name provided for record access validation.');
        }

        // Check if the user has read access to the object first
        checkObjectReadable(sObjectName);

        // Additional record-level access validation can be added here
        // For now, we rely on Salesforce sharing rules and the 'with sharing' keyword
        // This method provides a hook for future custom access control logic
    }
}
