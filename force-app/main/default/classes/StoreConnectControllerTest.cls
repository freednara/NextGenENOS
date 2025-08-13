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
}

