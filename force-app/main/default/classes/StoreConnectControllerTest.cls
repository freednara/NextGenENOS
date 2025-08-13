@IsTest
private class StoreConnectControllerTest {
  @TestSetup
  static void setup() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    Contact con = new Contact(LastName = 'Tester', AccountId = acc.Id);
    insert con;
    Product2 prod = new Product2(
      Name = 'Test Product',
      ProductCode = 'TEST-001',
      IsActive = true
    );
    insert prod;
    Id pbId = Test.getStandardPricebookId();
    insert new PricebookEntry(
      Product2Id = prod.Id,
      Pricebook2Id = pbId,
      UnitPrice = 10,
      IsActive = true
    );
    insert new View_Tracking__c(
      User_Contact__c = con.Id,
      Product__c = prod.Id,
      Last_Viewed_Date__c = System.now()
    );
  }

  @IsTest
  static void testGetRecentlyViewed() {
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    List<StoreConnectController.RecentlyViewedProduct> results = StoreConnectController.getRecentlyViewed(
      c.Id
    );
    Test.stopTest();
    System.assertEquals(1, results.size());
    System.assertEquals('Test Product', results[0].productName);
  }

  private static User createUser(String profileName) {
    Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
    Integer rand = Math.abs(Crypto.getRandomInteger());
    String randStr = String.valueOf(rand);
    return new User(
      Username = 'user' + randStr + '@example.com',
      Alias = 'u' + randStr.left(4),
      Email = 'user' + randStr + '@example.com',
      LastName = 'Test',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = p.Id
    );
  }

  @IsTest
  static void testGetRecentlyViewedSecurity() {
    User limited = createUser('Minimum Access - Salesforce');
    insert limited;
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    System.runAs(limited) {
      Boolean thrown = false;
      try {
        StoreConnectController.getRecentlyViewed(c.Id);
      } catch (AuraHandledException e) {
        thrown = true;
      }
      System.assert(thrown, 'Expected security exception to be thrown');
    }
  }

  @IsTest
  static void testGetProducts() {
    Test.startTest();
    StoreConnectController.ProductCatalogResult result = StoreConnectController.getProducts(
      '',
      '',
      0,
      10,
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(1, result.products.size(), 'Should return 1 product');
    System.assertEquals(
      'Test Product',
      result.products[0].Name,
      'Product name should match'
    );
    System.assertEquals(1, result.totalCount, 'Total count should be 1');
    System.assertEquals(0, result.pageNumber, 'Page number should be 0');
    System.assertEquals(10, result.pageSize, 'Page size should be 10');
  }

  @IsTest
  static void testGetProductsWithSearch() {
    Test.startTest();
    StoreConnectController.ProductCatalogResult result = StoreConnectController.getProducts(
      'Test',
      '',
      0,
      10,
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(
      1,
      result.products.size(),
      'Should return 1 product matching search'
    );
    System.assertEquals(
      'Test Product',
      result.products[0].Name,
      'Product name should match search'
    );
  }

  @IsTest
  static void testGetProductsWithCategory() {
    Test.startTest();
    StoreConnectController.ProductCatalogResult result = StoreConnectController.getProducts(
      '',
      'TEST',
      0,
      10,
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(
      1,
      result.products.size(),
      'Should return 1 product matching category'
    );
  }

  @IsTest
  static void testGetProductsPagination() {
    Test.startTest();
    StoreConnectController.ProductCatalogResult result = StoreConnectController.getProducts(
      '',
      '',
      0,
      5,
      false
    );
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertEquals(1, result.products.size(), 'Should return 1 product');
    System.assertEquals(5, result.pageSize, 'Page size should be 5');
  }
}
