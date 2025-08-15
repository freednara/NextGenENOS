// CREATE WORKING TEST DATA
// Uses only fields that are actually available in the org

System.debug('Creating test data with available fields...');

// Get existing contacts for shipping addresses
List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact LIMIT 10];
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 10];
List<Product2> products = [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true LIMIT 15];

System.debug('Found ' + accounts.size() + ' accounts, ' + contacts.size() + ' contacts, ' + products.size() + ' products');

// 1. Create Categories (this works)
List<Category__c> categories = new List<Category__c>();
categories.add(new Category__c(Name__c = 'Electronics & Audio'));
categories.add(new Category__c(Name__c = 'Computing & IT'));
categories.add(new Category__c(Name__c = 'Mobile & Wearables'));
categories.add(new Category__c(Name__c = 'Gaming & Entertainment'));
categories.add(new Category__c(Name__c = 'Networking & Security'));
categories.add(new Category__c(Name__c = 'Office & Productivity'));

insert categories;
System.debug('✅ Created ' + categories.size() + ' product categories');

// 2. Create Shipping Addresses
List<Shipping_Address__c> shippingAddresses = new List<Shipping_Address__c>();

for(Account acc : accounts) {
    shippingAddresses.add(new Shipping_Address__c(
        Account__c = acc.Id,
        Address_Label__c = 'Main Office',
        Street__c = '123 Business Street',
        City__c = 'San Francisco',
        State__c = 'CA',
        Postal_Code__c = '94105',
        Country__c = 'USA'
    ));
    
    // Add a secondary address for some accounts
    if(Math.mod(shippingAddresses.size(), 2) == 0) {
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
}

insert shippingAddresses;
System.debug('✅ Created ' + shippingAddresses.size() + ' shipping addresses');

// 3. Create basic Carts (without Contact field for now)
List<Cart__c> carts = new List<Cart__c>();

for(Integer i = 0; i < 8; i++) {
    carts.add(new Cart__c(
        Status__c = i < 6 ? 'Active' : 'Completed'
    ));
}

insert carts;
System.debug('✅ Created ' + carts.size() + ' carts');

// 4. Create View Tracking data
List<View_Tracking__c> viewTrackings = new List<View_Tracking__c>();

for(Integer i = 0; i < 40; i++) {
    Integer contactIndex = Math.mod(i, contacts.size());
    Integer productIndex = Math.mod(i, products.size());
    
    viewTrackings.add(new View_Tracking__c(
        User_Contact__c = contacts[contactIndex].Id,
        Product__c = products[productIndex].Id,
        Last_Viewed_Date__c = DateTime.now().addDays(-Math.mod(i, 7)).addHours(-Math.mod(i, 12))
    ));
}

insert viewTrackings;
System.debug('✅ Created ' + viewTrackings.size() + ' product view tracking records');

// 5. Create Notification Requests
List<Notification_Request__c> notifications = new List<Notification_Request__c>();

for(Integer i = 0; i < 15; i++) {
    Integer contactIndex = Math.mod(i, contacts.size());
    Integer productIndex = Math.mod(i*2, products.size());
    
    notifications.add(new Notification_Request__c(
        User_Contact__c = contacts[contactIndex].Id,
        Product__c = products[productIndex].Id,
        Status__c = i < 10 ? 'Pending' : 'Sent'
    ));
}

insert notifications;
System.debug('✅ Created ' + notifications.size() + ' notification requests');

// 6. Create Cart Items (if possible)
List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE IsActive = true LIMIT 15];

