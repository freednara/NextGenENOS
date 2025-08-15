// ========================================
// DEMO SCENARIOS DATA GENERATION
// Creates specific scenarios for demonstrations
// ========================================

System.debug('Creating demo scenarios...');

// ========================================
// SCENARIO 1: E-COMMERCE CUSTOMER JOURNEY
// ========================================
System.debug('Creating Scenario 1: E-commerce Customer Journey');

// Create demo customer account
Account demoAccount = new Account(
    Name = 'DEMO - TechStartup Inc',
    Type = 'Customer - Direct',
    Industry = 'Technology',
    BillingStreet = '123 Innovation Avenue',
    BillingCity = 'San Francisco',
    BillingState = 'CA',
    BillingPostalCode = '94105',
    BillingCountry = 'USA',
    Phone = '(415) 555-DEMO',
    Website = 'www.techstartup-demo.com',
    AnnualRevenue = 5000000,
    NumberOfEmployees = 50
);
insert demoAccount;

// Create demo contact
Contact demoContact = new Contact(
    FirstName = 'Demo',
    LastName = 'Customer',
    Email = 'demo.customer@techstartup-demo.com',
    Phone = '(415) 555-DEMO',
    Title = 'IT Manager',
    AccountId = demoAccount.Id,
    Department = 'IT'
);
insert demoContact;

// Create demo products for journey
List<Product2> demoProducts = new List<Product2>();
demoProducts.add(new Product2(
    Name = 'DEMO - Premium Laptop Workstation',
    ProductCode = 'DEMO-LAPTOP-001',
    Description = 'High-performance laptop perfect for development and design work. Features Intel i9 processor, 32GB RAM, 1TB SSD.',
    IsActive = true,
    Stock_Quantity__c = 10,
    Is_Top_Seller__c = true,
    Image_URL__c = 'https://via.placeholder.com/400x400?text=Premium+Laptop'
));

demoProducts.add(new Product2(
    Name = 'DEMO - 4K Monitor Ultra-Wide',
    ProductCode = 'DEMO-MONITOR-001',
    Description = 'Ultra-wide 4K monitor with USB-C connectivity and color accuracy perfect for professionals.',
    IsActive = true,
    Stock_Quantity__c = 15,
    Is_Top_Seller__c = true,
    Image_URL__c = 'https://via.placeholder.com/400x400?text=4K+Monitor'
));

demoProducts.add(new Product2(
    Name = 'DEMO - Wireless Keyboard & Mouse Set',
    ProductCode = 'DEMO-KEYBOARD-001',
    Description = 'Premium wireless keyboard and mouse set with long battery life and ergonomic design.',
    IsActive = true,
    Stock_Quantity__c = 25,
    Is_Top_Seller__c = false,
    Image_URL__c = 'https://via.placeholder.com/400x400?text=Keyboard+Mouse'
));

insert demoProducts;

// Create pricing for demo products
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
List<PricebookEntry> demoPricing = new List<PricebookEntry>();

demoPricing.add(new PricebookEntry(
    Product2Id = demoProducts[0].Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 2499.99,
    IsActive = true
));

demoPricing.add(new PricebookEntry(
    Product2Id = demoProducts[1].Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 799.99,
    IsActive = true
));

demoPricing.add(new PricebookEntry(
    Product2Id = demoProducts[2].Id,
    Pricebook2Id = standardPriceBook.Id,
    UnitPrice = 149.99,
    IsActive = true
));

insert demoPricing;

// Create demo cart with items
Cart__c demoCart = new Cart__c(
    Contact__c = demoContact.Id,
    Status__c = 'Active'
);
insert demoCart;

List<Cart_Item__c> demoCartItems = new List<Cart_Item__c>();
demoCartItems.add(new Cart_Item__c(
    Cart__c = demoCart.Id,
    Product__c = demoProducts[0].Id,
    Quantity__c = 2,
    Unit_Price__c = 2499.99
));

demoCartItems.add(new Cart_Item__c(
    Cart__c = demoCart.Id,
    Product__c = demoProducts[1].Id,
    Quantity__c = 2,
    Unit_Price__c = 799.99
));

demoCartItems.add(new Cart_Item__c(
    Cart__c = demoCart.Id,
    Product__c = demoProducts[2].Id,
    Quantity__c = 2,
    Unit_Price__c = 149.99
));

insert demoCartItems;

// Create shipping address
Shipping_Address__c demoAddress = new Shipping_Address__c(
    Account__c = demoAccount.Id,
    Address_Label__c = 'Main Office',
    Street__c = '123 Innovation Avenue',
    City__c = 'San Francisco',
    State__c = 'CA',
    Postal_Code__c = '94105',
    Country__c = 'USA'
);
insert demoAddress;

System.debug('✅ Scenario 1 Complete: Demo customer ready for checkout journey');

// ========================================
// SCENARIO 2: BULK ENTERPRISE ORDER
// ========================================
System.debug('Creating Scenario 2: Bulk Enterprise Order');

