// SIMPLIFIED TEST DATA CREATION SCRIPT
// Creates comprehensive test data without syntax issues

System.debug('Starting test data creation...');

// Create 10 diverse accounts
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
    Phone = '(415) 555-0101',
    Website = 'www.techcorp.com'
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
    Website = 'www.globalsystems.com'
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
    Phone = '(312) 555-0103',
    Website = 'www.metrohealth.org'
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
    Phone = '(212) 555-0105',
    Website = 'www.premierfinancial.com'
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
    Phone = '(617) 555-0106',
    Website = 'www.stateuniversity.edu'
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
    Phone = '(313) 555-0107',
    Website = 'www.advancedmfg.com'
));

accounts.add(new Account(
    Name = 'National Retail Chain',
    Type = 'Customer - Direct',
    Industry = 'Retail',
    BillingStreet = '2000 Commerce Street',
    BillingCity = 'Los Angeles',
    BillingState = 'CA',
    BillingPostalCode = '90012',
    BillingCountry = 'USA',
    Phone = '(213) 555-0108',
    Website = 'www.nationalretail.com'
));

accounts.add(new Account(
    Name = 'Federal Agency Division',
    Type = 'Customer - Direct',
    Industry = 'Government',
    BillingStreet = '1600 Government Way',
    BillingCity = 'Washington',
    BillingState = 'DC',
    BillingPostalCode = '20001',
    BillingCountry = 'USA',
    Phone = '(202) 555-0109',
    Website = 'www.federalagency.gov'
));

accounts.add(new Account(
    Name = 'Healthcare Systems Inc',
    Type = 'Customer - Direct',
    Industry = 'Healthcare',
    BillingStreet = '147 Health Plaza',
    BillingCity = 'Boston',
    BillingState = 'MA',
    BillingPostalCode = '02101',
    BillingCountry = 'USA',
    Phone = '(555) 678-9012',
    Website = 'www.healthcaresystems.com'
));

accounts.add(new Account(
    Name = 'Digital Marketing Agency',
    Type = 'Customer - Channel',
    Industry = 'Marketing',
    BillingStreet = '987 Digital Lane',
    BillingCity = 'Miami',
    BillingState = 'FL',
    BillingPostalCode = '33101',
    BillingCountry = 'USA',
    Phone = '(555) 567-8901',
    Website = 'www.digitalmarketing.com'
));

insert accounts;
System.debug('Inserted ' + accounts.size() + ' accounts');

// Create 20 contacts (2 per account)
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
        Email = firstNames[Math.mod(contactCounter, firstNames.size())].toLowerCase() + '.' + lastNames[Math.mod(contactCounter, lastNames.size())].toLowerCase() + '@' + acc.Name.replace(' ', '').toLowerCase() + '.com',
        Phone = '(555) ' + String.valueOf(Math.mod(contactCounter + 100, 900) + 100) + '-' + String.valueOf(Math.mod(contactCounter * 7, 9000) + 1000),
        Title = titles[Math.mod(contactCounter, titles.size())],
        AccountId = acc.Id,
        Department = 'IT'
    ));
    contactCounter++;
    
    // Secondary Contact
    contacts.add(new Contact(
        FirstName = firstNames[Math.mod(contactCounter, firstNames.size())],
        LastName = lastNames[Math.mod(contactCounter, lastNames.size())],
        Email = firstNames[Math.mod(contactCounter, firstNames.size())].toLowerCase() + '.' + lastNames[Math.mod(contactCounter, lastNames.size())].toLowerCase() + '@' + acc.Name.replace(' ', '').toLowerCase() + '.com',
        Phone = '(555) ' + String.valueOf(Math.mod(contactCounter + 100, 900) + 100) + '-' + String.valueOf(Math.mod(contactCounter * 7, 9000) + 1000),
        Title = titles[Math.mod(contactCounter, titles.size())],
        AccountId = acc.Id,
        Department = 'Procurement'
    ));
    contactCounter++;
}

insert contacts;
System.debug('Inserted ' + contacts.size() + ' contacts');

