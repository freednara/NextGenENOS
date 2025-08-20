// ========================================
// WORKING TEST DATA CREATION SCRIPT
// NextGenENOS ENOS Application
// ========================================
// Creates test data using only available fields

System.debug('=== WORKING TEST DATA CREATION ===');

try {
    // Check if data already exists
    Integer existingAccounts = [SELECT COUNT() FROM Account];
    Integer existingProducts = [SELECT COUNT() FROM Product2 WHERE IsActive = true];
    
    System.debug('📊 Existing data:');
    System.debug('  Accounts: ' + existingAccounts);
    System.debug('  Products: ' + existingProducts);
    
    if (existingAccounts > 0 || existingProducts > 0) {
        System.debug('ℹ️ Data already exists. Skipping creation.');
        return;
    }
    
    // Create 5 accounts
    System.debug('🔧 Creating accounts...');
    List<Account> accounts = new List<Account>();
    
    accounts.add(new Account(
        Name = 'TechCorp Solutions Inc',
        Type = 'Customer - Direct',
        Industry = 'Technology',
        BillingStreet = '100 Innovation Drive',
        BillingCity = 'San Francisco',
        BillingState = 'CA',
        BillingPostalCode = '94105',
        BillingCountry = 'USA',
        Phone = '(415) 555-0101'
    ));
    
    accounts.add(new Account(
        Name = 'Metro General Hospital',
        Type = 'Customer - Direct',
        Industry = 'Healthcare',
        BillingStreet = '500 Medical Center Drive',
        BillingCity = 'Chicago',
        BillingState = 'IL',
        BillingPostalCode = '60601',
        BillingCountry = 'USA',
        Phone = '(312) 555-0103'
    ));
    
    accounts.add(new Account(
        Name = 'Premier Financial Group',
        Type = 'Customer - Direct',
        Industry = 'Financial Services',
        BillingStreet = '1000 Wall Street',
        BillingCity = 'New York',
        BillingState = 'NY',
        BillingPostalCode = '10005',
        BillingCountry = 'USA',
        Phone = '(212) 555-0105'
    ));
    
    accounts.add(new Account(
        Name = 'State University System',
        Type = 'Customer - Direct',
        Industry = 'Education',
        BillingStreet = '300 University Circle',
        BillingCity = 'Boston',
        BillingState = 'MA',
        BillingPostalCode = '02115',
        BillingCountry = 'USA',
        Phone = '(617) 555-0106'
    ));
    
    accounts.add(new Account(
        Name = 'Advanced Manufacturing Corp',
        Type = 'Customer - Channel',
        Industry = 'Manufacturing',
        BillingStreet = '1500 Industrial Boulevard',
        BillingCity = 'Detroit',
        BillingState = 'MI',
        BillingPostalCode = '48201',
        BillingCountry = 'USA',
        Phone = '(313) 555-0107'
    ));
    
    insert accounts;
    System.debug('✅ Inserted ' + accounts.size() + ' accounts');
    
    // Create 10 contacts (2 per account)
    System.debug('🔧 Creating contacts...');
    List<Contact> contacts = new List<Contact>();
    
    String[] firstNames = new String[]{'John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Amanda', 'Christopher', 'Jennifer'};
    String[] lastNames = new String[]{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'};
    String[] titles = new String[]{'IT Director', 'Procurement Manager', 'Operations Manager', 'Technology Coordinator', 'Supply Chain Manager'};
    
    Integer contactCounter = 0;
    for(Account acc : accounts) {
        // Primary Contact
        contacts.add(new Contact(
            FirstName = firstNames[Math.mod(contactCounter, firstNames.size())],
            LastName = lastNames[Math.mod(contactCounter, lastNames.size())],
            Email = firstNames[Math.mod(contactCounter, firstNames.size())].toLowerCase() + '.' + lastNames[Math.mod(contactCounter, lastNames.size())].toLowerCase() + '@testcompany.com',
            Title = titles[Math.mod(contactCounter, titles.size())],
            AccountId = acc.Id,
            Phone = '(555) 555-' + String.valueOf(1000 + contactCounter)
        ));
        contactCounter++;
        
        // Secondary Contact
        contacts.add(new Contact(
            FirstName = firstNames[Math.mod(contactCounter, firstNames.size())],
            LastName = lastNames[Math.mod(contactCounter, lastNames.size())],
            Email = firstNames[Math.mod(contactCounter, firstNames.size())].toLowerCase() + '.' + lastNames[Math.mod(contactCounter, lastNames.size())].toLowerCase() + '@testcompany.com',
            Title = titles[Math.mod(contactCounter, titles.size())],
            AccountId = acc.Id,
            Phone = '(555) 555-' + String.valueOf(1000 + contactCounter)
        ));
        contactCounter++;
    }
    
    insert contacts;
    System.debug('✅ Inserted ' + contacts.size() + ' contacts');
    
    // Create 15 products using only available fields
    System.debug('🔧 Creating products...');
    List<Product2> products = new List<Product2>();
    
    String[] productNames = new String[]{
        'Laptop Pro X1', 'Wireless Mouse M200', 'USB-C Cable', 'Bluetooth Headphones', 'Portable Charger',
        'Webcam HD1080', 'Wireless Keyboard', 'USB Flash Drive', 'Phone Stand', 'Cable Organizer',
        'Screen Protector', 'Laptop Sleeve', 'Desk Lamp', 'Monitor Stand', 'Cable Ties'
    };
    
    String[] productCodes = new String[]{
        'LAP-001', 'MOU-001', 'CAB-001', 'HEA-001', 'CHA-001',
        'WEB-001', 'KEY-001', 'USB-001', 'STA-001', 'ORG-001',
        'SCR-001', 'SLE-001', 'LAM-001', 'MON-001', 'TIE-001'
    };
    
    String[] descriptions = new String[]{
        'High-performance laptop for professionals',
        'Ergonomic wireless mouse with precision tracking',
        'Fast charging USB-C cable',
        'Noise-cancelling Bluetooth headphones',
        '10000mAh portable power bank',
        'Full HD webcam for video conferencing',
        'Mechanical wireless keyboard',
        '128GB USB 3.0 flash drive',
        'Adjustable phone stand',
        'Cable management organizer',
        'Tempered glass screen protector',
        'Water-resistant laptop sleeve',
        'LED desk lamp with adjustable brightness',
        'Adjustable monitor stand',
        'Reusable cable ties'
    };
    
    String[] families = new String[]{'Electronics', 'Accessories', 'Cables', 'Audio', 'Power', 'Video', 'Input', 'Storage', 'Support', 'Organization', 'Protection', 'Cases', 'Lighting', 'Mounts', 'Tools'};
    
    for(Integer i = 0; i < 15; i++) {
        products.add(new Product2(
            Name = productNames[i],
            ProductCode = productCodes[i],
            Description = descriptions[i],
            IsActive = true,
            Family = families[i]
        ));
    }
    
    insert products;
    System.debug('✅ Inserted ' + products.size() + ' products');
    
    // Create standard pricebook entries
    System.debug('🔧 Creating pricebook entries...');
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    
    // Get standard pricebook ID
    Id standardPricebookId = Test.getStandardPricebookId();
    
    Decimal[] prices = new Decimal[]{1299.99, 29.99, 19.99, 89.99, 49.99, 79.99, 129.99, 24.99, 19.99, 14.99, 9.99, 39.99, 59.99, 89.99, 4.99};
    
    for(Integer i = 0; i < products.size(); i++) {
        pricebookEntries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = products[i].Id,
            UnitPrice = prices[i],
            IsActive = true
        ));
    }
    
    insert pricebookEntries;
    System.debug('✅ Inserted ' + pricebookEntries.size() + ' pricebook entries');
    
    // Create categories
    System.debug('🔧 Creating categories...');
    List<Category__c> categories = new List<Category__c>();
    
    String[] categoryNames = new String[]{'Electronics', 'Accessories', 'Cables', 'Audio', 'Power', 'Video', 'Input', 'Storage', 'Support', 'Organization', 'Protection', 'Cases', 'Lighting', 'Mounts', 'Tools'};
    String[] categoryDescriptions = new String[]{
        'Electronic devices and gadgets',
        'Device accessories and add-ons',
        'Cables and connectors',
        'Audio equipment and headphones',
        'Power supplies and batteries',
        'Video and camera equipment',
        'Input devices and peripherals',
        'Data storage solutions',
        'Device support and stands',
        'Organization and management tools',
        'Device protection products',
        'Cases and protective covers',
        'Lighting solutions',
        'Mounting and support systems',
        'Utility and maintenance tools'
    };
    
    for(Integer i = 0; i < categoryNames.size(); i++) {
        categories.add(new Category__c(
            Name__c = categoryNames[i],
            Description__c = categoryDescriptions[i]
        ));
    }
    
    insert categories;
    System.debug('✅ Inserted ' + categories.size() + ' categories');
    
    System.debug('🎉 Test data creation completed successfully!');
    System.debug('📊 Summary:');
    System.debug('  - Accounts: ' + accounts.size());
    System.debug('  - Contacts: ' + contacts.size());
    System.debug('  - Products: ' + products.size());
    System.debug('  - Pricebook Entries: ' + pricebookEntries.size());
    System.debug('  - Categories: ' + categories.size());
    
} catch (Exception e) {
    System.debug('❌ Error creating test data: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== TEST DATA CREATION COMPLETE ===');




