// Insert Additional Sample Data for StoreConnect
// This script adds missing data without creating duplicates
// Run this in Developer Console or via SF CLI

// Check existing data and add only what's missing
System.debug('=== CHECKING EXISTING DATA ===');

// Check existing accounts
List<Account> existingAccounts = [SELECT Name FROM Account];
Set<String> existingAccountNames = new Set<String>();
for(Account acc : existingAccounts) {
    existingAccountNames.add(acc.Name);
}
System.debug('Existing accounts: ' + existingAccountNames);

// Check existing products
List<Product2> existingProducts = [SELECT Name FROM Product2];
Set<String> existingProductNames = new Set<String>();
for(Product2 prod : existingProducts) {
    existingProductNames.add(prod.Name);
}
System.debug('Existing products: ' + existingProductNames);

// Define all the data we want
Map<String, Map<String, Object>> desiredAccounts = new Map<String, Map<String, Object>>{
    'Global Tech Solutions' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Technology',
        'BillingStreet' => '789 Innovation Drive',
        'BillingCity' => 'Austin',
        'BillingState' => 'TX',
        'BillingPostalCode' => '73301',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 456-7890'
    },
    'Premium Electronics Co' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Electronics',
        'BillingStreet' => '321 Tech Boulevard',
        'BillingCity' => 'Seattle',
        'BillingState' => 'WA',
        'BillingPostalCode' => '98101',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 234-5678'
    },
    'Smart Home Innovations' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Technology',
        'BillingStreet' => '654 Smart Street',
        'BillingCity' => 'Denver',
        'BillingState' => 'CO',
        'BillingPostalCode' => '80201',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 345-6789'
    },
    'Digital Marketing Agency' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Marketing',
        'BillingStreet' => '987 Digital Lane',
        'BillingCity' => 'Miami',
        'BillingState' => 'FL',
        'BillingPostalCode' => '33101',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 567-8901'
    },
    'Healthcare Systems Inc' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Healthcare',
        'BillingStreet' => '147 Health Plaza',
        'BillingCity' => 'Boston',
        'BillingState' => 'MA',
        'BillingPostalCode' => '02101',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 678-9012'
    },
    'Financial Services Group' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Financial Services',
        'BillingStreet' => '258 Finance Way',
        'BillingCity' => 'New York',
        'BillingState' => 'NY',
        'BillingPostalCode' => '10001',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 789-0123'
    },
    'Educational Institute' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Education',
        'BillingStreet' => '369 Learning Circle',
        'BillingCity' => 'Chicago',
        'BillingState' => 'IL',
        'BillingPostalCode' => '60601',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 890-1234'
    },
    'Manufacturing Solutions' => new Map<String, Object>{
        'Type' => 'Customer',
        'Industry' => 'Manufacturing',
        'BillingStreet' => '741 Factory Road',
        'BillingCity' => 'Detroit',
        'BillingState' => 'MI',
        'BillingPostalCode' => '48201',
        'BillingCountry' => 'USA',
        'Phone' => '(555) 901-2345'
    }
};

Map<String, Map<String, Object>> desiredProducts = new Map<String, Map<String, Object>>{
    '4K Action Camera' => new Map<String, Object>{
        'ProductCode' => 'AC-005',
        'Description' => 'Ultra HD action camera with image stabilization and waterproof case. Perfect for sports, travel, and adventure photography.'
    },
    'Smart Home Hub' => new Map<String, Object>{
        'ProductCode' => 'SH-006',
        'Description' => 'Central control hub for smart home devices. Compatible with Alexa, Google Home, and Apple HomeKit.'
    },
    'Gaming Mechanical Keyboard' => new Map<String, Object>{
        'ProductCode' => 'KB-007',
        'Description' => 'RGB mechanical gaming keyboard with customizable switches and macro keys. Designed for competitive gaming.'
    },
    'Wireless Gaming Mouse' => new Map<String, Object>{
        'ProductCode' => 'GM-008',
        'Description' => 'High-precision wireless gaming mouse with adjustable DPI and programmable buttons. Ultra-low latency for competitive play.'
    },
    'Portable Power Bank' => new Map<String, Object>{
        'ProductCode' => 'PB-009',
        'Description' => '20,000mAh portable charger with fast charging and multiple USB ports. Compact design for travel and daily use.'
    },
    'Smart LED Light Bulbs' => new Map<String, Object>{
        'ProductCode' => 'LB-010',
        'Description' => 'WiFi-enabled smart LED bulbs with 16 million colors and voice control. Compatible with all major smart home platforms.'
    }
};

// Create missing accounts
List<Account> newAccounts = new List<Account>();
for(String accountName : desiredAccounts.keySet()) {
    if(!existingAccountNames.contains(accountName)) {
        Map<String, Object> accountData = desiredAccounts.get(accountName);
        Account newAcc = new Account(
            Name = accountName,
            Type = (String)accountData.get('Type'),
            Industry = (String)accountData.get('Industry'),
            BillingStreet = (String)accountData.get('BillingStreet'),
            BillingCity = (String)accountData.get('BillingCity'),
            BillingState = (String)accountData.get('BillingState'),
            BillingPostalCode = (String)accountData.get('BillingPostalCode'),
            BillingCountry = (String)accountData.get('BillingCountry'),
            Phone = (String)accountData.get('Phone')
        );
        newAccounts.add(newAcc);
    }
}

