/**
 * @description Dynamic Apex utility class for ENOS e-commerce platform
 * Provides safe, secure dynamic query building and metadata access
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_DynamicUtils {
    
    // Cache for frequently accessed metadata
    private static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
    private static final Map<String, Schema.DescribeSObjectResult> DESCRIBE_CACHE = new Map<String, Schema.DescribeSObjectResult>();
    
    /**
     * @description Builds a safe dynamic SOQL query with security validation
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param whereClause Optional WHERE clause
     * @param orderByClause Optional ORDER BY clause
     * @param limitClause Optional LIMIT clause
     * @return Safe SOQL query string
     * @throws AuraHandledException if query construction fails security validation
     */
    public static String buildSafeQuery(String objectName, List<String> fields, 
                                      String whereClause, String orderByClause, Integer limitClause) {
        try {
            // 1. Security validation first
            ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'read');
            ENOS_SecurityUtils.checkDynamicFieldAccess(objectName, fields);
            
            // 2. Build SELECT clause
            String selectClause = buildSelectClause(fields);
            
            // 3. Build FROM clause
            String fromClause = ' FROM ' + objectName;
            
            // 4. Build WHERE clause (if provided)
            String wherePart = '';
            if (String.isNotBlank(whereClause)) {
                String sanitizedWhere = ENOS_SecurityUtils.sanitizeWhereClause(whereClause);
                wherePart = ' WHERE ' + sanitizedWhere;
            }
            
            // 5. Build ORDER BY clause (if provided)
            String orderByPart = '';
            if (String.isNotBlank(orderByClause)) {
                String sanitizedOrderBy = sanitizeOrderByClause(orderByClause);
                orderByPart = ' ORDER BY ' + sanitizedOrderBy;
            }
            
            // 6. Build LIMIT clause (if provided)
            String limitPart = '';
            if (limitClause != null && limitClause > 0) {
                limitPart = ' LIMIT ' + limitClause;
            }
            
            // 7. Add security enforcement with USER_MODE for complete security coverage
            String securityClause = ' WITH USER_MODE';
            
            // 8. Combine all clauses
            String query = selectClause + fromClause + wherePart + orderByPart + limitPart + securityClause;
            
            return query;
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('build dynamic query', e);
            return null;
        }
    }
    
    /**
     * @description Builds SELECT clause from field list
     * @param fields List of field names
     * @return SELECT clause string
     */
    private static String buildSelectClause(List<String> fields) {
        if (fields == null || fields.isEmpty()) {
            return 'SELECT Id';
        }
        
        // Join fields with commas and add SELECT keyword
        String fieldList = String.join(fields, ', ');
        return 'SELECT ' + fieldList;
    }
    
    /**
     * @description Sanitizes ORDER BY clause to prevent injection
     * @param orderByClause The ORDER BY clause to sanitize
     * @return Sanitized ORDER BY clause
     * @throws AuraHandledException if clause contains dangerous patterns
     */
    private static String sanitizeOrderByClause(String orderByClause) {
        if (String.isBlank(orderByClause)) {
            return '';
        }
        
        String sanitized = orderByClause.trim();
        
        // Check for dangerous patterns
        if (!ENOS_SecurityUtils.validateSOQLInjection(sanitized)) {
            ENOS_ExceptionUtils.throwSecurityViolation('ORDER BY clause validation', 'clause contains dangerous patterns');
        }
        
        // Escape single quotes
        sanitized = String.escapeSingleQuotes(sanitized);
        
        return sanitized;
    }
    
    /**
     * @description Executes a dynamic SOQL query with full security validation
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param whereClause Optional WHERE clause
     * @param orderByClause Optional ORDER BY clause
     * @param limitClause Optional LIMIT clause
     * @return List of SObjects from the query
     * @throws AuraHandledException if query execution fails
     */
    public static List<SObject> executeDynamicQuery(String objectName, List<String> fields, 
                                                  String whereClause, String orderByClause, Integer limitClause) {
        try {
            // Build safe query
            String query = buildSafeQuery(objectName, fields, whereClause, orderByClause, limitClause);
            
            // Execute query
            return Database.query(query);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute dynamic query', e);
            return new List<SObject>();
        }
    }
    
    /**
     * @description Gets object metadata information safely
     * @param objectName The SObject API name
     * @return DescribeSObjectResult for the object
     * @throws AuraHandledException if object is not accessible
     */
    public static Schema.DescribeSObjectResult getObjectMetadata(String objectName) {
        try {
            // Security validation
            ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'read');
            
            // Get metadata from cache or global describe
            if (!DESCRIBE_CACHE.containsKey(objectName)) {
                Schema.SObjectType objType = GLOBAL_DESCRIBE.get(objectName);
                if (objType == null) {
                    ENOS_ExceptionUtils.throwDataNotFound('Object', objectName);
                }
                DESCRIBE_CACHE.put(objectName, objType.getDescribe());
            }
            
            return DESCRIBE_CACHE.get(objectName);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('get object metadata', e);
            return null;
        }
    }
    
    /**
     * @description Gets field metadata for an object safely
     * @param objectName The SObject API name
     * @param fieldName The field API name
     * @return DescribeFieldResult for the field
     * @throws AuraHandledException if field is not accessible
     */
    public static Schema.DescribeFieldResult getFieldMetadata(String objectName, String fieldName) {
        try {
            // Security validation
            ENOS_SecurityUtils.checkDynamicFieldAccess(objectName, new List<String>{fieldName});
            
            // Get object metadata
            Schema.DescribeSObjectResult objectDesc = getObjectMetadata(objectName);
            Map<String, Schema.SObjectField> fieldMap = objectDesc.fields.getMap();
            
            if (!fieldMap.containsKey(fieldName)) {
                ENOS_ExceptionUtils.throwDataNotFound('Field', fieldName + ' on ' + objectName);
            }
            
            return fieldMap.get(fieldName).getDescribe();
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('get field metadata', e);
            return null;
        }
    }
    
    /**
     * @description Creates a new SObject record dynamically with security validation
     * @param objectName The SObject API name
     * @param fieldValues Map of field names to values
     * @return The created SObject
     * @throws AuraHandledException if creation fails
     */
    public static SObject createDynamicRecord(String objectName, Map<String, Object> fieldValues) {
        try {
            // Security validation
            ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'create');
            
            // Get accessible fields
            List<String> accessibleFields = ENOS_SecurityUtils.getDynamicAccessibleFields(objectName, 'edit');
            
            // Create new record
            SObject newRecord = Schema.getGlobalDescribe().get(objectName).newSObject();
            
            // Set field values with validation
            for (String fieldName : fieldValues.keySet()) {
                if (accessibleFields.contains(fieldName)) {
                    newRecord.put(fieldName, fieldValues.get(fieldName));
                }
            }
            
            // Insert record
            insert newRecord;
            
            return newRecord;
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('create dynamic record', e);
            return null;
        }
    }
    
    /**
     * @description Updates an existing SObject record dynamically with security validation
     * @param objectName The SObject API name
     * @param recordId The record ID to update
     * @param fieldValues Map of field names to new values
     * @throws AuraHandledException if update fails
     */
    public static void updateDynamicRecord(String objectName, Id recordId, Map<String, Object> fieldValues) {
        try {
            // Security validation
            ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'update');
            
            // Get accessible fields
            List<String> accessibleFields = ENOS_SecurityUtils.getDynamicAccessibleFields(objectName, 'edit');
            
            // Query existing record
            String query = buildSafeQuery(objectName, new List<String>{'Id'}, 'Id = \'' + recordId + '\'', null, 1);
            List<SObject> records = Database.query(query);
            
            if (records.isEmpty()) {
                ENOS_ExceptionUtils.throwDataNotFound('Record', recordId);
            }
            
            SObject recordToUpdate = records[0];
            
            // Update field values with validation
            for (String fieldName : fieldValues.keySet()) {
                if (accessibleFields.contains(fieldName)) {
                    recordToUpdate.put(fieldName, fieldValues.get(fieldName));
                }
            }
            
            // Update record
            update recordToUpdate;
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('update dynamic record', e);
        }
    }
    
    /**
     * @description Gets all accessible objects in the org
     * @return List of accessible object names
     */
    public static List<String> getAccessibleObjects() {
        List<String> accessibleObjects = new List<String>();
        
        for (String objectName : GLOBAL_DESCRIBE.keySet()) {
            try {
                Schema.DescribeSObjectResult describe = GLOBAL_DESCRIBE.get(objectName).getDescribe();
                if (describe.isAccessible()) {
                    accessibleObjects.add(objectName);
                }
            } catch (Exception e) {
                // Skip objects that can't be described
                continue;
            }
        }
        
        return accessibleObjects;
    }
    
    /**
     * @description Validates if a dynamic query can be executed safely
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param whereClause Optional WHERE clause
     * @return Boolean indicating if query is safe
     */
    public static Boolean validateDynamicQuery(String objectName, List<String> fields, String whereClause) {
        try {
            // Test query construction
            buildSafeQuery(objectName, fields, whereClause, null, null);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
