// BASIC TEST DATA CREATION SCRIPT
// Uses only standard Salesforce fields

System.debug('Starting basic test data creation...');

// Create 5 accounts
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
System.debug('Inserted ' + accounts.size() + ' accounts');

// Create 10 contacts (2 per account)
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
        Phone = '(555) 123-' + String.valueOf(contactCounter).leftPad(4, '0'),
        Title = titles[Math.mod(contactCounter, titles.size())],
        AccountId = acc.Id
    ));
    contactCounter++;
    
    // Secondary Contact
    contacts.add(new Contact(
        FirstName = firstNames[Math.mod(contactCounter, firstNames.size())],
        LastName = lastNames[Math.mod(contactCounter, lastNames.size())],
        Email = firstNames[Math.mod(contactCounter, firstNames.size())].toLowerCase() + '.' + lastNames[Math.mod(contactCounter, lastNames.size())].toLowerCase() + '@testcompany.com',
        Phone = '(555) 123-' + String.valueOf(contactCounter).leftPad(4, '0'),
        Title = titles[Math.mod(contactCounter, titles.size())],
        AccountId = acc.Id
    ));
    contactCounter++;
}

insert contacts;
System.debug('Inserted ' + contacts.size() + ' contacts');

// Create 15 products (using only standard fields)
List<Product2> products = new List<Product2>();

// Technology Products
products.add(new Product2(Name = 'Premium Wireless Headphones', ProductCode = 'AUD-001', Description = 'Professional-grade wireless headphones with active noise cancellation.', IsActive = true, Family = 'Audio'));
products.add(new Product2(Name = 'Bluetooth Speaker System', ProductCode = 'AUD-002', Description = 'Portable speaker with excellent sound quality.', IsActive = true, Family = 'Audio'));
products.add(new Product2(Name = 'Business Laptop Pro', ProductCode = 'COMP-001', Description = 'High-performance business laptop.', IsActive = true, Family = 'Computing'));
products.add(new Product2(Name = 'Gaming Desktop', ProductCode = 'COMP-002', Description = 'Powerful gaming desktop computer.', IsActive = true, Family = 'Computing'));
products.add(new Product2(Name = 'Flagship Smartphone', ProductCode = 'MOB-001', Description = 'Latest smartphone with advanced features.', IsActive = true, Family = 'Mobile'));
products.add(new Product2(Name = 'Smart Fitness Watch', ProductCode = 'MOB-002', Description = 'Advanced fitness tracking smartwatch.', IsActive = true, Family = 'Mobile'));
products.add(new Product2(Name = 'Gaming Console', ProductCode = 'GAM-001', Description = 'Next-generation gaming console.', IsActive = true, Family = 'Gaming'));
products.add(new Product2(Name = 'Gaming Keyboard', ProductCode = 'GAM-002', Description = 'Mechanical gaming keyboard with RGB.', IsActive = true, Family = 'Gaming'));
products.add(new Product2(Name = 'Smart Home Hub', ProductCode = 'IOT-001', Description = 'Central hub for smart home devices.', IsActive = true, Family = 'Smart Home'));
products.add(new Product2(Name = 'Smart LED Bulbs', ProductCode = 'IOT-002', Description = 'WiFi-enabled smart LED bulbs.', IsActive = true, Family = 'Smart Home'));
products.add(new Product2(Name = 'Mesh WiFi System', ProductCode = 'NET-001', Description = 'Whole-home mesh WiFi system.', IsActive = true, Family = 'Networking'));
products.add(new Product2(Name = 'Wireless Router', ProductCode = 'NET-002', Description = 'High-performance wireless router.', IsActive = true, Family = 'Networking'));
products.add(new Product2(Name = 'External Storage Drive', ProductCode = 'STO-001', Description = 'High-capacity external storage.', IsActive = true, Family = 'Storage'));
products.add(new Product2(Name = 'Power Bank', ProductCode = 'PWR-001', Description = 'Portable charging power bank.', IsActive = true, Family = 'Power'));
products.add(new Product2(Name = 'Wireless Charger', ProductCode = 'PWR-002', Description = 'Fast wireless charging pad.', IsActive = true, Family = 'Power'));

insert products;
System.debug('Inserted ' + products.size() + ' products');

// Create price book entries
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

Decimal[] prices = new Decimal[]{299.99, 189.99, 1299.99, 2499.99, 999.99, 349.99, 499.99, 179.99, 149.99, 34.99, 299.99, 129.99, 249.99, 99.99, 49.99};

for(Integer i = 0; i < products.size(); i++) {
    pricebookEntries.add(new PricebookEntry(
        Product2Id = products[i].Id,
        Pricebook2Id = standardPriceBook.Id,
        UnitPrice = prices[i],
        IsActive = true
    ));
}

insert pricebookEntries;
System.debug('Inserted ' + pricebookEntries.size() + ' price book entries');

// Create sample orders
List<Order> orders = new List<Order>();

for(Integer i = 0; i < 3; i++) {
    orders.add(new Order(
        AccountId = accounts[i].Id,
        Pricebook2Id = standardPriceBook.Id,
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Description = 'Test Order #' + (1000 + i)
    ));
}

insert orders;
System.debug('Inserted ' + orders.size() + ' orders');

// Add order items
List<OrderItem> orderItems = new List<OrderItem>();

for(Integer i = 0; i < orders.size(); i++) {
    Order ord = orders[i];
    
    // Add 3 items per order
    for(Integer j = 0; j < 3; j++) {
        Integer productIndex = (i * 3) + j;
        if(productIndex < products.size()) {
            orderItems.add(new OrderItem(
                OrderId = ord.Id,
                Product2Id = products[productIndex].Id,
                PricebookEntryId = pricebookEntries[productIndex].Id,
                Quantity = 1 + j,
                UnitPrice = pricebookEntries[productIndex].UnitPrice
            ));
        }
    }
}

insert orderItems;
System.debug('Inserted ' + orderItems.size() + ' order items');

// Final summary
System.debug('');
System.debug('=======================================');
System.debug('BASIC TEST DATA CREATION COMPLETE');
System.debug('=======================================');

System.debug('Data Summary:');
System.debug('Accounts: ' + [SELECT COUNT() FROM Account]);
System.debug('Contacts: ' + [SELECT COUNT() FROM Contact]);
System.debug('Products: ' + [SELECT COUNT() FROM Product2]);
System.debug('Price Book Entries: ' + [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :standardPriceBook.Id]);
System.debug('Orders: ' + [SELECT COUNT() FROM Order]);
System.debug('Order Items: ' + [SELECT COUNT() FROM OrderItem]);

System.debug('');
System.debug('Sample Products:');
for(Product2 prod : [SELECT Name, ProductCode, Family FROM Product2 ORDER BY Name LIMIT 5]) {
    System.debug('- ' + prod.Name + ' (' + prod.ProductCode + ') - Family: ' + prod.Family);
}

System.debug('');
System.debug('Basic test data generation successful!');
System.debug('Ready for testing ENOS application with standard Salesforce data.');
