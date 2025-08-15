/**
 * @description Test class for ENOS_AdvancedDynamicUtils
 * Tests all advanced dynamic Apex functionality with comprehensive coverage
 * @author ENOS Development Team
 * @version 1.0.0
 */
@IsTest
public class ENOS_AdvancedDynamicUtilsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test products
        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 1; i <= 10; i++) {
            testProducts.add(new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'TEST-' + i,
                Description = 'Test product description ' + i,
                IsActive = true,
                Family = 'Electronics'
            ));
        }
        insert testProducts;
        

    }
    
    @IsTest
    static void testBuildComplexQuery() {
        // Test basic complex query building
        List<String> fields = new List<String>{'Id', 'Name', 'ProductCode'};
        Map<String, Object> filters = new Map<String, Object>{
            'IsActive' => true,
            'Family' => 'Electronics'
        };
        List<String> aggregations = new List<String>{'COUNT(Id)'};
        List<String> groupBy = new List<String>{'Family'};
        
        String query = ENOS_AdvancedDynamicUtils.buildComplexQuery(
            'Product2', fields, filters, aggregations, groupBy, 
            'COUNT(Id) > 1', 'Family ASC', 10
        );
        
        System.assert(query.contains('SELECT Id, Name, ProductCode, COUNT(Id)'), 'Query should contain selected fields and aggregations');
        System.assert(query.contains('FROM Product2'), 'Query should contain FROM clause');
        System.assert(query.contains('WHERE IsActive = true AND Family = \'Electronics\''), 'Query should contain WHERE clause');
        System.assert(query.contains('GROUP BY Family'), 'Query should contain GROUP BY clause');
        System.assert(query.contains('HAVING COUNT(Id) > 1'), 'Query should contain HAVING clause');
        System.assert(query.contains('ORDER BY Family ASC'), 'Query should contain ORDER BY clause');
        System.assert(query.contains('LIMIT 10'), 'Query should contain LIMIT clause');
        System.assert(query.contains('WITH USER_MODE'), 'Query should contain security enforcement');
    }
    
    @IsTest
    static void testBuildComplexQueryWithNullParameters() {
        // Test query building with null parameters
        String query = ENOS_AdvancedDynamicUtils.buildComplexQuery(
            'Product2', null, null, null, null, null, null, null
        );
        
        System.assert(query.contains('SELECT Id'), 'Query should have default Id field');
        System.assert(query.contains('FROM Product2'), 'Query should contain FROM clause');
        System.assert(query.contains('WITH USER_MODE'), 'Query should contain security enforcement');
    }
    
    @IsTest
    static void testExecuteComplexQuery() {
        // Test complex query execution
        List<String> fields = new List<String>{'Id', 'Name', 'ProductCode'};
        Map<String, Object> filters = new Map<String, Object>{
            'IsActive' => true,
            'Family' => 'Electronics'
        };
        
        List<SObject> results = ENOS_AdvancedDynamicUtils.executeComplexQuery(
            'Product2', fields, filters, null, null, null, 'Name ASC', 5
        );
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return some results');
        System.assert(results.size() <= 5, 'Should respect LIMIT clause');
    }
    
    @IsTest
    static void testAdvancedFiltering() {
        // Test advanced filtering with operators
        Map<String, Object> filters = new Map<String, Object>{
            'Name' => 'LIKE:Product',
            'IsActive' => true,
            'Family' => 'Electronics'
        };
        
        String query = ENOS_AdvancedDynamicUtils.buildComplexQuery(
            'Product2', new List<String>{'Id', 'Name'}, filters, null, null, null, null, null
        );
        
        System.assert(query.contains('Name LIKE \'%Product%\''), 'Query should contain LIKE filter');
        System.assert(query.contains('Name LIKE \'%Product%\''), 'Query should contain LIKE filter');
        System.assert(query.contains('IsActive = true'), 'Query should contain boolean filter');
        System.assert(query.contains('Family = \'Electronics\''), 'Query should contain string filter');
    }
    
    @IsTest
    static void testAggregationFunctions() {
        // Test aggregation functions
        List<String> aggregations = new List<String>{
            'COUNT(Id)',
            'COUNT(Name)'
        };
        
        String query = ENOS_AdvancedDynamicUtils.buildComplexQuery(
            'Product2', new List<String>{'Family'}, null, aggregations, 
            new List<String>{'Family'}, null, null, null
        );
        
        for (String agg : aggregations) {
            System.assert(query.contains(agg), 'Query should contain aggregation: ' + agg);
        }
        System.assert(query.contains('GROUP BY Family'), 'Query should contain GROUP BY clause');
    }
    
    @IsTest
    static void testTemplateQueries() {
        // Test predefined query templates
        List<String> fields = new List<String>{'Id', 'Name', 'ProductCode'};
        
        String productQuery = ENOS_AdvancedDynamicUtils.buildTemplateQuery(
            'product_search', fields, 'Family = \'Electronics\'', 'Name ASC'
        );
        
        System.assert(productQuery.contains('SELECT Id, Name, ProductCode'), 'Template query should contain fields');
        System.assert(productQuery.contains('FROM Product2'), 'Template query should contain FROM clause');
        System.assert(productQuery.contains('WHERE IsActive = true'), 'Template query should contain base WHERE clause');
        System.assert(productQuery.contains('AND Family = \'Electronics\''), 'Template query should contain additional conditions');
        System.assert(productQuery.contains('ORDER BY Name ASC'), 'Template query should contain ORDER BY clause');
    }
    
    @IsTest
    static void testPerformanceMetrics() {
        // Test performance monitoring
        List<String> fields = new List<String>{'Id', 'Name'};
        
        // Execute some queries to generate metrics
        for (Integer i = 0; i < 3; i++) {
            ENOS_AdvancedDynamicUtils.executeComplexQuery(
                'Product2', fields, null, null, null, null, null, 5
            );
        }
        
        // Get performance metrics
        Map<String, Object> metrics = ENOS_AdvancedDynamicUtils.getPerformanceMetrics();
        
        System.assertNotEquals(null, metrics, 'Performance metrics should not be null');
        System.assert(metrics.containsKey('Product2_complex'), 'Should have Product2 metrics');
        
        Map<String, Object> productMetrics = (Map<String, Object>) metrics.get('Product2_complex');
        System.assertNotEquals(null, productMetrics.get('executionCount'), 'Should have execution count');
        System.assertNotEquals(null, productMetrics.get('totalExecutionTime'), 'Should have total execution time');
        System.assertNotEquals(null, productMetrics.get('averageExecutionTime'), 'Should have average execution time');
    }
    
    @IsTest
    static void testClearPerformanceMetrics() {
        // Test clearing performance metrics
        List<String> fields = new List<String>{'Id', 'Name'};
        
        // Execute a query to generate metrics
        ENOS_AdvancedDynamicUtils.executeComplexQuery(
            'Product2', fields, null, null, null, null, null, 5
        );
        
        // Verify metrics exist
        Map<String, Object> metrics = ENOS_AdvancedDynamicUtils.getPerformanceMetrics();
        System.assert(metrics.containsKey('Product2_complex'), 'Should have Product2 metrics');
        
        // Clear metrics
        ENOS_AdvancedDynamicUtils.clearPerformanceMetrics();
        
        // Verify metrics are cleared
        metrics = ENOS_AdvancedDynamicUtils.getPerformanceMetrics();
        System.assertEquals(0, metrics.size(), 'Metrics should be cleared');
    }
    
    @IsTest
    static void testParameterValidation() {
        // Test parameter validation
        Boolean isValid = ENOS_AdvancedDynamicUtils.validateComplexQueryParameters(
            'Product2', 
            new List<String>{'Id', 'Name'}, 
            new Map<String, Object>{'IsActive' => true}
        );
        
        System.assert(isValid, 'Valid parameters should pass validation');
        
        // Test invalid object
        Boolean isInvalid = ENOS_AdvancedDynamicUtils.validateComplexQueryParameters(
            'InvalidObject', 
            new List<String>{'Id'}, 
            null
        );
        
        System.assert(!isInvalid, 'Invalid object should fail validation');
    }
    
    @IsTest
    static void testSecurityEnforcement() {
        // Test that security checks are enforced
        try {
            ENOS_AdvancedDynamicUtils.executeComplexQuery(
                'InvalidObject', 
                new List<String>{'Id'}, 
                null, null, null, null, null, null
            );
            System.assert(false, 'Should throw security exception for invalid object');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Security Error'), 'Should throw security error');
        }
    }
    
    @IsTest
    static void testComplexQueryWithAllClauses() {
        // Test complex query with all possible clauses
        List<String> fields = new List<String>{'Id', 'Name', 'Family'};
        Map<String, Object> filters = new Map<String, Object>{
            'IsActive' => true,
            'Stock_Quantity__c' => '>0'
        };
        List<String> aggregations = new List<String>{'COUNT(Id)'};
        List<String> groupBy = new List<String>{'Family'};
        String havingClause = 'COUNT(Id) > 1';
        String orderByClause = 'Family ASC';
        Integer limitClause = 10;
        
        String query = ENOS_AdvancedDynamicUtils.buildComplexQuery(
            'Product2', fields, filters, aggregations, groupBy, 
            havingClause, orderByClause, limitClause
        );
        
        // Verify all clauses are present
        System.assert(query.contains('SELECT Id, Name, Family, COUNT(Id)'), 'Should contain all fields and aggregations');
        System.assert(query.contains('WHERE IsActive = true AND Stock_Quantity__c > 0'), 'Should contain WHERE clause');
        System.assert(query.contains('GROUP BY Family'), 'Should contain GROUP BY clause');
        System.assert(query.contains('HAVING COUNT(Id) > 1'), 'Should contain HAVING clause');
        System.assert(query.contains('ORDER BY Family ASC'), 'Should contain ORDER BY clause');
        System.assert(query.contains('LIMIT 10'), 'Should contain LIMIT clause');
        System.assert(query.contains('WITH USER_MODE'), 'Should contain security enforcement');
    }
    
    @IsTest
    static void testErrorHandling() {
        // Test error handling for invalid queries
        try {
            ENOS_AdvancedDynamicUtils.executeComplexQuery(
                'Product2', 
                new List<String>{'InvalidField'}, 
                null, null, null, null, null, null
            );
            System.assert(false, 'Should throw exception for invalid field');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Dynamic query execution failed'), 'Should throw appropriate error');
        }
    }
}
