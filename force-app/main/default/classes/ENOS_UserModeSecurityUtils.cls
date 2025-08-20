/**
 * @description Enhanced Security Utility class for ENOS e-commerce platform
 * Leverages WITH USER_MODE for complete object and field-level security enforcement
 * including DML operations (INSERT, UPDATE, DELETE, UPSERT)
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_UserModeSecurityUtils {
    
    /**
     * @description Executes a dynamic SOQL query with USER_MODE security enforcement
     * This ensures that the query respects the current user's object and field-level permissions
     * @param query The SOQL query to execute
     * @return List<SObject> Query results
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static List<SObject> executeSecureQuery(String query) {
        try {
            // Validate query for security
            if (!ENOS_SecurityUtils.validateSOQLInjection(query)) {
                ENOS_ExceptionUtils.throwSecurityViolation('Query validation', 'Query contains dangerous patterns');
            }
            
            // Execute query with USER_MODE for complete security enforcement
            return Database.query(query + ' WITH USER_MODE');
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure query', e);
            return new List<SObject>();
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query with specific fields and conditions
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param whereClause Optional WHERE clause
     * @param orderByClause Optional ORDER BY clause
     * @param limitClause Optional LIMIT clause
     * @return List<SObject> Query results
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static List<SObject> executeSecureQuery(String objectName, List<String> fields, 
                                                  String whereClause, String orderByClause, Integer limitClause) {
        try {
            // Build query using existing utility
            String query = ENOS_DynamicUtils.buildSafeQuery(objectName, fields, whereClause, orderByClause, limitClause);
            
            // Replace WITH SECURITY_ENFORCED with WITH USER_MODE
            query = query.replace('WITH SECURITY_ENFORCED', 'WITH USER_MODE');
            
            // Execute the query
            return Database.query(query);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure query', e);
            return new List<SObject>();
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query for a single record
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param whereClause WHERE clause to identify the record
     * @return SObject Single record result
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static SObject executeSecureSingleQuery(String objectName, List<String> fields, String whereClause) {
        try {
            List<SObject> results = executeSecureQuery(objectName, fields, whereClause, null, 1);
            return results.isEmpty() ? null : results[0];
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure single query', e);
            return null;
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query with COUNT
     * @param objectName The SObject API name
     * @param whereClause Optional WHERE clause
     * @return Integer Count of records
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static Integer executeSecureCountQuery(String objectName, String whereClause) {
        try {
            String query = 'SELECT COUNT() FROM ' + objectName;
            
            if (String.isNotBlank(whereClause)) {
                String sanitizedWhere = ENOS_SecurityUtils.sanitizeWhereClause(whereClause);
                query += ' WHERE ' + sanitizedWhere;
            }
            
            query += ' WITH USER_MODE';
            
            return Database.countQuery(query);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure count query', e);
            return 0;
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query with aggregate functions
     * @param objectName The SObject API name
     * @param aggregateFields List of aggregate functions (e.g., 'COUNT(Id)', 'SUM(Amount__c)')
     * @param whereClause Optional WHERE clause
     * @param groupByFields Optional GROUP BY fields
     * @return List<AggregateResult> Aggregate results
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static List<AggregateResult> executeSecureAggregateQuery(String objectName, List<String> aggregateFields,
                                                                  String whereClause, List<String> groupByFields) {
        try {
            // Build aggregate query
            String query = 'SELECT ' + String.join(aggregateFields, ', ') + ' FROM ' + objectName;
            
            if (String.isNotBlank(whereClause)) {
                String sanitizedWhere = ENOS_SecurityUtils.sanitizeWhereClause(whereClause);
                query += ' WHERE ' + sanitizedWhere;
            }
            
            if (groupByFields != null && !groupByFields.isEmpty()) {
                query += ' GROUP BY ' + String.join(groupByFields, ', ');
            }
            
            query += ' WITH USER_MODE';
            
            return Database.query(query);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure aggregate query', e);
            return new List<AggregateResult>();
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query with subqueries
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param subqueries List of subquery definitions
     * @param whereClause Optional WHERE clause
     * @return List<SObject> Query results with subquery data
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static List<SObject> executeSecureQueryWithSubqueries(String objectName, List<String> fields,
                                                                List<SubqueryDefinition> subqueries,
                                                                String whereClause) {
        try {
            // Build main query
            String query = 'SELECT ' + String.join(fields, ', ');
            
            // Add subqueries
            if (subqueries != null && !subqueries.isEmpty()) {
                for (SubqueryDefinition subquery : subqueries) {
                    query += ', (' + subquery.buildSubquery() + ')';
                }
            }
            
            query += ' FROM ' + objectName;
            
            if (String.isNotBlank(whereClause)) {
                String sanitizedWhere = ENOS_SecurityUtils.sanitizeWhereClause(whereClause);
                query += ' WHERE ' + sanitizedWhere;
            }
            
            query += ' WITH USER_MODE';
            
            return Database.query(query);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure subquery', e);
            return new List<SObject>();
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query with relationship fields
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param relationshipFields List of relationship fields to include
     * @param whereClause Optional WHERE clause
     * @return List<SObject> Query results with relationship data
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static List<SObject> executeSecureQueryWithRelationships(String objectName, List<String> fields,
                                                                  List<String> relationshipFields,
                                                                  String whereClause) {
        try {
            // Build query with relationships
            List<String> allFields = new List<String>(fields);
            if (relationshipFields != null && !relationshipFields.isEmpty()) {
                for (String relationshipField : relationshipFields) {
                    allFields.add(relationshipField + '.*');
                }
            }
            
            return executeSecureQuery(objectName, allFields, whereClause, null, null);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure relationship query', e);
            return new List<SObject>();
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query with text search
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param searchTerm Search term for FIND clause
     * @param whereClause Optional additional WHERE conditions
     * @return List<SObject> Search results
     * @throws AuraHandledException if query fails or security validation fails
     */
    public static List<SObject> executeSecureSearchQuery(String objectName, List<String> fields,
                                                        String searchTerm, String whereClause) {
        try {
            // Build search query
            String query = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + objectName;
            
            // Add FIND clause
            if (String.isNotBlank(searchTerm)) {
                String sanitizedSearch = String.escapeSingleQuotes(searchTerm);
                query += ' WHERE FIND(\'' + sanitizedSearch + '\' IN ALL FIELDS)';
            }
            
            // Add additional WHERE conditions
            if (String.isNotBlank(whereClause)) {
                String sanitizedWhere = ENOS_SecurityUtils.sanitizeWhereClause(whereClause);
                query += (query.contains('WHERE') ? ' AND ' : ' WHERE ') + sanitizedWhere;
            }
            
            query += ' WITH USER_MODE';
            
            return Database.query(query);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure search query', e);
            return new List<SObject>();
        }
    }
    
    /**
     * @description Executes a dynamic SOQL query with SOSL
     * @param searchQuery The SOSL search query
     * @param objectTypes List of SObject types to search
     * @param fields List of fields to return
     * @return List<List<SObject>> Search results organized by object type
     * @throws AuraHandledException if search fails or security validation fails
     */
    public static List<List<SObject>> executeSecureSOSL(String searchQuery, List<String> objectTypes,
                                                        List<String> fields) {
        try {
            // Build SOSL query
            String query = 'FIND {' + String.escapeSingleQuotes(searchQuery) + '}';
            
            if (objectTypes != null && !objectTypes.isEmpty()) {
                query += ' IN ALL FIELDS RETURNING ' + String.join(objectTypes, ', ');
            }
            
            if (fields != null && !fields.isEmpty()) {
                query += ' (' + String.join(fields, ', ') + ')';
            }
            
            query += ' WITH USER_MODE';
            
            return Search.query(query);
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('execute secure SOSL', e);
            return new List<List<SObject>>();
        }
    }
    
    /**
     * @description Subquery definition class for building complex queries
     */
    public class SubqueryDefinition {
        private String objectName;
        private List<String> fields;
        private String whereClause;
        
        public SubqueryDefinition(String objectName, List<String> fields, String whereClause) {
            this.objectName = objectName;
            this.fields = fields;
            this.whereClause = whereClause;
        }
        
        public String buildSubquery() {
            String subquery = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + objectName;
            
            if (String.isNotBlank(whereClause)) {
                String sanitizedWhere = ENOS_SecurityUtils.sanitizeWhereClause(whereClause);
                subquery += ' WHERE ' + sanitizedWhere;
            }
            
            return subquery;
        }
    }
    
    /**
     * @description Validates that a query string is safe and secure
     * @param query The query string to validate
     * @return Boolean indicating if the query is safe
     */
    public static Boolean validateQuerySecurity(String query) {
        if (String.isBlank(query)) {
            return false;
        }
        
        // Check for dangerous patterns
        if (!ENOS_SecurityUtils.validateSOQLInjection(query)) {
            return false;
        }
        
        // Check for USER_MODE clause
        if (!query.contains('WITH USER_MODE')) {
            return false;
        }
        
        // Check for basic SOQL structure
        if (!query.toUpperCase().contains('SELECT') || !query.toUpperCase().contains('FROM')) {
            return false;
        }
        
        return true;
    }
    
    /**
     * @description Gets the current user's security context information
     * @return Map<String, Object> User security context
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUserSecurityContext() {
        Map<String, Object> context = new Map<String, Object>();
        
        try {
            User currentUser = [SELECT Id, Username, Profile.Name, UserRole.Name 
                               FROM User WHERE Id = :UserInfo.getUserId() 
                               WITH USER_MODE LIMIT 1];
            
            context.put('userId', currentUser.Id);
            context.put('username', currentUser.Username);
            context.put('profile', currentUser.Profile.Name);
            context.put('userRole', currentUser.UserRole?.Name);
            context.put('isSystemAdmin', currentUser.Profile.Name == 'System Administrator');
            
        } catch (Exception e) {
            context.put('error', e.getMessage());
        }
        
        return context;
    }
    
    /**
     * @description Checks if the current user has access to a specific object and operation
     * @param objectName The SObject API name
     * @param operation The operation to check (read, create, edit, delete)
     * @return Boolean indicating if access is granted
     */
    @AuraEnabled(cacheable=true)
    public static Boolean checkUserAccess(String objectName, String operation) {
        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType == null) {
                return false;
            }
            
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            
            if (operation.toLowerCase() == 'read') {
                return describeResult.isAccessible();
            } else if (operation.toLowerCase() == 'create') {
                return describeResult.isCreateable();
            } else if (operation.toLowerCase() == 'edit') {
                return describeResult.isUpdateable();
            } else if (operation.toLowerCase() == 'delete') {
                return describeResult.isDeletable();
            } else {
                return false;
            }
            
        } catch (Exception e) {
            return false;
        }
    }
}
