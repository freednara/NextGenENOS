// Simple test data creation for ENOS flow testing
// Run this in Developer Console or via SF CLI

try {
    // Create test account
    Account testAccount = new Account();
    testAccount.Name = 'ENOS Test Customer';
    testAccount.BillingStreet = '123 Test Street';
    testAccount.BillingCity = 'Test City';
    testAccount.BillingState = 'Test State';
    testAccount.BillingPostalCode = '12345';
    testAccount.BillingCountry = 'Test Country';
    insert testAccount;
    System.debug('Account created: ' + testAccount.Id);

    // Create test contact
    Contact testContact = new Contact();
    testContact.AccountId = testAccount.Id;
    testContact.FirstName = 'Test';
    testContact.LastName = 'Customer';
    testContact.Email = 'test.customer@enos.com';
    testContact.Phone = '555-123-4567';
    insert testContact;
    System.debug('Contact created: ' + testContact.Id);

    // Check Cart__c object structure
    Schema.DescribeSObjectResult cartDescribe = Cart__c.SObjectType.getDescribe();
    System.debug('Cart__c fields: ' + cartDescribe.fields.getMap().keySet());
    
    // Try to create test cart
    Cart__c testCart = new Cart__c();
    testCart.Contact__c = testContact.Id;
    testCart.Status__c = 'Active';
    insert testCart;
    System.debug('Cart created: ' + testCart.Id);

    System.debug('Test data created successfully!');
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
