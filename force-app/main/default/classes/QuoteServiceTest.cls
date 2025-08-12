@IsTest
private class QuoteServiceTest {

    /**
     * @description Creates a test user linked to a contact and account.
     */
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Account a = new Account(Name = 'Test Account');
        insert a;
        Contact c = new Contact(FirstName = 'Test', LastName = 'User', AccountId = a.Id);
        insert c;
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            ContactId = c.Id
        );
        insert u;
        return u;
    }

    @IsTest
    static void testGetQuotes() {
        User u = createTestUser();
        System.runAs(u) {
            Id pbId = Test.getStandardPricebookId();
            User current = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            Quote q1 = new Quote(Name = 'Quote1', AccountId = current.Contact.AccountId, Pricebook2Id = pbId, Status = 'Draft');
            Quote q2 = new Quote(Name = 'Quote2', AccountId = current.Contact.AccountId, Pricebook2Id = pbId, Status = 'Approved');
            insert new List<Quote>{q1, q2};

            Test.startTest();
            List<Quote> quotes = QuoteService.getQuotes();
            Test.stopTest();

            System.assertEquals(2, quotes.size(), 'Should return two quotes');
        }
    }

    @IsTest
    static void testCreateQuote() {
        User u = createTestUser();
        System.runAs(u) {
            User current = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            Cart__c cart = new Cart__c(Contact__c = current.ContactId, Status__c = 'Active', Subtotal__c = 100, Total_Items__c = 0);
            insert cart;

            Test.startTest();
            Quote q = QuoteService.createQuote();
            Test.stopTest();

            System.assertNotEquals(null, q.Id, 'Quote should be created');
            System.assertEquals(current.Contact.AccountId, q.AccountId, 'Quote account should match user account');
        }
    }
}
