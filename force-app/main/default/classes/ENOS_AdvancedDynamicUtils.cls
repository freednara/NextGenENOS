/**
 * @description Advanced Dynamic Apex utility class for ENOS e-commerce platform
 * Provides complex query building, performance monitoring, and advanced dynamic operations
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_AdvancedDynamicUtils {
    
    // Performance monitoring
    private static final Map<String, Long> QUERY_PERFORMANCE = new Map<String, Long>();
    private static final Map<String, Integer> QUERY_COUNT = new Map<String, Integer>();
    
    // Advanced query patterns with support for complex operations
    private static final Map<String, String> QUERY_TEMPLATES = new Map<String, String>{
        'product_search' => 'SELECT {0} FROM Product2 WHERE IsActive = true {1} {2} WITH USER_MODE',
        'cart_analysis' => 'SELECT {0} FROM Cart_Item__c WHERE Cart__r.Status__c = \'Active\' {1} {2} WITH USER_MODE',
        'user_activity' => 'SELECT {0} FROM View_Tracking__c WHERE User_Contact__c = :userId {1} {2} WITH USER_MODE',
        'sales_analytics' => 'SELECT {0} FROM Order WHERE Status = \'Activated\' {1} GROUP BY {2} HAVING {3} {4} WITH USER_MODE',
        'inventory_tracking' => 'SELECT {0} FROM Product2 WHERE Stock_Quantity__c > 0 {1} ORDER BY {2} {3} WITH USER_MODE',
        'customer_insights' => 'SELECT {0} FROM Account WHERE Type = \'Customer\' {1} GROUP BY {2} HAVING {3} {4} WITH USER_MODE'
    };
    
    /**
     * @description Builds complex dynamic queries with advanced filtering and aggregation
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param filters Map of field filters with operators
     * @param aggregations List of aggregation functions
     * @param groupBy List of fields to group by
     * @param havingClause HAVING clause for aggregated results
     * @param orderByClause ORDER BY clause
     * @param limitClause LIMIT clause
     * @return Complex SOQL query string
     * @throws AuraHandledException if query construction fails
     */
    public static String buildComplexQuery(String objectName, List<String> fields, 
                                         Map<String, Object> filters, List<String> aggregations,
                                         List<String> groupBy, String havingClause,
                                         String orderByClause, Integer limitClause) {
        try {
            // 1. Security validation first
            ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'read');
            if (fields != null && !fields.isEmpty()) {
                ENOS_SecurityUtils.checkDynamicFieldAccess(objectName, fields);
            }
            
            // 2. Build SELECT clause with aggregations
            String selectClause = buildComplexSelectClause(fields, aggregations);
            
            // 3. Build FROM clause
            String fromClause = ' FROM ' + objectName;
            
            // 4. Build WHERE clause with advanced filters
            String whereClause = buildAdvancedWhereClause(filters);
            
            // 5. Build GROUP BY clause
            String groupByClause = buildGroupByClause(groupBy);
            
            // 6. Build HAVING clause
            String havingPart = buildHavingClause(havingClause);
            
            // 7. Build ORDER BY clause
            String orderByPart = buildOrderByClause(orderByClause);
            
            // 8. Build LIMIT clause
            String limitPart = buildLimitClause(limitClause);
            
            // 9. Add security enforcement with USER_MODE for complete security coverage
            String securityClause = ' WITH USER_MODE';
            
            // 10. Combine all clauses
            String query = selectClause + fromClause + whereClause + groupByClause + 
                          havingPart + orderByPart + limitPart + securityClause;
            
            return query;
            
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('build complex query', e);
            return null;
        }
    }
    
    /**
     * @description Builds SELECT clause with aggregation functions
     * @param fields List of field names
     * @param aggregations List of aggregation functions
     * @return SELECT clause string
     */
    private static String buildComplexSelectClause(List<String> fields, List<String> aggregations) {
        if (fields == null || fields.isEmpty()) {
            return 'SELECT Id';
        }
        
        List<String> selectParts = new List<String>();
        
        // Add regular fields
        for (String field : fields) {
            if (String.isNotBlank(field)) {
                selectParts.add(field);
            }
        }
        
        // Add aggregation functions
        if (aggregations != null && !aggregations.isEmpty()) {
            for (String agg : aggregations) {
                if (String.isNotBlank(agg)) {
                    selectParts.add(agg);
                }
            }
        }
        
        return 'SELECT ' + String.join(selectParts, ', ');
    }
    
    /**
     * @description Builds advanced WHERE clause with complex filters
     * @param filters Map of field filters with operators
     * @return WHERE clause string
     */
    private static String buildAdvancedWhereClause(Map<String, Object> filters) {
        if (filters == null || filters.isEmpty()) {
            return '';
        }
        
        List<String> conditions = new List<String>();
        
        for (String field : filters.keySet()) {
            Object value = filters.get(field);
            
            if (value != null && String.isNotBlank(field)) {
                // Validate field name
                if (!ENOS_SecurityUtils.isValidFieldName(field)) {
                    continue;
                }
                
                String condition = buildFilterCondition(field, value);
                if (String.isNotBlank(condition)) {
                    conditions.add(condition);
                }
            }
        }
        
        if (conditions.isEmpty()) {
            return '';
        }
        
        return ' WHERE ' + String.join(conditions, ' AND ');
    }
    
    /**
     * @description Builds individual filter condition
     * @param field Field name
     * @param value Filter value
     * @return Filter condition string
     */
    private static String buildFilterCondition(String field, Object value) {
        if (value == null) {
            return field + ' = null';
        }
        
        if (value instanceof String) {
            String strValue = (String) value;
            if (strValue.startsWith('LIKE:')) {
                String likeValue = strValue.substring(5);
                return field + ' LIKE \'%' + String.escapeSingleQuotes(likeValue) + '%\'';
            } else if (strValue.startsWith('IN:')) {
                String inValue = strValue.substring(3);
                return field + ' IN (' + inValue + ')';
            } else if (strValue.startsWith('NOT_IN:')) {
                String notInValue = strValue.substring(7);
                return field + ' NOT IN (' + notInValue + ')';
            } else if (strValue.startsWith('>')) {
                String numValue = strValue.substring(1);
                return field + ' > ' + numValue;
            } else if (strValue.startsWith('<')) {
                String numValue = strValue.substring(1);
                return field + ' < ' + numValue;
            } else if (strValue.startsWith('>=')) {
                String numValue = strValue.substring(2);
                return field + ' >= ' + numValue;
            } else if (strValue.startsWith('<=')) {
                String numValue = strValue.substring(2);
                return field + ' <= ' + numValue;
            } else {
                return field + ' = \'' + String.escapeSingleQuotes(strValue) + '\'';
            }
        } else if (value instanceof Boolean) {
            return field + ' = ' + value;
        } else if (value instanceof Decimal || value instanceof Integer || value instanceof Long) {
            return field + ' = ' + value;
        } else if (value instanceof Date) {
            Date dateValue = (Date) value;
            return field + ' = ' + dateValue.format();
        } else if (value instanceof Datetime) {
            Datetime dtValue = (Datetime) value;
            return field + ' = ' + dtValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        
        return field + ' = \'' + String.valueOf(value) + '\'';
    }
    
    /**
     * @description Builds GROUP BY clause
     * @param groupBy List of fields to group by
     * @return GROUP BY clause string
     */
    private static String buildGroupByClause(List<String> groupBy) {
        if (groupBy == null || groupBy.isEmpty()) {
            return '';
        }
        
        List<String> validFields = new List<String>();
        for (String field : groupBy) {
            if (String.isNotBlank(field) && ENOS_SecurityUtils.isValidFieldName(field)) {
                validFields.add(field);
            }
        }
        
        if (validFields.isEmpty()) {
            return '';
        }
        
        return ' GROUP BY ' + String.join(validFields, ', ');
    }
    
    /**
     * @description Builds HAVING clause
     * @param havingClause HAVING clause string
     * @return HAVING clause string
     */
    private static String buildHavingClause(String havingClause) {
        if (String.isBlank(havingClause)) {
            return '';
        }
        
        // Validate HAVING clause
        if (!ENOS_SecurityUtils.validateSOQLInjection(havingClause)) {
            return '';
        }
        
        return ' HAVING ' + String.escapeSingleQuotes(havingClause);
    }
    
    /**
     * @description Builds ORDER BY clause
     * @param orderByClause ORDER BY clause string
     * @return ORDER BY clause string
     */
    private static String buildOrderByClause(String orderByClause) {
        if (String.isBlank(orderByClause)) {
            return '';
        }
        
        // Validate ORDER BY clause
        if (!ENOS_SecurityUtils.validateSOQLInjection(orderByClause)) {
            return '';
        }
        
        return ' ORDER BY ' + String.escapeSingleQuotes(orderByClause);
    }
    
    /**
     * @description Builds LIMIT clause
     * @param limitClause LIMIT value
     * @return LIMIT clause string
     */
    private static String buildLimitClause(Integer limitClause) {
        if (limitClause == null || limitClause <= 0) {
            return '';
        }
        
        return ' LIMIT ' + limitClause;
    }
    
    /**
     * @description Executes complex dynamic query with performance monitoring
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param filters Map of field filters with operators
     * @param aggregations List of aggregation functions
     * @param groupBy List of fields to group by
     * @param havingClause HAVING clause for aggregated results
     * @param orderByClause ORDER BY clause
     * @param limitClause LIMIT clause
     * @return List of SObject results
     * @throws AuraHandledException if query execution fails
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> executeComplexQuery(String objectName, List<String> fields, 
                                                   Map<String, Object> filters, List<String> aggregations,
                                                   List<String> groupBy, String havingClause,
                                                   String orderByClause, Integer limitClause) {
        Long startTime = System.currentTimeMillis();
        String queryKey = objectName + '_complex';
        
        try {
            // 1. Build complex query
            String query = buildComplexQuery(objectName, fields, filters, aggregations, 
                                           groupBy, havingClause, orderByClause, limitClause);
            
            // 2. Execute query
            List<SObject> results = Database.query(query);
            
            // 3. Record performance metrics
            recordQueryPerformance(queryKey, System.currentTimeMillis() - startTime);
            
            return results;
            
        } catch (Exception e) {
            // Record failed query performance
            recordQueryPerformance(queryKey, System.currentTimeMillis() - startTime);
            
            ENOS_ExceptionUtils.throwOperationFailure('execute complex query', e);
            return new List<SObject>();
        }
    }
    
    /**
     * @description Records query performance metrics
     * @param queryKey Unique identifier for the query
     * @param executionTime Execution time in milliseconds
     */
    private static void recordQueryPerformance(String queryKey, Long executionTime) {
        if (QUERY_PERFORMANCE.containsKey(queryKey)) {
            Long totalTime = QUERY_PERFORMANCE.get(queryKey) + executionTime;
            QUERY_PERFORMANCE.put(queryKey, totalTime);
        } else {
            QUERY_PERFORMANCE.put(queryKey, executionTime);
        }
        
        if (QUERY_COUNT.containsKey(queryKey)) {
            Integer count = QUERY_COUNT.get(queryKey) + 1;
            QUERY_COUNT.put(queryKey, count);
        } else {
            QUERY_COUNT.put(queryKey, 1);
        }
    }
    
    /**
     * @description Gets performance metrics for all queries
     * @return Map containing performance statistics
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPerformanceMetrics() {
        Map<String, Object> metrics = new Map<String, Object>();
        
        for (String queryKey : QUERY_PERFORMANCE.keySet()) {
            Long totalTime = QUERY_PERFORMANCE.get(queryKey);
            Integer count = QUERY_COUNT.get(queryKey);
            
            Map<String, Object> queryMetrics = new Map<String, Object>();
            queryMetrics.put('totalExecutionTime', totalTime);
            queryMetrics.put('executionCount', count);
            queryMetrics.put('averageExecutionTime', count > 0 ? totalTime / count : 0);
            
            metrics.put(queryKey, queryMetrics);
        }
        
        return metrics;
    }
    
    /**
     * @description Clears performance metrics
     */
    @AuraEnabled
    public static void clearPerformanceMetrics() {
        QUERY_PERFORMANCE.clear();
        QUERY_COUNT.clear();
    }
    
    /**
     * @description Builds query using predefined templates
     * @param templateName Name of the template to use
     * @param fields List of fields to select
     * @param whereConditions Additional WHERE conditions
     * @param orderByClause ORDER BY clause
     * @return SOQL query string
     */
    public static String buildTemplateQuery(String templateName, List<String> fields, 
                                          String whereConditions, String orderByClause) {
        if (!QUERY_TEMPLATES.containsKey(templateName)) {
            ENOS_ExceptionUtils.throwDataNotFound('Query template', templateName);
            return null;
        }
        
        String template = QUERY_TEMPLATES.get(templateName);
        String fieldList = fields != null ? String.join(fields, ', ') : 'Id';
        String wherePart = String.isNotBlank(whereConditions) ? ' AND ' + whereConditions : '';
        String orderPart = String.isNotBlank(orderByClause) ? ' ORDER BY ' + orderByClause : '';
        
        return String.format(template, new List<String>{fieldList, wherePart, orderPart});
    }
    
    /**
     * @description Validates complex query parameters
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param filters Map of field filters
     * @return Boolean indicating if parameters are valid
     */
    public static Boolean validateComplexQueryParameters(String objectName, List<String> fields, 
                                                       Map<String, Object> filters) {
        try {
            // Validate object access
            ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'read');
            
            // Validate fields
            if (fields != null && !fields.isEmpty()) {
                ENOS_SecurityUtils.checkDynamicFieldAccess(objectName, fields);
            }
            
            // Validate filters
            if (filters != null && !filters.isEmpty()) {
                for (String field : filters.keySet()) {
                    if (!ENOS_SecurityUtils.isValidFieldName(field)) {
                        return false;
                    }
                }
            }
            
            return true;
            
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * @description Executes operations with retry mechanism and exponential backoff
     * @param operation The operation to execute (callable interface)
     * @param maxRetries Maximum number of retry attempts
     * @param baseDelay Base delay in milliseconds
     * @return Object Result of the operation
     * @throws AuraHandledException if operation fails after all retries
     */
    public static Object executeWithRetry(Callable operation, Integer maxRetries, Integer baseDelay) {
        Integer retryCount = 0;
        Exception lastException;
        
        while (retryCount <= maxRetries) {
            try {
                return operation.call();
                
            } catch (Exception e) {
                lastException = e;
                retryCount++;
                
                if (retryCount <= maxRetries) {
                    // Exponential backoff with jitter
                    Integer delay = baseDelay * Math.pow(2, retryCount - 1).intValue();
                    Integer jitter = Math.mod(Crypto.getRandomInteger(), delay / 4);
                    Integer totalDelay = delay + jitter;
                    
                    System.debug('Operation failed, retrying in ' + totalDelay + 'ms. Attempt ' + retryCount + '/' + maxRetries);
                    
                    // Note: Thread.sleep is not available in Apex
                    // In production, consider using Queueable jobs or Platform Events for retry logic
                    System.debug('Retry delay: ' + totalDelay + 'ms (simulated in Apex)');
                }
            }
        }
        
        // All retries exhausted
                    ENOS_ExceptionUtils.throwRetryExhausted('execute operation', maxRetries, lastException);
                    return null;
    }
    
    /**
     * @description Callable interface for retry mechanism
     */
    public interface Callable {
        Object call();
    }

    /**
     * @description Builds advanced analytics queries with aggregations and grouping
     * @param objectName The SObject API name
     * @param fields List of fields to select (can include aggregate functions)
     * @param filters Map of field filters with operators
     * @param groupBy List of fields to group by
     * @param havingClause HAVING clause for aggregated results
     * @param orderByClause ORDER BY clause
     * @param limitClause LIMIT clause
     * @return Advanced SOQL query string
     * @throws AuraHandledException if query construction fails
     */
    public static String buildAnalyticsQuery(String objectName, List<String> fields, 
                                           Map<String, Object> filters, List<String> groupBy,
                                           String havingClause, String orderByClause, Integer limitClause) {
        try {
            // 1. Security validation first
            ENOS_SecurityUtils.checkObjectReadable(objectName);
            
            // 2. Build SELECT clause with field validation
            String selectClause = buildSelectClause(fields, objectName);
            
            // 3. Build FROM clause
            String fromClause = 'FROM ' + objectName;
            
            // 4. Build WHERE clause
            String whereClause = buildWhereClause(filters, objectName);
            
            // 5. Build GROUP BY clause
            String groupByClause = '';
            if (groupBy != null && !groupBy.isEmpty()) {
                groupByClause = 'GROUP BY ' + String.join(groupBy, ', ');
            }
            
            // 6. Build HAVING clause
            String havingClauseFinal = '';
            if (String.isNotBlank(havingClause)) {
                havingClauseFinal = 'HAVING ' + havingClause;
            }
            
            // 7. Build ORDER BY clause
            String orderByClauseFinal = '';
            if (String.isNotBlank(orderByClause)) {
                orderByClauseFinal = 'ORDER BY ' + orderByClause;
            }
            
            // 8. Build LIMIT clause
            String limitClauseFinal = '';
            if (limitClause != null && limitClause > 0) {
                limitClauseFinal = 'LIMIT ' + limitClause;
            }
            
            // 9. Assemble query with security
            String query = String.join(new List<String>{
                selectClause, fromClause, whereClause, groupByClause, 
                havingClauseFinal, orderByClauseFinal, limitClauseFinal
            }, ' ').trim();
            
            // 10. Add security clause
            query += ' WITH USER_MODE';
            
            // 11. Validate final query
            validateQuery(query);
            
            return query;
            
        } catch (Exception e) {
            ENOS_LoggingUtils.logError('Advanced Analytics Query Building', e);
            ENOS_ExceptionUtils.throwOperationFailure('build analytics query', e);
            return null;
        }
    }

    /**
     * @description Executes advanced analytics query with performance monitoring
     * @param objectName The SObject API name
     * @param fields List of fields to select
     * @param filters Map of field filters with operators
     * @param groupBy List of fields to group by
     * @param havingClause HAVING clause for aggregated results
     * @param orderByClause ORDER BY clause
     * @param limitClause LIMIT clause
     * @return List of SObject results
     * @throws AuraHandledException if query execution fails
     */
    public static List<SObject> executeAnalyticsQuery(String objectName, List<String> fields, 
                                                     Map<String, Object> filters, List<String> groupBy,
                                                     String havingClause, String orderByClause, Integer limitClause) {
        Long startTime = System.currentTimeMillis();
        String queryKey = objectName + '_analytics';
        
        try {
            // 1. Build analytics query
            String query = buildAnalyticsQuery(objectName, fields, filters, groupBy, 
                                             havingClause, orderByClause, limitClause);
            
            // 2. Execute query
            List<SObject> results = Database.query(query);
            
            // 3. Record performance metrics
            recordQueryPerformance(queryKey, System.currentTimeMillis() - startTime);
            
            return results;
            
        } catch (Exception e) {
            // Record failed query performance
            recordQueryPerformance(queryKey, System.currentTimeMillis() - startTime);
            
            ENOS_ExceptionUtils.throwOperationFailure('execute analytics query', e);
            return new List<SObject>();
        }
    }

    /**
     * @description Builds dynamic subqueries for complex relationships
     * @param parentObject The parent SObject API name
     * @param childObject The child SObject API name
     * @param relationshipField The relationship field name
     * @param childFields List of child fields to select
     * @param childFilters Map of child field filters
     * @return Subquery string
     * @throws AuraHandledException if subquery construction fails
     */
    public static String buildSubquery(String parentObject, String childObject, String relationshipField,
                                     List<String> childFields, Map<String, Object> childFilters) {
        try {
            // 1. Security validation
            ENOS_SecurityUtils.checkObjectReadable(parentObject);
            ENOS_SecurityUtils.checkObjectReadable(childObject);
            
            // 2. Build child field list
            String childFieldList = String.join(childFields, ', ');
            
            // 3. Build child WHERE clause
            String childWhereClause = buildWhereClause(childFilters, childObject);
            
            // 4. Assemble subquery
            String subquery = '(SELECT ' + childFieldList + ' FROM ' + childObject;
            if (String.isNotBlank(childWhereClause)) {
                subquery += ' ' + childWhereClause;
            }
            subquery += ' WITH USER_MODE)';
            
            return subquery;
            
        } catch (Exception e) {
            ENOS_LoggingUtils.logError('Subquery Building', e);
            ENOS_ExceptionUtils.throwOperationFailure('build subquery', e);
            return null;
        }
    }

    /**
     * @description Creates a query cache for frequently accessed data
     * @param cacheKey Unique identifier for the cache
     * @param query The SOQL query to cache
     * @param cacheDurationMinutes How long to cache the results
     * @return Cached query results
     */
    public static List<SObject> getCachedQueryResults(String cacheKey, String query, Integer cacheDurationMinutes) {
        try {
            // Check if caching is enabled
            if (!ENOS_ConfigurationUtils.isPerformanceMonitoringEnabled()) {
                return Database.query(query);
            }
            
            // Check cache for existing results
            if (QUERY_CACHE.containsKey(cacheKey)) {
                CacheEntry entry = QUERY_CACHE.get(cacheKey);
                if (DateTime.now().addMinutes(-cacheDurationMinutes) < entry.timestamp) {
                    // Cache hit - return cached results
                    ENOS_LoggingUtils.logPerformance('Query Cache', 'Cache Hit', 1, 'count');
                    return entry.results;
                }
            }
            
            // Cache miss - execute query and cache results
            List<SObject> results = Database.query(query);
            QUERY_CACHE.put(cacheKey, new CacheEntry(results, DateTime.now()));
            
            ENOS_LoggingUtils.logPerformance('Query Cache', 'Cache Miss', 1, 'count');
            return results;
            
        } catch (Exception e) {
            ENOS_LoggingUtils.logError('Query Caching', e);
            // Fallback to direct query execution
            return Database.query(query);
        }
    }

    /**
     * @description Clears the query cache
     * @param cacheKey Optional specific cache key to clear, or null to clear all
     */
    public static void clearQueryCache(String cacheKey) {
        if (String.isBlank(cacheKey)) {
            QUERY_CACHE.clear();
            ENOS_LoggingUtils.logInfo('Query Cache', 'All cache entries cleared');
        } else {
            QUERY_CACHE.remove(cacheKey);
            ENOS_LoggingUtils.logInfo('Query Cache', 'Cache entry cleared: ' + cacheKey);
        }
    }

    // Cache storage
    private static final Map<String, CacheEntry> QUERY_CACHE = new Map<String, CacheEntry>();
    
    /**
     * @description Cache entry class for storing query results
     */
    public class CacheEntry {
        public List<SObject> results;
        public DateTime timestamp;
        
        public CacheEntry(List<SObject> results, DateTime timestamp) {
            this.results = results;
            this.timestamp = timestamp;
        }
    }
    
    /**
     * @description Builds SELECT clause for dynamic queries
     * @param fields List of fields to select
     * @param objectName The SObject API name
     * @return SELECT clause string
     */
    private static String buildSelectClause(List<String> fields, String objectName) {
        if (fields == null || fields.isEmpty()) {
            return 'SELECT Id';
        }
        
        // Validate fields and build clause
        List<String> validFields = new List<String>();
        for (String field : fields) {
            if (ENOS_SecurityUtils.isValidFieldName(field)) {
                validFields.add(field);
            }
        }
        
        if (validFields.isEmpty()) {
            return 'SELECT Id';
        }
        
        return 'SELECT ' + String.join(validFields, ', ');
    }
    
    /**
     * @description Builds WHERE clause for dynamic queries
     * @param filters Map of field filters with operators
     * @param objectName The SObject API name
     * @return WHERE clause string
     */
    private static String buildWhereClause(Map<String, Object> filters, String objectName) {
        if (filters == null || filters.isEmpty()) {
            return '';
        }
        
        List<String> conditions = new List<String>();
        
        for (String field : filters.keySet()) {
            Object value = filters.get(field);
            
            if (value instanceof Map<String, Object>) {
                // Complex filter with operator
                Map<String, Object> filterMap = (Map<String, Object>) value;
                String operator = (String) filterMap.get('operator');
                Object filterValue = filterMap.get('values');
                
                if (operator == 'BETWEEN' && filterValue instanceof List<DateTime>) {
                    List<DateTime> dates = (List<DateTime>) filterValue;
                    if (dates.size() == 2) {
                        conditions.add(field + ' >= ' + dates[0].format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                        conditions.add(field + ' <= ' + dates[1].format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                    }
                } else if (operator == 'IN' && filterValue instanceof List<String>) {
                    List<String> values = (List<String>) filterValue;
                    conditions.add(field + ' IN (' + String.join(values, ',') + ')');
                }
            } else {
                // Simple equality filter
                if (value instanceof String) {
                    conditions.add(field + ' = \'' + String.escapeSingleQuotes((String) value) + '\'');
                } else if (value instanceof Boolean) {
                    conditions.add(field + ' = ' + value);
                } else {
                    conditions.add(field + ' = ' + value);
                }
            }
        }
        
        if (conditions.isEmpty()) {
            return '';
        }
        
        return 'WHERE ' + String.join(conditions, ' AND ');
    }
    
    /**
     * @description Validates SOQL query for security and syntax
     * @param query The SOQL query to validate
     * @throws AuraHandledException if query is invalid
     */
    private static void validateQuery(String query) {
        // Basic security validation
        if (query.toLowerCase().contains('from all')) {
            ENOS_ExceptionUtils.throwInvalidQueryPattern('FROM ALL is not allowed');
        }
        
        if (query.toLowerCase().contains('limit 0')) {
            ENOS_ExceptionUtils.throwInvalidQueryPattern('LIMIT 0 is not allowed');
        }
        
        // Check for potential injection patterns
        if (query.contains(';') || query.contains('--')) {
            ENOS_ExceptionUtils.throwInjectionAttempt('SQL');
        }
    }
}
