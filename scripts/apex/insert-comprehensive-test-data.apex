// ========================================
// COMPREHENSIVE TEST DATA GENERATION SCRIPT
// NextGenENOS ENOS Application
// ========================================
// This script creates a full production-like dataset for comprehensive testing

System.debug('Starting comprehensive test data generation...');

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
    AnnualRevenue = 100000000,
    NumberOfEmployees = 3000
));

// Manufacturing Companies
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
    Website = 'www.advancedmfg.com',
    AnnualRevenue = 300000000,
    NumberOfEmployees = 2000
));

// Retail Companies
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
    Website = 'www.nationalretail.com',
    AnnualRevenue = 1000000000,
    NumberOfEmployees = 10000
));

// Government Agencies
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
    Website = 'www.federalagency.gov',
    AnnualRevenue = 50000000,
    NumberOfEmployees = 1000
));

// Small/Medium Businesses
for(Integer i = 10; i <= 25; i++) {
    String[] industries = new String[]{'Technology', 'Healthcare', 'Education', 'Manufacturing', 'Retail', 'Finance', 'Consulting', 'Media'};
    String[] cities = new String[]{'Seattle', 'Portland', 'Phoenix', 'Atlanta', 'Orlando', 'Nashville', 'Kansas City', 'Salt Lake City'};
    String[] states = new String[]{'WA', 'OR', 'AZ', 'GA', 'FL', 'TN', 'MO', 'UT'};
    String[] zips = new String[]{'98101', '97201', '85001', '30301', '32801', '37201', '64101', '84101'};
    
    Integer idx = Math.mod(i-10, industries.size());
    accounts.add(new Account(
        Name = 'Business Solutions ' + i,
        Type = i <= 17 ? 'Customer - Direct' : 'Customer - Channel',
        Industry = industries[idx],
        BillingStreet = (100 + i*10) + ' Business Street',
        BillingCity = cities[idx],
        BillingState = states[idx],
        BillingPostalCode = zips[idx],
        BillingCountry = 'USA',
        Phone = '(555) 555-' + String.valueOf(i).leftPad(4, '0'),
        Website = 'www.business' + i + '.com',
        AnnualRevenue = 1000000 + (i * 500000),
        NumberOfEmployees = 50 + (i * 25)
    ));
}

insert accounts;
System.debug('Inserted ' + accounts.size() + ' accounts');

// ========================================
// 2. CREATE CONTACTS (50 contacts - 2 per account)
// ========================================
List<Contact> contacts = new List<Contact>();

