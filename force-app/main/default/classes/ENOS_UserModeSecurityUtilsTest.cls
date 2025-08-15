/**
 * @description Test class for ENOS_UserModeSecurityUtils
 * @author ENOS Development Team
 * @version 1.0.0
 */
@IsTest
private class ENOS_UserModeSecurityUtilsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingCity = 'Test City'
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        
        // Create test product
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'TEST-001'
        );
        insert testProduct;
        
        // Create test cart
        Cart__c testCart = new Cart__c(
            Contact__c = testContact.Id,
            Status__c = 'Active'
        );
        insert testCart;
        
        // Create test cart item
        Cart_Item__c testCartItem = new Cart_Item__c(
            Cart__c = testCart.Id,
            Product__c = testProduct.Id,
            Quantity__c = 2,
            Unit_Price__c = 29.99
        );
        insert testCartItem;
    }
    
    @IsTest
    static void testExecuteSecureQuery() {
        Test.startTest();
        
        // Test basic query execution
        List<String> fields = new List<String>{'Id', 'Name'};
        String whereClause = 'IsActive = true';
        
        List<Product2> results = ENOS_UserModeSecurityUtils.executeSecureQuery(
            'Product2', fields, whereClause, null, null
        );
        
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        System.assertEquals('Test Product', results[0].Name);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteSecureSingleQuery() {
        Test.startTest();
        
        List<String> fields = new List<String>{'Id', 'Name'};
        String whereClause = 'Name = \'Test Product\'';
        
        Product2 result = ENOS_UserModeSecurityUtils.executeSecureSingleQuery(
            'Product2', fields, whereClause
        );
        
        System.assertNotEquals(null, result);
        System.assertEquals('Test Product', result.Name);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteSecureCountQuery() {
        Test.startTest();
        
        String whereClause = 'IsActive = true';
        Integer count = ENOS_UserModeSecurityUtils.executeSecureCountQuery('Product2', whereClause);
        
        System.assertEquals(1, count);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteSecureAggregateQuery() {
        Test.startTest();
        
        List<String> aggregateFields = new List<String>{'COUNT(Id)'};
        String whereClause = 'IsActive = true';
        List<String> groupByFields = new List<String>{'IsActive'};
        
        List<AggregateResult> results = ENOS_UserModeSecurityUtils.executeSecureAggregateQuery(
            'Product2', aggregateFields, whereClause, groupByFields
        );
        
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteSecureSearchQuery() {
        Test.startTest();
        
        List<String> fields = new List<String>{'Id', 'Name'};
        String searchTerm = 'Test';
        String whereClause = 'IsActive = true';
        
        List<Product2> results = ENOS_UserModeSecurityUtils.executeSecureSearchQuery(
            'Product2', fields, searchTerm, whereClause
        );
        
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteSecureSOSL() {
        Test.startTest();
        
        String searchQuery = 'Test';
        List<String> objectTypes = new List<String>{'Product2'};
        List<String> fields = new List<String>{'Id', 'Name'};
        
        List<List<SObject>> results = ENOS_UserModeSecurityUtils.executeSecureSOSL(
            searchQuery, objectTypes, fields
        );
        
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testValidateQuerySecurity() {
        Test.startTest();
        
        // Test valid query
        String validQuery = 'SELECT Id, Name FROM Product2 WITH USER_MODE';
        Boolean isValid = ENOS_UserModeSecurityUtils.validateQuerySecurity(validQuery);
        System.assertEquals(true, isValid);
        
        // Test invalid query (missing USER_MODE)
        String invalidQuery = 'SELECT Id, Name FROM Product2';
        Boolean isInvalid = ENOS_UserModeSecurityUtils.validateQuerySecurity(invalidQuery);
        System.assertEquals(false, isInvalid);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetUserSecurityContext() {
        Test.startTest();
        
        Map<String, Object> context = ENOS_UserModeSecurityUtils.getUserSecurityContext();
        
        System.assertNotEquals(null, context);
        System.assertNotEquals(null, context.get('userId'));
        System.assertNotEquals(null, context.get('username'));
        System.assertNotEquals(null, context.get('profile'));
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCheckUserAccess() {
        Test.startTest();
        
        // Test read access
        Boolean canRead = ENOS_UserModeSecurityUtils.checkUserAccess('Product2', 'read');
        System.assertEquals(true, canRead);
        
        // Test create access
        Boolean canCreate = ENOS_UserModeSecurityUtils.checkUserAccess('Product2', 'create');
        System.assertEquals(true, canCreate);
        
        // Test invalid operation
        Boolean invalidOp = ENOS_UserModeSecurityUtils.checkUserAccess('Product2', 'invalid');
        System.assertEquals(false, invalidOp);
        
        Test.stopTest();
    }
    
    @IsTest
    static void testSecurityValidationFailure() {
        Test.startTest();
        
        // Test with non-existent object
        try {
            ENOS_UserModeSecurityUtils.executeSecureQuery(
                'NonExistentObject', new List<String>{'Id'}, null, null, null
            );
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Access denied'));
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testBulkOperations() {
        Test.startTest();
        
        // Create multiple test products
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 200; i++) {
            products.add(new Product2(
                Name = 'Bulk Test Product ' + i,
                IsActive = true,
                ProductCode = 'BULK-' + i
            ));
        }
        insert products;
        
        // Test bulk query
        List<String> fields = new List<String>{'Id', 'Name'};
        String whereClause = 'Name LIKE \'Bulk Test Product%\'';
        
        List<Product2> results = ENOS_UserModeSecurityUtils.executeSecureQuery(
            'Product2', fields, whereClause, null, null
        );
        
        System.assertEquals(200, results.size());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testSubqueryOperations() {
        Test.startTest();
        
        List<String> fields = new List<String>{'Id', 'Name'};
        List<ENOS_UserModeSecurityUtils.SubqueryDefinition> subqueries = new List<ENOS_UserModeSecurityUtils.SubqueryDefinition>();
        
        // Create subquery for cart items
        ENOS_UserModeSecurityUtils.SubqueryDefinition cartSubquery = 
            new ENOS_UserModeSecurityUtils.SubqueryDefinition(
                'Cart_Item__c', 
                new List<String>{'Id', 'Quantity__c'}, 
                'Cart__c = \'' + [SELECT Id FROM Cart__c LIMIT 1].Id + '\''
            );
        subqueries.add(cartSubquery);
        
        List<Product2> results = ENOS_UserModeSecurityUtils.executeSecureQueryWithSubqueries(
            'Product2', fields, subqueries, 'IsActive = true'
        );
        
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testRelationshipQueries() {
        Test.startTest();
        
        List<String> fields = new List<String>{'Id', 'Name'};
        List<String> relationshipFields = new List<String>{'Cart_Items__r'};
        
        List<Cart__c> results = ENOS_UserModeSecurityUtils.executeSecureQueryWithRelationships(
            'Cart__c', fields, relationshipFields, 'Status__c = \'Active\''
        );
        
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
}
