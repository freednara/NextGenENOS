// Insert Comprehensive Sample Data for StoreConnect (Basic Version)
// Run this in Developer Console or via SF CLI
// This version uses only standard Product2 fields to avoid custom field access issues

// Insert 10 Accounts
Account acc1 = new Account(
    Name = 'Demo Customer Corp',
    Type = 'Customer',
    Industry = 'Technology',
    BillingStreet = '123 Main Street',
    BillingCity = 'San Francisco',
    BillingState = 'CA',
    BillingPostalCode = '94105',
    BillingCountry = 'USA',
    Phone = '(555) 123-4567'
);

Account acc2 = new Account(
    Name = 'Test Retail Store',
    Type = 'Customer',
    Industry = 'Retail',
    BillingStreet = '456 Commerce Ave',
    BillingCity = 'Los Angeles',
    BillingState = 'CA',
    BillingPostalCode = '90210',
    BillingCountry = 'USA',
    Phone = '(555) 987-6543'
);

Account acc3 = new Account(
    Name = 'Global Tech Solutions',
    Type = 'Customer',
    Industry = 'Technology',
    BillingStreet = '789 Innovation Drive',
    BillingCity = 'Austin',
    BillingState = 'TX',
    BillingPostalCode = '73301',
    BillingCountry = 'USA',
    Phone = '(555) 456-7890'
);

Account acc4 = new Account(
    Name = 'Premium Electronics Co',
    Type = 'Customer',
    Industry = 'Electronics',
    BillingStreet = '321 Tech Boulevard',
    BillingCity = 'Seattle',
    BillingState = 'WA',
    BillingPostalCode = '98101',
    BillingCountry = 'USA',
    Phone = '(555) 234-5678'
);

Account acc5 = new Account(
    Name = 'Smart Home Innovations',
    Type = 'Customer',
    Industry = 'Technology',
    BillingStreet = '654 Smart Street',
    BillingCity = 'Denver',
    BillingState = 'CO',
    BillingPostalCode = '80201',
    BillingCountry = 'USA',
    Phone = '(555) 345-6789'
);

Account acc6 = new Account(
    Name = 'Digital Marketing Agency',
    Type = 'Customer',
    Industry = 'Marketing',
    BillingStreet = '987 Digital Lane',
    BillingCity = 'Miami',
    BillingState = 'FL',
    BillingPostalCode = '33101',
    BillingCountry = 'USA',
    Phone = '(555) 567-8901'
);

Account acc7 = new Account(
    Name = 'Healthcare Systems Inc',
    Type = 'Customer',
    Industry = 'Healthcare',
    BillingStreet = '147 Health Plaza',
    BillingCity = 'Boston',
    BillingState = 'MA',
    BillingPostalCode = '02101',
    BillingCountry = 'USA',
    Phone = '(555) 678-9012'
);

Account acc8 = new Account(
    Name = 'Financial Services Group',
    Type = 'Customer',
    Industry = 'Financial Services',
    BillingStreet = '258 Finance Way',
    BillingCity = 'New York',
    BillingState = 'NY',
    BillingPostalCode = '10001',
    BillingCountry = 'USA',
    Phone = '(555) 789-0123'
);

Account acc9 = new Account(
    Name = 'Educational Institute',
    Type = 'Customer',
    Industry = 'Education',
    BillingStreet = '369 Learning Circle',
    BillingCity = 'Chicago',
    BillingState = 'IL',
    BillingPostalCode = '60601',
    BillingCountry = 'USA',
    Phone = '(555) 890-1234'
);

Account acc10 = new Account(
    Name = 'Manufacturing Solutions',
    Type = 'Customer',
    Industry = 'Manufacturing',
    BillingStreet = '741 Factory Road',
    BillingCity = 'Detroit',
    BillingState = 'MI',
    BillingPostalCode = '48201',
    BillingCountry = 'USA',
    Phone = '(555) 901-2345'
);

List<Account> accounts = new List<Account>{acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8, acc9, acc10};
insert accounts;

System.debug('Accounts inserted: ' + accounts.size());

// Insert 10 Contacts
Contact con1 = new Contact(
    FirstName = 'John',
    LastName = 'Demo',
    Email = 'john.demo@democustomer.com',
    Phone = '(555) 123-4567',
    Title = 'Procurement Manager',
    AccountId = acc1.Id
);

