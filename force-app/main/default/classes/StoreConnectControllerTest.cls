@isTest
private class StoreConnectControllerTest {

    @testSetup
    static void setupData() {
        Id pricebookId = Test.getStandardPricebookId();

        List<Product2> prods = new List<Product2>();
        for (Integer i = 0; i < 6; i++) {
            prods.add(new Product2(Name = 'Test Product ' + i, ProductCode = 'TP' + i, IsActive = true));
        }
        insert prods;

        List<PricebookEntry> pbes = new List<PricebookEntry>();
        for (Integer i = 0; i < prods.size(); i++) {
            pbes.add(new PricebookEntry(Product2Id = prods[i].Id, Pricebook2Id = pricebookId, UnitPrice = 10 + i, IsActive = true));
        }
        insert pbes;
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

    @isTest
    static void testGetRecentlyViewedReturnsFive() {
        User u = createUser('Standard User');
        insert u;

        System.runAs(u) {
            List<Product2> prods = [SELECT Id FROM Product2 ORDER BY Name];
            List<View_Tracking__c> tracks = new List<View_Tracking__c>();
            Integer idx = 0;
            for (Product2 p : prods) {
                tracks.add(new View_Tracking__c(Product__c = p.Id, Last_Viewed_Date__c = System.now().addMinutes(idx)));
                idx++;
            }
            insert tracks;

            Test.startTest();
            List<Product2> result = StoreConnectController.getRecentlyViewed();
            Test.stopTest();

            System.assertEquals(5, result.size(), 'Should return last five products');
            System.assertEquals(prods[5].Id, result[0].Id, 'Most recent product should be first');
        }
    }

    @isTest
    static void testGetRecentlyViewedSecurity() {
        User limited = createUser('Minimum Access - Salesforce');
        insert limited;

        System.runAs(limited) {
            Boolean thrown = false;
            try {
                StoreConnectController.getRecentlyViewed();
            } catch (AuraHandledException e) {
                thrown = true;
            }
            System.assert(thrown, 'Expected security exception to be thrown');
        }
    }
}
