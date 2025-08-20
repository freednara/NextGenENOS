// ========================================
// SIMPLE TEST DATA CREATION SCRIPT
// NextGenENOS ENOS Application
// ========================================
// This script creates minimal test data using only available fields

System.debug('=== CREATING SIMPLE TEST DATA ===');

try {
    // Check what fields are actually available on Product2
    Schema.DescribeSObjectResult productDesc = Schema.SObjectType.Product2;
    Map<String, Schema.SObjectField> fieldMap = productDesc.fields.getMap();
    
    System.debug('📊 Available Product2 fields:');
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDesc = field.getDescribe();
        
        if (fieldDesc.isCustom()) {
            System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ') - Custom: ' + fieldDesc.isCustom());
        }
    }
    
    // Get the standard pricebook
    List<Pricebook2> standardPricebooks = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    Id standardPricebookId = standardPricebooks[0].Id;
    System.debug('🔍 Standard Pricebook ID: ' + standardPricebookId);
    
    // Create test products using only available fields
    List<Product2> products = new List<Product2>();
    
    // Product 1
    Product2 product1 = new Product2(
        Name = 'Test Product 1',
        ProductCode = 'TEST-001',
        Description = 'First test product',
        IsActive = true,
        Family = 'Electronics'
    );
    products.add(product1);
    
    // Product 2
    Product2 product2 = new Product2(
        Name = 'Test Product 2',
        ProductCode = 'TEST-002',
        Description = 'Second test product',
        IsActive = true,
        Family = 'Electronics'
    );
    products.add(product2);
    
    // Insert products
    System.debug('🔧 Inserting ' + products.size() + ' products...');
    insert products;
    
    System.debug('✅ Products created successfully:');
    for (Product2 p : products) {
        System.debug('  - ' + p.Name + ' (ID: ' + p.Id + ')');
    }
    
    // Create pricebook entries
    List<PricebookEntry> entries = new List<PricebookEntry>();
    
    for (Product2 product : products) {
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 99.99,
            IsActive = true
        );
        entries.add(entry);
    }
    
    System.debug('🔧 Creating pricebook entries...');
    insert entries;
    
    System.debug('✅ Pricebook entries created successfully:');
    for (PricebookEntry entry : entries) {
        System.debug('  - Product: ' + entry.Product2Id + ', Price: ' + entry.UnitPrice);
    }
    
    // Create test categories
    List<Category__c> categories = new List<Category__c>();
    
    Category__c category1 = new Category__c(
        Name__c = 'Electronics'
    );
    categories.add(category1);
    
    Category__c category2 = new Category__c(
        Name__c = 'Books'
    );
    categories.add(category2);
    
    System.debug('🔧 Creating categories...');
    insert categories;
    
    System.debug('✅ Categories created successfully:');
    for (Category__c cat : categories) {
        System.debug('  - ' + cat.Name__c);
    }
    
    // Create test accounts
    List<Account> accounts = new List<Account>();
    
    Account account1 = new Account(
        Name = 'Test Account 1',
        BillingCity = 'Test City',
        BillingState = 'CA',
        BillingCountry = 'USA'
    );
    accounts.add(account1);
    
    Account account2 = new Account(
        Name = 'Test Account 2',
        BillingCity = 'Another City',
        BillingState = 'NY',
        BillingCountry = 'USA'
    );
    accounts.add(account2);
    
    System.debug('🔧 Creating accounts...');
    insert accounts;
    
    System.debug('✅ Accounts created successfully:');
    for (Account acc : accounts) {
        System.debug('  - ' + acc.Name + ' (ID: ' + acc.Id + ')');
    }
    
    // Create test contacts
    List<Contact> contacts = new List<Contact>();
    
    Contact contact1 = new Contact(
        FirstName = 'Test',
        LastName = 'Contact 1',
        AccountId = account1.Id,
        Email = 'test1@example.com'
    );
    contacts.add(contact1);
    
    Contact contact2 = new Contact(
        FirstName = 'Test',
        LastName = 'Contact 2',
        AccountId = account2.Id,
        Email = 'test2@example.com'
    );
    contacts.add(contact2);
    
    System.debug('🔧 Creating contacts...');
    insert contacts;
    
    System.debug('✅ Contacts created successfully:');
    for (Contact con : contacts) {
        System.debug('  - ' + con.FirstName + ' ' + con.LastName + ' (ID: ' + con.Id + ')');
    }
    
    // Create test carts (only with available fields)
    List<Cart__c> carts = new List<Cart__c>();
    
    Cart__c cart1 = new Cart__c(
        Status__c = 'Active'
    );
    carts.add(cart1);
    
    Cart__c cart2 = new Cart__c(
        Status__c = 'Active'
    );
    carts.add(cart2);
    
    System.debug('🔧 Creating carts...');
    insert carts;
    
    System.debug('✅ Carts created successfully:');
    for (Cart__c cart : carts) {
        System.debug('  - Cart with status: ' + cart.Status__c + ' (ID: ' + cart.Id + ')');
    }
    
    System.debug('🎉 SIMPLE TEST DATA CREATION COMPLETE!');
    System.debug('📊 Summary:');
    System.debug('  - Products: ' + products.size());
    System.debug('  - Pricebook Entries: ' + entries.size());
    System.debug('  - Categories: ' + categories.size());
    System.debug('  - Accounts: ' + accounts.size());
    System.debug('  - Contacts: ' + contacts.size());
    System.debug('  - Carts: ' + carts.size());
    
} catch (Exception e) {
    System.debug('❌ Error creating test data: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== SIMPLE TEST DATA CREATION COMPLETE ===');
