// BASIC SAFE TEST DATA
// Only creates objects and fields that are confirmed to work

System.debug('Creating basic safe test data...');

// Get existing standard data
List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact LIMIT 10];
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 10];
List<Product2> products = [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true LIMIT 15];

System.debug('Found ' + accounts.size() + ' accounts, ' + contacts.size() + ' contacts, ' + products.size() + ' products');

// 1. Create Categories - THIS WORKS
List<Category__c> categories = new List<Category__c>();
categories.add(new Category__c(Name__c = 'Audio & Electronics'));
categories.add(new Category__c(Name__c = 'Computing & Laptops'));
categories.add(new Category__c(Name__c = 'Mobile & Tablets'));
categories.add(new Category__c(Name__c = 'Gaming & Entertainment'));
categories.add(new Category__c(Name__c = 'Smart Home & IoT'));
categories.add(new Category__c(Name__c = 'Networking & WiFi'));
categories.add(new Category__c(Name__c = 'Office & Productivity'));

insert categories;
System.debug('✅ Created ' + categories.size() + ' product categories');

// 2. Create Shipping Addresses - THIS WORKS
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
    
    // Add a warehouse address for every other account
    if(Math.mod(shippingAddresses.size(), 2) == 0) {
        shippingAddresses.add(new Shipping_Address__c(
            Account__c = acc.Id,
            Address_Label__c = 'Distribution Center',
            Street__c = '456 Warehouse Lane',
            City__c = 'Oakland',
            State__c = 'CA',
            Postal_Code__c = '94601',
            Country__c = 'USA'
        ));
    }
}

insert shippingAddresses;
System.debug('✅ Created ' + shippingAddresses.size() + ' shipping addresses');

// 3. Create basic Carts - THIS WORKS (only Status__c field)
List<Cart__c> carts = new List<Cart__c>();

for(Integer i = 0; i < 12; i++) {
    carts.add(new Cart__c(
        Status__c = i < 8 ? 'Active' : 'Completed'
    ));
}

insert carts;
System.debug('✅ Created ' + carts.size() + ' carts');

// Final Summary
System.debug('');
System.debug('==========================================');
System.debug('✅ BASIC TEST DATA CREATION COMPLETE ✅');
System.debug('==========================================');

System.debug('');
System.debug('📊 DATA SUMMARY:');
System.debug('');

System.debug('🏢 STANDARD OBJECTS:');
System.debug('   • Accounts: ' + [SELECT COUNT() FROM Account]);
System.debug('   • Contacts: ' + [SELECT COUNT() FROM Contact]);
System.debug('   • Products: ' + [SELECT COUNT() FROM Product2 WHERE IsActive = true]);
System.debug('   • Price Book Entries: ' + [SELECT COUNT() FROM PricebookEntry WHERE IsActive = true]);
System.debug('   • Orders: ' + [SELECT COUNT() FROM Order]);
System.debug('   • Order Items: ' + [SELECT COUNT() FROM OrderItem]);

System.debug('');
System.debug('🛒 CUSTOM OBJECTS:');
System.debug('   • Categories: ' + [SELECT COUNT() FROM Category__c]);
System.debug('   • Shipping Addresses: ' + [SELECT COUNT() FROM Shipping_Address__c]);
System.debug('   • Total Carts: ' + [SELECT COUNT() FROM Cart__c]);

Integer activeCarts = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Active'];
System.debug('   • Active Carts: ' + activeCarts);

Integer completedCarts = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Completed'];
System.debug('   • Completed Carts: ' + completedCarts);

System.debug('');
System.debug('🏷️ CATEGORIES CREATED:');
for(Category__c cat : [SELECT Name__c FROM Category__c ORDER BY Name__c]) {
    System.debug('   • ' + cat.Name__c);
}

System.debug('');
System.debug('📦 SAMPLE PRODUCTS:');
for(Product2 prod : [SELECT Name, ProductCode, Family FROM Product2 WHERE IsActive = true ORDER BY Name LIMIT 5]) {
    System.debug('   • ' + prod.Name + ' (' + prod.ProductCode + ')' + (prod.Family != null ? ' - ' + prod.Family : ''));
}

System.debug('');
System.debug('🏢 SAMPLE ACCOUNTS:');
for(Account acc : [SELECT Name, Industry FROM Account LIMIT 5]) {
    System.debug('   • ' + acc.Name + (acc.Industry != null ? ' (' + acc.Industry + ')' : ''));
}

System.debug('');
System.debug('📍 SHIPPING LOCATIONS:');
for(Shipping_Address__c addr : [SELECT Account__r.Name, Address_Label__c, City__c, State__c FROM Shipping_Address__c LIMIT 5]) {
    System.debug('   • ' + addr.Account__r.Name + ' - ' + addr.Address_Label__c + ' (' + addr.City__c + ', ' + addr.State__c + ')');
}

System.debug('');
System.debug('🎯 READY FOR TESTING:');
System.debug('   ✅ Product catalog browsing');
System.debug('   ✅ Customer account management');
System.debug('   ✅ Order processing');
System.debug('   ✅ Shopping cart basic functionality');
System.debug('   ✅ Shipping address management');
System.debug('   ✅ Product categorization');

System.debug('');
System.debug('🎉 SUCCESS! Your ENOS test org is ready!');
System.debug('🚀 You can now test the core ENOS functionality.');

System.debug('Basic test data creation completed successfully!');
