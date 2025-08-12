@IsTest
private class StoreConnectControllerTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Tester', AccountId = acc.Id);
        insert con;

        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        Id pbId = Test.getStandardPricebookId();
        insert new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = pbId, UnitPrice = 10, IsActive = true);

        insert new View_Tracking__c(User_Contact__c = con.Id, Product__c = prod.Id, Last_Viewed_Date__c = System.now());
    }

    @IsTest
    static void testGetRecentlyViewed() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        List<StoreConnectController.RecentlyViewedProduct> results = StoreConnectController.getRecentlyViewed(c.Id);
        Test.stopTest();
        System.assertEquals(1, results.size());
        System.assertEquals('Test Product', results[0].Name);
    }
}