// Create product categories
List<Category__c> categories = new List<Category__c>();

categories.add(new Category__c(Name__c = 'Audio & Sound'));
categories.add(new Category__c(Name__c = 'Computing & Laptops'));
categories.add(new Category__c(Name__c = 'Mobile & Wearables'));
categories.add(new Category__c(Name__c = 'Gaming & Entertainment'));
categories.add(new Category__c(Name__c = 'Smart Home & IoT'));
categories.add(new Category__c(Name__c = 'Networking & Connectivity'));
categories.add(new Category__c(Name__c = 'Storage & Memory'));
categories.add(new Category__c(Name__c = 'Power & Charging'));

insert categories;
System.debug('Inserted ' + categories.size() + ' categories');

// Create 30 products
List<Product2> products = new List<Product2>();

// Audio Products
products.add(new Product2(Name = 'Premium Wireless Headphones Pro', ProductCode = 'AUD-001', Description = 'Professional-grade wireless headphones with active noise cancellation, 30-hour battery life, and premium audio drivers.', IsActive = true, Stock_Quantity__c = 75, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Premium+Headphones+Pro'));
products.add(new Product2(Name = 'Portable Bluetooth Speaker Max', ProductCode = 'AUD-002', Description = 'Rugged portable speaker with 40-hour battery, waterproof design, and 360-degree sound.', IsActive = true, Stock_Quantity__c = 120, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Bluetooth+Speaker+Max'));
products.add(new Product2(Name = 'Studio Condenser Microphone', ProductCode = 'AUD-003', Description = 'Professional condenser microphone with USB connectivity for podcasting, streaming, and recording.', IsActive = true, Stock_Quantity__c = 45, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Studio+Microphone'));
products.add(new Product2(Name = 'Wireless Earbuds Elite', ProductCode = 'AUD-004', Description = 'True wireless earbuds with active noise cancellation and wireless charging case.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Wireless+Earbuds'));

// Computing Products
products.add(new Product2(Name = 'Business Laptop Pro 15-inch', ProductCode = 'COMP-001', Description = 'High-performance business laptop with Intel i7 processor, 16GB RAM, 512GB SSD, and 15-inch 4K display.', IsActive = true, Stock_Quantity__c = 50, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Business+Laptop+Pro'));
products.add(new Product2(Name = 'Gaming Desktop Powerhouse', ProductCode = 'COMP-002', Description = 'Ultimate gaming desktop with RTX 4080, AMD Ryzen 9, 32GB RAM, and RGB lighting.', IsActive = true, Stock_Quantity__c = 25, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Desktop'));
products.add(new Product2(Name = 'Ultrabook Lightweight 13-inch', ProductCode = 'COMP-003', Description = 'Ultra-portable laptop weighing only 2.2 lbs with all-day battery life and premium build quality.', IsActive = true, Stock_Quantity__c = 75, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Ultrabook'));
products.add(new Product2(Name = 'All-in-One Desktop 24-inch', ProductCode = 'COMP-004', Description = 'Sleek all-in-one desktop computer with 24-inch touchscreen and wireless peripherals.', IsActive = true, Stock_Quantity__c = 40, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=All+in+One+Desktop'));

// Mobile Products
products.add(new Product2(Name = 'Flagship Smartphone 256GB', ProductCode = 'MOB-001', Description = 'Latest flagship smartphone with 256GB storage, triple camera system, and 5G connectivity.', IsActive = true, Stock_Quantity__c = 100, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Flagship+Smartphone'));
products.add(new Product2(Name = 'Smart Fitness Watch Pro', ProductCode = 'MOB-002', Description = 'Advanced fitness smartwatch with GPS, heart rate monitoring, and 14-day battery life.', IsActive = true, Stock_Quantity__c = 150, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Fitness+Watch'));
products.add(new Product2(Name = 'Wireless Charging Stand', ProductCode = 'MOB-003', Description = 'Fast wireless charging stand compatible with all Qi-enabled devices.', IsActive = true, Stock_Quantity__c = 250, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Wireless+Charging+Stand'));
products.add(new Product2(Name = 'Phone Case Protective Ultra', ProductCode = 'MOB-004', Description = 'Military-grade protective phone case with screen protector and belt clip.', IsActive = true, Stock_Quantity__c = 300, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Protective+Phone+Case'));

// Gaming Products
products.add(new Product2(Name = 'Gaming Console Next-Gen', ProductCode = 'GAM-001', Description = 'Latest generation gaming console with 4K gaming and ray tracing capabilities.', IsActive = true, Stock_Quantity__c = 30, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Console'));
products.add(new Product2(Name = 'Gaming Mechanical Keyboard RGB', ProductCode = 'GAM-002', Description = 'Premium mechanical gaming keyboard with RGB backlighting and programmable keys.', IsActive = true, Stock_Quantity__c = 120, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Keyboard'));
products.add(new Product2(Name = 'Gaming Mouse Precision Pro', ProductCode = 'GAM-003', Description = 'High-precision gaming mouse with adjustable DPI and customizable buttons.', IsActive = true, Stock_Quantity__c = 180, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Mouse'));
products.add(new Product2(Name = 'VR Headset Immersive', ProductCode = 'GAM-004', Description = 'Virtual reality headset with 4K display and spatial tracking technology.', IsActive = true, Stock_Quantity__c = 40, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=VR+Headset'));

// Smart Home Products
products.add(new Product2(Name = 'Smart Home Hub Central', ProductCode = 'IOT-001', Description = 'Central smart home hub compatible with Alexa, Google, and Apple HomeKit.', IsActive = true, Stock_Quantity__c = 85, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Home+Hub'));
products.add(new Product2(Name = 'Smart LED Bulbs Color', ProductCode = 'IOT-002', Description = 'WiFi-enabled smart LED bulbs with 16 million colors and voice control.', IsActive = true, Stock_Quantity__c = 300, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+LED+Bulbs'));
products.add(new Product2(Name = 'Smart Security Camera Outdoor', ProductCode = 'IOT-003', Description = 'Weatherproof security camera with night vision and motion detection.', IsActive = true, Stock_Quantity__c = 120, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Security+Camera'));
products.add(new Product2(Name = 'Smart Door Lock Keyless', ProductCode = 'IOT-004', Description = 'Keyless smart door lock with fingerprint and smartphone access.', IsActive = true, Stock_Quantity__c = 45, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Door+Lock'));

// Networking Products
products.add(new Product2(Name = 'Mesh WiFi System 3-Pack', ProductCode = 'NET-001', Description = 'Whole-home mesh WiFi system with seamless roaming and app control.', IsActive = true, Stock_Quantity__c = 75, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Mesh+WiFi+System'));
products.add(new Product2(Name = 'Enterprise Router Gigabit', ProductCode = 'NET-002', Description = 'High-performance gigabit router for enterprise networks with advanced security features.', IsActive = true, Stock_Quantity__c = 40, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Enterprise+Router'));
products.add(new Product2(Name = 'Network Switch 24-Port', ProductCode = 'NET-003', Description = '24-port managed Ethernet switch with VLAN support and web interface.', IsActive = true, Stock_Quantity__c = 25, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Network+Switch'));
products.add(new Product2(Name = 'WiFi Range Extender', ProductCode = 'NET-004', Description = 'WiFi range extender to boost signal strength in large homes and offices.', IsActive = true, Stock_Quantity__c = 150, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=WiFi+Extender'));

// Storage Products
products.add(new Product2(Name = 'External SSD 2TB', ProductCode = 'STO-001', Description = 'High-speed external SSD with 2TB capacity and USB-C connectivity.', IsActive = true, Stock_Quantity__c = 100, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=External+SSD'));
products.add(new Product2(Name = 'Cloud Storage 1-Year Plan', ProductCode = 'STO-002', Description = 'Secure cloud storage with 1TB capacity and 1-year subscription.', IsActive = true, Stock_Quantity__c = 500, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Cloud+Storage'));

// Power Products
products.add(new Product2(Name = 'Portable Power Bank 30000mAh', ProductCode = 'PWR-001', Description = 'High-capacity 30,000mAh power bank with fast charging and multiple ports.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Power+Bank+30K'));
products.add(new Product2(Name = 'Wireless Charging Pad 15W', ProductCode = 'PWR-002', Description = 'Fast 15W wireless charging pad with cooling fan and LED indicators.', IsActive = true, Stock_Quantity__c = 250, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Wireless+Charging+Pad'));
products.add(new Product2(Name = 'UPS Battery Backup 1500VA', ProductCode = 'PWR-003', Description = 'Uninterruptible power supply for computers and network equipment protection.', IsActive = true, Stock_Quantity__c = 30, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=UPS+Battery+Backup'));

insert products;
System.debug('Inserted ' + products.size() + ' products');

// Create price book entries
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

// Audio pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[0].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 299.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[1].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 189.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[2].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 149.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[3].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 179.99, IsActive = true));

// Computing pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[4].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 1299.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[5].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 2499.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[6].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 899.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[7].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 799.99, IsActive = true));

// Mobile pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[8].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 999.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[9].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 349.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[10].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 59.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[11].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 24.99, IsActive = true));

// Gaming pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[12].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 499.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[13].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 179.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[14].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 129.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[15].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 399.99, IsActive = true));

// Smart Home pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[16].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 149.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[17].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 34.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[18].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 159.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[19].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 199.99, IsActive = true));

// Networking pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[20].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 299.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[21].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 599.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[22].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 899.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[23].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 89.99, IsActive = true));

// Storage pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[24].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 249.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[25].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 99.99, IsActive = true));

// Power pricing
pricebookEntries.add(new PricebookEntry(Product2Id = products[26].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 99.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[27].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 49.99, IsActive = true));
pricebookEntries.add(new PricebookEntry(Product2Id = products[28].Id, Pricebook2Id = standardPriceBook.Id, UnitPrice = 199.99, IsActive = true));

insert pricebookEntries;
System.debug('Inserted ' + pricebookEntries.size() + ' price book entries');

// Create shipping addresses
List<Shipping_Address__c> shippingAddresses = new List<Shipping_Address__c>();

for(Account acc : accounts) {
    shippingAddresses.add(new Shipping_Address__c(
        Account__c = acc.Id,
        Address_Label__c = 'Primary Office',
        Street__c = acc.BillingStreet,
        City__c = acc.BillingCity,
        State__c = acc.BillingState,
        Postal_Code__c = acc.BillingPostalCode,
        Country__c = acc.BillingCountry
    ));
}

insert shippingAddresses;
System.debug('Inserted ' + shippingAddresses.size() + ' shipping addresses');

// Create active carts
List<Cart__c> carts = new List<Cart__c>();

for(Integer i = 0; i < 10; i++) {
    carts.add(new Cart__c(
        Contact__c = contacts[i*2].Id,
        Status__c = 'Active'
    ));
}

insert carts;
System.debug('Inserted ' + carts.size() + ' carts');

// Add items to carts
List<Cart_Item__c> cartItems = new List<Cart_Item__c>();

for(Integer i = 0; i < carts.size(); i++) {
    Cart__c cart = carts[i];
    Integer numItems = 2 + Math.mod(i, 4);
    
    for(Integer j = 0; j < numItems; j++) {
        Integer productIndex = Math.mod(i*3 + j, products.size());
        Integer quantity = 1 + Math.mod(i + j, 3);
        
        cartItems.add(new Cart_Item__c(
            Cart__c = cart.Id,
            Product__c = products[productIndex].Id,
            Quantity__c = quantity,
            Unit_Price__c = pricebookEntries[productIndex].UnitPrice
        ));
    }
}

insert cartItems;
System.debug('Inserted ' + cartItems.size() + ' cart items');

// Create sample orders
List<Order> orders = new List<Order>();

for(Integer i = 0; i < 5; i++) {
    orders.add(new Order(
        AccountId = accounts[i].Id,
        Pricebook2Id = standardPriceBook.Id,
        EffectiveDate = Date.today().addDays(-Math.mod(i, 30)),
        Status = 'Activated',
        Description = 'Test Order #' + (1000 + i)
    ));
}

insert orders;
System.debug('Inserted ' + orders.size() + ' orders');

// Add order items
List<OrderItem> orderItems = new List<OrderItem>();

for(Integer i = 0; i < orders.size(); i++) {
    Order ord = orders[i];
    Integer numItems = 2 + Math.mod(i, 3);
    
    for(Integer j = 0; j < numItems; j++) {
        Integer productIndex = Math.mod(i*2 + j, products.size());
        Integer quantity = 1 + Math.mod(i + j, 4);
        
        orderItems.add(new OrderItem(
            OrderId = ord.Id,
            Product2Id = products[productIndex].Id,
            PricebookEntryId = pricebookEntries[productIndex].Id,
            Quantity = quantity,
            UnitPrice = pricebookEntries[productIndex].UnitPrice
        ));
    }
}

insert orderItems;
System.debug('Inserted ' + orderItems.size() + ' order items');

// Create view tracking data
List<View_Tracking__c> viewTrackings = new List<View_Tracking__c>();

for(Integer i = 0; i < 100; i++) {
    Integer contactIndex = Math.mod(i, contacts.size());
    Integer productIndex = Math.mod(i, products.size());
    
    viewTrackings.add(new View_Tracking__c(
        User_Contact__c = contacts[contactIndex].Id,
        Product__c = products[productIndex].Id,
        Last_Viewed_Date__c = DateTime.now().addDays(-Math.mod(i, 7)).addHours(-Math.mod(i, 24))
    ));
}

insert viewTrackings;
System.debug('Inserted ' + viewTrackings.size() + ' view tracking records');

// Create notification requests
List<Notification_Request__c> notifications = new List<Notification_Request__c>();

for(Integer i = 0; i < 20; i++) {
    Integer contactIndex = Math.mod(i, contacts.size());
    Integer productIndex = Math.mod(i*2, products.size());
    
    notifications.add(new Notification_Request__c(
        User_Contact__c = contacts[contactIndex].Id,
        Product__c = products[productIndex].Id,
        Status__c = i < 15 ? 'Pending' : 'Sent'
    ));
}

insert notifications;
System.debug('Inserted ' + notifications.size() + ' notification requests');

// Final summary
System.debug('');
System.debug('======================================');
System.debug('TEST DATA CREATION COMPLETE');
System.debug('======================================');

System.debug('Data Summary:');
System.debug('Accounts: ' + [SELECT COUNT() FROM Account]);
System.debug('Contacts: ' + [SELECT COUNT() FROM Contact]);
System.debug('Categories: ' + [SELECT COUNT() FROM Category__c]);
System.debug('Products: ' + [SELECT COUNT() FROM Product2]);
System.debug('Price Book Entries: ' + [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :standardPriceBook.Id]);
System.debug('Shipping Addresses: ' + [SELECT COUNT() FROM Shipping_Address__c]);
Integer activeCartCount = [SELECT COUNT() FROM Cart__c WHERE Status__c = 'Active'];
System.debug('Active Carts: ' + activeCartCount);
System.debug('Cart Items: ' + [SELECT COUNT() FROM Cart_Item__c]);
System.debug('Orders: ' + [SELECT COUNT() FROM Order]);
System.debug('Order Items: ' + [SELECT COUNT() FROM OrderItem]);
System.debug('View Tracking: ' + [SELECT COUNT() FROM View_Tracking__c]);
System.debug('Notification Requests: ' + [SELECT COUNT() FROM Notification_Request__c]);

System.debug('');
System.debug('Top Selling Products:');
for(Product2 prod : [SELECT Name, ProductCode, Stock_Quantity__c FROM Product2 WHERE Is_Top_Seller__c = true ORDER BY Name LIMIT 5]) {
    System.debug('- ' + prod.Name + ' (' + prod.ProductCode + ') - Stock: ' + prod.Stock_Quantity__c);
}

System.debug('');
System.debug('Test data generation successful!');
System.debug('Ready for comprehensive testing of ENOS application.');
