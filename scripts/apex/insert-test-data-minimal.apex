// ========================================
// MINIMAL TEST DATA CREATION SCRIPT - CONSOLIDATED VERSION
// NextGenENOS ENOS Application
// ========================================
// Creates minimal test data for quick validation and smoke tests
// Fast execution, minimal governor limit usage

System.debug('Starting minimal test data creation...');

try {
    // Check if minimal data already exists
    Integer existingAccounts = [SELECT COUNT() FROM Account];
    Integer existingProducts = [SELECT COUNT() FROM Product2 WHERE IsActive = true];
    
    if (existingAccounts > 0 || existingProducts > 0) {
        System.debug('Data already exists. Skipping creation.');
        System.debug('Existing accounts: ' + existingAccounts + ', Existing products: ' + existingProducts);
        return;
    }
    
    // Create 2 minimal accounts
    List<Account> accounts = new List<Account>();
    
    accounts.add(new Account(
        Name = 'Test Company A',
        Type = 'Customer - Direct',
        Industry = 'Technology',
        BillingStreet = '100 Test Street',
        BillingCity = 'Test City',
        BillingState = 'CA',
        BillingPostalCode = '12345',
        BillingCountry = 'USA'
    ));
    
    accounts.add(new Account(
        Name = 'Test Company B',
        Type = 'Customer - Channel',
        Industry = 'Healthcare',
        BillingStreet = '200 Test Avenue',
        BillingCity = 'Test Town',
        BillingState = 'NY',
        BillingPostalCode = '54321',
        BillingCountry = 'USA'
    ));
    
    insert accounts;
    System.debug('Inserted ' + accounts.size() + ' minimal accounts');
    
    // Create 2 contacts (1 per account)
    List<Contact> contacts = new List<Contact>();
    
    contacts.add(new Contact(
        FirstName = 'John',
        LastName = 'Test',
        Email = 'john.test@testcompanya.com',
        Phone = '(555) 123-4567',
        Title = 'IT Manager',
        AccountId = accounts[0].Id
    ));
    
    contacts.add(new Contact(
        FirstName = 'Jane',
        LastName = 'Test',
        Email = 'jane.test@testcompanyb.com',
        Phone = '(555) 987-6543',
        Title = 'Procurement Manager',
        AccountId = accounts[1].Id
    ));
    
    insert contacts;
    System.debug('Inserted ' + contacts.size() + ' minimal contacts');
    
    // Create 5 minimal products
    List<Product2> products = new List<Product2>();
    
    String[] productNames = new String[]{'Test Product 1', 'Test Product 2', 'Test Product 3', 'Test Product 4', 'Test Product 5'};
    String[] productCodes = new String[]{'TEST-001', 'TEST-002', 'TEST-003', 'TEST-004', 'TEST-005'};
    
    for(Integer i = 0; i < productNames.size(); i++) {
        products.add(new Product2(
            Name = productNames[i],
            ProductCode = productCodes[i],
            IsActive = true,
            Description = 'Minimal test product ' + (i + 1),
            Stock_Quantity__c = 50 + (i * 10),
            Is_Top_Seller__c = (i < 2), // First 2 are top sellers
            Image_URL__c = 'https://via.placeholder.com/200x150?text=' + productNames[i].replace(' ', '+')
        ));
    }
    
    insert products;
    System.debug('Inserted ' + products.size() + ' minimal products');
    
    // Create 2 minimal categories
    List<Category__c> categories = new List<Category__c>();
    
    categories.add(new Category__c(
        Name__c = 'Test Category A',
        Description__c = 'Minimal test category for validation'
    ));
    
    categories.add(new Category__c(
        Name__c = 'Test Category B',
        Description__c = 'Another minimal test category'
    ));
    
    insert categories;
    System.debug('Inserted ' + categories.size() + ' minimal categories');
    
    // Create minimal pricebook entries
    Id standardPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
    
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    
    for(Product2 product : products) {
        pricebookEntries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = 100.00 + (product.Stock_Quantity__c * 2), // Simple pricing
            IsActive = true
        ));
    }
    
    insert pricebookEntries;
    System.debug('Inserted ' + pricebookEntries.size() + ' minimal pricebook entries');
    
    System.debug('✅ Minimal test data creation completed successfully!');
    System.debug('Created: ' + accounts.size() + ' accounts, ' + contacts.size() + ' contacts, ' + 
                products.size() + ' products, ' + categories.size() + ' categories, ' + 
                pricebookEntries.size() + ' pricebook entries');
    System.debug('Execution time: ~15 seconds, minimal governor limit usage');
    
} catch (Exception e) {
    System.debug('❌ Error creating minimal test data: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    throw e;
}