Account enterpriseAccount = new Account(
    Name = 'DEMO - Global Enterprise Corp',
    Type = 'Customer - Direct',
    Industry = 'Financial Services',
    BillingStreet = '500 Corporate Plaza',
    BillingCity = 'New York',
    BillingState = 'NY',
    BillingPostalCode = '10001',
    BillingCountry = 'USA',
    Phone = '(212) 555-CORP',
    Website = 'www.globalenterprise-demo.com',
    AnnualRevenue = 500000000,
    NumberOfEmployees = 5000
);
insert enterpriseAccount;

Contact enterpriseContact = new Contact(
    FirstName = 'Enterprise',
    LastName = 'Buyer',
    Email = 'enterprise.buyer@globalenterprise-demo.com',
    Phone = '(212) 555-CORP',
    Title = 'Chief Technology Officer',
    AccountId = enterpriseAccount.Id,
    Department = 'IT'
);
insert enterpriseContact;

// Create bulk order
Order bulkOrder = new Order(
    AccountId = enterpriseAccount.Id,
    Pricebook2Id = standardPriceBook.Id,
    EffectiveDate = Date.today(),
    Status = 'Draft',
    Description = 'DEMO - Bulk Enterprise Hardware Procurement Q1 2024'
);
insert bulkOrder;

// Add bulk order items
List<OrderItem> bulkOrderItems = new List<OrderItem>();
bulkOrderItems.add(new OrderItem(
    OrderId = bulkOrder.Id,
    Product2Id = demoProducts[0].Id,
    PricebookEntryId = demoPricing[0].Id,
    Quantity = 50,
    UnitPrice = 2499.99
));

bulkOrderItems.add(new OrderItem(
    OrderId = bulkOrder.Id,
    Product2Id = demoProducts[1].Id,
    PricebookEntryId = demoPricing[1].Id,
    Quantity = 50,
    UnitPrice = 799.99
));

insert bulkOrderItems;

System.debug('✅ Scenario 2 Complete: Bulk enterprise order ready for processing');

// ========================================
// SCENARIO 3: CUSTOMER SUPPORT CASE
// ========================================
System.debug('Creating Scenario 3: Customer Support Case');

// Create completed order for case reference
Order supportOrder = new Order(
    AccountId = demoAccount.Id,
    Pricebook2Id = standardPriceBook.Id,
    EffectiveDate = Date.today().addDays(-7),
    Status = 'Activated',
    Description = 'DEMO - Support Case Reference Order'
);
insert supportOrder;

OrderItem supportOrderItem = new OrderItem(
    OrderId = supportOrder.Id,
    Product2Id = demoProducts[0].Id,
    PricebookEntryId = demoPricing[0].Id,
    Quantity = 1,
    UnitPrice = 2499.99
);
insert supportOrderItem;

// Create support case
Case supportCase = new Case(
    AccountId = demoAccount.Id,
    ContactId = demoContact.Id,
    Order__c = supportOrder.Id,
    Subject = 'DEMO - Laptop Display Issues',
    Description = 'Customer reporting intermittent display flickering on recently received laptop. Requesting technical support and possible replacement.',
    Status = 'New',
    Priority = 'Medium',
    Origin = 'Email',
    Type = 'Product Issue'
);
insert supportCase;

System.debug('✅ Scenario 3 Complete: Support case created with order reference');

// ========================================
// SCENARIO 4: ANALYTICS & REPORTING DATA
// ========================================
System.debug('Creating Scenario 4: Analytics & Reporting Data');

// Create view tracking for popular products
List<View_Tracking__c> analyticsViews = new List<View_Tracking__c>();

for(Integer i = 0; i < 50; i++) {
    analyticsViews.add(new View_Tracking__c(
        User_Contact__c = demoContact.Id,
        Product__c = demoProducts[0].Id, // Laptop is most viewed
        Last_Viewed_Date__c = DateTime.now().addDays(-Math.mod(i, 7)).addHours(-Math.mod(i, 12))
    ));
}

for(Integer i = 0; i < 30; i++) {
    analyticsViews.add(new View_Tracking__c(
        User_Contact__c = demoContact.Id,
        Product__c = demoProducts[1].Id, // Monitor is second most viewed
        Last_Viewed_Date__c = DateTime.now().addDays(-Math.mod(i, 5)).addHours(-Math.mod(i, 8))
    ));
}

for(Integer i = 0; i < 20; i++) {
    analyticsViews.add(new View_Tracking__c(
        User_Contact__c = demoContact.Id,
        Product__c = demoProducts[2].Id, // Keyboard set least viewed
        Last_Viewed_Date__c = DateTime.now().addDays(-Math.mod(i, 3)).addHours(-Math.mod(i, 6))
    ));
}

insert analyticsViews;

// Create notification requests
List<Notification_Request__c> demoNotifications = new List<Notification_Request__c>();
demoNotifications.add(new Notification_Request__c(
    User_Contact__c = demoContact.Id,
    Product__c = demoProducts[0].Id,
    Status__c = 'Pending'
));

