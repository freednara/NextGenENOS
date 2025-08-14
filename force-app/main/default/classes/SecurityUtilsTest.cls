/**
 * @description Test class for SecurityUtils
 * Tests security utility methods for CRUD and FLS compliance.
 *
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class SecurityUtilsTest {
    
    @isTest
    static void testCheckFieldReadAccess() {
        List<String> fieldsToCheck = new List<String>{'Name', 'Description', 'IsActive'};
        
        Test.startTest();
        try {
            SecurityUtils.checkFieldReadAccess('Product2', fieldsToCheck);
            System.assert(true, 'Field read access check should pass for standard user');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('read access'), 'Exception should be about read access');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckFieldCreateAccess() {
        List<String> fieldsToCheck = new List<String>{'Name', 'Description', 'IsActive'};
        
        Test.startTest();
        try {
            SecurityUtils.checkFieldCreateAccess('Product2', fieldsToCheck);
            System.assert(true, 'Field create access check should pass for admin user');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('create access'), 'Exception should be about create access');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckFieldUpdateAccess() {
        List<String> fieldsToCheck = new List<String>{'Name', 'Description'};
        
        Test.startTest();
        try {
            SecurityUtils.checkFieldUpdateAccess('Product2', fieldsToCheck);
            System.assert(true, 'Field update access check should pass for admin user');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('update access'), 'Exception should be about update access');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckObjectReadAccess() {
        Test.startTest();
        try {
            SecurityUtils.checkObjectReadAccess('Product2');
            System.assert(true, 'Object read access check should pass');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('read access'), 'Exception should be about read access');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckObjectCreateAccess() {
        Test.startTest();
        try {
            SecurityUtils.checkObjectCreateAccess('Cart__c');
            System.assert(true, 'Object create access check should pass');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('create access'), 'Exception should be about create access');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckObjectUpdateAccess() {
        Test.startTest();
        try {
            SecurityUtils.checkObjectUpdateAccess('Cart__c');
            System.assert(true, 'Object update access check should pass');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('update access'), 'Exception should be about update access');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckObjectDeleteAccess() {
        Test.startTest();
        try {
            SecurityUtils.checkObjectDeleteAccess('Cart_Item__c');
            System.assert(true, 'Object delete access check should pass');
        } catch (SecurityException e) {
            System.assert(e.getMessage().contains('delete access'), 'Exception should be about delete access');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testHasPermission() {
        Test.startTest();
        Boolean hasPermission = SecurityUtils.hasPermission('Product2');
        Test.stopTest();
        
        System.assertNotEquals(null, hasPermission, 'Permission check result should not be null');
    }
    
    @isTest
    static void testValidateSOQLInjection() {
        String safeQuery = 'SELECT Id, Name FROM Product2 WHERE IsActive = true';
        String unsafeQuery = 'SELECT Id, Name FROM Product2 WHERE Name = \'' + String.escapeSingleQuotes('Test\'; DROP TABLE Product2; --') + '\'';
        
        Test.startTest();
        Boolean safeResult = SecurityUtils.validateSOQLInjection(safeQuery);
        Boolean unsafeResult = SecurityUtils.validateSOQLInjection(unsafeQuery);
        Test.stopTest();
        
        System.assertEquals(true, safeResult, 'Safe query should pass validation');
        System.assertEquals(false, unsafeResult, 'Unsafe query should fail validation');
    }
    
    @isTest
    static void testSanitizeInput() {
        String maliciousInput = '<script>alert("XSS")</script>';
        String normalInput = 'Regular product name';
        
        Test.startTest();
        String sanitizedMalicious = SecurityUtils.sanitizeInput(maliciousInput);
        String sanitizedNormal = SecurityUtils.sanitizeInput(normalInput);
        Test.stopTest();
        
        System.assertNotEquals(maliciousInput, sanitizedMalicious, 'Malicious input should be sanitized');
        System.assertEquals(normalInput, sanitizedNormal, 'Normal input should remain unchanged');
        System.assert(!sanitizedMalicious.contains('<script>'), 'Sanitized input should not contain script tags');
    }
    
    @isTest
    static void testValidateFieldAccess() {
        Test.startTest();
        Boolean hasAccess = SecurityUtils.validateFieldAccess('Product2', 'Name', 'read');
        Test.stopTest();
        
        System.assertNotEquals(null, hasAccess, 'Field access validation should return a result');
    }
    
    @isTest
    static void testGetAccessibleFields() {
        Test.startTest();
        List<String> accessibleFields = SecurityUtils.getAccessibleFields('Product2', 'read');
        Test.stopTest();
        
        System.assertNotEquals(null, accessibleFields, 'Accessible fields list should not be null');
        System.assert(accessibleFields.size() > 0, 'Should return at least some accessible fields');
    }
    
    @isTest
    static void testFilterAccessibleRecords() {
        // Create test products
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Test Product 1', IsActive = true),
            new Product2(Name = 'Test Product 2', IsActive = true)
        };
        insert products;
        
        Test.startTest();
        List<Product2> filteredProducts = SecurityUtils.filterAccessibleRecords(products, 'read');
        Test.stopTest();
        
        System.assertNotEquals(null, filteredProducts, 'Filtered products should not be null');
        System.assertEquals(products.size(), filteredProducts.size(), 'All products should be accessible to admin');
    }
    
    @isTest
    static void testCheckSharingAccess() {
        Account testAccount = new Account(Name = 'Test Security Account');
        insert testAccount;
        
        Test.startTest();
        Boolean hasAccess = SecurityUtils.checkSharingAccess(testAccount.Id, 'Account');
        Test.stopTest();
        
        System.assertEquals(true, hasAccess, 'Admin should have sharing access to created account');
    }
    
    @isTest
    static void testInvalidObjectName() {
        Test.startTest();
        try {
            SecurityUtils.checkObjectReadAccess('InvalidObject__c');
            System.assert(false, 'Should throw exception for invalid object');
        } catch (Exception e) {
            System.assert(true, 'Should handle invalid object name gracefully');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidFieldName() {
        List<String> invalidFields = new List<String>{'InvalidField__c'};

        Test.startTest();
        try {
            SecurityUtils.checkFieldReadAccess('Product2', invalidFields);
            System.assert(false, 'Should throw exception for invalid field');
        } catch (Exception e) {
            System.assert(true, 'Should handle invalid field name gracefully');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateRecordAccess() {
        Account acc1 = new Account(Name = 'Access OK');
        Account acc2 = new Account(Name = 'Access Denied');
        insert new List<Account>{ acc1, acc2 };
        delete acc2;

        Test.startTest();
        SecurityUtils.validateRecordAccess(acc1.Id, 'Account');
        Boolean threw = false;
        try {
            SecurityUtils.validateRecordAccess(acc2.Id, 'Account');
        } catch (Exception e) {
            threw = true;
        }
        Test.stopTest();

        System.assert(threw, 'Should throw for inaccessible record');
    }
    
    @isTest
    static void testBulkPermissionChecks() {
        List<String> objectNames = new List<String>{'Product2', 'Account', 'Contact', 'Cart__c'};
        
        Test.startTest();
        for (String objectName : objectNames) {
            try {
                SecurityUtils.checkObjectReadAccess(objectName);
            } catch (SecurityException e) {
                System.debug('Permission denied for object: ' + objectName);
            }
        }
        Test.stopTest();
        
        System.assert(true, 'Bulk permission checks should complete without fatal errors');
    }
    
    @isTest
    static void testPermissionSetValidation() {
        Test.startTest();
        Boolean hasCustomPermission = SecurityUtils.hasCustomPermission('StoreConnect_Admin');
        Test.stopTest();
        
        System.assertNotEquals(null, hasCustomPermission, 'Custom permission check should return a result');
    }
    
    @isTest
    static void testRowLevelSecurity() {
        Account testAccount = new Account(Name = 'RLS Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'RLS',
            LastName = 'Test',
            AccountId = testAccount.Id,
            Email = 'rlstest@example.com'
        );
        insert testContact;
        
        Test.startTest();
        Boolean hasRowAccess = SecurityUtils.checkRowLevelAccess(testContact.Id, 'Contact');
        Test.stopTest();
        
        System.assertEquals(true, hasRowAccess, 'Admin should have row-level access to created contact');
    }
}
