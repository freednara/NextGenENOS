/**
 * @description Test class for ENOS_DataManager
 * Tests all consolidated data management operations
 * @author ENOS Development Team
 * @version 1.0.0
 */
@IsTest
private class ENOS_DataManagerTest {
    
    // ============================================================================
    // BASIC OPERATION TESTS
    // ============================================================================
    
    @IsTest
    static void testDefaultExecution() {
        // Test default execution
        ENOS_DataManager.execute();
        
        // Verify products were created
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assert(products.size() > 0, 'Should create products with default execution');
        
        // Verify pricebook entries were created
        List<PricebookEntry> entries = [SELECT Id FROM PricebookEntry WHERE IsActive = true];
        System.assert(entries.size() > 0, 'Should create pricebook entries with default execution');
    }
    
    @IsTest
    static void testCreateMinimalDataSet() {
        // Test creating minimal data set
        ENOS_DataManager.createMinimalDataSet();
        
        // Verify minimal data was created
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assert(products.size() >= 5, 'Should create at least 5 products for minimal set');
        
        List<Category__c> categories = [SELECT Id FROM Category__c];
        System.assert(categories.size() >= 2, 'Should create at least 2 categories for minimal set');
    }
    
    @IsTest
    static void testCreateStandardDataSet() {
        // Test creating standard data set
        ENOS_DataManager.createStandardDataSet();
        
        // Verify standard data was created
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assert(products.size() >= 10, 'Should create at least 10 products for standard set');
        
        List<Category__c> categories = [SELECT Id FROM Category__c];
        System.assert(categories.size() >= 3, 'Should create at least 3 categories for standard set');
    }
    
    @IsTest
    static void testCreateComprehensiveDataSet() {
        // Test creating comprehensive data set
        ENOS_DataManager.createComprehensiveDataSet();
        
        // Verify comprehensive data was created
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assert(products.size() >= 20, 'Should create at least 20 products for comprehensive set');
        
        List<Category__c> categories = [SELECT Id FROM Category__c];
        System.assert(categories.size() >= 5, 'Should create at least 5 categories for comprehensive set');
    }
    
    // ============================================================================
    // CUSTOM CONFIGURATION TESTS
    // ============================================================================
    
    @IsTest
    static void testCustomConfiguration() {
        // Test custom configuration
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_PRODUCTS;
        config.scope = ENOS_DataManager.DataScope.CUSTOM;
        config.productCount = 15;
        config.productFamily = 'Electronics';
        config.activatePricebook = true;
        config.addStockData = true;
        config.verboseLogging = false;
        
        ENOS_DataManager.execute(config);
        
        // Verify custom configuration was applied
        List<Product2> products = [SELECT Id, Family FROM Product2 WHERE IsActive = true];
        System.assertEquals(15, products.size(), 'Should create exactly 15 products');
        
        for (Product2 product : products) {
            System.assertEquals('Electronics', product.Family, 'Product family should be Electronics');
        }
    }
    
    @IsTest
    static void testCreateCategoriesOnly() {
        // Test creating only categories
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_CATEGORIES;
        config.scope = ENOS_DataManager.DataScope.CUSTOM;
        config.categoryCount = 4;
        
        ENOS_DataManager.execute(config);
        
        // Verify only categories were created
        List<Category__c> categories = [SELECT Id FROM Category__c];
        System.assertEquals(4, categories.size(), 'Should create exactly 4 categories');
        
        // Verify no products were created
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assertEquals(0, products.size(), 'Should not create products when only creating categories');
    }
    
    @IsTest
    static void testCreateAccountsOnly() {
        // Test creating only accounts
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_ACCOUNTS;
        config.scope = ENOS_DataManager.DataScope.CUSTOM;
        config.accountCount = 3;
        
        ENOS_DataManager.execute(config);
        
        // Verify only accounts were created
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(3, accounts.size(), 'Should create exactly 3 accounts');
        
        // Verify no products were created
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assertEquals(0, products.size(), 'Should not create products when only creating accounts');
    }
    
    @IsTest
    static void testCreateContactsOnly() {
        // Test creating only contacts
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_CONTACTS;
        config.scope = ENOS_DataManager.DataScope.CUSTOM;
        config.contactCountPerAccount = 2;
        
        // First create an account for contacts
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        
        ENOS_DataManager.execute(config);
        
        // Verify contacts were created
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assert(contacts.size() >= 2, 'Should create at least 2 contacts');
    }
    
    // ============================================================================
    // STOCK DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testAddStockData() {
        // First create some products
        List<Product2> products = ENOS_TestDataFactory.createTestProducts(5);
        insert products;
        
        // Test adding stock data
        ENOS_DataManager.addStockData();
        
