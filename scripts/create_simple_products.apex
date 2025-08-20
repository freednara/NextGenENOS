// Create simple sample products with standard fields only
// This script creates basic products for testing cart functionality

try {
    // Get the Standard Price Book ID
    Id standardPricebookId = null;
    List<Pricebook2> standardPricebooks = [
        SELECT Id, Name, IsActive 
        FROM Pricebook2 
        WHERE IsStandard = true AND IsActive = true 
        LIMIT 1
    ];
    
    if (standardPricebooks.isEmpty()) {
        System.debug('❌ No active Standard Price Book found');
        return;
    }
    
    standardPricebookId = standardPricebooks[0].Id;
    System.debug('✅ Using Standard Price Book: ' + standardPricebooks[0].Name + ' (ID: ' + standardPricebookId + ')');
    
    // Create sample products with standard fields only
    List<Product2> products = new List<Product2>();
    
    // Electronics category
    products.add(new Product2(
        Name = 'ENOS Laptop Pro',
        Description = 'High-performance laptop for professionals',
        Family = 'Electronics',
        IsActive = true
    ));
    
    products.add(new Product2(
        Name = 'ENOS Smartphone X',
        Description = 'Latest smartphone with advanced features',
        Family = 'Electronics',
        IsActive = true
    ));
    
    products.add(new Product2(
        Name = 'ENOS Wireless Headphones',
        Description = 'Premium noise-canceling headphones',
        Family = 'Electronics',
        IsActive = true
    ));
    
    // Office category
    products.add(new Product2(
        Name = 'ENOS Ergonomic Chair',
        Description = 'Comfortable office chair for long work hours',
        Family = 'Office',
        IsActive = true
    ));
    
    products.add(new Product2(
        Name = 'ENOS Standing Desk',
        Description = 'Adjustable standing desk for health-conscious workers',
        Family = 'Office',
        IsActive = true
    ));
    
    // Insert products
    insert products;
    System.debug('✅ Created ' + products.size() + ' products');
    
    // Create PricebookEntry records for each product
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    
    for (Product2 product : products) {
        pricebookEntries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = Math.random() * 1000 + 100, // Random price between $100-$1100
            IsActive = true
        ));
    }
    
    // Insert price book entries
    insert pricebookEntries;
    System.debug('✅ Created ' + pricebookEntries.size() + ' price book entries');
    
    // Verify the setup
    Integer productCount = [SELECT COUNT() FROM Product2 WHERE IsActive = true];
    Integer pbeCount = [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :standardPricebookId AND IsActive = true];
    
    System.debug('📊 Final counts:');
    System.debug('  Products: ' + productCount);
    System.debug('  Active PricebookEntries: ' + pbeCount);
    
    System.debug('🎉 Sample products created successfully!');
    
} catch (Exception e) {
    System.debug('❌ Error creating sample products: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
