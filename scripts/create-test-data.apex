// Create test data for ENOS flow testing
// Run this in Developer Console or via SF CLI

// Create test account
Account testAccount = new Account();
testAccount.Name = 'ENOS Test Customer';
testAccount.BillingStreet = '123 Test Street';
testAccount.BillingCity = 'Test City';
testAccount.BillingState = 'Test State';
testAccount.BillingPostalCode = '12345';
testAccount.BillingCountry = 'Test Country';
insert testAccount;

// Create test contact
Contact testContact = new Contact();
testContact.AccountId = testAccount.Id;
testContact.FirstName = 'Test';
testContact.LastName = 'Customer';
testContact.Email = 'test.customer@enos.com';
testContact.Phone = '555-123-4567';
insert testContact;

// Create test cart
Cart__c testCart = new Cart__c();
testCart.Contact__c = testContact.Id;
testCart.Status__c = 'Active';
insert testCart;

// Create test cart item
Cart_Item__c testCartItem = new Cart_Item__c();
testCartItem.Cart__c = testCart.Id;
testCartItem.Product__c = '01tSL000003qbpmYAA'; // Premium Wireless Headphones
testCartItem.Quantity__c = 2;
testCartItem.Unit_Price__c = 29.99;
insert testCartItem;

System.debug('Test data created successfully:');
System.debug('Account: ' + testAccount.Id);
System.debug('Contact: ' + testContact.Id);
System.debug('Cart: ' + testCart.Id);
System.debug('Cart Item: ' + testCartItem.Id);