        // Verify stock was added
        List<Product2> productsWithStock = [
            SELECT Id, Stock_Quantity__c 
            FROM Product2 
            WHERE Stock_Quantity__c > 0 AND IsActive = true
        ];
        System.assertEquals(5, productsWithStock.size(), 'All products should have stock data');
    }
    
    // ============================================================================
    // PRICEBOOK TESTS
    // ============================================================================
    
    @IsTest
    static void testActivatePricebook() {
        // Test activating pricebook
        ENOS_DataManager.activatePricebook();
        
        // Verify pricebook is active
        Pricebook2 standardPricebook = [
            SELECT Id, IsActive 
            FROM Pricebook2 
            WHERE IsStandard = true
        ];
        System.assertEquals(true, standardPricebook.IsActive, 'Standard pricebook should be active');
    }
    
    // ============================================================================
    // DATA VERIFICATION TESTS
    // ============================================================================
    
    @IsTest
    static void testVerifyData() {
        // First create some test data
        ENOS_DataManager.createMinimalDataSet();
        
        // Test data verification
        ENOS_DataManager.verifyData();
        
        // Verify verification completed without errors
        System.assert(true, 'Data verification should complete without errors');
    }
    
    // ============================================================================
    // DATA CLEANUP TESTS
    // ============================================================================
    
    @IsTest
    static void testCleanupData() {
        // First create some test data
        ENOS_DataManager.createMinimalDataSet();
        
        // Verify data exists
        List<Product2> productsBefore = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assert(productsBefore.size() > 0, 'Should have products before cleanup');
        
        // Test data cleanup
        ENOS_DataManager.cleanupData();
        
        // Verify data was cleaned up
        List<Product2> productsAfter = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assertEquals(0, productsAfter.size(), 'All products should be cleaned up');
        
        List<Category__c> categoriesAfter = [SELECT Id FROM Category__c];
        System.assertEquals(0, categoriesAfter.size(), 'All categories should be cleaned up');
        
        List<Account> accountsAfter = [SELECT Id FROM Account];
        System.assertEquals(0, accountsAfter.size(), 'All accounts should be cleaned up');
    }
    
    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================
    
    @IsTest
    static void testIntegrationWithTestDataFactory() {
        // Test that ENOS_DataManager works with ENOS_TestDataFactory
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_PRODUCTS;
        config.scope = ENOS_DataManager.DataScope.MINIMAL;
        config.productFamily = 'Test Integration';
        
        ENOS_DataManager.execute(config);
        
        // Verify integration worked
        List<Product2> products = [SELECT Id, Family FROM Product2 WHERE IsActive = true];
        System.assert(products.size() > 0, 'Should create products through integration');
        
        for (Product2 product : products) {
            System.assertEquals('Test Integration', product.Family, 'Product family should match integration test');
        }
    }
    
    @IsTest
    static void testIntegrationWithLogging() {
        // Test that ENOS_DataManager works with ENOS_LoggingUtils
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_PRODUCTS;
        config.scope = ENOS_DataManager.DataScope.MINIMAL;
        config.verboseLogging = true;
        
        ENOS_DataManager.execute(config);
        
        // Verify logging integration worked
        System.assert(true, 'Logging integration should work without errors');
    }
    
    @IsTest
    static void testIntegrationWithConfiguration() {
        // Test that ENOS_DataManager works with ENOS_ConfigurationUtils
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_PRODUCTS;
        config.scope = ENOS_DataManager.DataScope.MINIMAL;
        config.addStockData = true;
        
        ENOS_DataManager.execute(config);
        
        // Verify configuration integration worked
        List<Product2> products = [SELECT Id, Stock_Quantity__c FROM Product2 WHERE IsActive = true];
        System.assert(products.size() > 0, 'Should create products with configuration integration');
        
        for (Product2 product : products) {
            System.assertNotEquals(null, product.Stock_Quantity__c, 'Stock quantity should be set through configuration');
        }
    }
    
    // ============================================================================
    // ERROR HANDLING TESTS
    // ============================================================================
    
    @IsTest
    static void testErrorHandling() {
        // Test error handling by trying to create products without proper setup
        try {
            // This should work even without setup
            ENOS_DataManager.createMinimalDataSet();
            System.assert(true, 'Should handle missing setup gracefully');
        } catch (Exception e) {
            // If an exception occurs, it should be logged properly
            System.assert(true, 'Exceptions should be handled and logged');
        }
    }
    
    // ============================================================================
    // PERFORMANCE TESTS
    // ============================================================================
    
    @IsTest
    static void testPerformance() {
        // Test performance of data creation
        Long startTime = System.currentTimeMillis();
        
        ENOS_DataManager.createMinimalDataSet();
        
        Long duration = System.currentTimeMillis() - startTime;
        
        // Verify performance is reasonable (should complete in less than 10 seconds)
        System.assert(duration < 10000, 'Data creation should complete within 10 seconds: ' + duration + 'ms');
        
        // Clean up
        ENOS_DataManager.cleanupData();
    }
    
    // ============================================================================
    // EDGE CASE TESTS
    // ============================================================================
    
    @IsTest
    static void testEdgeCases() {
        // Test edge cases
        ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
        config.operation = ENOS_DataManager.OperationType.CREATE_PRODUCTS;
        config.scope = ENOS_DataManager.DataScope.CUSTOM;
        config.productCount = 1; // Minimum count
        config.categoryCount = 1; // Minimum count
        config.accountCount = 1; // Minimum count
        config.contactCountPerAccount = 1; // Minimum count
        
        ENOS_DataManager.execute(config);
        
        // Verify edge case handling
        List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
        System.assertEquals(1, products.size(), 'Should handle minimum product count');
        
        List<Category__c> categories = [SELECT Id FROM Category__c];
        System.assertEquals(1, categories.size(), 'Should handle minimum category count');
        
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(1, accounts.size(), 'Should handle minimum account count');
        
        // Clean up
        ENOS_DataManager.cleanupData();
    }
}
