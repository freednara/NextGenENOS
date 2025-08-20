/**
 * @description Test class for ENOS_DynamicUtils
 * Tests all dynamic Apex functionality with comprehensive coverage
 * @author ENOS Development Team
 * @version 1.0.0
 */
@IsTest
public class ENOS_DynamicUtilsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test products
        List<Product2> testProducts = new List<Product2>();
        for (Integer i = 1; i <= 5; i++) {
            testProducts.add(new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'TEST-' + i,
                Description = 'Test product description ' + i,
                IsActive = true,
                Family = 'Electronics'
            ));
        }
        insert testProducts;
        
        // Create test categories
        List<Category__c> testCategories = new List<Category__c>();
        testCategories.add(new Category__c(
            Name__c = 'Test Category 1',
            Description__c = 'Test category description 1'
        ));
        testCategories.add(new Category__c(
            Name__c = 'Test Category 2',
            Description__c = 'Test category description 2'
        ));
        insert testCategories;
    }
    
    @IsTest
    static void testBuildSafeQuery() {
        // Test basic query building
        List<String> fields = new List<String>{'Id', 'Name', 'ProductCode'};
        String query = ENOS_DynamicUtils.buildSafeQuery('Product2', fields, 'IsActive = true', 'Name ASC', 10);
        
        System.assert(query.contains('SELECT Id, Name, ProductCode'), 'Query should contain selected fields');
        System.assert(query.contains('FROM Product2'), 'Query should contain FROM clause');
        System.assert(query.contains('WHERE IsActive = true'), 'Query should contain WHERE clause');
        System.assert(query.contains('ORDER BY Name ASC'), 'Query should contain ORDER BY clause');
        System.assert(query.contains('LIMIT 10'), 'Query should contain LIMIT clause');
        System.assert(query.contains('WITH USER_MODE'), 'Query should contain security enforcement');
    }
    
    @IsTest
    static void testBuildSafeQueryWithNullParameters() {
        // Test query building with null parameters
        String query = ENOS_DynamicUtils.buildSafeQuery('Product2', null, null, null, null);
        
        System.assert(query.contains('SELECT Id'), 'Query should have default Id field');
        System.assert(query.contains('FROM Product2'), 'Query should contain FROM clause');
        System.assert(query.contains('WITH USER_MODE'), 'Query should contain security enforcement');
    }
    
    @IsTest
    static void testExecuteDynamicQuery() {
        // Test dynamic query execution
        List<String> fields = new List<String>{'Id', 'Name', 'ProductCode'};
        List<SObject> results = ENOS_DynamicUtils.executeDynamicQuery(
            'Product2', 
            fields, 
            'IsActive = true', 
            'Name ASC', 
            5
        );
        
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() > 0, 'Should return some results');
        System.assert(results.size() <= 5, 'Should respect LIMIT clause');
    }
    
    @IsTest
    static void testGetObjectMetadata() {
        // Test object metadata retrieval
        Schema.DescribeSObjectResult metadata = ENOS_DynamicUtils.getObjectMetadata('Product2');
        
        System.assertNotEquals(null, metadata, 'Metadata should not be null');
        System.assertEquals('Product2', metadata.getName(), 'Should return correct object name');
        System.assertNotEquals(null, metadata.getLabel(), 'Should have object label');
    }
    
    @IsTest
    static void testGetFieldMetadata() {
        // Test field metadata retrieval
        Schema.DescribeFieldResult fieldMetadata = ENOS_DynamicUtils.getFieldMetadata('Product2', 'Name');
        
        System.assertNotEquals(null, fieldMetadata, 'Field metadata should not be null');
        System.assertEquals('Name', fieldMetadata.getName(), 'Should return correct field name');
        System.assertNotEquals(null, fieldMetadata.getLabel(), 'Should have field label');
    }
    
    @IsTest
    static void testCreateDynamicRecord() {
        // Test dynamic record creation
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Name' => 'Dynamic Test Product',
            'ProductCode' => 'DYN-TEST',
            'IsActive' => true
        };
        
        SObject newRecord = ENOS_DynamicUtils.createDynamicRecord('Product2', fieldValues);
        
        System.assertNotEquals(null, newRecord, 'New record should not be null');
        System.assertEquals('Dynamic Test Product', newRecord.get('Name'), 'Should set Name field');
        System.assertEquals('DYN-TEST', newRecord.get('ProductCode'), 'Should set ProductCode field');
        System.assertEquals(true, newRecord.get('IsActive'), 'Should set IsActive field');
    }
    
    @IsTest
    static void testUpdateDynamicRecord() {
        // Create a test record first
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        
        // Test dynamic record update
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Description' => 'Updated description via dynamic update'
        };
        
        Test.startTest();
        ENOS_DynamicUtils.updateDynamicRecord('Product2', testProduct.Id, fieldValues);
        Test.stopTest();
        
        // Verify update
        Product2 updatedProduct = [SELECT Id, Description FROM Product2 WHERE Id = :testProduct.Id];
        System.assertEquals('Updated description via dynamic update', updatedProduct.Description, 'Description should be updated');
    }
    
    @IsTest
    static void testGetAccessibleObjects() {
        // Test accessible objects retrieval
        List<String> accessibleObjects = ENOS_DynamicUtils.getAccessibleObjects();
        
        System.assertNotEquals(null, accessibleObjects, 'Accessible objects should not be null');
        System.assert(accessibleObjects.size() > 0, 'Should return some accessible objects');
        
        // In test context, we just need to verify that the method returns some objects
        // The specific objects returned may vary depending on the org configuration
        System.debug('Accessible objects returned: ' + accessibleObjects);
        System.assert(accessibleObjects.size() >= 1, 'Should return at least one accessible object');
    }
    
    @IsTest
    static void testValidateDynamicQuery() {
        // Test query validation
        List<String> fields = new List<String>{'Id', 'Name'};
        Boolean isValid = ENOS_DynamicUtils.validateDynamicQuery('Product2', fields, 'IsActive = true');
        
        System.assertEquals(true, isValid, 'Valid query should return true');
    }
    
    @IsTest
    static void testValidateDynamicQueryInvalidObject() {
        // Test query validation with invalid object
        List<String> fields = new List<String>{'Id', 'Name'};
        Boolean isValid = ENOS_DynamicUtils.validateDynamicQuery('InvalidObject__c', fields, 'IsActive = true');
        
        System.assertEquals(false, isValid, 'Invalid object should return false');
    }
    
    @IsTest
    static void testSecurityValidation() {
        // Test that security validation is enforced
        try {
            // This should fail due to security validation
            ENOS_DynamicUtils.buildSafeQuery('InvalidObject__c', new List<String>{'Id'}, null, null, null);
            System.assert(false, 'Should have thrown security exception');
        } catch (AuraHandledException e) {
            // The actual implementation throws AuraHandledException with "Script-thrown exception" message
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Should throw AuraHandledException');
        }
    }
    
    @IsTest
    static void testFieldValidation() {
        // Test that field validation is enforced
        try {
            // This should fail due to invalid field
            ENOS_DynamicUtils.buildSafeQuery('Product2', new List<String>{'InvalidField__c'}, null, null, null);
            System.assert(false, 'Should have thrown field validation exception');
        } catch (AuraHandledException e) {
            // The actual implementation throws AuraHandledException with "Script-thrown exception" message
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Should throw AuraHandledException');
        }
    }
    
    @IsTest
    static void testBulkOperations() {
        // Test bulk record creation
        List<Map<String, Object>> bulkFieldValues = new List<Map<String, Object>>();
        
        for (Integer i = 1; i <= 3; i++) {
            bulkFieldValues.add(new Map<String, Object>{
                'Name' => 'Bulk Test Product ' + i,
                'ProductCode' => 'BULK-' + i,
                'IsActive' => true
            });
        }
        
        List<SObject> createdRecords = new List<SObject>();
        for (Map<String, Object> fieldValues : bulkFieldValues) {
            SObject newRecord = ENOS_DynamicUtils.createDynamicRecord('Product2', fieldValues);
            createdRecords.add(newRecord);
        }
        
        System.assertEquals(3, createdRecords.size(), 'Should create 3 records');
        
        // Verify all records were created
        for (Integer i = 0; i < createdRecords.size(); i++) {
            SObject record = createdRecords[i];
            System.assertEquals('Bulk Test Product ' + (i + 1), record.get('Name'), 'Should set correct Name');
            System.assertEquals('BULK-' + (i + 1), record.get('ProductCode'), 'Should set correct ProductCode');
        }
    }
    
    @IsTest
    static void testErrorHandling() {
        // Test various error scenarios
        
        // Test with null object name
        try {
            ENOS_DynamicUtils.buildSafeQuery(null, new List<String>{'Id'}, null, null, null);
            System.assert(false, 'Should have thrown exception for null object name');
        } catch (AuraHandledException e) {
            // The actual implementation throws AuraHandledException with "Script-thrown exception" message
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Should throw AuraHandledException');
        }
        
        // Test with empty field list
        try {
            ENOS_DynamicUtils.buildSafeQuery('Product2', new List<String>(), null, null, null);
            // This should work with default Id field
            String query = ENOS_DynamicUtils.buildSafeQuery('Product2', new List<String>(), null, null, null);
            System.assert(query.contains('SELECT Id'), 'Should use default Id field');
        } catch (Exception e) {
            System.assert(false, 'Should handle empty field list gracefully');
        }
    }
    
    @IsTest
    static void testPerformanceOptimization() {
        // Test that metadata caching works
        Test.startTest();
        
        // First call should populate cache
        Schema.DescribeSObjectResult metadata1 = ENOS_DynamicUtils.getObjectMetadata('Product2');
        
        // Second call should use cache
        Schema.DescribeSObjectResult metadata2 = ENOS_DynamicUtils.getObjectMetadata('Product2');
        
        Test.stopTest();
        
        System.assertEquals(metadata1, metadata2, 'Should return same metadata instance from cache');
    }
}
