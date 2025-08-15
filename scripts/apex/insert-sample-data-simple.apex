// Insert Sample Data for ENOS (Simplified Version)
// Run this in Developer Console or via SF CLI

// Insert Accounts
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
insert acc1;

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
insert acc2;

// Insert Contacts
Contact con1 = new Contact(
    FirstName = 'John',
    LastName = 'Demo',
    Email = 'john.demo@democustomer.com',
    Phone = '(555) 123-4567',
    Title = 'Procurement Manager',
    AccountId = acc1.Id
);
insert con1;

Contact con2 = new Contact(
    FirstName = 'Jane',
    LastName = 'Test',
    Email = 'jane.test@testretail.com',
    Phone = '(555) 987-6543',
    Title = 'Store Manager',
    AccountId = acc2.Id
);
insert con2;

// Insert Products (using only standard fields)
Product2 prod1 = new Product2(
    Name = 'Premium Wireless Headphones',
    ProductCode = 'WH-001',
    Description = 'High-quality wireless headphones with noise cancellation',
    IsActive = true,
    Family = 'Electronics',
    Type = 'Product',
    ProductClass = 'Product',
    ProductPurpose = 'Product',
    StockKeepingUnit = 'WH-001-001',
    ExternalId = 'WH-001-EXT',
    DisplayUrl = 'https://example.com/headphones',
    QuantityUnitOfMeasure = 'Each'
);
insert prod1;

Product2 prod2 = new Product2(
    Name = 'Smart Fitness Watch',
    ProductCode = 'FW-002',
    Description = 'Advanced fitness tracking with heart rate monitoring',
    IsActive = true,
    Family = 'Electronics',
    Type = 'Product',
    ProductClass = 'Product',
    ProductPurpose = 'Product',
    StockKeepingUnit = 'FW-002-001',
    ExternalId = 'FW-002-EXT',
    DisplayUrl = 'https://example.com/watch',
    QuantityUnitOfMeasure = 'Each'
);
insert prod2;

Product2 prod3 = new Product2(
    Name = 'Portable Bluetooth Speaker',
    ProductCode = 'BS-003',
    Description = 'Waterproof portable speaker with 20-hour battery life',
    IsActive = true,
    Family = 'Electronics',
    Type = 'Product',
    ProductClass = 'Product',
    ProductPurpose = 'Product',
    StockKeepingUnit = 'BS-003-001',
    ExternalId = 'BS-003-EXT',
    DisplayUrl = 'https://example.com/speaker',
    QuantityUnitOfMeasure = 'Each'
);
insert prod3;

Product2 prod4 = new Product2(
    Name = 'Wireless Charging Pad',
    ProductCode = 'WC-004',
    Description = 'Fast wireless charging pad compatible with all devices',
    IsActive = true,
    Family = 'Electronics',
    Type = 'Product',
    ProductClass = 'Product',
    ProductPurpose = 'Product',
    StockKeepingUnit = 'WC-004-001',
    ExternalId = 'WC-004-EXT',
    DisplayUrl = 'https://example.com/charger',
    QuantityUnitOfMeasure = 'Each'
);
insert prod4;

// Insert Price Book Entries
Id standardPriceBookId = Test.getStandardPricebookId();

PricebookEntry pbe1 = new PricebookEntry(
    Product2Id = prod1.Id,
    Pricebook2Id = standardPriceBookId,
    UnitPrice = 299.99,
    IsActive = true
);
insert pbe1;

PricebookEntry pbe2 = new PricebookEntry(
    Product2Id = prod2.Id,
    Pricebook2Id = standardPriceBookId,
    UnitPrice = 199.99,
    IsActive = true
);
insert pbe2;

PricebookEntry pbe3 = new PricebookEntry(
    Product2Id = prod3.Id,
    Pricebook2Id = standardPriceBookId,
    UnitPrice = 89.99,
    IsActive = true
);
insert pbe3;

PricebookEntry pbe4 = new PricebookEntry(
    Product2Id = prod4.Id,
    Pricebook2Id = standardPriceBookId,
    UnitPrice = 49.99,
    IsActive = true
);
insert pbe4;

System.debug('Sample data inserted successfully!');
System.debug('Accounts: ' + [SELECT Id, Name FROM Account]);
System.debug('Contacts: ' + [SELECT Id, Name FROM Contact]);
System.debug('Products: ' + [SELECT Id, Name FROM Product2]);
System.debug('Price Book Entries: ' + [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry]);
