/**
 * @description Test utility class for creating test data for ENOS
 * Provides comprehensive test data setup for all ENOS functionality
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public class ENOSTestUtils {
  /**
   * @description Test data container for comprehensive testing
   */
  public class TestDataContainer {
    public Account testAccount;
    public Contact testContact;
    public User testUser;
    public Product2 testProduct;
    public Category__c testCategory;
    public Cart__c testCart;
    public Cart_Item__c testCartItem;
    public Shipping_Address__c testAddress;
  }

  /**
   * @description Creates comprehensive test data for ENOS functionality
   * @return TestDataContainer with all required test data
   */
  public static TestDataContainer createENOSTestData() {
    TestDataContainer container = new TestDataContainer();

    // Create test account
    container.testAccount = new Account(Name = 'ENOS Test Account');
    insert container.testAccount;

    // Create test contact
    container.testContact = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john.doe.test@enos.com',
      AccountId = container.testAccount.Id
    );
    insert container.testContact;

    // Create test user
    Profile communityProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Customer Community Plus Login User'
      LIMIT 1
    ];

    container.testUser = new User(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john.doe.test@enos.com',
      Username = 'john.doe.test@enos.com.' + System.currentTimeMillis(),
      Alias = 'jdoe',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = communityProfile.Id,
      ContactId = container.testContact.Id
    );
    insert container.testUser;

    // Create test category
    container.testCategory = new Category__c(
      Name__c = 'Test Category',
      Description__c = 'Test category for ENOS testing'
    );
    insert container.testCategory;

    // Create test product
    container.testProduct = new Product2(
      Name = 'Test Product',
      ProductCode = 'TEST-001',
      Description = 'Test product for ENOS testing',
      Category__c = container.testCategory.Id,
      IsActive = true,
      Stock_Quantity__c = 100,
      Image_URL__c = 'https://example.com/test-image.jpg'
    );
    insert container.testProduct;

    // Create test cart
    container.testCart = new Cart__c(
      Contact__c = container.testContact.Id,
      Status__c = 'Active'
    );
    insert container.testCart;

    // Create test cart item
    container.testCartItem = new Cart_Item__c(
      Cart__c = container.testCart.Id,
      Product__c = container.testProduct.Id,
      Quantity__c = 2,
      Unit_Price__c = 29.99
    );
    insert container.testCartItem;

    // Create test shipping address
    container.testAddress = new Shipping_Address__c(
      Account__c = container.testAccount.Id,
      Address_Label__c = 'Test Address',
      Street__c = '123 Test St',
      City__c = 'Test City',
      State__c = 'TS',
      Postal_Code__c = '12345',
      Country__c = 'Test Country',
      Is_Default__c = true
    );
    insert container.testAddress;

    return container;
  }

  /**
   * @description Creates a basic ENOS user for testing
   * @param contactId The contact ID to associate with the user
   * @return User record
   */
  public static User createENOSUser(Id contactId) {
    Profile communityProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Customer Community Plus Login User'
      LIMIT 1
    ];

    User testUser = new User(
      FirstName = 'Test',
      LastName = 'User',
      Email = 'test.user@enos.com',
      Username = 'test.user@enos.com.' + System.currentTimeMillis(),
      Alias = 'tuser',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = communityProfile.Id,
      ContactId = contactId
    );
    insert testUser;
    return testUser;
  }
}
