// MINIMAL WORKING TEST DATA
// Creates only what absolutely works

System.debug('Creating minimal working test data...');

// Get existing data
List<Contact> contacts = [SELECT Id, FirstName, LastName, AccountId FROM Contact];
List<Account> accounts = [SELECT Id, Name FROM Account];
List<Product2> products = [SELECT Id, Name, ProductCode FROM Product2 WHERE IsActive = true];

System.debug('Found ' + accounts.size() + ' accounts, ' + contacts.size() + ' contacts, ' + products.size() + ' products');

// 1. Create Categories - CONFIRMED WORKING
List<Category__c> categories = new List<Category__c>();
categories.add(new Category__c(Name__c = 'Electronics'));
categories.add(new Category__c(Name__c = 'Computing'));
categories.add(new Category__c(Name__c = 'Mobile'));
categories.add(new Category__c(Name__c = 'Gaming'));
categories.add(new Category__c(Name__c = 'Smart Home'));

insert categories;
System.debug('✅ Created ' + categories.size() + ' product categories');

// 2. Create Shipping Addresses - CONFIRMED WORKING
if(!accounts.isEmpty()) {
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
        
        // Only add a few to avoid too much data
        if(shippingAddresses.size() >= 5) {
            break;
        }
    }
    
    insert shippingAddresses;
    System.debug('✅ Created ' + shippingAddresses.size() + ' shipping addresses');
}

// 3. Create basic Carts - TRY WITH MINIMAL STATUS
List<Cart__c> carts = new List<Cart__c>();

// Try with just 'Active' status first
for(Integer i = 0; i < 5; i++) {
    carts.add(new Cart__c(
        Status__c = 'Active'
    ));
}

try {
    insert carts;
    System.debug('✅ Created ' + carts.size() + ' carts with Active status');
} catch(Exception e) {
    System.debug('⚠️ Could not create carts: ' + e.getMessage());
    
    // Try without any status
    carts.clear();
    for(Integer i = 0; i < 3; i++) {
        carts.add(new Cart__c());
    }
    
    try {
        insert carts;
        System.debug('✅ Created ' + carts.size() + ' carts without status');
    } catch(Exception e2) {
        System.debug('❌ Could not create carts at all: ' + e2.getMessage());
        carts.clear();
    }
}

// SUMMARY
System.debug('');
System.debug('==========================================');
System.debug('✅ MINIMAL TEST DATA CREATION COMPLETE ✅');
System.debug('==========================================');

System.debug('');
System.debug('📊 FINAL DATA COUNTS:');

System.debug('🏢 STANDARD OBJECTS:');
System.debug('   • Accounts: ' + [SELECT COUNT() FROM Account]);
System.debug('   • Contacts: ' + [SELECT COUNT() FROM Contact]);
System.debug('   • Products: ' + [SELECT COUNT() FROM Product2 WHERE IsActive = true]);
System.debug('   • Orders: ' + [SELECT COUNT() FROM Order]);

System.debug('');
System.debug('🛒 CUSTOM OBJECTS:');
System.debug('   • Categories: ' + [SELECT COUNT() FROM Category__c]);
System.debug('   • Shipping Addresses: ' + [SELECT COUNT() FROM Shipping_Address__c]);
System.debug('   • Carts: ' + [SELECT COUNT() FROM Cart__c]);

System.debug('');
System.debug('🏷️ CATEGORIES:');
for(Category__c cat : [SELECT Name__c FROM Category__c ORDER BY Name__c]) {
    System.debug('   • ' + cat.Name__c);
}

System.debug('');
System.debug('📦 SAMPLE PRODUCTS:');
for(Product2 prod : [SELECT Name, ProductCode FROM Product2 WHERE IsActive = true ORDER BY Name LIMIT 5]) {
    System.debug('   • ' + prod.Name + ' (' + prod.ProductCode + ')');
}

System.debug('');
System.debug('🎉 SUCCESS! Basic test data has been created for your ENOS org');
System.debug('🚀 You can now begin testing the ENOS application!');

System.debug('Minimal test data creation completed successfully!');
