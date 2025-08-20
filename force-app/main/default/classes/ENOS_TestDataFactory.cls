/**
 * @description Centralized test data factory for ENOS platform
 * Provides standardized methods for creating test data across all test classes
 * Eliminates inconsistent test data patterns and reduces maintenance overhead
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_TestDataFactory {
    
    // Default values for test data
    private static final String DEFAULT_PRODUCT_FAMILY = 'Test Family';
    private static final String DEFAULT_PRODUCT_DESCRIPTION = 'Test product description';
    private static final String DEFAULT_CATEGORY_NAME = 'Test Category';
    private static final String DEFAULT_CATEGORY_DESCRIPTION = 'Test category description';
    private static final String DEFAULT_ACCOUNT_NAME = 'Test Account';
    private static final String DEFAULT_CONTACT_FIRST_NAME = 'Test';
    private static final String DEFAULT_CONTACT_LAST_NAME = 'Contact';
    private static final String DEFAULT_CONTACT_EMAIL = 'test.contact@example.com';
    
    // ============================================================================
    // PRODUCT TEST DATA
    // ============================================================================
    
    /**
     * @description Creates a single test product with minimal required fields
     * @param productName The name of the product
     * @return Product2 The created test product
     */
    public static Product2 createTestProduct(String productName) {
        return createTestProduct(productName, DEFAULT_PRODUCT_FAMILY, DEFAULT_PRODUCT_DESCRIPTION);
    }
    
    /**
     * @description Creates a single test product with specified family and description
     * @param productName The name of the product
     * @param family The product family
     * @param description The product description
     * @return Product2 The created test product
     */
    public static Product2 createTestProduct(String productName, String family, String description) {
        return new Product2(
            Name = productName,
            ProductCode = generateProductCode(productName),
            Description = description,
            Family = family,
            IsActive = true,
            Stock_Quantity__c = ENOS_ConfigurationUtils.getDefaultStockQuantity()
        );
    }
    
    /**
     * @description Creates multiple test products with consistent naming pattern
     * @param count The number of products to create
     * @param family The product family for all products
     * @return List<Product2> List of created test products
     */
    public static List<Product2> createTestProducts(Integer count, String family) {
        List<Product2> products = new List<Product2>();
        
        for (Integer i = 1; i <= count; i++) {
            products.add(createTestProduct(
                'Test Product ' + i,
                family,
                'Test product description ' + i
            ));
        }
        
        return products;
    }
    
    /**
     * @description Creates multiple test products with default family
     * @param count The number of products to create
     * @return List<Product2> List of created test products
     */
    public static List<Product2> createTestProducts(Integer count) {
        return createTestProducts(count, DEFAULT_PRODUCT_FAMILY);
    }
    
    /**
     * @description Creates test products with specific product codes
     * @param productCodes List of product codes to create
     * @param family The product family
     * @return List<Product2> List of created test products
     */
    public static List<Product2> createTestProductsWithCodes(List<String> productCodes, String family) {
        List<Product2> products = new List<Product2>();
        
        for (String productCode : productCodes) {
            products.add(new Product2(
                Name = 'Test Product ' + productCode,
                ProductCode = productCode,
                Description = 'Test product with code ' + productCode,
                Family = family,
                IsActive = true,
                Stock_Quantity__c = ENOS_ConfigurationUtils.getStockQuantity(productCode)
            ));
        }
        
        return products;
    }
    
    // ============================================================================
    // CATEGORY TEST DATA
    // ============================================================================
    
    /**
     * @description Creates a single test category
     * @param categoryName The name of the category
     * @return Category__c The created test category
     */
    public static Category__c createTestCategory(String categoryName) {
        return createTestCategory(categoryName, DEFAULT_CATEGORY_DESCRIPTION);
    }
    
    /**
     * @description Creates a single test category with description
     * @param categoryName The name of the category
     * @param description The category description
     * @return Category__c The created test category
     */
    public static Category__c createTestCategory(String categoryName, String description) {
        return new Category__c(
            Name__c = categoryName,
            Description__c = description
        );
    }
    
    /**
     * @description Creates multiple test categories
     * @param count The number of categories to create
     * @return List<Category__c> List of created test categories
     */
    public static List<Category__c> createTestCategories(Integer count) {
        List<Category__c> categories = new List<Category__c>();
        
        for (Integer i = 1; i <= count; i++) {
            categories.add(createTestCategory(
                'Test Category ' + i,
                'Test category description ' + i
            ));
        }
        
        return categories;
    }
    
    // ============================================================================
    // ACCOUNT TEST DATA
    // ============================================================================
    
    /**
     * @description Creates a single test account
     * @param accountName The name of the account
     * @return Account The created test account
     */
    public static Account createTestAccount(String accountName) {
        return new Account(
            Name = accountName,
            Type = 'Customer',
            Industry = 'Technology',
            BillingStreet = '123 Test Street',
            BillingCity = 'Test City',
            BillingState = 'CA',
            BillingPostalCode = '12345',
            BillingCountry = 'United States'
        );
    }
    
    /**
     * @description Creates a single test account with default name
     * @return Account The created test account
     */
    public static Account createTestAccount() {
        return createTestAccount(DEFAULT_ACCOUNT_NAME);
    }
    
    /**
     * @description Creates multiple test accounts
     * @param count The number of accounts to create
     * @return List<Account> List of created test accounts
     */
    public static List<Account> createTestAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 1; i <= count; i++) {
            accounts.add(createTestAccount('Test Account ' + i));
        }
        
        return accounts;
    }
    
    // ============================================================================
    // CONTACT TEST DATA
    // ============================================================================
    
    /**
     * @description Creates a single test contact
     * @param firstName The first name of the contact
     * @param lastName The last name of the contact
     * @param accountId The account ID for the contact
     * @return Contact The created test contact
     */
    public static Contact createTestContact(String firstName, String lastName, Id accountId) {
        return new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@example.com',
            AccountId = accountId,
            Phone = '555-0123',
            MailingStreet = '456 Test Avenue',
            MailingCity = 'Test City',
            MailingState = 'CA',
            MailingPostalCode = '12345',
            MailingCountry = 'United States'
        );
    }
    
    /**
     * @description Creates a single test contact with default values
     * @param accountId The account ID for the contact
     * @return Contact The created test contact
     */
    public static Contact createTestContact(Id accountId) {
        return createTestContact(DEFAULT_CONTACT_FIRST_NAME, DEFAULT_CONTACT_LAST_NAME, accountId);
    }
    
    /**
     * @description Creates multiple test contacts for an account
     * @param count The number of contacts to create
     * @param accountId The account ID for the contacts
     * @return List<Contact> List of created test contacts
     */
    public static List<Contact> createTestContacts(Integer count, Id accountId) {
        List<Contact> contacts = new List<Contact>();
        
        for (Integer i = 1; i <= count; i++) {
            contacts.add(createTestContact(
                'Test' + i,
                'Contact' + i,
                accountId
            ));
        }
        
        return contacts;
    }
    
    // ============================================================================
    // CART TEST DATA
    // ============================================================================
    
    /**
     * @description Creates a single test cart
     * @param contactId The contact ID for the cart
     * @return Cart__c The created test cart
     */
    public static Cart__c createTestCart(Id contactId) {
        return new Cart__c(
            Contact__c = contactId,
            Status__c = 'Active'
        );
    }
    
    /**
     * @description Creates multiple test carts
     * @param count The number of carts to create
     * @param contactId The contact ID for the carts
     * @return List<Cart__c> List of created test carts
     */
    public static List<Cart__c> createTestCarts(Integer count, Id contactId) {
        List<Cart__c> carts = new List<Cart__c>();
        
        for (Integer i = 1; i <= count; i++) {
            carts.add(createTestCart(contactId));
        }
        
        return carts;
    }
    
    // ============================================================================
    // CART ITEM TEST DATA
    // ============================================================================
    
    /**
     * @description Creates a single test cart item
     * @param cartId The cart ID for the item
     * @param productId The product ID for the item
     * @param quantity The quantity of the item
     * @param unitPrice The unit price of the item
     * @return Cart_Item__c The created test cart item
     */
    public static Cart_Item__c createTestCartItem(Id cartId, Id productId, Integer quantity, Decimal unitPrice) {
        return new Cart_Item__c(
            Cart__c = cartId,
            Product__c = productId,
            Quantity__c = quantity,
            Unit_Price__c = unitPrice
        );
    }
    
    /**
     * @description Creates a single test cart item with default quantity and price
     * @param cartId The cart ID for the item
     * @param productId The product ID for the item
     * @return Cart_Item__c The created test cart item
     */
    public static Cart_Item__c createTestCartItem(Id cartId, Id productId) {
        return createTestCartItem(cartId, productId, 1, 99.99);
    }
    
    /**
     * @description Creates multiple test cart items
     * @param count The number of cart items to create
     * @param cartId The cart ID for the items
     * @param productId The product ID for the items
     * @return List<Cart_Item__c> List of created test cart items
     */
    public static List<Cart_Item__c> createTestCartItems(Integer count, Id cartId, Id productId) {
        List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
        
        for (Integer i = 1; i <= count; i++) {
            cartItems.add(createTestCartItem(cartId, productId, i, 99.99 + i));
        }
        
        return cartItems;
    }
    
    // ============================================================================
    // SHIPPING ADDRESS TEST DATA
    // ============================================================================
    
    /**
     * @description Creates a single test shipping address
     * @param accountId The account ID for the shipping address
     * @param addressLabel The label for the shipping address
     * @return Shipping_Address__c The created test shipping address
     */
    public static Shipping_Address__c createTestShippingAddress(Id accountId, String addressLabel) {
        return new Shipping_Address__c(
            Account__c = accountId,
            Address_Label__c = addressLabel,
            Street__c = '789 Test Boulevard',
            City__c = 'Test City',
            State__c = 'CA',
            Postal_Code__c = '12345',
            Country__c = 'United States',
            Is_Default__c = true
        );
    }
    
    /**
     * @description Creates a single test shipping address with default label
     * @param accountId The account ID for the shipping address
     * @return Shipping_Address__c The created test shipping address
     */
    public static Shipping_Address__c createTestShippingAddress(Id accountId) {
        return createTestShippingAddress(accountId, 'Home');
    }
    
    /**
     * @description Creates multiple test shipping addresses
     * @param count The number of shipping addresses to create
     * @param accountId The account ID for the shipping addresses
     * @return List<Shipping_Address__c> List of created test shipping addresses
     */
    public static List<Shipping_Address__c> createTestShippingAddresses(Integer count, Id accountId) {
        List<Shipping_Address__c> addresses = new List<Shipping_Address__c>();
        List<String> labels = new List<String>{'Home', 'Work', 'Other'};
        
        for (Integer i = 0; i < count && i < labels.size(); i++) {
            addresses.add(createTestShippingAddress(accountId, labels[i]));
        }
        
        return addresses;
    }
    
    // ============================================================================
    // PRICEBOOK TEST DATA
    // ============================================================================
    
    /**
     * @description Creates test pricebook entries for products
     * @param products List of products to create pricebook entries for
     * @param pricebookId The pricebook ID
     * @return List<PricebookEntry> List of created test pricebook entries
     */
    public static List<PricebookEntry> createTestPricebookEntries(List<Product2> products, Id pricebookId) {
        List<PricebookEntry> entries = new List<PricebookEntry>();
        
        for (Product2 product : products) {
            entries.add(new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = product.Id,
                UnitPrice = 99.99,
                IsActive = true
            ));
        }
        
        return entries;
    }
    
    // ============================================================================
    // COMPLETE TEST DATA SETUP
    // ============================================================================
    
    /**
     * @description Creates a complete test data set with all related objects
     * @param productCount The number of products to create
     * @param categoryCount The number of categories to create
     * @param accountCount The number of accounts to create
     * @param contactCountPerAccount The number of contacts per account
     * @return TestDataResult The complete test data set
     */
    public static TestDataResult createCompleteTestDataSet(
        Integer productCount, 
        Integer categoryCount, 
        Integer accountCount, 
        Integer contactCountPerAccount
    ) {
        TestDataResult result = new TestDataResult();
        
        try {
            // Create categories
            List<Category__c> categories = createTestCategories(categoryCount);
            insert categories;
            result.categories = categories;
            
            // Create products
            List<Product2> products = createTestProducts(productCount);
            insert products;
            result.products = products;
            
            // Create accounts
            List<Account> accounts = createTestAccounts(accountCount);
            insert accounts;
            result.accounts = accounts;
            
            // Create contacts for each account
            List<Contact> allContacts = new List<Contact>();
            for (Account account : accounts) {
                List<Contact> contacts = createTestContacts(contactCountPerAccount, account.Id);
                allContacts.addAll(contacts);
            }
            insert allContacts;
            result.contacts = allContacts;
            
            // Create pricebook entries
            Id standardPricebookId = Test.getStandardPricebookId();
            List<PricebookEntry> pricebookEntries = createTestPricebookEntries(products, standardPricebookId);
            insert pricebookEntries;
            result.pricebookEntries = pricebookEntries;
            
            // Create carts for each contact
            List<Cart__c> allCarts = new List<Cart__c>();
            for (Contact contact : allContacts) {
                Cart__c cart = createTestCart(contact.Id);
                allCarts.add(cart);
            }
            insert allCarts;
            result.carts = allCarts;
            
            // Create shipping addresses for each account
            List<Shipping_Address__c> allAddresses = new List<Shipping_Address__c>();
            for (Account account : accounts) {
                List<Shipping_Address__c> addresses = createTestShippingAddresses(2, account.Id);
                allAddresses.addAll(addresses);
            }
            insert allAddresses;
            result.shippingAddresses = allAddresses;
            
            ENOS_LoggingUtils.info('Complete test data set created successfully', 
                'Products: ' + products.size() + ', Accounts: ' + accounts.size() + 
                ', Contacts: ' + allContacts.size() + ', Carts: ' + allCarts.size());
                
        } catch (Exception e) {
            ENOS_LoggingUtils.error('Error creating complete test data set', e);
            throw e;
        }
        
        return result;
    }
    
    /**
     * @description Creates a minimal test data set for basic testing
     * @return TestDataResult The minimal test data set
     */
    public static TestDataResult createMinimalTestDataSet() {
        return createCompleteTestDataSet(5, 2, 2, 1);
    }
    
    /**
     * @description Creates a comprehensive test data set for extensive testing
     * @return TestDataResult The comprehensive test data set
     */
    public static TestDataResult createComprehensiveTestDataSet() {
        return createCompleteTestDataSet(20, 5, 5, 2);
    }
    
    // ============================================================================
    // UTILITY METHODS
    // ============================================================================
    
    /**
     * @description Generates a product code based on the product name
     * @param productName The product name
     * @return String The generated product code
     */
    private static String generateProductCode(String productName) {
        if (String.isBlank(productName)) {
            return 'TEST-001';
        }
        
        // Extract first 3 characters and add random number
        String prefix = productName.left(3).toUpperCase();
        String suffix = String.valueOf(Math.round(Math.random() * 999)).leftPad(3, '0');
        return prefix + '-' + suffix;
    }
    
    /**
     * @description Cleans up test data to prevent test pollution
     * @param testData The test data result to clean up
     */
    public static void cleanupTestData(TestDataResult testData) {
        try {
            if (testData != null) {
                // Delete in reverse order of dependencies
                if (testData.cartItems != null && !testData.cartItems.isEmpty()) {
                    delete testData.cartItems;
                }
                if (testData.carts != null && !testData.carts.isEmpty()) {
                    delete testData.carts;
                }
                if (testData.shippingAddresses != null && !testData.shippingAddresses.isEmpty()) {
                    delete testData.shippingAddresses;
                }
                if (testData.contacts != null && !testData.contacts.isEmpty()) {
                    delete testData.contacts;
                }
                if (testData.pricebookEntries != null && !testData.pricebookEntries.isEmpty()) {
                    delete testData.pricebookEntries;
                }
                if (testData.products != null && !testData.products.isEmpty()) {
                    delete testData.products;
                }
                if (testData.categories != null && !testData.categories.isEmpty()) {
                    delete testData.categories;
                }
                if (testData.accounts != null && !testData.accounts.isEmpty()) {
                    delete testData.accounts;
                }
                
                ENOS_LoggingUtils.info('Test data cleanup completed successfully');
            }
        } catch (Exception e) {
            ENOS_LoggingUtils.error('Error during test data cleanup', e);
            // Don't throw exception during cleanup to avoid masking test failures
        }
    }
    
    // ============================================================================
    // INNER CLASSES
    // ============================================================================
    
    /**
     * @description Result class containing all created test data
     */
    public class TestDataResult {
        @TestVisible public List<Category__c> categories;
        @TestVisible public List<Product2> products;
        @TestVisible public List<Account> accounts;
        @TestVisible public List<Contact> contacts;
        @TestVisible public List<Cart__c> carts;
        @TestVisible public List<Cart_Item__c> cartItems;
        @TestVisible public List<Shipping_Address__c> shippingAddresses;
        @TestVisible public List<PricebookEntry> pricebookEntries;
        
        public TestDataResult() {
            this.categories = new List<Category__c>();
            this.products = new List<Product2>();
            this.accounts = new List<Account>();
            this.contacts = new List<Contact>();
            this.carts = new List<Cart__c>();
            this.cartItems = new List<Cart_Item__c>();
            this.shippingAddresses = new List<Shipping_Address__c>();
            this.pricebookEntries = new List<PricebookEntry>();
        }
    }
}
