// ENOS CUSTOM OBJECTS TEST DATA
// This script creates comprehensive test data for ENOS custom objects
System.debug('Starting ENOS custom objects test data creation...');

// Get existing data for references
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 5];
List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact LIMIT 10];
List<Product2> products = [SELECT Id, Name, ProductCode FROM Product2 LIMIT 15];
List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE IsActive = true LIMIT 15];

System.debug('Found ' + accounts.size() + ' accounts, ' + contacts.size() + ' contacts, ' + products.size() + ' products');

// Create Categories
List<Category__c> categories = new List<Category__c>();
categories.add(new Category__c(Name__c = 'Electronics'));
categories.add(new Category__c(Name__c = 'Computers'));
categories.add(new Category__c(Name__c = 'Mobile Devices'));
categories.add(new Category__c(Name__c = 'Gaming'));
categories.add(new Category__c(Name__c = 'Home & Office'));

insert categories;
System.debug('Inserted ' + categories.size() + ' categories');

// Create Shipping Addresses
List<Shipping_Address__c> shippingAddresses = new List<Shipping_Address__c>();

for(Account acc : accounts) {
    shippingAddresses.add(new Shipping_Address__c(
        Account__c = acc.Id,
        Address_Label__c = 'Primary Office',
        Street__c = '123 Business Street',
        City__c = 'San Francisco',
        State__c = 'CA',
        Postal_Code__c = '94105',
        Country__c = 'USA'
    ));
    
    shippingAddresses.add(new Shipping_Address__c(
        Account__c = acc.Id,
        Address_Label__c = 'Warehouse',
        Street__c = '456 Industrial Drive',
        City__c = 'Oakland',
        State__c = 'CA',
        Postal_Code__c = '94601',
        Country__c = 'USA'
    ));
}

insert shippingAddresses;
System.debug('Inserted ' + shippingAddresses.size() + ' shipping addresses');

// Create Active Carts
List<Cart__c> carts = new List<Cart__c>();

for(Integer i = 0; i < 5; i++) {
    carts.add(new Cart__c(
        Contact__c = contacts[i].Id,
        Status__c = 'Active'
    ));
}

// Create some completed carts
for(Integer i = 5; i < 8; i++) {
    carts.add(new Cart__c(
        Contact__c = contacts[i].Id,
        Status__c = 'Completed'
    ));
}

insert carts;
System.debug('Inserted ' + carts.size() + ' carts');

// Create Cart Items
List<Cart_Item__c> cartItems = new List<Cart_Item__c>();

Integer itemCounter = 0;
for(Cart__c cart : carts) {
    // Add 2-4 items per cart
    Integer numItems = 2 + Math.mod(itemCounter, 3);
    
    for(Integer j = 0; j < numItems; j++) {
        Integer productIndex = Math.mod(itemCounter + j, products.size());
        Integer pricebookIndex = Math.mod(itemCounter + j, pricebookEntries.size());
        Integer quantity = 1 + Math.mod(itemCounter + j, 3);
        
        cartItems.add(new Cart_Item__c(
            Cart__c = cart.Id,
            Product__c = products[productIndex].Id,
            Quantity__c = quantity,
            Unit_Price__c = pricebookEntries[pricebookIndex].UnitPrice
        ));
        itemCounter++;
    }
}

insert cartItems;
System.debug('Inserted ' + cartItems.size() + ' cart items');

// Create View Tracking data
List<View_Tracking__c> viewTrackings = new List<View_Tracking__c>();

for(Integer i = 0; i < 50; i++) {
    Integer contactIndex = Math.mod(i, contacts.size());
    Integer productIndex = Math.mod(i, products.size());
    
    viewTrackings.add(new View_Tracking__c(
        User_Contact__c = contacts[contactIndex].Id,
        Product__c = products[productIndex].Id,
        Last_Viewed_Date__c = DateTime.now().addDays(-Math.mod(i, 7)).addHours(-Math.mod(i, 12))
    ));
}

insert viewTrackings;
System.debug('Inserted ' + viewTrackings.size() + ' view tracking records');

// Create Notification Requests
List<Notification_Request__c> notifications = new List<Notification_Request__c>();

for(Integer i = 0; i < 20; i++) {
    Integer contactIndex = Math.mod(i, contacts.size());
    Integer productIndex = Math.mod(i*2, products.size());
    
    notifications.add(new Notification_Request__c(
        User_Contact__c = contacts[contactIndex].Id,
        Product__c = products[productIndex].Id,
        Status__c = i < 15 ? 'Pending' : 'Sent'
    ));
}

insert notifications;
System.debug('Inserted ' + notifications.size() + ' notification requests');

// Final summary
System.debug('');
System.debug('==========================================');
System.debug('ENOS TEST DATA CREATION COMPLETE');
System.debug('==========================================');

System.debug('Custom Objects Data Summary:');
System.debug('Categories: ' + [SELECT COUNT() FROM Category__c]);
System.debug('Shipping Addresses: ' + [SELECT COUNT() FROM Shipping_Address__c]);

// Use separate queries to avoid compile issues
Integer activeCartCount = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Active'];
System.debug('Active Carts: ' + activeCartCount);

Integer completedCartCount = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Completed'];
System.debug('Completed Carts: ' + completedCartCount);

System.debug('Cart Items: ' + [SELECT COUNT() FROM Cart_Item__c]);
System.debug('View Tracking: ' + [SELECT COUNT() FROM View_Tracking__c]);

Integer pendingNotifications = [SELECT COUNT() FROM Notification_Request__c WHERE Status__c = 'Pending'];
System.debug('Pending Notifications: ' + pendingNotifications);

Integer sentNotifications = [SELECT COUNT() FROM Notification_Request__c WHERE Status__c = 'Sent'];
System.debug('Sent Notifications: ' + sentNotifications);

System.debug('');
System.debug('Sample Active Carts:');
for(Cart__c cart : [SELECT Id, Contact__r.FirstName, Contact__r.LastName, Status__c FROM Cart__c WHERE Status__c = 'Active' LIMIT 3]) {
    System.debug('- Cart for ' + cart.Contact__r.FirstName + ' ' + cart.Contact__r.LastName + ' (Status: ' + cart.Status__c + ')');
}

System.debug('');
System.debug('Sample Cart Items:');
for(Cart_Item__c item : [SELECT Product__r.Name, Quantity__c, Unit_Price__c FROM Cart_Item__c LIMIT 5]) {
    System.debug('- ' + item.Product__r.Name + ' (Qty: ' + item.Quantity__c + ', Price: $' + item.Unit_Price__c + ')');
}

System.debug('');
System.debug('ENOS test data creation successful!');
System.debug('Ready for comprehensive testing of ENOS application with custom objects.');
