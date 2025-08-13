// Insert Sample Data for StoreConnect (Minimal Version)
// Run this in Developer Console or via SF CLI

// Insert Accounts
Account acc1 = new Account(
    Name = 'Demo Customer Corp',
    Type = 'Customer',
    Industry = 'Technology'
);
insert acc1;

Account acc2 = new Account(
    Name = 'Test Retail Store',
    Type = 'Customer',
    Industry = 'Retail'
);
insert acc2;

// Insert Contacts
Contact con1 = new Contact(
    FirstName = 'John',
    LastName = 'Demo',
    Email = 'john.demo@democustomer.com',
    AccountId = acc1.Id
);
insert con1;

Contact con2 = new Contact(
    FirstName = 'Jane',
    LastName = 'Test',
    Email = 'jane.test@testretail.com',
    AccountId = acc2.Id
);
insert con2;

// Insert Products (minimal required fields)
Product2 prod1 = new Product2(
    Name = 'Premium Wireless Headphones',
    ProductCode = 'WH-001',
    Description = 'High-quality wireless headphones with noise cancellation',
    IsActive = true
);
insert prod1;

Product2 prod2 = new Product2(
    Name = 'Smart Fitness Watch',
    ProductCode = 'FW-002',
    Description = 'Advanced fitness tracking with heart rate monitoring',
    IsActive = true
);
insert prod2;

Product2 prod3 = new Product2(
    Name = 'Portable Bluetooth Speaker',
    ProductCode = 'BS-003',
    Description = 'Waterproof portable speaker with 20-hour battery life',
    IsActive = true
);
insert prod3;

Product2 prod4 = new Product2(
    Name = 'Wireless Charging Pad',
    ProductCode = 'WC-004',
    Description = 'Fast wireless charging pad compatible with all devices',
    IsActive = true
);
insert prod4;

// Get Standard Price Book ID
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

// Insert Price Book Entries
PricebookEntry pbe1 = new PricebookEntry(
    Product2Id = prod1.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 299.99,
    IsActive = true
);
insert pbe1;

PricebookEntry pbe2 = new PricebookEntry(
    Product2Id = prod2.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 199.99,
    IsActive = true
);
insert pbe2;

PricebookEntry pbe3 = new PricebookEntry(
    Product2Id = prod3.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 89.99,
    IsActive = true
);
insert pbe3;

PricebookEntry pbe4 = new PricebookEntry(
    Product2Id = prod4.Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 49.99,
    IsActive = true
);
insert pbe4;

System.debug('Sample data inserted successfully!');
System.debug('Accounts: ' + [SELECT Id, Name FROM Account]);
System.debug('Contacts: ' + [SELECT Id, Name FROM Contact]);
System.debug('Products: ' + [SELECT Id, Name FROM Product2]);
System.debug('Price Book Entries: ' + [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry]);
