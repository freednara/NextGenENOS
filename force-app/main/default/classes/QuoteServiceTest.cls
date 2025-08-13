@IsTest
private class QuoteServiceTest {
    
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'User', AccountId = acc.Id);
        insert con;
        
        // Create test quotes
        Id pbId = Test.getStandardPricebookId();
        Quote q1 = new Quote(Name = 'Quote1', AccountId = acc.Id, Pricebook2Id = pbId, Status = 'Draft');
        Quote q2 = new Quote(Name = 'Quote2', AccountId = acc.Id, Pricebook2Id = pbId, Status = 'Approved');
        insert new List<Quote>{q1, q2};
        
        // Create test cart
        Cart__c cart = new Cart__c(Contact__c = con.Id, Status__c = 'Active', Subtotal__c = 100, Total_Items__c = 2);
        insert cart;
    }
    
    /**
     * @description Creates a test user linked to a contact and account.
     */
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact c = [SELECT Id FROM Contact WHERE AccountId = :a.Id LIMIT 1];
        
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
            Test.startTest();
            List<Quote> quotes = QuoteService.getQuotes();
            Test.stopTest();
            
            System.assertEquals(2, quotes.size(), 'Should return two quotes for the user\'s account');
            System.assertEquals('Quote2', quotes[0].Name, 'Most recent quote should be first');
            System.assertEquals('Quote1', quotes[1].Name, 'Older quote should be second');
        }
    }
    
    @IsTest
    static void testGetQuotesForAccount() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        List<Quote> quotes = QuoteService.getQuotesForAccount(acc.Id);
        Test.stopTest();
        
        System.assertEquals(2, quotes.size(), 'Should return two quotes for the account');
    }
    
    @IsTest
    static void testGetQuotesForAccountWithNullId() {
        Test.startTest();
        try {
            QuoteService.getQuotesForAccount(null);
            System.assert(false, 'Should have thrown an exception for null account ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testCreateQuoteFromCart() {
        User u = createTestUser();
        System.runAs(u) {
            Test.startTest();
            Quote q = QuoteService.createQuoteFromCart();
            Test.stopTest();
            
            System.assertNotEquals(null, q.Id, 'Quote should be created');
            System.assertEquals('Draft', q.Status, 'Quote should be in Draft status');
            System.assert(q.Name.contains('Quote for Cart'), 'Quote name should reference cart');
            
            // Verify the quote is associated with the correct account
            User current = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            System.assertEquals(current.Contact.AccountId, q.AccountId, 'Quote account should match user account');
        }
    }
    
    @IsTest
    static void testCreateQuote() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Quote created = QuoteService.createQuote(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, created.Id, 'Quote should be created');
        System.assertEquals('New Quote', created.Name, 'Quote should have default name');
        System.assertEquals('Draft', created.Status, 'Quote should be in Draft status');
        System.assertEquals(acc.Id, created.AccountId, 'Quote should be associated with correct account');
        System.assertNotEquals(null, created.ExpirationDate, 'Quote should have expiration date');
    }
    
    @IsTest
    static void testCreateQuoteWithNullAccountId() {
        Test.startTest();
        try {
            QuoteService.createQuote(null);
            System.assert(false, 'Should have thrown an exception for null account ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Account ID cannot be null'), 'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testCreateAndGetQuotesIntegration() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Quote created = QuoteService.createQuote(acc.Id);
        List<Quote> quotes = QuoteService.getQuotesForAccount(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, created.Id, 'Quote should be created');
        System.assertEquals(3, quotes.size(), 'Should return three quotes (2 from setup + 1 created)');
        
        // Find our created quote in the results
        Boolean foundCreatedQuote = false;
        for (Quote q : quotes) {
            if (q.Id == created.Id) {
                foundCreatedQuote = true;
                break;
            }
        }
        System.assert(foundCreatedQuote, 'Created quote should be in the results');
    }
    
    @IsTest
    static void testGetQuotesUserWithoutContact() {
        // Create a user without a contact
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'nocon',
            Email = 'nocontact@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NoContact',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'nocontact' + System.currentTimeMillis() + '@example.com'
        );
        insert u;
        
        System.runAs(u) {
            Test.startTest();
            List<Quote> quotes = QuoteService.getQuotes();
            Test.stopTest();
            
            System.assertEquals(0, quotes.size(), 'Should return empty list for user without contact');
        }
    }
    
    @IsTest
    static void testCreateQuoteFromCartUserWithoutContact() {
        // Create a user without a contact
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'nocon',
            Email = 'nocontact@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NoContact',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'nocontact' + System.currentTimeMillis() + '@example.com'
        );
        insert u;
        
        System.runAs(u) {
            Test.startTest();
            try {
                QuoteService.createQuoteFromCart();
                System.assert(false, 'Should have thrown an exception for user without contact');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('not associated with a contact'), 'Should throw appropriate error message');
            }
            Test.stopTest();
        }
    }
}