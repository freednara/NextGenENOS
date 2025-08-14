/**
 * @description Test class for ProductController
 * Ensures proper functionality and security compliance of product-related operations.
 *
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class ProductControllerTest {
    
    @TestSetup
    static void setup() {
        // Create test products
        List<Product2> products = new List<Product2>{
            new Product2(
                Name = 'Test Product 1',
                ProductCode = 'TEST001',
                Description = 'Test Product Description 1',
                IsActive = true,
                Stock_Quantity__c = 100,
                Image_URL__c = 'https://example.com/image1.jpg'
            ),
            new Product2(
                Name = 'Test Product 2',
                ProductCode = 'TEST002',
                Description = 'Test Product Description 2',
                IsActive = true,
                Stock_Quantity__c = 50,
                Image_URL__c = 'https://example.com/image2.jpg'
            ),
            new Product2(
                Name = 'Inactive Product',
                ProductCode = 'INACTIVE001',
                Description = 'Inactive Product',
                IsActive = false,
                Stock_Quantity__c = 0
            )
        };
        insert products;
        
        // Create standard pricebook entries
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        Id standardPricebookId = Test.getStandardPricebookId();
        
        for (Product2 product : products) {
            pricebookEntries.add(new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = product.Id,
                UnitPrice = 100.00,
                IsActive = product.IsActive
            ));
        }
        insert pricebookEntries;
        
        // Create test account with assigned price book
        Account testAccount = new Account(
            Name = 'Test Account',
            Assigned_Price_Book_ID__c = standardPricebookId
        );
        insert testAccount;
        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            AccountId = testAccount.Id,
            Email = 'test@example.com'
        );
        insert testContact;
        
        // Create category
        Category__c category = new Category__c(
            Name__c = 'Test Category',
            Description__c = 'Test Category Description'
        );
        insert category;
    }
    
    @isTest
    static void testGetProducts() {
        Test.startTest();
        List<Product2> products = ProductController.getProducts();
        Test.stopTest();
        
        // Verify products are returned
        System.assertNotEquals(null, products, 'Products list should not be null');
        System.assertEquals(2, products.size(), 'Should return 2 active products');
        
        // Verify product data
        for (Product2 product : products) {
            System.assertEquals(true, product.IsActive, 'All returned products should be active');
            System.assertNotEquals(null, product.Name, 'Product name should not be null');
            System.assertNotEquals(null, product.ProductCode, 'Product code should not be null');
        }
    }
    
    @isTest
    static void testGetProductById() {
        Product2 testProduct = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST001' LIMIT 1];
        
        Test.startTest();
        Product2 retrievedProduct = ProductController.getProductById(testProduct.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, retrievedProduct, 'Product should be retrieved');
        System.assertEquals(testProduct.Id, retrievedProduct.Id, 'Retrieved product ID should match');
        System.assertEquals('Test Product 1', retrievedProduct.Name, 'Product name should match');
    }
    
    @isTest
    static void testGetProductByIdNotFound() {
        Id nonExistentId = 'a02000000000000';
        
        Test.startTest();
        Product2 retrievedProduct = ProductController.getProductById(nonExistentId);
        Test.stopTest();
        
        System.assertEquals(null, retrievedProduct, 'Should return null for non-existent product');
    }
    
    @isTest
    static void testGetProductsWithPricing() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id LIMIT 1];
        
        // Run as community user
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'Test',
            Email = 'test@example.com',
            Username = 'test@example.com.test',
            CompanyName = 'Test Company',
            Title = 'Test Title',
            Alias = 'test',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = testContact.Id
        );
        insert testUser;
        
        System.runAs(testUser) {
            Test.startTest();
            List<Product2> products = ProductController.getProductsWithPricing();
            Test.stopTest();
            
            System.assertNotEquals(null, products, 'Products list should not be null');
            System.assertEquals(2, products.size(), 'Should return 2 active products');
        }
    }
    
    @isTest
    static void testGetCategories() {
        Test.startTest();
        List<Category__c> categories = ProductController.getCategories();
        Test.stopTest();
        
        System.assertNotEquals(null, categories, 'Categories list should not be null');
        System.assertEquals(1, categories.size(), 'Should return 1 category');
        System.assertEquals('Test Category', categories[0].Name__c, 'Category name should match');
    }
    
    @isTest
    static void testSearchProducts() {
        Test.startTest();
        List<Product2> searchResults = ProductController.searchProducts('Test Product 1');
        Test.stopTest();
        
        System.assertNotEquals(null, searchResults, 'Search results should not be null');
        System.assertEquals(1, searchResults.size(), 'Should return 1 matching product');
        System.assertEquals('Test Product 1', searchResults[0].Name, 'Search result should match');
    }
    
    @isTest
    static void testSearchProductsNoResults() {
        Test.startTest();
        List<Product2> searchResults = ProductController.searchProducts('Nonexistent Product');
        Test.stopTest();
        
        System.assertNotEquals(null, searchResults, 'Search results should not be null');
        System.assertEquals(0, searchResults.size(), 'Should return 0 results for non-matching search');
    }
    
    @isTest
    static void testGetProductsWithCategory() {
        Category__c category = [SELECT Id FROM Category__c WHERE Name__c = 'Test Category' LIMIT 1];
        
        Test.startTest();
        List<Product2> categoryProducts = ProductController.getProductsWithCategory(category.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, categoryProducts, 'Category products should not be null');
        // Note: In a real implementation, you would have a junction object for Product-Category relationships
    }
    
    @isTest
    static void testSecurityExceptions() {
        // Create a user without proper permissions
        User limitedUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'Limited',
            Email = 'limited@example.com',
            Username = 'limited@example.com.test',
            CompanyName = 'Test Company',
            Title = 'Limited User',
            Alias = 'limited',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert limitedUser;
        
        System.runAs(limitedUser) {
            Test.startTest();
            try {
                List<Product2> products = ProductController.getProducts();
                // In a real scenario with proper permission restrictions, this might throw an exception
                System.assertNotEquals(null, products, 'Products should be accessible to standard user');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('permission'), 'Exception should be related to permissions');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetTopSellingProducts() {
        // Mark one product as top seller
        Product2 topProduct = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST001' LIMIT 1];
        topProduct.Is_Top_Seller__c = true;
        update topProduct;
        
        Test.startTest();
        List<Product2> topProducts = ProductController.getTopSellingProducts();
        Test.stopTest();
        
        System.assertNotEquals(null, topProducts, 'Top products should not be null');
        System.assertEquals(1, topProducts.size(), 'Should return 1 top selling product');
        System.assertEquals(true, topProducts[0].Is_Top_Seller__c, 'Product should be marked as top seller');
    }
    
    @isTest
    static void testUpdateProductViewTracking() {
        Product2 testProduct = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST001' LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        ProductController.updateProductViewTracking(testProduct.Id, testContact.Id);
        Test.stopTest();
        
        // Verify view tracking record was created
        List<View_Tracking__c> viewRecords = [
            SELECT Id, Product__c, User_Contact__c, Last_Viewed_Date__c
            FROM View_Tracking__c
            WHERE Product__c = :testProduct.Id AND User_Contact__c = :testContact.Id
        ];
        
        System.assertEquals(1, viewRecords.size(), 'Should create 1 view tracking record');
        System.assertEquals(testProduct.Id, viewRecords[0].Product__c, 'Product ID should match');
        System.assertEquals(testContact.Id, viewRecords[0].User_Contact__c, 'Contact ID should match');
    }
}
