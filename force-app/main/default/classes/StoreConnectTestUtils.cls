/**
 * @description Test utility class for StoreConnect test setup
 * Provides common test data creation and permission assignment methods
 *
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class StoreConnectTestUtils {
    
    /**
     * @description Creates a test user with System Administrator profile
     * @param firstName First name of the test user
     * @param lastName Last name of the test user
     * @param email Email of the test user
     * @param contactId Optional contact ID to associate with the user
     * @return User The created test user
     */
    public static User createTestUser(String firstName, String lastName, String email, Id contactId) {
        // Get System Administrator profile (always available in orgs)
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        String uniqueName = email + '.' + DateTime.now().getTime();
        
        User testUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = uniqueName,
            Alias = (firstName.substring(0,1) + lastName.substring(0,1) + String.valueOf(DateTime.now().getTime()).substring(8,13)).toLowerCase(),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = adminProfile.Id,
            ContactId = contactId
        );
        
        insert testUser;
        return testUser;
    }
    
    /**
     * @description Creates a standard StoreConnect test user
     * @param contactId Optional contact ID to associate with the user
     * @return User Test user with admin permissions (for testing)
     */
    public static User createStoreConnectUser(Id contactId) {
        return createTestUser('Store', 'User', 'storeuser@test.com', contactId);
    }
    
    /**
     * @description Creates a StoreConnect admin test user
     * @param contactId Optional contact ID to associate with the user
     * @return User Test user with admin permissions
     */
    public static User createStoreConnectAdmin(Id contactId) {
        return createTestUser('Store', 'Admin', 'storeadmin@test.com', contactId);
    }
    
    /**
     * @description Creates a payment processor test user
     * @param contactId Optional contact ID to associate with the user
     * @return User Test user with admin permissions (for testing)
     */
    public static User createPaymentProcessor(Id contactId) {
        return createTestUser('Payment', 'Processor', 'payment@test.com', contactId);
    }
    

    
    /**
     * @description Creates test data for StoreConnect including Account, Contact, Products, etc.
     * @return TestDataContainer containing all created test data
     */
    public static TestDataContainer createStoreConnectTestData() {
        TestDataContainer data = new TestDataContainer();
        
        // Create test account
        data.testAccount = new Account(Name = 'StoreConnect Test Account');
        insert data.testAccount;
        
        // Create test contact
        data.testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Customer',
            Email = 'testcustomer@storeconnect.test',
            AccountId = data.testAccount.Id
        );
        insert data.testContact;
        
        // Create test products
        data.testProducts = new List<Product2>{
            new Product2(
                Name = 'Test Product 1',
                ProductCode = 'TEST001',
                Description = 'Test Product 1 Description',
                IsActive = true,
                Stock_Quantity__c = 100
            ),
            new Product2(
                Name = 'Test Product 2',
                ProductCode = 'TEST002',
                Description = 'Test Product 2 Description',
                IsActive = true,
                Stock_Quantity__c = 50
            )
        };
        insert data.testProducts;
        
        // Create pricebook entries
        data.pricebookEntries = new List<PricebookEntry>();
        Id standardPricebookId = Test.getStandardPricebookId();
        
        for (Product2 product : data.testProducts) {
            data.pricebookEntries.add(new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = product.Id,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        insert data.pricebookEntries;
        
        // Create test cart
        data.testCart = new Cart__c(
            Contact__c = data.testContact.Id,
            Status__c = 'Active',
            Subtotal__c = 0.00,
            Total_Items__c = 0
        );
        insert data.testCart;
        
        // Create test user associated with the contact
        data.testUser = createStoreConnectUser(data.testContact.Id);
        
        return data;
    }
    
    /**
     * @description Container class for test data
     */
    public class TestDataContainer {
        public Account testAccount;
        public Contact testContact;
        public List<Product2> testProducts;
        public List<PricebookEntry> pricebookEntries;
        public Cart__c testCart;
        public User testUser;
    }
}