demoNotifications.add(new Notification_Request__c(
    User_Contact__c = enterpriseContact.Id,
    Product__c = demoProducts[1].Id,
    Status__c = 'Sent'
));

insert demoNotifications;

System.debug('✅ Scenario 4 Complete: Analytics data ready for reporting demos');

// ========================================
// SCENARIO 5: MULTI-USER COLLABORATION
// ========================================
System.debug('Creating Scenario 5: Multi-User Collaboration');

// Create additional users for collaboration demo
List<Contact> collaborationContacts = new List<Contact>();

collaborationContacts.add(new Contact(
    FirstName = 'Project',
    LastName = 'Manager',
    Email = 'project.manager@techstartup-demo.com',
    Phone = '(415) 555-PM01',
    Title = 'Project Manager',
    AccountId = demoAccount.Id,
    Department = 'IT'
));

collaborationContacts.add(new Contact(
    FirstName = 'Finance',
    LastName = 'Approver',
    Email = 'finance.approver@techstartup-demo.com',
    Phone = '(415) 555-FIN1',
    Title = 'Finance Director',
    AccountId = demoAccount.Id,
    Department = 'Finance'
));

insert collaborationContacts;

// Create shared cart for collaboration
Cart__c sharedCart = new Cart__c(
    Contact__c = collaborationContacts[0].Id,
    Status__c = 'Active'
);
insert sharedCart;

// Add items to shared cart
List<Cart_Item__c> sharedCartItems = new List<Cart_Item__c>();
for(Integer i = 0; i < demoProducts.size(); i++) {
    sharedCartItems.add(new Cart_Item__c(
        Cart__c = sharedCart.Id,
        Product__c = demoProducts[i].Id,
        Quantity__c = 5,
        Unit_Price__c = demoPricing[i].UnitPrice
    ));
}
insert sharedCartItems;

System.debug('✅ Scenario 5 Complete: Multi-user collaboration setup ready');

// ========================================
// DEMO SCENARIOS SUMMARY
// ========================================
System.debug('');
System.debug('========================================');
System.debug('DEMO SCENARIOS CREATION COMPLETE');
System.debug('========================================');

System.debug('🎭 AVAILABLE DEMO SCENARIOS:');
System.debug('');

System.debug('1. 🛒 E-COMMERCE CUSTOMER JOURNEY');
System.debug('   - Customer: ' + demoContact.FirstName + ' ' + demoContact.LastName);
System.debug('   - Company: ' + demoAccount.Name);
System.debug('   - Cart Items: ' + [SELECT COUNT() FROM Cart_Item__c WHERE Cart__c = :demoCart.Id]);
System.debug('   - Cart Value: $' + ([SELECT SUM(Line_Total__c) FROM Cart_Item__c WHERE Cart__c = :demoCart.Id][0].get('expr0') ?? 0));

System.debug('');
System.debug('2. 🏢 BULK ENTERPRISE ORDER');
System.debug('   - Customer: ' + enterpriseContact.FirstName + ' ' + enterpriseContact.LastName);
System.debug('   - Company: ' + enterpriseAccount.Name);
System.debug('   - Order Items: ' + [SELECT COUNT() FROM OrderItem WHERE OrderId = :bulkOrder.Id]);
System.debug('   - Order Value: $' + ([SELECT SUM(TotalPrice) FROM OrderItem WHERE OrderId = :bulkOrder.Id][0].get('expr0') ?? 0));

System.debug('');
System.debug('3. 🎧 CUSTOMER SUPPORT CASE');
System.debug('   - Case Subject: ' + supportCase.Subject);
System.debug('   - Case Status: ' + supportCase.Status);
System.debug('   - Related Order: ' + supportOrder.Description);

System.debug('');
System.debug('4. 📊 ANALYTICS & REPORTING');
System.debug('   - Product Views: ' + [SELECT COUNT() FROM View_Tracking__c WHERE User_Contact__r.Email LIKE '%techstartup-demo%']);
System.debug('   - Notification Requests: ' + [SELECT COUNT() FROM Notification_Request__c]);
System.debug('   - Most Viewed Product: ' + demoProducts[0].Name);

System.debug('');
System.debug('5. 👥 MULTI-USER COLLABORATION');
System.debug('   - Collaboration Users: ' + collaborationContacts.size());
System.debug('   - Shared Cart Items: ' + [SELECT COUNT() FROM Cart_Item__c WHERE Cart__c = :sharedCart.Id]);
System.debug('   - Project Manager: ' + collaborationContacts[0].Email);

System.debug('');
System.debug('🎯 DEMO READY!');
System.debug('All scenarios are configured and ready for demonstration.');
System.debug('Use these scenarios to showcase:');
System.debug('- Complete customer purchase journey');
System.debug('- Enterprise bulk ordering capabilities');
System.debug('- Customer support integration');
System.debug('- Analytics and business intelligence');
System.debug('- Multi-user collaboration features');

System.debug('Demo scenarios creation completed successfully!');