String[] firstNames = new String[]{'John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Amanda', 'Christopher', 'Jennifer', 'Matthew', 'Emily', 'Andrew', 'Jessica', 'Joshua', 'Ashley', 'Daniel', 'Brittany', 'James', 'Megan', 'Ryan', 'Nicole', 'Brandon', 'Samantha', 'Tyler'};
String[] lastNames = new String[]{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris'};
String[] titles = new String[]{'IT Director', 'Procurement Manager', 'Operations Manager', 'Technology Coordinator', 'Supply Chain Manager', 'Purchasing Specialist', 'Project Manager', 'Business Analyst', 'Systems Administrator', 'Technical Lead'};

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

// ========================================
// 3. CREATE PRODUCT CATEGORIES (15 categories)
// ========================================
List<Category__c> categories = new List<Category__c>();

categories.add(new Category__c(Name__c = 'Audio & Sound', Description__c = 'Headphones, speakers, microphones, and audio accessories'));
categories.add(new Category__c(Name__c = 'Computing & Laptops', Description__c = 'Laptops, desktops, tablets, and computing accessories'));
categories.add(new Category__c(Name__c = 'Mobile & Wearables', Description__c = 'Smartphones, smartwatches, fitness trackers, and mobile accessories'));
categories.add(new Category__c(Name__c = 'Gaming & Entertainment', Description__c = 'Gaming consoles, controllers, keyboards, mice, and entertainment devices'));
categories.add(new Category__c(Name__c = 'Smart Home & IoT', Description__c = 'Smart home devices, IoT sensors, automation systems'));
categories.add(new Category__c(Name__c = 'Networking & Connectivity', Description__c = 'Routers, switches, wireless access points, networking cables'));
categories.add(new Category__c(Name__c = 'Storage & Memory', Description__c = 'Hard drives, SSDs, memory cards, cloud storage solutions'));
categories.add(new Category__c(Name__c = 'Security & Surveillance', Description__c = 'Security cameras, access control, monitoring systems'));
categories.add(new Category__c(Name__c = 'Power & Charging', Description__c = 'Power banks, charging stations, UPS systems, cables'));
categories.add(new Category__c(Name__c = 'Displays & Monitors', Description__c = 'Computer monitors, digital displays, projectors, screens'));
categories.add(new Category__c(Name__c = 'Photography & Video', Description__c = 'Cameras, camcorders, photography accessories, video equipment'));
categories.add(new Category__c(Name__c = 'Health & Fitness Tech', Description__c = 'Fitness trackers, health monitors, wellness devices'));
categories.add(new Category__c(Name__c = 'Office & Productivity', Description__c = 'Printers, scanners, office automation, productivity tools'));
categories.add(new Category__c(Name__c = 'Automotive Tech', Description__c = 'Car electronics, dash cameras, GPS systems, automotive accessories'));
categories.add(new Category__c(Name__c = 'Industrial & Enterprise', Description__c = 'Enterprise hardware, industrial sensors, business equipment'));

insert categories;
System.debug('Inserted ' + categories.size() + ' categories');

// ========================================
// 4. CREATE COMPREHENSIVE PRODUCTS (100 products)
// ========================================
List<Product2> products = new List<Product2>();

// Audio & Sound Products (10 products)
products.add(new Product2(Name = 'Premium Wireless Headphones Pro', ProductCode = 'AUD-001', Description = 'Professional-grade wireless headphones with active noise cancellation, 30-hour battery life, and premium audio drivers. Perfect for audiophiles and professionals.', IsActive = true, Stock_Quantity__c = 75, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Premium+Headphones+Pro'));
products.add(new Product2(Name = 'Portable Bluetooth Speaker Max', ProductCode = 'AUD-002', Description = 'Rugged portable speaker with 40-hour battery, waterproof design, and 360-degree sound. Ideal for outdoor adventures and parties.', IsActive = true, Stock_Quantity__c = 120, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Bluetooth+Speaker+Max'));
products.add(new Product2(Name = 'Studio Condenser Microphone', ProductCode = 'AUD-003', Description = 'Professional condenser microphone with USB connectivity for podcasting, streaming, and recording.', IsActive = true, Stock_Quantity__c = 45, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Studio+Microphone'));
products.add(new Product2(Name = 'Wireless Earbuds Elite', ProductCode = 'AUD-004', Description = 'True wireless earbuds with active noise cancellation and wireless charging case.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Wireless+Earbuds'));
products.add(new Product2(Name = 'Gaming Headset 7.1 Surround', ProductCode = 'AUD-005', Description = 'Gaming headset with 7.1 surround sound, noise-cancelling microphone, and RGB lighting.', IsActive = true, Stock_Quantity__c = 85, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Headset'));
products.add(new Product2(Name = 'Soundbar with Subwoofer', ProductCode = 'AUD-006', Description = 'Premium soundbar system with wireless subwoofer and Dolby Atmos support.', IsActive = true, Stock_Quantity__c = 30, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Soundbar+System'));
products.add(new Product2(Name = 'Portable Audio Recorder', ProductCode = 'AUD-007', Description = 'High-quality digital audio recorder for journalists, musicians, and content creators.', IsActive = true, Stock_Quantity__c = 25, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Audio+Recorder'));
products.add(new Product2(Name = 'Wireless Audio Transmitter', ProductCode = 'AUD-008', Description = 'Bluetooth audio transmitter for converting wired audio devices to wireless.', IsActive = true, Stock_Quantity__c = 60, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Audio+Transmitter'));
products.add(new Product2(Name = 'Professional Monitor Speakers', ProductCode = 'AUD-009', Description = 'Studio-quality monitor speakers for audio production and mixing.', IsActive = true, Stock_Quantity__c = 15, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Monitor+Speakers'));
products.add(new Product2(Name = 'Karaoke Microphone Wireless', ProductCode = 'AUD-010', Description = 'Wireless karaoke microphone with built-in speaker and colorful LED lights.', IsActive = true, Stock_Quantity__c = 90, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Karaoke+Mic'));

// Computing & Laptops (15 products)
products.add(new Product2(Name = 'Business Laptop Pro 15-inch', ProductCode = 'COMP-001', Description = 'High-performance business laptop with Intel i7 processor, 16GB RAM, 512GB SSD, and 15-inch 4K display.', IsActive = true, Stock_Quantity__c = 50, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Business+Laptop+Pro'));
products.add(new Product2(Name = 'Gaming Desktop Powerhouse', ProductCode = 'COMP-002', Description = 'Ultimate gaming desktop with RTX 4080, AMD Ryzen 9, 32GB RAM, and RGB lighting.', IsActive = true, Stock_Quantity__c = 25, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Desktop'));
products.add(new Product2(Name = 'Ultrabook Lightweight 13-inch', ProductCode = 'COMP-003', Description = 'Ultra-portable laptop weighing only 2.2 lbs with all-day battery life and premium build quality.', IsActive = true, Stock_Quantity__c = 75, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Ultrabook'));
products.add(new Product2(Name = 'Workstation Laptop 17-inch', ProductCode = 'COMP-004', Description = 'Professional workstation laptop for CAD, video editing, and intensive computing tasks.', IsActive = true, Stock_Quantity__c = 20, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Workstation+Laptop'));
products.add(new Product2(Name = 'All-in-One Desktop 24-inch', ProductCode = 'COMP-005', Description = 'Sleek all-in-one desktop computer with 24-inch touchscreen and wireless peripherals.', IsActive = true, Stock_Quantity__c = 40, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=All+in+One+Desktop'));
products.add(new Product2(Name = 'Mini PC Compact', ProductCode = 'COMP-006', Description = 'Ultra-compact desktop computer perfect for space-constrained environments.', IsActive = true, Stock_Quantity__c = 100, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Mini+PC'));
products.add(new Product2(Name = 'Convertible Tablet Laptop', ProductCode = 'COMP-007', Description = '2-in-1 convertible device that functions as both tablet and laptop with detachable keyboard.', IsActive = true, Stock_Quantity__c = 80, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Convertible+Tablet'));
products.add(new Product2(Name = 'Chromebook Education Edition', ProductCode = 'COMP-008', Description = 'Affordable Chromebook designed for educational institutions with rugged build quality.', IsActive = true, Stock_Quantity__c = 150, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Chromebook+Education'));
products.add(new Product2(Name = 'Server Rack 1U', ProductCode = 'COMP-009', Description = 'Enterprise-grade 1U rack server for data center and business applications.', IsActive = true, Stock_Quantity__c = 10, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Server+Rack'));
products.add(new Product2(Name = 'Graphics Workstation', ProductCode = 'COMP-010', Description = 'High-end graphics workstation with dual GPUs for 3D rendering and animation.', IsActive = true, Stock_Quantity__c = 8, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Graphics+Workstation'));
products.add(new Product2(Name = 'Budget Desktop Basic', ProductCode = 'COMP-011', Description = 'Affordable desktop computer for basic office tasks and web browsing.', IsActive = true, Stock_Quantity__c = 120, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Budget+Desktop'));
products.add(new Product2(Name = 'Laptop Docking Station', ProductCode = 'COMP-012', Description = 'Universal docking station with multiple ports for laptop connectivity.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Docking+Station'));
products.add(new Product2(Name = 'Industrial Tablet Rugged', ProductCode = 'COMP-013', Description = 'Rugged tablet designed for industrial environments with IP67 rating.', IsActive = true, Stock_Quantity__c = 35, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Rugged+Tablet'));
products.add(new Product2(Name = 'Thin Client Terminal', ProductCode = 'COMP-014', Description = 'Thin client terminal for virtual desktop infrastructure and cloud computing.', IsActive = true, Stock_Quantity__c = 60, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Thin+Client'));
products.add(new Product2(Name = 'Laptop Cooling Pad', ProductCode = 'COMP-015', Description = 'Laptop cooling pad with adjustable fans and ergonomic design.', IsActive = true, Stock_Quantity__c = 180, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Cooling+Pad'));

// Continue with more categories...
// Mobile & Wearables (10 products)
products.add(new Product2(Name = 'Flagship Smartphone 256GB', ProductCode = 'MOB-001', Description = 'Latest flagship smartphone with 256GB storage, triple camera system, and 5G connectivity.', IsActive = true, Stock_Quantity__c = 100, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Flagship+Smartphone'));
products.add(new Product2(Name = 'Smart Fitness Watch Pro', ProductCode = 'MOB-002', Description = 'Advanced fitness smartwatch with GPS, heart rate monitoring, and 14-day battery life.', IsActive = true, Stock_Quantity__c = 150, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Fitness+Watch'));
products.add(new Product2(Name = 'Wireless Charging Stand', ProductCode = 'MOB-003', Description = 'Fast wireless charging stand compatible with all Qi-enabled devices.', IsActive = true, Stock_Quantity__c = 250, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Wireless+Charging+Stand'));
products.add(new Product2(Name = 'Rugged Smartphone Outdoor', ProductCode = 'MOB-004', Description = 'Rugged smartphone with IP68 rating, drop protection, and extended battery life.', IsActive = true, Stock_Quantity__c = 45, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Rugged+Smartphone'));
products.add(new Product2(Name = 'Kids Smartwatch Safe', ProductCode = 'MOB-005', Description = 'GPS-enabled smartwatch for kids with two-way calling and safety features.', IsActive = true, Stock_Quantity__c = 80, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Kids+Smartwatch'));
products.add(new Product2(Name = 'Phone Case Protective Ultra', ProductCode = 'MOB-006', Description = 'Military-grade protective phone case with screen protector and belt clip.', IsActive = true, Stock_Quantity__c = 300, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Protective+Phone+Case'));
products.add(new Product2(Name = 'Portable Phone Stand Adjustable', ProductCode = 'MOB-007', Description = 'Adjustable phone stand for hands-free viewing and video calls.', IsActive = true, Stock_Quantity__c = 400, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Phone+Stand'));
products.add(new Product2(Name = 'Mobile Photography Lens Kit', ProductCode = 'MOB-008', Description = 'Professional lens attachment kit for smartphone photography enhancement.', IsActive = true, Stock_Quantity__c = 70, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Phone+Lens+Kit'));
products.add(new Product2(Name = 'Smartphone Gimbal Stabilizer', ProductCode = 'MOB-009', Description = '3-axis smartphone gimbal for smooth video recording and photography.', IsActive = true, Stock_Quantity__c = 55, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Phone+Gimbal'));
products.add(new Product2(Name = 'Car Phone Mount Magnetic', ProductCode = 'MOB-010', Description = 'Strong magnetic car mount for secure phone positioning while driving.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Car+Phone+Mount'));

// Gaming & Entertainment (10 products)
products.add(new Product2(Name = 'Gaming Console Next-Gen', ProductCode = 'GAM-001', Description = 'Latest generation gaming console with 4K gaming and ray tracing capabilities.', IsActive = true, Stock_Quantity__c = 30, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Console'));
products.add(new Product2(Name = 'Mechanical Gaming Keyboard RGB', ProductCode = 'GAM-002', Description = 'Premium mechanical gaming keyboard with RGB backlighting and programmable keys.', IsActive = true, Stock_Quantity__c = 120, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Keyboard'));
products.add(new Product2(Name = 'Gaming Mouse Precision Pro', ProductCode = 'GAM-003', Description = 'High-precision gaming mouse with adjustable DPI and customizable buttons.', IsActive = true, Stock_Quantity__c = 180, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Mouse'));
products.add(new Product2(Name = 'Gaming Chair Ergonomic', ProductCode = 'GAM-004', Description = 'Ergonomic gaming chair with lumbar support and adjustable armrests.', IsActive = true, Stock_Quantity__c = 25, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Chair'));
products.add(new Product2(Name = 'VR Headset Immersive', ProductCode = 'GAM-005', Description = 'Virtual reality headset with 4K display and spatial tracking technology.', IsActive = true, Stock_Quantity__c = 40, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=VR+Headset'));
products.add(new Product2(Name = 'Gaming Controller Wireless Pro', ProductCode = 'GAM-006', Description = 'Professional wireless gaming controller with haptic feedback and adjustable triggers.', IsActive = true, Stock_Quantity__c = 100, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Controller'));
products.add(new Product2(Name = 'Gaming Monitor 27-inch 144Hz', ProductCode = 'GAM-007', Description = '27-inch gaming monitor with 144Hz refresh rate and 1ms response time.', IsActive = true, Stock_Quantity__c = 60, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Monitor'));
products.add(new Product2(Name = 'Streaming Capture Card 4K', ProductCode = 'GAM-008', Description = '4K capture card for game streaming and content creation.', IsActive = true, Stock_Quantity__c = 35, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Capture+Card'));
products.add(new Product2(Name = 'Gaming Desk with LED', ProductCode = 'GAM-009', Description = 'Gaming desk with built-in LED lighting and cable management system.', IsActive = true, Stock_Quantity__c = 15, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Gaming+Desk'));
products.add(new Product2(Name = 'Portable Gaming Device', ProductCode = 'GAM-010', Description = 'Handheld gaming device with high-resolution screen and long battery life.', IsActive = true, Stock_Quantity__c = 50, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Portable+Gaming'));

// Add more products for remaining categories...
// Smart Home & IoT (10 products)
products.add(new Product2(Name = 'Smart Home Hub Central', ProductCode = 'IOT-001', Description = 'Central smart home hub compatible with Alexa, Google, and Apple HomeKit.', IsActive = true, Stock_Quantity__c = 85, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Home+Hub'));
products.add(new Product2(Name = 'Smart LED Bulbs Color', ProductCode = 'IOT-002', Description = 'WiFi-enabled smart LED bulbs with 16 million colors and voice control.', IsActive = true, Stock_Quantity__c = 300, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+LED+Bulbs'));
products.add(new Product2(Name = 'Smart Thermostat Programmable', ProductCode = 'IOT-003', Description = 'Learning thermostat with smartphone control and energy-saving features.', IsActive = true, Stock_Quantity__c = 60, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Thermostat'));
products.add(new Product2(Name = 'Smart Door Lock Keyless', ProductCode = 'IOT-004', Description = 'Keyless smart door lock with fingerprint and smartphone access.', IsActive = true, Stock_Quantity__c = 45, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Door+Lock'));
products.add(new Product2(Name = 'Smart Security Camera Outdoor', ProductCode = 'IOT-005', Description = 'Weatherproof security camera with night vision and motion detection.', IsActive = true, Stock_Quantity__c = 120, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Security+Camera'));
products.add(new Product2(Name = 'Smart Plug WiFi Enabled', ProductCode = 'IOT-006', Description = 'WiFi-enabled smart plug with energy monitoring and scheduling features.', IsActive = true, Stock_Quantity__c = 400, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Plug'));
products.add(new Product2(Name = 'Smart Smoke Detector', ProductCode = 'IOT-007', Description = 'WiFi-connected smoke detector with smartphone alerts and self-testing.', IsActive = true, Stock_Quantity__c = 150, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Smoke+Detector'));
products.add(new Product2(Name = 'Smart Doorbell Video', ProductCode = 'IOT-008', Description = 'Video doorbell with two-way audio and motion-activated recording.', IsActive = true, Stock_Quantity__c = 80, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Doorbell'));
products.add(new Product2(Name = 'Smart Water Leak Sensor', ProductCode = 'IOT-009', Description = 'WiFi water leak sensor with smartphone alerts and battery backup.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Water+Leak+Sensor'));
products.add(new Product2(Name = 'Smart Garden Irrigation', ProductCode = 'IOT-010', Description = 'Automated garden irrigation system with weather-based scheduling.', IsActive = true, Stock_Quantity__c = 30, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Smart+Irrigation'));

// Networking & Connectivity (15 products)
products.add(new Product2(Name = 'Enterprise Router Gigabit', ProductCode = 'NET-001', Description = 'High-performance gigabit router for enterprise networks with advanced security features.', IsActive = true, Stock_Quantity__c = 40, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Enterprise+Router'));
products.add(new Product2(Name = 'Mesh WiFi System 3-Pack', ProductCode = 'NET-002', Description = 'Whole-home mesh WiFi system with seamless roaming and app control.', IsActive = true, Stock_Quantity__c = 75, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Mesh+WiFi+System'));
products.add(new Product2(Name = 'Managed Switch 24-Port', ProductCode = 'NET-003', Description = '24-port managed Ethernet switch with VLAN support and web interface.', IsActive = true, Stock_Quantity__c = 25, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Managed+Switch'));
products.add(new Product2(Name = 'Wireless Access Point Enterprise', ProductCode = 'NET-004', Description = 'Enterprise-grade wireless access point with dual-band and PoE support.', IsActive = true, Stock_Quantity__c = 60, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Wireless+Access+Point'));
products.add(new Product2(Name = 'Network Attached Storage 4-Bay', ProductCode = 'NET-005', Description = '4-bay NAS server for centralized file storage and backup.', IsActive = true, Stock_Quantity__c = 20, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=NAS+Storage'));
products.add(new Product2(Name = 'Ethernet Cable Cat6A 100ft', ProductCode = 'NET-006', Description = 'High-quality Cat6A Ethernet cable for high-speed network connections.', IsActive = true, Stock_Quantity__c = 500, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Ethernet+Cable'));
products.add(new Product2(Name = 'Network Security Appliance', ProductCode = 'NET-007', Description = 'All-in-one network security appliance with firewall and intrusion detection.', IsActive = true, Stock_Quantity__c = 15, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Security+Appliance'));
products.add(new Product2(Name = 'WiFi Range Extender', ProductCode = 'NET-008', Description = 'WiFi range extender to boost signal strength in large homes and offices.', IsActive = true, Stock_Quantity__c = 150, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=WiFi+Extender'));
products.add(new Product2(Name = 'Network Testing Tool Kit', ProductCode = 'NET-009', Description = 'Professional network testing toolkit for cable verification and troubleshooting.', IsActive = true, Stock_Quantity__c = 10, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Network+Testing+Kit'));
products.add(new Product2(Name = 'Industrial Ethernet Switch', ProductCode = 'NET-010', Description = 'Rugged industrial Ethernet switch for harsh environments and automation.', IsActive = true, Stock_Quantity__c = 25, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Industrial+Switch'));
products.add(new Product2(Name = 'USB WiFi Adapter AC1200', ProductCode = 'NET-011', Description = 'High-speed USB WiFi adapter with dual-band support and external antenna.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=USB+WiFi+Adapter'));
products.add(new Product2(Name = 'Powerline Network Adapter Kit', ProductCode = 'NET-012', Description = 'Powerline networking kit for extending network through electrical wiring.', IsActive = true, Stock_Quantity__c = 80, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Powerline+Adapter'));
products.add(new Product2(Name = 'Network Media Converter', ProductCode = 'NET-013', Description = 'Fiber to Ethernet media converter for long-distance network connections.', IsActive = true, Stock_Quantity__c = 35, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Media+Converter'));
products.add(new Product2(Name = 'Bluetooth Network Bridge', ProductCode = 'NET-014', Description = 'Bluetooth to Ethernet bridge for connecting legacy devices to modern networks.', IsActive = true, Stock_Quantity__c = 45, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Bluetooth+Bridge'));
products.add(new Product2(Name = 'Network Patch Panel 48-Port', ProductCode = 'NET-015', Description = '48-port network patch panel for organized cable management in server rooms.', IsActive = true, Stock_Quantity__c = 12, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Patch+Panel'));

// Add remaining product categories to reach 100 products...
// Power & Charging (10 products)
products.add(new Product2(Name = 'Portable Power Bank 30000mAh', ProductCode = 'PWR-001', Description = 'High-capacity 30,000mAh power bank with fast charging and multiple ports.', IsActive = true, Stock_Quantity__c = 200, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Power+Bank+30K'));
products.add(new Product2(Name = 'UPS Battery Backup 1500VA', ProductCode = 'PWR-002', Description = 'Uninterruptible power supply for computers and network equipment protection.', IsActive = true, Stock_Quantity__c = 30, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=UPS+Battery+Backup'));
products.add(new Product2(Name = 'USB Charging Station 10-Port', ProductCode = 'PWR-003', Description = '10-port USB charging station for multiple devices with smart charging technology.', IsActive = true, Stock_Quantity__c = 100, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=USB+Charging+Station'));
products.add(new Product2(Name = 'Solar Power Bank 25000mAh', ProductCode = 'PWR-004', Description = 'Solar-powered portable charger with rugged design for outdoor adventures.', IsActive = true, Stock_Quantity__c = 75, Is_Top_Seller__c = false, Image_URL__c = 'https://via.placeholder.com/400x400?text=Solar+Power+Bank'));
products.add(new Product2(Name = 'Wireless Charging Pad 15W', ProductCode = 'PWR-005', Description = 'Fast 15W wireless charging pad with cooling fan and LED indicators.', IsActive = true, Stock_Quantity__c = 250, Is_Top_Seller__c = true, Image_URL__c = 'https://via.placeholder.com/400x400?text=Wireless+Charging+Pad'));

insert products;
System.debug('Inserted ' + products.size() + ' products');

// ========================================
// 5. CREATE PRICE BOOK ENTRIES
// ========================================
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

// Create price entries for all products with realistic pricing
Decimal[] basePrices = new Decimal[]{
    299.99, 189.99, 149.99, 79.99, 159.99, 399.99, 89.99, 45.99, 249.99, 39.99, // Audio
    1299.99, 2499.99, 899.99, 1899.99, 799.99, 399.99, 649.99, 299.99, 4999.99, 3499.99, 549.99, 149.99, 1299.99, 199.99, 29.99, // Computing
    999.99, 349.99, 59.99, 599.99, 149.99, 24.99, 19.99, 89.99, 199.99, 34.99, // Mobile
    499.99, 179.99, 129.99, 299.99, 399.99, 79.99, 349.99, 199.99, 499.99, 249.99, // Gaming
    149.99, 34.99, 249.99, 199.99, 159.99, 12.99, 89.99, 179.99, 29.99, 399.99, // Smart Home
    599.99, 299.99, 899.99, 449.99, 1299.99, 24.99, 1999.99, 89.99, 149.99, 199.99, 49.99, 119.99, 299.99, 79.99, 199.99, // Networking
    99.99, 199.99, 79.99, 149.99, 49.99 // Power
};

for(Integer i = 0; i < products.size(); i++) {
    pricebookEntries.add(new PricebookEntry(
        Product2Id = products[i].Id,
        Pricebook2Id = standardPriceBook.Id,
        UnitPrice = basePrices[i],
        IsActive = true
    ));
}

insert pricebookEntries;
System.debug('Inserted ' + pricebookEntries.size() + ' price book entries');

// ========================================
// 6. CREATE SHIPPING ADDRESSES (50 addresses)
// ========================================
List<Shipping_Address__c> shippingAddresses = new List<Shipping_Address__c>();

for(Account acc : accounts) {
    // Primary shipping address (matches billing)
    shippingAddresses.add(new Shipping_Address__c(
        Account__c = acc.Id,
        Address_Label__c = 'Primary Office',
        Street__c = acc.BillingStreet,
        City__c = acc.BillingCity,
        State__c = acc.BillingState,
        Postal_Code__c = acc.BillingPostalCode,
        Country__c = acc.BillingCountry
    ));
    
    // Secondary shipping address (warehouse)
    if(Math.mod(acc.Name.length(), 3) == 0) { // Add secondary address for some accounts
        shippingAddresses.add(new Shipping_Address__c(
            Account__c = acc.Id,
            Address_Label__c = 'Warehouse Facility',
            Street__c = '2000 Industrial Park Drive',
            City__c = acc.BillingCity,
            State__c = acc.BillingState,
            Postal_Code__c = acc.BillingPostalCode,
            Country__c = acc.BillingCountry
        ));
    }
}

insert shippingAddresses;
System.debug('Inserted ' + shippingAddresses.size() + ' shipping addresses');

// ========================================
// 7. CREATE CARTS WITH ITEMS (25 active carts)
// ========================================
List<Cart__c> carts = new List<Cart__c>();

for(Integer i = 0; i < 25; i++) {
    carts.add(new Cart__c(
        Contact__c = contacts[i*2].Id, // Use primary contacts
        Status__c = 'Active'
    ));
}

insert carts;
System.debug('Inserted ' + carts.size() + ' carts');

// Add items to carts
List<Cart_Item__c> cartItems = new List<Cart_Item__c>();
Integer itemCounter = 0;

for(Cart__c cart : carts) {
    // Add 2-5 random items to each cart
    Integer numItems = 2 + Math.mod(itemCounter, 4);
    
    for(Integer j = 0; j < numItems; j++) {
        Integer productIndex = Math.mod(itemCounter + j, products.size());
        Integer quantity = 1 + Math.mod(itemCounter + j, 3);
        
        cartItems.add(new Cart_Item__c(
            Cart__c = cart.Id,
            Product__c = products[productIndex].Id,
            Quantity__c = quantity,
            Unit_Price__c = pricebookEntries[productIndex].UnitPrice
        ));
    }
    itemCounter++;
}

insert cartItems;
System.debug('Inserted ' + cartItems.size() + ' cart items');

// ========================================
// 8. CREATE SAMPLE ORDERS (15 completed orders)
// ========================================
List<Order> orders = new List<Order>();

for(Integer i = 0; i < 15; i++) {
    orders.add(new Order(
        AccountId = accounts[i].Id,
        Pricebook2Id = standardPriceBook.Id,
        EffectiveDate = Date.today().addDays(-Math.mod(i, 30)),
        Status = i < 12 ? 'Activated' : 'Draft',
        Description = 'Order #' + (1000 + i) + ' - Standard purchase order'
    ));
}

insert orders;
System.debug('Inserted ' + orders.size() + ' orders');

// Add order items
List<OrderItem> orderItems = new List<OrderItem>();

for(Integer i = 0; i < orders.size(); i++) {
    Order ord = orders[i];
    Integer numItems = 2 + Math.mod(i, 4);
    
    for(Integer j = 0; j < numItems; j++) {
        Integer productIndex = Math.mod(i*3 + j, products.size());
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

// ========================================
// 9. CREATE VIEW TRACKING DATA (200 views)
// ========================================
List<View_Tracking__c> viewTrackings = new List<View_Tracking__c>();

for(Integer i = 0; i < 200; i++) {
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

// ========================================
// 10. CREATE NOTIFICATION REQUESTS (50 requests)
// ========================================
List<Notification_Request__c> notifications = new List<Notification_Request__c>();

for(Integer i = 0; i < 50; i++) {
    Integer contactIndex = Math.mod(i, contacts.size());
    Integer productIndex = Math.mod(i*2, products.size());
    
    notifications.add(new Notification_Request__c(
        User_Contact__c = contacts[contactIndex].Id,
        Product__c = products[productIndex].Id,
        Status__c = i < 40 ? 'Pending' : 'Sent'
    ));
}

insert notifications;
System.debug('Inserted ' + notifications.size() + ' notification requests');

// ========================================
// FINAL SUMMARY REPORT
// ========================================
System.debug('');
System.debug('========================================');
System.debug('COMPREHENSIVE TEST DATA CREATION COMPLETE');
System.debug('========================================');

System.debug('📊 DATA SUMMARY:');
System.debug('✅ Accounts: ' + [SELECT COUNT() FROM Account]);
System.debug('✅ Contacts: ' + [SELECT COUNT() FROM Contact]);
System.debug('✅ Categories: ' + [SELECT COUNT() FROM Category__c]);
System.debug('✅ Products: ' + [SELECT COUNT() FROM Product2]);
System.debug('✅ Price Book Entries: ' + [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :standardPriceBook.Id]);
System.debug('✅ Shipping Addresses: ' + [SELECT COUNT() FROM Shipping_Address__c]);
System.debug('✅ Active Carts: ' + [SELECT COUNT() FROM Cart__c WHERE Status__c = \'Active\']);
System.debug('✅ Cart Items: ' + [SELECT COUNT() FROM Cart_Item__c]);
System.debug('✅ Orders: ' + [SELECT COUNT() FROM Order]);
System.debug('✅ Order Items: ' + [SELECT COUNT() FROM OrderItem]);
System.debug('✅ View Tracking: ' + [SELECT COUNT() FROM View_Tracking__c]);
System.debug('✅ Notification Requests: ' + [SELECT COUNT() FROM Notification_Request__c]);

System.debug('');
System.debug('🎯 TOP SELLING PRODUCTS:');
for(Product2 prod : [SELECT Name, ProductCode, Stock_Quantity__c FROM Product2 WHERE Is_Top_Seller__c = true ORDER BY Name LIMIT 10]) {
    System.debug('⭐ ' + prod.Name + ' (' + prod.ProductCode + ') - Stock: ' + prod.Stock_Quantity__c);
}

System.debug('');
System.debug('💰 SAMPLE PRICING:');
for(PricebookEntry pbe : [SELECT Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :standardPriceBook.Id ORDER BY UnitPrice DESC LIMIT 10]) {
    System.debug('💵 ' + pbe.Product2.Name + ' - $' + pbe.UnitPrice);
}

System.debug('');
System.debug('🎉 TEST DATA GENERATION SUCCESSFUL!');
System.debug('Ready for comprehensive testing of ENOS application.');