Contact con2 = new Contact(
    FirstName = 'Jane',
    LastName = 'Test',
    Email = 'jane.test@testretail.com',
    Phone = '(555) 987-6543',
    Title = 'Store Manager',
    AccountId = acc2.Id
);

Contact con3 = new Contact(
    FirstName = 'Michael',
    LastName = 'Tech',
    Email = 'michael.tech@globaltech.com',
    Phone = '(555) 456-7890',
    Title = 'IT Director',
    AccountId = acc3.Id
);

Contact con4 = new Contact(
    FirstName = 'Sarah',
    LastName = 'Electronics',
    Email = 'sarah.electronics@premium.com',
    Phone = '(555) 234-5678',
    Title = 'Purchasing Manager',
    AccountId = acc4.Id
);

Contact con5 = new Contact(
    FirstName = 'David',
    LastName = 'Smart',
    Email = 'david.smart@smarthome.com',
    Phone = '(555) 345-6789',
    Title = 'Operations Manager',
    AccountId = acc5.Id
);

Contact con6 = new Contact(
    FirstName = 'Lisa',
    LastName = 'Digital',
    Email = 'lisa.digital@marketing.com',
    Phone = '(555) 567-8901',
    Title = 'Marketing Director',
    AccountId = acc6.Id
);

Contact con7 = new Contact(
    FirstName = 'Robert',
    LastName = 'Health',
    Email = 'robert.health@healthcare.com',
    Phone = '(555) 678-9012',
    Title = 'IT Manager',
    AccountId = acc7.Id
);

Contact con8 = new Contact(
    FirstName = 'Amanda',
    LastName = 'Finance',
    Email = 'amanda.finance@financial.com',
    Phone = '(555) 789-0123',
    Title = 'Procurement Specialist',
    AccountId = acc8.Id
);

Contact con9 = new Contact(
    FirstName = 'Christopher',
    LastName = 'Education',
    Email = 'christopher.education@edu.com',
    Phone = '(555) 890-1234',
    Title = 'Technology Coordinator',
    AccountId = acc9.Id
);

Contact con10 = new Contact(
    FirstName = 'Jennifer',
    LastName = 'Manufacturing',
    Email = 'jennifer.manufacturing@mfg.com',
    Phone = '(555) 901-2345',
    Title = 'Supply Chain Manager',
    AccountId = acc10.Id
);

List<Contact> contacts = new List<Contact>{con1, con2, con3, con4, con5, con6, con7, con8, con9, con10};
insert contacts;

System.debug('Contacts inserted: ' + contacts.size());

// Insert 10 Products (using only standard fields)
Product2 prod1 = new Product2(
    Name = 'Premium Wireless Headphones',
    ProductCode = 'WH-001',
    Description = 'High-quality wireless headphones with noise cancellation and premium sound quality. Perfect for music enthusiasts and professionals.',
    IsActive = true
);

Product2 prod2 = new Product2(
    Name = 'Smart Fitness Watch',
    ProductCode = 'FW-002',
    Description = 'Advanced fitness tracking with heart rate monitoring, GPS, and 7-day battery life. Ideal for athletes and health-conscious individuals.',
    IsActive = true
);

Product2 prod3 = new Product2(
    Name = 'Portable Bluetooth Speaker',
    ProductCode = 'BS-003',
    Description = 'Waterproof portable speaker with 20-hour battery life and 360-degree sound. Perfect for outdoor activities and parties.',
    IsActive = true
);

Product2 prod4 = new Product2(
    Name = 'Wireless Charging Pad',
    ProductCode = 'WC-004',
    Description = 'Fast wireless charging pad compatible with all devices. Sleek design with LED indicators and safety features.',
    IsActive = true
);

Product2 prod5 = new Product2(
    Name = '4K Action Camera',
    ProductCode = 'AC-005',
    Description = 'Ultra HD action camera with image stabilization and waterproof case. Perfect for sports, travel, and adventure photography.',
    IsActive = true
);

Product2 prod6 = new Product2(
    Name = 'Smart Home Hub',
    ProductCode = 'SH-006',
    Description = 'Central control hub for smart home devices. Compatible with Alexa, Google Home, and Apple HomeKit.',
    IsActive = true
);