if(!newAccounts.isEmpty()) {
    insert newAccounts;
    System.debug('New accounts inserted: ' + newAccounts.size());
} else {
    System.debug('No new accounts needed');
}

// Create missing products
List<Product2> newProducts = new List<Product2>();
for(String productName : desiredProducts.keySet()) {
    if(!existingProductNames.contains(productName)) {
        Map<String, Object> productData = desiredProducts.get(productName);
        Product2 newProd = new Product2(
            Name = productName,
            ProductCode = (String)productData.get('ProductCode'),
            Description = (String)productData.get('Description'),
            IsActive = true
        );
        newProducts.add(newProd);
    }
}

if(!newProducts.isEmpty()) {
    insert newProducts;
    System.debug('New products inserted: ' + newProducts.size());
} else {
    System.debug('No new products needed');
}

// Get all accounts for contact creation
Map<String, Id> accountNameToId = new Map<String, Id>();
for(Account acc : [SELECT Id, Name FROM Account]) {
    accountNameToId.put(acc.Name, acc.Id);
}

// Create contacts for new accounts
List<Contact> newContacts = new List<Contact>();
Map<String, String> contactData = new Map<String, String>{
    'Global Tech Solutions' => 'Michael|Tech|michael.tech@globaltech.com|(555) 456-7890|IT Director',
    'Premium Electronics Co' => 'Sarah|Electronics|sarah.electronics@premium.com|(555) 234-5678|Purchasing Manager',
    'Smart Home Innovations' => 'David|Smart|david.smart@smarthome.com|(555) 345-6789|Operations Manager',
    'Digital Marketing Agency' => 'Lisa|Digital|lisa.digital@marketing.com|(555) 567-8901|Marketing Director',
    'Healthcare Systems Inc' => 'Robert|Health|robert.health@healthcare.com|(555) 678-9012|IT Manager',
    'Financial Services Group' => 'Amanda|Finance|amanda.finance@financial.com|(555) 789-0123|Procurement Specialist',
    'Educational Institute' => 'Christopher|Education|christopher.education@edu.com|(555) 890-1234|Technology Coordinator',
    'Manufacturing Solutions' => 'Jennifer|Manufacturing|jennifer.manufacturing@mfg.com|(555) 901-2345|Supply Chain Manager'
};

for(String accountName : contactData.keySet()) {
    if(accountNameToId.containsKey(accountName)) {
        String[] contactInfo = contactData.get(accountName).split('\\|');
        Contact newCon = new Contact(
            FirstName = contactInfo[0],
            LastName = contactInfo[1],
            Email = contactInfo[2],
            Phone = contactInfo[3],
            Title = contactInfo[4],
            AccountId = accountNameToId.get(accountName)
        );
        newContacts.add(newCon);
    }
}

if(!newContacts.isEmpty()) {
    insert newContacts;
    System.debug('New contacts inserted: ' + newContacts.size());
} else {
    System.debug('No new contacts needed');
}

// Get all products for price book entry creation
Map<String, Id> productNameToId = new Map<String, Id>();
for(Product2 prod : [SELECT Id, Name FROM Product2]) {
    productNameToId.put(prod.Name, prod.Id);
}

// Get Standard Price Book ID
Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

// Create price book entries for new products
List<PricebookEntry> newPricebookEntries = new List<PricebookEntry>();
Map<String, Decimal> productPrices = new Map<String, Decimal>{
    '4K Action Camera' => 399.99,
    'Smart Home Hub' => 149.99,
    'Gaming Mechanical Keyboard' => 179.99,
    'Wireless Gaming Mouse' => 129.99,
    'Portable Power Bank' => 79.99,
    'Smart LED Light Bulbs' => 34.99
};

for(String productName : productPrices.keySet()) {
    if(productNameToId.containsKey(productName)) {
        PricebookEntry newPbe = new PricebookEntry(
            Product2Id = productNameToId.get(productName),
            Pricebook2Id = standardPriceBook.Id,
            UnitPrice = productPrices.get(productName),
            IsActive = true
        );
        newPricebookEntries.add(newPbe);
    }
}

if(!newPricebookEntries.isEmpty()) {
    insert newPricebookEntries;
    System.debug('New price book entries inserted: ' + newPricebookEntries.size());
} else {
    System.debug('No new price book entries needed');
}

// Final summary
System.debug('=== ADDITIONAL SAMPLE DATA INSERTION COMPLETE ===');
System.debug('Total Accounts: ' + [SELECT Id FROM Account].size());
System.debug('Total Contacts: ' + [SELECT Id FROM Contact].size());
System.debug('Total Products: ' + [SELECT Id FROM Product2].size());
System.debug('Total Price Book Entries: ' + [SELECT Id FROM PricebookEntry].size());

// Display all products for verification
System.debug('=== ALL PRODUCTS ===');
for(Product2 prod : [SELECT Id, Name, ProductCode FROM Product2 ORDER BY Name]) {
    System.debug(prod.Name + ' (' + prod.ProductCode + ')');
}
