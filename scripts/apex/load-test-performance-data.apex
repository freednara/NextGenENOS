// ========================================
// PERFORMANCE TESTING DATA GENERATION
// Creates large datasets for performance testing
// ========================================

System.debug('Starting performance test data generation...');

// ========================================
// 1. CREATE BULK ACCOUNTS (100 accounts)
// ========================================
List<Account> performanceAccounts = new List<Account>();

String[] industries = new String[]{'Technology', 'Healthcare', 'Education', 'Manufacturing', 'Retail', 'Finance', 'Government', 'Energy'};
String[] accountTypes = new String[]{'Customer - Direct', 'Customer - Channel', 'Partner', 'Prospect'};
String[] cities = new String[]{'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'};
String[] states = new String[]{'NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'TX', 'CA', 'TX', 'CA'};

for(Integer i = 1; i <= 100; i++) {
    performanceAccounts.add(new Account(
        Name = 'Performance Test Account ' + String.valueOf(i).leftPad(3, '0'),
        Type = accountTypes[Math.mod(i, accountTypes.size())],
        Industry = industries[Math.mod(i, industries.size())],
        BillingStreet = (1000 + i) + ' Performance Drive Suite ' + i,
        BillingCity = cities[Math.mod(i, cities.size())],
        BillingState = states[Math.mod(i, states.size())],
        BillingPostalCode = String.valueOf(10000 + i),
        BillingCountry = 'USA',
        Phone = '(555) ' + String.valueOf(i).leftPad(3, '0') + '-' + String.valueOf(1000 + i),
        Website = 'www.perftest' + i + '.com',
        AnnualRevenue = 1000000 + (i * 100000),
        NumberOfEmployees = 50 + (i * 10)
    ));
}

insert performanceAccounts;
System.debug('Inserted ' + performanceAccounts.size() + ' performance test accounts');

// ========================================
// 2. CREATE BULK CONTACTS (500 contacts)
// ========================================
List<Contact> performanceContacts = new List<Contact>();

String[] firstNames = new String[]{'Alex', 'Blake', 'Casey', 'Drew', 'Ellis', 'Finley', 'Gray', 'Harper', 'Indigo', 'Jordan', 'Kai', 'Lane', 'Morgan', 'Noel', 'Oakley', 'Peyton', 'Quinn', 'Reese', 'Sage', 'Taylor'};
String[] lastNames = new String[]{'Anderson', 'Brown', 'Clark', 'Davis', 'Evans', 'Foster', 'Garcia', 'Hall', 'Irwin', 'Jones', 'King', 'Lee', 'Miller', 'Nelson', 'Parker', 'Quinn', 'Roberts', 'Smith', 'Turner', 'Wilson'};
String[] titles = new String[]{'Manager', 'Director', 'Specialist', 'Coordinator', 'Analyst', 'Administrator', 'Supervisor', 'Executive', 'Officer', 'Representative'};

Integer contactIndex = 0;
for(Account acc : performanceAccounts) {
    // Create 5 contacts per account
    for(Integer j = 1; j <= 5; j++) {
        contactIndex++;
        performanceContacts.add(new Contact(
            FirstName = firstNames[Math.mod(contactIndex, firstNames.size())],
            LastName = lastNames[Math.mod(contactIndex, lastNames.size())] + String.valueOf(contactIndex),
            Email = 'perftest' + contactIndex + '@' + acc.Name.replace(' ', '').toLowerCase() + '.com',
            Phone = '(555) ' + String.valueOf(Math.mod(contactIndex, 900) + 100) + '-' + String.valueOf(Math.mod(contactIndex * 7, 9000) + 1000),
            Title = titles[Math.mod(contactIndex, titles.size())],
            AccountId = acc.Id,
            Department = j <= 2 ? 'IT' : j <= 4 ? 'Procurement' : 'Operations'
        ));
    }
}

insert performanceContacts;
System.debug('Inserted ' + performanceContacts.size() + ' performance test contacts');

// ========================================
// 3. CREATE BULK PRODUCTS (500 products)
// ========================================
List<Product2> performanceProducts = new List<Product2>();

String[] productCategories = new String[]{'Audio', 'Computing', 'Mobile', 'Gaming', 'Smart Home', 'Networking', 'Storage', 'Security', 'Power', 'Display'};
String[] productTypes = new String[]{'Pro', 'Max', 'Ultra', 'Elite', 'Premium', 'Standard', 'Basic', 'Advanced', 'Professional', 'Enterprise'};

for(Integer i = 1; i <= 500; i++) {
    String category = productCategories[Math.mod(i, productCategories.size())];
    String type = productTypes[Math.mod(i, productTypes.size())];
    
    performanceProducts.add(new Product2(
        Name = category + ' Device ' + type + ' ' + String.valueOf(i).leftPad(3, '0'),
        ProductCode = category.substring(0,3).toUpperCase() + '-' + String.valueOf(i).leftPad(3, '0'),
        Description = 'High-performance ' + category.toLowerCase() + ' device with advanced features and enterprise-grade reliability. Model ' + String.valueOf(i) + ' in the ' + type + ' series.',
        IsActive = true,
        Stock_Quantity__c = 10 + Math.mod(i * 7, 500),
        Is_Top_Seller__c = Math.mod(i, 5) == 0, // Every 5th product is a top seller
        Image_URL__c = 'https://via.placeholder.com/400x400?text=' + category + '+' + type + '+' + String.valueOf(i)
    ));
}

insert performanceProducts;
System.debug('Inserted ' + performanceProducts.size() + ' performance test products');

// ========================================
// 4. CREATE BULK PRICE BOOK ENTRIES
// ========================================
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
List<PricebookEntry> performancePriceEntries = new List<PricebookEntry>();

for(Integer i = 0; i < performanceProducts.size(); i++) {
    Decimal basePrice = 49.99 + (Math.mod(i * 13, 2000)); // Prices from $49.99 to $2049.99
    performancePriceEntries.add(new PricebookEntry(
        Product2Id = performanceProducts[i].Id,
        Pricebook2Id = standardPriceBook.Id,
        UnitPrice = basePrice,
        IsActive = true
    ));
}

insert performancePriceEntries;
System.debug('Inserted ' + performancePriceEntries.size() + ' performance test price entries');

// ========================================
// 5. CREATE BULK CARTS (200 carts)
// ========================================
List<Cart__c> performanceCarts = new List<Cart__c>();

for(Integer i = 0; i < 200; i++) {
    Integer contactIndex = Math.mod(i, performanceContacts.size());
    performanceCarts.add(new Cart__c(
        Contact__c = performanceContacts[contactIndex].Id,
        Status__c = i < 150 ? 'Active' : (i < 180 ? 'Checkout' : 'Completed')
    ));
}

insert performanceCarts;
System.debug('Inserted ' + performanceCarts.size() + ' performance test carts');

// ========================================
// 6. CREATE BULK CART ITEMS (2000 items)
// ========================================
List<Cart_Item__c> performanceCartItems = new List<Cart_Item__c>();

Integer itemCounter = 0;
for(Cart__c cart : performanceCarts) {
    // Add 8-12 items per cart
    Integer numItems = 8 + Math.mod(itemCounter, 5);
    
    for(Integer j = 0; j < numItems; j++) {
        Integer productIndex = Math.mod(itemCounter + j, performanceProducts.size());
        Integer quantity = 1 + Math.mod(itemCounter + j, 5);
        
        performanceCartItems.add(new Cart_Item__c(
            Cart__c = cart.Id,
            Product__c = performanceProducts[productIndex].Id,
            Quantity__c = quantity,
            Unit_Price__c = performancePriceEntries[productIndex].UnitPrice
        ));
        itemCounter++;
    }
}

insert performanceCartItems;
System.debug('Inserted ' + performanceCartItems.size() + ' performance test cart items');

// ========================================
// 7. CREATE BULK ORDERS (150 orders)
// ========================================
List<Order> performanceOrders = new List<Order>();

for(Integer i = 0; i < 150; i++) {
    Integer accountIndex = Math.mod(i, performanceAccounts.size());
    performanceOrders.add(new Order(
        AccountId = performanceAccounts[accountIndex].Id,
        Pricebook2Id = standardPriceBook.Id,
        EffectiveDate = Date.today().addDays(-Math.mod(i, 90)),
        Status = i < 120 ? 'Activated' : 'Draft',
        Description = 'Performance Test Order #PT-' + String.valueOf(10000 + i)
    ));
}

insert performanceOrders;
System.debug('Inserted ' + performanceOrders.size() + ' performance test orders');

// ========================================
// 8. CREATE BULK ORDER ITEMS (1500 items)
// ========================================
List<OrderItem> performanceOrderItems = new List<OrderItem>();

for(Integer i = 0; i < performanceOrders.size(); i++) {
    Order ord = performanceOrders[i];
    Integer numItems = 8 + Math.mod(i, 5); // 8-12 items per order
    
    for(Integer j = 0; j < numItems; j++) {
        Integer productIndex = Math.mod(i*7 + j, performanceProducts.size());
        Integer quantity = 1 + Math.mod(i + j, 6);
        
        performanceOrderItems.add(new OrderItem(
            OrderId = ord.Id,
            Product2Id = performanceProducts[productIndex].Id,
            PricebookEntryId = performancePriceEntries[productIndex].Id,
            Quantity = quantity,
            UnitPrice = performancePriceEntries[productIndex].UnitPrice
        ));
    }
}

insert performanceOrderItems;
System.debug('Inserted ' + performanceOrderItems.size() + ' performance test order items');

// ========================================
// 9. CREATE BULK VIEW TRACKING (5000 views)
// ========================================
List<View_Tracking__c> performanceViews = new List<View_Tracking__c>();

for(Integer i = 0; i < 5000; i++) {
    Integer contactIndex = Math.mod(i, performanceContacts.size());
    Integer productIndex = Math.mod(i, performanceProducts.size());
    
    performanceViews.add(new View_Tracking__c(
        User_Contact__c = performanceContacts[contactIndex].Id,
        Product__c = performanceProducts[productIndex].Id,
        Last_Viewed_Date__c = DateTime.now().addDays(-Math.mod(i, 30)).addHours(-Math.mod(i, 24)).addMinutes(-Math.mod(i, 60))
    ));
}

insert performanceViews;
System.debug('Inserted ' + performanceViews.size() + ' performance test view tracking records');

// ========================================
// 10. CREATE BULK SHIPPING ADDRESSES (300 addresses)
// ========================================
List<Shipping_Address__c> performanceAddresses = new List<Shipping_Address__c>();

for(Account acc : performanceAccounts) {
    // Primary address
    performanceAddresses.add(new Shipping_Address__c(
        Account__c = acc.Id,
        Address_Label__c = 'Primary Office',
        Street__c = acc.BillingStreet,
        City__c = acc.BillingCity,
        State__c = acc.BillingState,
        Postal_Code__c = acc.BillingPostalCode,
        Country__c = acc.BillingCountry
    ));
    
    // Secondary address
    performanceAddresses.add(new Shipping_Address__c(
        Account__c = acc.Id,
        Address_Label__c = 'Warehouse',
        Street__c = '5000 Distribution Center Drive',
        City__c = acc.BillingCity,
        State__c = acc.BillingState,
        Postal_Code__c = acc.BillingPostalCode,
        Country__c = acc.BillingCountry
    ));
    
    // Branch office (for some accounts)
    if(Math.mod(acc.Name.length(), 3) == 0) {
        performanceAddresses.add(new Shipping_Address__c(
            Account__c = acc.Id,
            Address_Label__c = 'Branch Office',
            Street__c = '7500 Regional Boulevard',
            City__c = acc.BillingCity,
            State__c = acc.BillingState,
            Postal_Code__c = acc.BillingPostalCode,
            Country__c = acc.BillingCountry
        ));
    }
}

insert performanceAddresses;
System.debug('Inserted ' + performanceAddresses.size() + ' performance test shipping addresses');

// ========================================
// PERFORMANCE TEST SUMMARY
// ========================================
System.debug('');
System.debug('========================================');
System.debug('PERFORMANCE TEST DATA CREATION COMPLETE');
System.debug('========================================');

System.debug('📊 PERFORMANCE DATA SUMMARY:');
System.debug('🏢 Accounts: ' + [SELECT COUNT() FROM Account WHERE Name LIKE 'Performance Test Account%']);
System.debug('👥 Contacts: ' + [SELECT COUNT() FROM Contact WHERE Email LIKE 'perftest%']);
System.debug('📦 Products: ' + [SELECT COUNT() FROM Product2 WHERE Name LIKE '%Device%']);
System.debug('💰 Price Entries: ' + [SELECT COUNT() FROM PricebookEntry WHERE Product2.Name LIKE '%Device%']);
System.debug('🛒 Carts: ' + [SELECT COUNT() FROM Cart__c WHERE Contact__r.Email LIKE 'perftest%']);
System.debug('📝 Cart Items: ' + [SELECT COUNT() FROM Cart_Item__c WHERE Cart__r.Contact__r.Email LIKE 'perftest%']);
System.debug('📋 Orders: ' + [SELECT COUNT() FROM Order WHERE Description LIKE 'Performance Test Order%']);
System.debug('📄 Order Items: ' + [SELECT COUNT() FROM OrderItem WHERE Order.Description LIKE 'Performance Test Order%']);
System.debug('👁️ View Tracking: ' + [SELECT COUNT() FROM View_Tracking__c WHERE User_Contact__r.Email LIKE 'perftest%']);
System.debug('📍 Addresses: ' + [SELECT COUNT() FROM Shipping_Address__c WHERE Account__r.Name LIKE 'Performance Test Account%']);

System.debug('');
System.debug('🚀 PERFORMANCE TESTING READY!');
System.debug('This dataset enables testing with:');
System.debug('- Large product catalogs (500+ products)');
System.debug('- High-volume cart operations (200+ active carts)');
System.debug('- Bulk order processing (150+ orders)');
System.debug('- Analytics and reporting (5000+ views)');
System.debug('- Customer management (100+ accounts, 500+ contacts)');

System.debug('');
System.debug('📈 RECOMMENDED PERFORMANCE TESTS:');
System.debug('1. Product search with 500+ products');
System.debug('2. Cart operations with bulk items');
System.debug('3. Order processing workflow');
System.debug('4. Analytics and reporting queries');
System.debug('5. Customer data management');
System.debug('6. Concurrent user simulation');

System.debug('Performance test data generation completed successfully!');
