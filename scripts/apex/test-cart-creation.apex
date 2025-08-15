// Test Cart Creation
System.debug('Testing cart creation...');

// Get a contact
List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
if(contacts.isEmpty()) {
    System.debug('No contacts found! Creating basic contact first...');
    
    Account testAccount = new Account(Name = 'Test Account', Industry = 'Technology');
    insert testAccount;
    
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'test@example.com',
        AccountId = testAccount.Id
    );
    insert testContact;
    contacts.add(testContact);
}

System.debug('Using contact: ' + contacts[0].FirstName + ' ' + contacts[0].LastName);

// Try to create a cart
try {
    Cart__c testCart = new Cart__c(
        Contact__c = contacts[0].Id,
        Status__c = 'Active'
    );
    insert testCart;
    System.debug('SUCCESS: Created cart with ID: ' + testCart.Id);
} catch(Exception e) {
    System.debug('ERROR creating cart: ' + e.getMessage());
}

System.debug('Cart creation test complete.');