Product2 prod7 = new Product2(
    Name = 'Gaming Mechanical Keyboard',
    ProductCode = 'KB-007',
    Description = 'RGB mechanical gaming keyboard with customizable switches and macro keys. Designed for competitive gaming.',
    IsActive = true
);

Product2 prod8 = new Product2(
    Name = 'Wireless Gaming Mouse',
    ProductCode = 'GM-008',
    Description = 'High-precision wireless gaming mouse with adjustable DPI and programmable buttons. Ultra-low latency for competitive play.',
    IsActive = true
);

Product2 prod9 = new Product2(
    Name = 'Portable Power Bank',
    ProductCode = 'PB-009',
    Description = '20,000mAh portable charger with fast charging and multiple USB ports. Compact design for travel and daily use.',
    IsActive = true
);

Product2 prod10 = new Product2(
    Name = 'Smart LED Light Bulbs',
    ProductCode = 'LB-010',
    Description = 'WiFi-enabled smart LED bulbs with 16 million colors and voice control. Compatible with all major smart home platforms.',
    IsActive = true
);

List<Product2> products = new List<Product2>{prod1, prod2, prod3, prod4, prod5, prod6, prod7, prod8, prod9, prod10};
insert products;

System.debug('Products inserted: ' + products.size());

// Get Standard Price Book ID
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

// Insert 10 Price Book Entries
PricebookEntry pbe1 = new PricebookEntry(
    Product2Id = prod1.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 299.99,
    IsActive = true
);

PricebookEntry pbe2 = new PricebookEntry(
    Product2Id = prod2.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 199.99,
    IsActive = true
);

PricebookEntry pbe3 = new PricebookEntry(
    Product2Id = prod3.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 89.99,
    IsActive = true
);

PricebookEntry pbe4 = new PricebookEntry(
    Product2Id = prod4.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 49.99,
    IsActive = true
);

PricebookEntry pbe5 = new PricebookEntry(
    Product2Id = prod5.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 399.99,
    IsActive = true
);

PricebookEntry pbe6 = new PricebookEntry(
    Product2Id = prod6.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 149.99,
    IsActive = true
);

PricebookEntry pbe7 = new PricebookEntry(
    Product2Id = prod7.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 179.99,
    IsActive = true
);

PricebookEntry pbe8 = new PricebookEntry(
    Product2Id = prod8.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 129.99,
    IsActive = true
);

PricebookEntry pbe9 = new PricebookEntry(
    Product2Id = prod9.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 79.99,
    IsActive = true
);

PricebookEntry pbe10 = new PricebookEntry(
    Product2Id = prod10.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 34.99,
    IsActive = true
);

List<PricebookEntry> pricebookEntries = new List<PricebookEntry>{pbe1, pbe2, pbe3, pbe4, pbe5, pbe6, pbe7, pbe8, pbe9, pbe10};
insert pricebookEntries;

System.debug('Price Book Entries inserted: ' + pricebookEntries.size());

// Summary Report
System.debug('=== SAMPLE DATA INSERTION COMPLETE ===');
System.debug('Accounts: ' + [SELECT Id, Name FROM Account].size());
System.debug('Contacts: ' + [SELECT Id, Name FROM Contact].size());
System.debug('Products: ' + [SELECT Id, Name FROM Product2].size());
System.debug('Price Book Entries: ' + [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry].size());

// Display sample data for verification
System.debug('=== SAMPLE ACCOUNTS ===');
for(Account acc : [SELECT Id, Name, Industry, BillingCity FROM Account LIMIT 5]) {
    System.debug(acc.Name + ' - ' + acc.Industry + ' (' + acc.BillingCity + ')');
}

System.debug('=== SAMPLE PRODUCTS ===');
for(Product2 prod : [SELECT Id, Name, ProductCode FROM Product2 LIMIT 5]) {
    System.debug(prod.Name + ' (' + prod.ProductCode + ')');
}

System.debug('=== SAMPLE PRICES ===');
for(PricebookEntry pbe : [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry LIMIT 5]) {
    Product2 prod = [SELECT Name FROM Product2 WHERE Id = :pbe.Product2Id];
    System.debug(prod.Name + ' - $' + pbe.UnitPrice);
}
