@IsTest
private class QuoteServiceTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Quote Account');
        insert acc;
    }

    @IsTest
    static void testCreateAndGetQuotes() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Quote created = QuoteService.createQuote(acc.Id);
        Test.stopTest();
        System.assertNotEquals(null, created.Id);
        List<Quote> quotes = QuoteService.getQuotes(acc.Id);
        System.assertEquals(1, quotes.size());
        System.assertEquals(created.Id, quotes[0].Id);
    }
}