if(!pricebookEntries.isEmpty()) {
    Integer itemCounter = 0;
    for(Cart__c cart : carts) {
        // Add 2-3 items per cart
        Integer numItems = 2 + Math.mod(itemCounter, 2);
        
        for(Integer j = 0; j < numItems && itemCounter < 20; j++) {
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
    System.debug('✅ Created ' + cartItems.size() + ' cart items');
} else {
    System.debug('⚠️ No price book entries found - skipping cart items');
}

// FINAL SUMMARY
System.debug('');
System.debug('==========================================');
System.debug('TEST DATA CREATION COMPLETE');
System.debug('==========================================');

System.debug('📊 COMPREHENSIVE DATA SUMMARY:');
System.debug('');

// Standard Objects
System.debug('📋 STANDARD OBJECTS:');
System.debug('   Accounts: ' + [SELECT COUNT() FROM Account]);
System.debug('   Contacts: ' + [SELECT COUNT() FROM Contact]);
System.debug('   Products: ' + [SELECT COUNT() FROM Product2 WHERE IsActive = true]);
System.debug('   Price Book Entries: ' + [SELECT COUNT() FROM PricebookEntry WHERE IsActive = true]);
System.debug('   Orders: ' + [SELECT COUNT() FROM Order]);
System.debug('   Order Items: ' + [SELECT COUNT() FROM OrderItem]);

System.debug('');
System.debug('🛒 CUSTOM ENOS OBJECTS:');
System.debug('   Categories: ' + [SELECT COUNT() FROM Category__c]);
System.debug('   Shipping Addresses: ' + [SELECT COUNT() FROM Shipping_Address__c]);

Integer activeCarts = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Active'];
System.debug('   Active Carts: ' + activeCarts);

Integer completedCarts = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Completed'];
System.debug('   Completed Carts: ' + completedCarts);

System.debug('   Cart Items: ' + [SELECT COUNT() FROM Cart_Item__c]);
System.debug('   View Tracking: ' + [SELECT COUNT() FROM View_Tracking__c]);

Integer pendingNotifications = [SELECT COUNT() FROM Notification_Request__c WHERE Status__c = 'Pending'];
System.debug('   Pending Notifications: ' + pendingNotifications);

Integer sentNotifications = [SELECT COUNT() FROM Notification_Request__c WHERE Status__c = 'Sent'];
System.debug('   Sent Notifications: ' + sentNotifications);

System.debug('');
System.debug('📈 SAMPLE DATA FOR TESTING:');

System.debug('');
System.debug('🏷️ Product Categories:');
for(Category__c cat : [SELECT Name__c FROM Category__c ORDER BY Name__c]) {
    System.debug('   • ' + cat.Name__c);
}

System.debug('');
System.debug('📦 Sample Products:');
for(Product2 prod : [SELECT Name, ProductCode, Family FROM Product2 WHERE IsActive = true ORDER BY Name LIMIT 5]) {
    System.debug('   • ' + prod.Name + ' (' + prod.ProductCode + ') - ' + (prod.Family != null ? prod.Family : 'General'));
}

System.debug('');
System.debug('🛒 Active Shopping Carts:');
Integer cartCount = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Active'];
System.debug('   • ' + cartCount + ' active carts ready for testing');

System.debug('');
System.debug('📍 Shipping Locations:');
for(Shipping_Address__c addr : [SELECT Address_Label__c, City__c, State__c FROM Shipping_Address__c LIMIT 3]) {
    System.debug('   • ' + addr.Address_Label__c + ' - ' + addr.City__c + ', ' + addr.State__c);
}

System.debug('');
System.debug('👁️ Recent Product Views:');
for(View_Tracking__c view : [SELECT Product__r.Name, User_Contact__r.FirstName, User_Contact__r.LastName 
                            FROM View_Tracking__c 
                            ORDER BY Last_Viewed_Date__c DESC 
                            LIMIT 3]) {
    System.debug('   • ' + view.Product__r.Name + ' viewed by ' + view.User_Contact__r.FirstName + ' ' + view.User_Contact__r.LastName);
}

System.debug('');
System.debug('🎉 SUCCESS! Test data created and ready for ENOS testing');
System.debug('');
System.debug('🧪 READY FOR TESTING:');
System.debug('   ✅ Product browsing and search');
System.debug('   ✅ Shopping cart operations');
System.debug('   ✅ Order management');
System.debug('   ✅ Customer tracking and analytics'); 
System.debug('   ✅ Shipping and fulfillment');
System.debug('   ✅ Notification systems');

System.debug('Test data generation completed successfully!');
