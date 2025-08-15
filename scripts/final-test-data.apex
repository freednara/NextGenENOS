// Final test data creation for ENOS flow testing
// This script uses the actual field names that exist in the org

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

    // Create test cart (using only existing fields)
    Cart__c testCart = new Cart__c();
    testCart.Status__c = 'Active';
    insert testCart;
    System.debug('Cart created: ' + testCart.Id);

    // Create test cart item (using correct field names)
    Cart_Item__c testCartItem = new Cart_Item__c();
    testCartItem.Cart__c = testCart.Id;
    testCartItem.Quantity__c = 2;
    testCartItem.Unit_Price__c = 29.99;
    insert testCartItem;
    System.debug('Cart Item created: ' + testCartItem.Id);

    System.debug('Test data created successfully!');
    System.debug('Account ID: ' + testAccount.Id);
    System.debug('Contact ID: ' + testContact.Id);
    System.debug('Cart ID: ' + testCart.Id);
    System.debug('Cart Item ID: ' + testCartItem.Id);
    
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
