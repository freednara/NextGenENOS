/**
 * @description Test utility class for creating test data for StoreConnect
 * Provides standardized test data creation methods for all test classes
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class StoreConnectTestUtils {
    
    /**
     * @description Container class for all test data
     */
    public class TestDataContainer {
        public Account testAccount;
        public Contact testContact;
        public User testUser;
        public List<Product2> testProducts;
        public Pricebook2 standardPricebook;
        public List<PricebookEntry> pricebookEntries;
        public Cart__c testCart;
        public List<Cart_Item__c> testCartItems;
    }
    
    /**
     * @description Creates comprehensive test data for StoreConnect functionality
     * @return TestDataContainer with all necessary test records
     */
    public static TestDataContainer createStoreConnectTestData() {
        TestDataContainer testData = new TestDataContainer();
        
        // Create test account
        testData.testAccount = new Account(
            Name = 'StoreConnect Test Account'
        );
        insert testData.testAccount;
        
        // Create test contact
        testData.testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            AccountId = testData.testAccount.Id
        );
        insert testData.testContact;
        
        // Create test user with fallback profile selection
        Profile communityProfile;
        try {
            communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' OR Name = 'Customer Community Plus User' LIMIT 1];
        } catch (Exception e) {
            // Fallback to standard user if community profiles don't exist
            communityProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        }
        
        testData.testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'storeuser@test.com',
            Username = 'john.doe.test@storeconnect.com.' + System.currentTimeMillis(),
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = communityProfile.Id,
            ContactId = testData.testContact.Id
        );
        insert testData.testUser;
        
        // Get standard pricebook
        testData.standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        // Create test products with unique codes
        String uniqueId = String.valueOf(System.currentTimeMillis()).substring(7);
        testData.testProducts = new List<Product2>{
            new Product2(
                Name = 'Test Product 1',
                ProductCode = 'TEST-001-' + uniqueId,
                Description = 'Test product for unit testing',
                IsActive = true
            ),
            new Product2(
                Name = 'Test Product 2', 
                ProductCode = 'TEST-002-' + uniqueId,
                Description = 'Second test product',
                IsActive = true
            )
        };
        insert testData.testProducts;
        
        // Create pricebook entries
        testData.pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : testData.testProducts) {
            testData.pricebookEntries.add(new PricebookEntry(
                Product2Id = product.Id,
                Pricebook2Id = testData.standardPricebook.Id,
                UnitPrice = 25.00,
                IsActive = true
            ));
        }
        insert testData.pricebookEntries;
        
        return testData;
    }
    
    /**
     * @description Creates a test cart with items for a given contact
     * @param contactId The contact ID to create cart for
     * @param products List of products to add to cart
     * @return Cart__c The created cart
     */
    public static Cart__c createTestCart(Id contactId, List<Product2> products) {
        Cart__c testCart = new Cart__c(
            Contact__c = contactId,
            Status__c = 'Active'
        );
        insert testCart;
        
        if (products != null && !products.isEmpty()) {
            List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
            for (Product2 product : products) {
                cartItems.add(new Cart_Item__c(
                    Cart__c = testCart.Id,
                    Product__c = product.Id,
                    Quantity__c = 1,
                    Unit_Price__c = 25.00
                ));
            }
            insert cartItems;
        }
        
        return testCart;
    }
    
    /**
     * @description Creates test shipping address
     * @param accountId The account ID to associate with
     * @return Shipping_Address__c The created shipping address
     */
    public static Shipping_Address__c createTestShippingAddress(Id accountId) {
        Shipping_Address__c address = new Shipping_Address__c(
            Account__c = accountId,
            Address_Label__c = 'Test Address',
            Street__c = '123 Test Street',
            City__c = 'Test City',
            State__c = 'TS',
            Postal_Code__c = '12345',
            Country__c = 'United States',
            Is_Default__c = true
        );
        insert address;
        return address;
    }
}