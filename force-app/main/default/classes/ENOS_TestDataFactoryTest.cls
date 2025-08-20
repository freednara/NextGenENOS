/**
 * @description Test class for ENOS_TestDataFactory
 * Tests all test data creation methods and validates the factory functionality
 * @author ENOS Development Team
 * @version 1.0.0
 */
@IsTest
private class ENOS_TestDataFactoryTest {
    
    // ============================================================================
    // PRODUCT TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestProduct() {
        // Test creating single product with minimal parameters
        Product2 product = ENOS_TestDataFactory.createTestProduct('Test Product');
        
        System.assertNotEquals(null, product, 'Product should not be null');
        System.assertEquals('Test Product', product.Name, 'Product name should match');
        System.assertEquals('Test Family', product.Family, 'Product family should be default');
        System.assertEquals('Test product description', product.Description, 'Product description should be default');
        System.assertEquals(true, product.IsActive, 'Product should be active');
        System.assertNotEquals(null, product.Stock_Quantity__c, 'Stock quantity should be set');
    }
    
    @IsTest
    static void testCreateTestProductWithCustomValues() {
        // Test creating single product with custom values
        Product2 product = ENOS_TestDataFactory.createTestProduct('Custom Product', 'Custom Family', 'Custom Description');
        
        System.assertNotEquals(null, product, 'Product should not be null');
        System.assertEquals('Custom Product', product.Name, 'Product name should match');
        System.assertEquals('Custom Family', product.Family, 'Product family should match');
        System.assertEquals('Custom Description', product.Description, 'Product description should match');
        System.assertEquals(true, product.IsActive, 'Product should be active');
    }
    
    @IsTest
    static void testCreateTestProducts() {
        // Test creating multiple products
        List<Product2> products = ENOS_TestDataFactory.createTestProducts(5);
        
        System.assertEquals(5, products.size(), 'Should create 5 products');
        for (Integer i = 0; i < products.size(); i++) {
            Product2 product = products[i];
            System.assertEquals('Test Product ' + (i + 1), product.Name, 'Product name should match pattern');
            System.assertEquals('Test Family', product.Family, 'Product family should be consistent');
            System.assertEquals(true, product.IsActive, 'Product should be active');
        }
    }
    
    @IsTest
    static void testCreateTestProductsWithFamily() {
        // Test creating multiple products with custom family
        List<Product2> products = ENOS_TestDataFactory.createTestProducts(3, 'Electronics');
        
        System.assertEquals(3, products.size(), 'Should create 3 products');
        for (Product2 product : products) {
            System.assertEquals('Electronics', product.Family, 'Product family should be Electronics');
        }
    }
    
    @IsTest
    static void testCreateTestProductsWithCodes() {
        // Test creating products with specific codes
        List<String> productCodes = new List<String>{'AUD-001', 'COMP-001', 'MOB-001'};
        List<Product2> products = ENOS_TestDataFactory.createTestProductsWithCodes(productCodes, 'Technology');
        
        System.assertEquals(3, products.size(), 'Should create 3 products');
        for (Integer i = 0; i < products.size(); i++) {
            Product2 product = products[i];
            System.assertEquals(productCodes[i], product.ProductCode, 'Product code should match');
            System.assertEquals('Technology', product.Family, 'Product family should be Technology');
        }
    }
    
    // ============================================================================
    // CATEGORY TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestCategory() {
        // Test creating single category
        Category__c category = ENOS_TestDataFactory.createTestCategory('Test Category');
        
        System.assertNotEquals(null, category, 'Category should not be null');
        System.assertEquals('Test Category', category.Name__c, 'Category name should match');
        System.assertEquals('Test category description', category.Description__c, 'Category description should be default');
    }
    
    @IsTest
    static void testCreateTestCategoryWithDescription() {
        // Test creating category with custom description
        Category__c category = ENOS_TestDataFactory.createTestCategory('Custom Category', 'Custom Description');
        
        System.assertNotEquals(null, category, 'Category should not be null');
        System.assertEquals('Custom Category', category.Name__c, 'Category name should match');
        System.assertEquals('Custom Description', category.Description__c, 'Category description should match');
    }
    
    @IsTest
    static void testCreateTestCategories() {
        // Test creating multiple categories
        List<Category__c> categories = ENOS_TestDataFactory.createTestCategories(4);
        
        System.assertEquals(4, categories.size(), 'Should create 4 categories');
        for (Integer i = 0; i < categories.size(); i++) {
            Category__c category = categories[i];
            System.assertEquals('Test Category ' + (i + 1), category.Name__c, 'Category name should match pattern');
            System.assertEquals('Test category description ' + (i + 1), category.Description__c, 'Category description should match pattern');
        }
    }
    
    // ============================================================================
    // ACCOUNT TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestAccount() {
        // Test creating single account with default name
        Account account = ENOS_TestDataFactory.createTestAccount();
        
        System.assertNotEquals(null, account, 'Account should not be null');
        System.assertEquals('Test Account', account.Name, 'Account name should be default');
        System.assertEquals('Customer', account.Type, 'Account type should be Customer');
        System.assertEquals('Technology', account.Industry, 'Account industry should be Technology');
        System.assertEquals('123 Test Street', account.BillingStreet, 'Billing street should be set');
    }
    
    @IsTest
    static void testCreateTestAccountWithName() {
        // Test creating account with custom name
        Account account = ENOS_TestDataFactory.createTestAccount('Custom Account');
        
        System.assertNotEquals(null, account, 'Account should not be null');
        System.assertEquals('Custom Account', account.Name, 'Account name should match');
        System.assertEquals('Customer', account.Type, 'Account type should be Customer');
    }
    
    @IsTest
    static void testCreateTestAccounts() {
        // Test creating multiple accounts
        List<Account> accounts = ENOS_TestDataFactory.createTestAccounts(3);
        
        System.assertEquals(3, accounts.size(), 'Should create 3 accounts');
        for (Integer i = 0; i < accounts.size(); i++) {
            Account account = accounts[i];
            System.assertEquals('Test Account ' + (i + 1), account.Name, 'Account name should match pattern');
            System.assertEquals('Customer', account.Type, 'Account type should be consistent');
        }
    }
    
    // ============================================================================
    // CONTACT TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestContact() {
        // Test creating single contact with default values
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        
        Contact contact = ENOS_TestDataFactory.createTestContact(testAccount.Id);
        
        System.assertNotEquals(null, contact, 'Contact should not be null');
        System.assertEquals('Test', contact.FirstName, 'Contact first name should be default');
        System.assertEquals('Contact', contact.LastName, 'Contact last name should be default');
        System.assertEquals(testAccount.Id, contact.AccountId, 'Contact account should match');
        System.assertEquals('test.contact@example.com', contact.Email, 'Contact email should be generated');
    }
    
    @IsTest
    static void testCreateTestContactWithCustomValues() {
        // Test creating contact with custom values
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        
        Contact contact = ENOS_TestDataFactory.createTestContact('John', 'Doe', testAccount.Id);
        
        System.assertNotEquals(null, contact, 'Contact should not be null');
        System.assertEquals('John', contact.FirstName, 'Contact first name should match');
        System.assertEquals('Doe', contact.LastName, 'Contact last name should match');
        System.assertEquals(testAccount.Id, contact.AccountId, 'Contact account should match');
        System.assertEquals('john.doe@example.com', contact.Email, 'Contact email should be generated');
    }
    
    @IsTest
    static void testCreateTestContacts() {
        // Test creating multiple contacts
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        
        List<Contact> contacts = ENOS_TestDataFactory.createTestContacts(3, testAccount.Id);
        
        System.assertEquals(3, contacts.size(), 'Should create 3 contacts');
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact contact = contacts[i];
            System.assertEquals('Test' + (i + 1), contact.FirstName, 'Contact first name should match pattern');
            System.assertEquals('Contact' + (i + 1), contact.LastName, 'Contact last name should match pattern');
            System.assertEquals(testAccount.Id, contact.AccountId, 'Contact account should match');
        }
    }
    
    // ============================================================================
    // CART TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestCart() {
        // Test creating single cart
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        Contact testContact = ENOS_TestDataFactory.createTestContact(testAccount.Id);
        insert testContact;
        
        Cart__c cart = ENOS_TestDataFactory.createTestCart(testContact.Id);
        
        System.assertNotEquals(null, cart, 'Cart should not be null');
        System.assertEquals(testContact.Id, cart.Contact__c, 'Cart contact should match');
        System.assertEquals('Active', cart.Status__c, 'Cart status should be Active');
    }
    
    @IsTest
    static void testCreateTestCarts() {
        // Test creating multiple carts
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        Contact testContact = ENOS_TestDataFactory.createTestContact(testAccount.Id);
        insert testContact;
        
        List<Cart__c> carts = ENOS_TestDataFactory.createTestCarts(3, testContact.Id);
        
        System.assertEquals(3, carts.size(), 'Should create 3 carts');
        for (Cart__c cart : carts) {
            System.assertEquals(testContact.Id, cart.Contact__c, 'Cart contact should match');
            System.assertEquals('Active', cart.Status__c, 'Cart status should be Active');
        }
    }
    
    // ============================================================================
    // CART ITEM TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestCartItem() {
        // Test creating single cart item with default values
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        Contact testContact = ENOS_TestDataFactory.createTestContact(testAccount.Id);
        insert testContact;
        Cart__c testCart = ENOS_TestDataFactory.createTestCart(testContact.Id);
        insert testCart;
        Product2 testProduct = ENOS_TestDataFactory.createTestProduct('Test Product');
        insert testProduct;
        
        Cart_Item__c cartItem = ENOS_TestDataFactory.createTestCartItem(testCart.Id, testProduct.Id);
        
        System.assertNotEquals(null, cartItem, 'Cart item should not be null');
        System.assertEquals(testCart.Id, cartItem.Cart__c, 'Cart item cart should match');
        System.assertEquals(testProduct.Id, cartItem.Product__c, 'Cart item product should match');
        System.assertEquals(1, cartItem.Quantity__c, 'Cart item quantity should be 1');
        System.assertEquals(99.99, cartItem.Unit_Price__c, 'Cart item unit price should be 99.99');
    }
    
    @IsTest
    static void testCreateTestCartItemWithCustomValues() {
        // Test creating cart item with custom values
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        Contact testContact = ENOS_TestDataFactory.createTestContact(testAccount.Id);
        insert testContact;
        Cart__c testCart = ENOS_TestDataFactory.createTestCart(testContact.Id);
        insert testCart;
        Product2 testProduct = ENOS_TestDataFactory.createTestProduct('Test Product');
        insert testProduct;
        
        Cart_Item__c cartItem = ENOS_TestDataFactory.createTestCartItem(testCart.Id, testProduct.Id, 5, 199.99);
        
        System.assertNotEquals(null, cartItem, 'Cart item should not be null');
        System.assertEquals(5, cartItem.Quantity__c, 'Cart item quantity should be 5');
        System.assertEquals(199.99, cartItem.Unit_Price__c, 'Cart item unit price should be 199.99');
    }
    
    @IsTest
    static void testCreateTestCartItems() {
        // Test creating multiple cart items
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        Contact testContact = ENOS_TestDataFactory.createTestContact(testAccount.Id);
        insert testContact;
        Cart__c testCart = ENOS_TestDataFactory.createTestCart(testContact.Id);
        insert testCart;
        Product2 testProduct = ENOS_TestDataFactory.createTestProduct('Test Product');
        insert testProduct;
        
        List<Cart_Item__c> cartItems = ENOS_TestDataFactory.createTestCartItems(3, testCart.Id, testProduct.Id);
        
        System.assertEquals(3, cartItems.size(), 'Should create 3 cart items');
        for (Integer i = 0; i < cartItems.size(); i++) {
            Cart_Item__c cartItem = cartItems[i];
            System.assertEquals(i + 1, cartItem.Quantity__c, 'Cart item quantity should match pattern');
            System.assertEquals(99.99 + (i + 1), cartItem.Unit_Price__c, 'Cart item unit price should match pattern');
        }
    }
    
    // ============================================================================
    // SHIPPING ADDRESS TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestShippingAddress() {
        // Test creating single shipping address with default label
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        
        Shipping_Address__c address = ENOS_TestDataFactory.createTestShippingAddress(testAccount.Id);
        
        System.assertNotEquals(null, address, 'Shipping address should not be null');
        System.assertEquals(testAccount.Id, address.Account__c, 'Shipping address account should match');
        System.assertEquals('Home', address.Address_Label__c, 'Shipping address label should be Home');
        System.assertEquals('789 Test Boulevard', address.Street__c, 'Shipping address street should be set');
        System.assertEquals('Test City', address.City__c, 'Shipping address city should be set');
        System.assertEquals(true, address.Is_Default__c, 'Shipping address should be default');
    }
    
    @IsTest
    static void testCreateTestShippingAddressWithLabel() {
        // Test creating shipping address with custom label
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        
        Shipping_Address__c address = ENOS_TestDataFactory.createTestShippingAddress(testAccount.Id, 'Work');
        
        System.assertNotEquals(null, address, 'Shipping address should not be null');
        System.assertEquals('Work', address.Address_Label__c, 'Shipping address label should be Work');
        System.assertEquals(testAccount.Id, address.Account__c, 'Shipping address account should match');
    }
    
    @IsTest
    static void testCreateTestShippingAddresses() {
        // Test creating multiple shipping addresses
        Account testAccount = ENOS_TestDataFactory.createTestAccount();
        insert testAccount;
        
        List<Shipping_Address__c> addresses = ENOS_TestDataFactory.createTestShippingAddresses(2, testAccount.Id);
        
        System.assertEquals(2, addresses.size(), 'Should create 2 shipping addresses');
        System.assertEquals('Home', addresses[0].Address_Label__c, 'First address label should be Home');
        System.assertEquals('Work', addresses[1].Address_Label__c, 'Second address label should be Work');
    }
    
    // ============================================================================
    // PRICEBOOK TEST DATA TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateTestPricebookEntries() {
        // Test creating pricebook entries
        List<Product2> products = ENOS_TestDataFactory.createTestProducts(3);
        insert products;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> entries = ENOS_TestDataFactory.createTestPricebookEntries(products, standardPricebookId);
        
        System.assertEquals(3, entries.size(), 'Should create 3 pricebook entries');
        for (PricebookEntry entry : entries) {
            System.assertEquals(standardPricebookId, entry.Pricebook2Id, 'Pricebook ID should match');
            System.assertEquals(true, entry.IsActive, 'Pricebook entry should be active');
            System.assertEquals(99.99, entry.UnitPrice, 'Unit price should be 99.99');
        }
    }
    
    // ============================================================================
    // COMPLETE TEST DATA SET TESTS
    // ============================================================================
    
    @IsTest
    static void testCreateMinimalTestDataSet() {
        // Test creating minimal test data set
        ENOS_TestDataFactory.TestDataResult result = ENOS_TestDataFactory.createMinimalTestDataSet();
        
        System.assertNotEquals(null, result, 'Test data result should not be null');
        System.assertEquals(5, result.products.size(), 'Should create 5 products');
        System.assertEquals(2, result.categories.size(), 'Should create 2 categories');
        System.assertEquals(2, result.accounts.size(), 'Should create 2 accounts');
        System.assertEquals(2, result.contacts.size(), 'Should create 2 contacts (1 per account)');
        System.assertEquals(2, result.carts.size(), 'Should create 2 carts (1 per contact)');
        System.assertEquals(4, result.shippingAddresses.size(), 'Should create 4 shipping addresses (2 per account)');
        System.assertEquals(5, result.pricebookEntries.size(), 'Should create 5 pricebook entries (1 per product)');
    }
    
    @IsTest
    static void testCreateComprehensiveTestDataSet() {
        // Test creating comprehensive test data set
        ENOS_TestDataFactory.TestDataResult result = ENOS_TestDataFactory.createComprehensiveTestDataSet();
        
        System.assertNotEquals(null, result, 'Test data result should not be null');
        System.assertEquals(20, result.products.size(), 'Should create 20 products');
        System.assertEquals(5, result.categories.size(), 'Should create 5 categories');
        System.assertEquals(5, result.accounts.size(), 'Should create 5 accounts');
        System.assertEquals(10, result.contacts.size(), 'Should create 10 contacts (2 per account)');
        System.assertEquals(10, result.carts.size(), 'Should create 10 carts (1 per contact)');
        System.assertEquals(10, result.shippingAddresses.size(), 'Should create 10 shipping addresses (2 per account)');
        System.assertEquals(20, result.pricebookEntries.size(), 'Should create 20 pricebook entries (1 per product)');
    }
    
    @IsTest
    static void testCreateCompleteTestDataSetWithCustomCounts() {
        // Test creating complete test data set with custom counts
        ENOS_TestDataFactory.TestDataResult result = ENOS_TestDataFactory.createCompleteTestDataSet(10, 3, 4, 3);
        
        System.assertNotEquals(null, result, 'Test data result should not be null');
        System.assertEquals(10, result.products.size(), 'Should create 10 products');
        System.assertEquals(3, result.categories.size(), 'Should create 3 categories');
        System.assertEquals(4, result.accounts.size(), 'Should create 4 accounts');
        System.assertEquals(12, result.contacts.size(), 'Should create 12 contacts (3 per account)');
        System.assertEquals(12, result.carts.size(), 'Should create 12 carts (1 per contact)');
        System.assertEquals(8, result.shippingAddresses.size(), 'Should create 8 shipping addresses (2 per account)');
        System.assertEquals(10, result.pricebookEntries.size(), 'Should create 10 pricebook entries (1 per product)');
    }
    
    // ============================================================================
    // UTILITY METHOD TESTS
    // ============================================================================
    
    @IsTest
    static void testCleanupTestData() {
        // Test test data cleanup
        ENOS_TestDataFactory.TestDataResult result = ENOS_TestDataFactory.createMinimalTestDataSet();
        
        // Verify data was created
        System.assertNotEquals(null, result.products, 'Products should exist before cleanup');
        System.assertNotEquals(null, result.accounts, 'Accounts should exist before cleanup');
        
        // Clean up test data
        ENOS_TestDataFactory.cleanupTestData(result);
        
        // Verify cleanup completed without errors
        System.assert(true, 'Cleanup should complete without errors');
    }
    
    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================
    
    @IsTest
    static void testIntegrationWithConfiguration() {
        // Test that test data factory works with configuration
        Product2 product = ENOS_TestDataFactory.createTestProduct('Config Test Product');
        
        System.assertNotEquals(null, product.Stock_Quantity__c, 'Stock quantity should be set from configuration');
        System.assertEquals(true, product.IsActive, 'Product should be active');
        
        // Verify no exceptions were thrown
        System.assert(true, 'Integration test should complete without errors');
    }
    
    @IsTest
    static void testIntegrationWithLogging() {
        // Test that test data factory works with logging
        ENOS_TestDataFactory.TestDataResult result = ENOS_TestDataFactory.createMinimalTestDataSet();
        
        // Verify data was created successfully
        System.assertNotEquals(null, result, 'Test data result should not be null');
        System.assert(result.products.size() > 0, 'Should have created products');
        
        // Clean up
        ENOS_TestDataFactory.cleanupTestData(result);
        
        // Verify no exceptions were thrown
        System.assert(true, 'Integration with logging should complete without errors');
    }
}
