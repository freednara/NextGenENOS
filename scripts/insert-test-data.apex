// Insert test data for ENOS application
// Run this in Developer Console or via anonymous apex

// Create test categories
List<Category__c> categories = new List<Category__c>();
categories.add(new Category__c(Name__c = 'Electronics', Description__c = 'Electronic devices and accessories'));
categories.add(new Category__c(Name__c = 'Clothing', Description__c = 'Apparel and fashion items'));
categories.add(new Category__c(Name__c = 'Books', Description__c = 'Books and publications'));
insert categories;

// Create test products
List<Product2> products = new List<Product2>();
products.add(new Product2(
    Name = 'Test Laptop',
    ProductCode = 'LAPTOP001',
    IsActive = true,
    Description = 'A high-performance test laptop',
    Stock_Quantity__c = 10,
    Is_Top_Seller__c = true,
    Image_URL__c = 'https://example.com/laptop.jpg',
    Category__c = categories[0].Id
));
products.add(new Product2(
    Name = 'Test T-Shirt',
    ProductCode = 'TSHIRT001',
    IsActive = true,
    Description = 'A comfortable test t-shirt',
    Stock_Quantity__c = 50,
    Is_Top_Seller__c = false,
    Image_URL__c = 'https://example.com/tshirt.jpg',
    Category__c = categories[1].Id
));
insert products;

// Create standard price book entries
List<PricebookEntry> entries = new List<PricebookEntry>();
for(Product2 prod : products) {
    entries.add(new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = prod.Id,
        UnitPrice = 99.99,
        IsActive = true
    ));
}
insert entries;

System.debug('Test data inserted successfully:');
System.debug('Categories: ' + categories.size());
System.debug('Products: ' + products.size());
System.debug('Pricebook Entries: ' + entries.size());
