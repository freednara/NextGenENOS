// ========================================
// COMPREHENSIVE TEST DATA GENERATION SCRIPT - CONSOLIDATED VERSION
// NextGenENOS ENOS Application
// ========================================
// This script creates a full production-like dataset for comprehensive testing
// Includes diverse accounts, products, categories, and complex scenarios

System.debug('Starting comprehensive test data generation...');

try {
    // Check if comprehensive data already exists
    Integer existingAccounts = [SELECT COUNT() FROM Account WHERE AnnualRevenue > 0];
    Integer existingProducts = [SELECT COUNT() FROM Product2 WHERE IsActive = true AND Stock_Quantity__c > 0];
    
    if (existingAccounts > 20 || existingProducts > 50) {
        System.debug('Comprehensive data already exists. Skipping creation.');
        System.debug('Existing accounts: ' + existingAccounts + ', Existing products: ' + existingProducts);
        return;
    }
    
    // ========================================
    // 1. CREATE DIVERSE ACCOUNTS (25 accounts)
    // ========================================
    List<Account> accounts = new List<Account>();
    
    // Technology Companies
    accounts.add(new Account(
        Name = 'TechCorp Solutions Inc',
        Type = 'Customer - Direct',
        Industry = 'Technology',
        BillingStreet = '100 Innovation Drive',
        BillingCity = 'San Francisco',
        BillingState = 'CA',
        BillingPostalCode = '94105',
        BillingCountry = 'USA',
        Phone = '(415) 555-0101',
        Website = 'www.techcorp.com',
        AnnualRevenue = 50000000,
        NumberOfEmployees = 500
    ));
    
    accounts.add(new Account(
        Name = 'Global Systems Enterprise',
        Type = 'Customer - Channel',
        Industry = 'Technology',
        BillingStreet = '250 Tech Plaza',
        BillingCity = 'Austin',
        BillingState = 'TX',
        BillingPostalCode = '78701',
        BillingCountry = 'USA',
        Phone = '(512) 555-0102',
        Website = 'www.globalsystems.com',
        AnnualRevenue = 75000000,
        NumberOfEmployees = 750
    ));
    
    // Healthcare Organizations
    accounts.add(new Account(
        Name = 'Metro General Hospital',
        Type = 'Customer - Direct',
        Industry = 'Healthcare',
        BillingStreet = '500 Medical Center Drive',
        BillingCity = 'Chicago',
        BillingState = 'IL',
        BillingPostalCode = '60601',
        BillingCountry = 'USA',
        Phone = '(312) 555-0103',
        Website = 'www.metrohealth.org',
        AnnualRevenue = 200000000,
        NumberOfEmployees = 2500
    ));
    
    accounts.add(new Account(
        Name = 'Regional Healthcare Network',
        Type = 'Customer - Channel',
        Industry = 'Healthcare',
        BillingStreet = '750 Wellness Way',
        BillingCity = 'Denver',
        BillingState = 'CO',
        BillingPostalCode = '80202',
        BillingCountry = 'USA',
        Phone = '(303) 555-0104',
        Website = 'www.regionalhealthcare.net',
        AnnualRevenue = 150000000,
        NumberOfEmployees = 1800
    ));
    
    // Financial Services
    accounts.add(new Account(
        Name = 'Premier Financial Group',
        Type = 'Customer - Direct',
        Industry = 'Financial Services',
        BillingStreet = '1000 Wall Street',
        BillingCity = 'New York',
        BillingState = 'NY',
        BillingPostalCode = '10005',
        BillingCountry = 'USA',
        Phone = '(212) 555-0105',
        Website = 'www.premierfinancial.com',
        AnnualRevenue = 500000000,
        NumberOfEmployees = 5000
    ));
    
    // Education Institutions
    accounts.add(new Account(
        Name = 'State University System',
        Type = 'Customer - Direct',
        Industry = 'Education',
        BillingStreet = '300 University Circle',
        BillingCity = 'Boston',
        BillingState = 'MA',
        BillingPostalCode = '02115',
        BillingCountry = 'USA',
        Phone = '(617) 555-0106',
        Website = 'www.stateuniversity.edu',
        AnnualRevenue = 80000000,
        NumberOfEmployees = 1200
    ));
    
    // Manufacturing
    accounts.add(new Account(
        Name = 'Advanced Manufacturing Corp',
        Type = 'Customer - Channel',
        Industry = 'Manufacturing',
        BillingStreet = '1500 Industrial Boulevard',
        BillingCity = 'Detroit',
        BillingState = 'MI',
        BillingPostalCode = '48201',
        BillingCountry = 'USA',
        Phone = '(313) 555-0107',
        Website = 'www.advancedmanufacturing.com',
        AnnualRevenue = 120000000,
        NumberOfEmployees = 800
    ));
    
    // Retail
    accounts.add(new Account(
        Name = 'Metro Retail Chain',
        Type = 'Customer - Direct',
        Industry = 'Retail',
        BillingStreet = '2000 Shopping Center Drive',
        BillingCity = 'Miami',
        BillingState = 'FL',
        BillingPostalCode = '33101',
        BillingCountry = 'USA',
        Phone = '(305) 555-0108',
        Website = 'www.metroretail.com',
        AnnualRevenue = 300000000,
        NumberOfEmployees = 3000
    ));
    
    // Government
    accounts.add(new Account(
        Name = 'City Government Services',
        Type = 'Customer - Direct',
        Industry = 'Government',
        BillingStreet = '100 City Hall Plaza',
        BillingCity = 'Seattle',
        BillingState = 'WA',
        BillingPostalCode = '98101',
        BillingCountry = 'USA',
        Phone = '(206) 555-0109',
        Website = 'www.citygov.org',
        AnnualRevenue = 150000000,
        NumberOfEmployees = 2000
    ));
    
    // Non-Profit
    accounts.add(new Account(
        Name = 'Community Foundation',
        Type = 'Customer - Direct',
        Industry = 'Non-Profit',
        BillingStreet = '500 Charity Lane',
        BillingCity = 'Portland',
        BillingState = 'OR',
        BillingPostalCode = '97201',
        BillingCountry = 'USA',
        Phone = '(503) 555-0110',
        Website = 'www.communityfoundation.org',
        AnnualRevenue = 25000000,
        NumberOfEmployees = 150
    ));
    
    // Add more diverse accounts
    String[] industries = new String[]{'Energy', 'Transportation', 'Real Estate', 'Media', 'Consulting', 'Legal', 'Insurance', 'Construction', 'Agriculture', 'Telecommunications', 'Hospitality', 'Automotive', 'Aerospace', 'Pharmaceuticals', 'Biotechnology'};
    String[] cities = new String[]{'Atlanta', 'Dallas', 'Phoenix', 'San Diego', 'Las Vegas', 'Nashville', 'Charlotte', 'Orlando', 'Minneapolis', 'Salt Lake City', 'Kansas City', 'Columbus', 'Indianapolis', 'Louisville', 'Memphis'};
    String[] states = new String[]{'GA', 'TX', 'AZ', 'CA', 'NV', 'TN', 'NC', 'FL', 'MN', 'UT', 'MO', 'OH', 'IN', 'KY', 'TN'};
    
    for(Integer i = 0; i < 15; i++) {
        accounts.add(new Account(
            Name = industries[i] + ' Solutions ' + (i + 1),
            Type = Math.mod(i, 2) == 0 ? 'Customer - Direct' : 'Customer - Channel',
            Industry = industries[i],
            BillingStreet = (1000 + i * 100) + ' ' + industries[i] + ' Street',
            BillingCity = cities[i],
            BillingState = states[i],
            BillingPostalCode = String.valueOf(10000 + i * 100),
            BillingCountry = 'USA',
            Phone = '(555) 555-' + String.valueOf(1000 + i).leftPad(4, '0'),
            Website = 'www.' + industries[i].toLowerCase().replace(' ', '') + 'solutions' + (i + 1) + '.com',
            AnnualRevenue = (10000000 + i * 5000000),
            NumberOfEmployees = (100 + i * 50)
        ));
    }
    
    insert accounts;
    System.debug('Inserted ' + accounts.size() + ' diverse accounts');
    
    // ========================================
    // 2. CREATE EXTENSIVE CONTACTS (50+ contacts)
    // ========================================
    List<Contact> contacts = new List<Contact>();
    
    String[] firstNames = new String[]{'John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Amanda', 'Christopher', 'Jennifer', 'James', 'Mary', 'William', 'Elizabeth', 'Richard', 'Patricia', 'Joseph', 'Linda', 'Thomas', 'Barbara', 'Charles', 'Susan', 'Christopher', 'Jessica', 'Daniel', 'Sarah', 'Matthew', 'Karen', 'Anthony', 'Nancy', 'Mark', 'Betty', 'Donald', 'Helen', 'Steven', 'Sandra', 'Paul', 'Donna', 'Andrew', 'Carol', 'Joshua', 'Ruth', 'Kenneth', 'Sharon', 'Kevin', 'Michelle', 'Brian', 'Laura', 'George', 'Emily'};
    String[] lastNames = new String[]{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts'};
    String[] titles = new String[]{'CEO', 'CTO', 'CFO', 'VP of Operations', 'IT Director', 'Procurement Manager', 'Operations Manager', 'Technology Coordinator', 'Supply Chain Manager', 'Project Manager', 'Business Analyst', 'Sales Director', 'Marketing Manager', 'HR Director', 'Legal Counsel', 'Facilities Manager', 'Quality Assurance Manager', 'Research Director', 'Product Manager', 'Customer Success Manager'};
    
    Integer contactCounter = 0;
    for(Account acc : accounts) {
        // Primary Contact (Executive)
        contacts.add(new Contact(
            FirstName = firstNames[Math.mod(contactCounter, firstNames.size())],
            LastName = lastNames[Math.mod(contactCounter, lastNames.size())],
            Email = firstNames[Math.mod(contactCounter, firstNames.size())].toLowerCase() + '.' + lastNames[Math.mod(contactCounter, lastNames.size())].toLowerCase() + '@' + acc.Name.toLowerCase().replace(' ', '').replace('-', '').replace('&', 'and') + '.com',
            Phone = '(555) 123-' + String.valueOf(contactCounter).leftPad(4, '0'),
            Title = titles[Math.mod(contactCounter, titles.size())],
            AccountId = acc.Id
        ));
        contactCounter++;
        
        // Secondary Contact (Technical)
        contacts.add(new Contact(
            FirstName = firstNames[Math.mod(contactCounter, firstNames.size())],
            LastName = lastNames[Math.mod(contactCounter, lastNames.size())],
            Email = firstNames[Math.mod(contactCounter, firstNames.size())].toLowerCase() + '.' + lastNames[Math.mod(contactCounter, lastNames.size())].toLowerCase() + '@' + acc.Name.toLowerCase().replace(' ', '').replace('-', '').replace('&', 'and') + '.com',
            Phone = '(555) 456-' + String.valueOf(contactCounter).leftPad(4, '0'),
            Title = titles[Math.mod(contactCounter + 5, titles.size())],
            AccountId = acc.Id
        ));
        contactCounter++;
    }
    
    insert contacts;
    System.debug('Inserted ' + contacts.size() + ' contacts');
    
    // ========================================
    // 3. CREATE EXTENSIVE PRODUCT CATALOG (100+ products)
    // ========================================
    List<Product2> products = new List<Product2>();
    
    // Electronics Category
    String[] electronics = new String[]{'Laptop Pro X1', 'Ultrabook Air', 'Gaming Desktop', 'Workstation Pro', 'All-in-One PC', 'Tablet Pro', 'Smartphone X', 'Smartwatch Elite', 'Wireless Earbuds', 'Bluetooth Speaker', 'Portable Monitor', 'External SSD', 'USB Hub', 'Wireless Charger', 'Cable Organizer'};
    
    // Office Supplies
    String[] office = new String[]{'Ergonomic Chair', 'Standing Desk', 'Monitor Stand', 'Desk Lamp LED', 'File Cabinet', 'Whiteboard', 'Projector', 'Conference Phone', 'Wireless Keyboard', 'Wireless Mouse', 'Webcam HD1080', 'Microphone Pro', 'Document Scanner', 'Label Maker', 'Paper Shredder'};
    
    // Networking
    String[] networking = new String[]{'WiFi Router', 'Network Switch', 'Ethernet Cable', 'Powerline Adapter', 'VPN Router', 'Network Storage', 'Wireless Bridge', 'Network Card', 'Modem', 'Repeater', 'Antenna', 'Cable Tester', 'Crimping Tool', 'Patch Panel', 'Network Cabinet'};
    
    // Accessories
    String[] accessories = new String[]{'Laptop Sleeve', 'Phone Stand', 'Screen Protector', 'Car Charger', 'Travel Adapter', 'Cable Ties', 'Velcro Straps', 'Cable Clips', 'Desk Mat', 'Monitor Arm', 'Keyboard Tray', 'Foot Rest', 'Wrist Rest', 'Eye Care Glasses', 'Anti-Fatigue Mat'};
    
    // Software
    String[] software = new String[]{'Office Suite Pro', 'Design Software', 'Accounting Software', 'Project Management', 'CRM System', 'Security Suite', 'Backup Software', 'Video Editor', 'Photo Editor', 'Audio Editor', 'Database Tool', 'Development IDE', 'Testing Suite', 'Monitoring Tool', 'Analytics Platform'};
    
    // Combine all categories
    List<String> allProducts = new List<String>();
    allProducts.addAll(electronics);
    allProducts.addAll(office);
    allProducts.addAll(networking);
    allProducts.addAll(accessories);
    allProducts.addAll(software);
    
    // Create products with realistic data
    for(Integer i = 0; i < allProducts.size(); i++) {
        String productName = allProducts[i];
        String productCode = productName.toUpperCase().replace(' ', '-').replace('&', 'AND');
        
        // Determine category based on product type
        String category = '';
        if(electronics.contains(productName)) category = 'Electronics';
        else if(office.contains(productName)) category = 'Office Supplies';
        else if(networking.contains(productName)) category = 'Networking';
        else if(accessories.contains(productName)) category = 'Accessories';
        else if(software.contains(productName)) category = 'Software';
        
        // Generate realistic pricing
        Decimal basePrice = 0;
        if(electronics.contains(productName)) basePrice = Math.round((Math.random() * 2000 + 100) * 100) / 100;
        else if(office.contains(productName)) basePrice = Math.round((Math.random() * 500 + 50) * 100) / 100;
        else if(networking.contains(productName)) basePrice = Math.round((Math.random() * 300 + 25) * 100) / 100;
        else if(accessories.contains(productName)) basePrice = Math.round((Math.random() * 200 + 10) * 100) / 100;
        else if(software.contains(productName)) basePrice = Math.round((Math.random() * 1000 + 99) * 100) / 100;
        
        products.add(new Product2(
            Name = productName,
            ProductCode = productCode,
            IsActive = true,
            Description = 'Professional ' + productName.toLowerCase() + ' for enterprise use. Category: ' + category,
            Stock_Quantity__c = Math.round(Math.random() * 200) + 10,
            Is_Top_Seller__c = (i < 20), // First 20 are top sellers
            Image_URL__c = 'https://via.placeholder.com/400x300?text=' + productName.replace(' ', '+')
        ));
    }
    
    insert products;
    System.debug('Inserted ' + products.size() + ' products');
    
    // ========================================
    // 4. CREATE CATEGORIES
    // ========================================
    List<Category__c> categories = new List<Category__c>();
    
    String[] categoryNames = new String[]{'Electronics', 'Office Supplies', 'Networking', 'Accessories', 'Software', 'Hardware', 'Peripherals', 'Mobile Devices', 'Cables & Adapters', 'Tools & Equipment'};
    String[] categoryDescriptions = new String[]{
        'Electronic devices and equipment for professional use',
        'Office and workspace essentials for productivity',
        'Networking equipment and connectivity solutions',
        'Essential accessories and add-ons',
        'Professional software applications and tools',
        'Computer hardware and components',
        'Input/output devices and peripherals',
        'Mobile computing and communication devices',
        'Cables, adapters, and connection solutions',
        'Professional tools and testing equipment'
    };
    
    for(Integer i = 0; i < categoryNames.size(); i++) {
        categories.add(new Category__c(
            Name__c = categoryNames[i],
            Description__c = categoryDescriptions[i]
        ));
    }
    
    insert categories;
    System.debug('Inserted ' + categories.size() + ' categories');
    
    // ========================================
    // 5. CREATE PRICEBOOK ENTRIES
    // ========================================
    Id standardPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
    
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    
    for(Product2 product : products) {
        // Find the product name to determine pricing
        String productName = product.Name;
        Decimal basePrice = product.Stock_Quantity__c * 10; // Simple pricing based on stock
        
        // Adjust pricing for different categories
        if(productName.contains('Pro') || productName.contains('Elite')) basePrice *= 1.5;
        if(productName.contains('Software') || productName.contains('Suite')) basePrice *= 2.0;
        
        pricebookEntries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = basePrice,
            IsActive = true
        ));
    }
    
    insert pricebookEntries;
    System.debug('Inserted ' + pricebookEntries.size() + ' pricebook entries');
    
    // ========================================
    // 6. CREATE SAMPLE CARTS AND CART ITEMS
    // ========================================
    List<Cart__c> carts = new List<Cart__c>();
    List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
    
    // Create sample carts for different contacts
    for(Integer i = 0; i < Math.min(10, contacts.size()); i++) {
        Contact contact = contacts[i];
        
        Cart__c cart = new Cart__c(
            Contact__c = contact.Id,
            Status__c = 'Active',
            Subtotal__c = 0,
            Total_Items__c = 0
        );
        carts.add(cart);
    }
    
    insert carts;
    System.debug('Inserted ' + carts.size() + ' sample carts');
    
    // Add items to carts
    for(Cart__c cart : carts) {
        // Add 2-5 random products to each cart
        Integer numItems = Math.round(Math.random() * 3) + 2;
        Set<Integer> usedIndices = new Set<Integer>();
        
        for(Integer i = 0; i < numItems; i++) {
            Integer productIndex;
            do {
                productIndex = Math.round(Math.random() * (products.size() - 1));
            } while(usedIndices.contains(productIndex));
            
            usedIndices.add(productIndex);
            Product2 product = products[productIndex];
            
            Cart_Item__c item = new Cart_Item__c(
                Cart__c = cart.Id,
                Product__c = product.Id,
                Quantity__c = Math.round(Math.random() * 3) + 1,
                Unit_Price__c = product.Stock_Quantity__c * 10, // Simple pricing
                Line_Total__c = 0 // Will be calculated by trigger
            );
            cartItems.add(item);
        }
    }
    
    insert cartItems;
    System.debug('Inserted ' + cartItems.size() + ' cart items');
    
    // ========================================
    // 7. CREATE SHIPPING ADDRESSES
    // ========================================
    List<Shipping_Address__c> shippingAddresses = new List<Shipping_Address__c>();
    
    for(Integer i = 0; i < Math.min(15, accounts.size()); i++) {
        Account acc = accounts[i];
        
        shippingAddresses.add(new Shipping_Address__c(
            Account__c = acc.Id,
            Address_Label__c = 'Primary Office',
            Street__c = acc.BillingStreet,
            City__c = acc.BillingCity,
            State__c = acc.BillingState,
            Postal_Code__c = acc.BillingPostalCode,
            Country__c = acc.BillingCountry,
            Is_Default__c = true
        ));
        
        // Add secondary address for some accounts
        if(Math.mod(i, 3) == 0) {
            shippingAddresses.add(new Shipping_Address__c(
                Account__c = acc.Id,
                Address_Label__c = 'Secondary Location',
                Street__c = (2000 + i * 100) + ' Secondary Street',
                City__c = acc.BillingCity,
                State__c = acc.BillingState,
                Postal_Code__c = acc.BillingPostalCode,
                Country__c = acc.BillingCountry,
                Is_Default__c = false
            ));
        }
    }
    
    insert shippingAddresses;
    System.debug('Inserted ' + shippingAddresses.size() + ' shipping addresses');
    
    System.debug('✅ Comprehensive test data creation completed successfully!');
    System.debug('Created: ' + accounts.size() + ' accounts, ' + contacts.size() + ' contacts, ' + 
                products.size() + ' products, ' + categories.size() + ' categories, ' + 
                pricebookEntries.size() + ' pricebook entries, ' + carts.size() + ' carts, ' +
                cartItems.size() + ' cart items, ' + shippingAddresses.size() + ' shipping addresses');
    
} catch (Exception e) {
    System.debug('❌ Error creating comprehensive test data: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    throw e;
}

