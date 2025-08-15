// Script to insert sample data for ENOS project
// Creates products with pricing, a test contact, shipping address,
// cart with items, and optional order, quote, and view tracking records.

// Query Standard Price Book
Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

// Create sample products
List<Product2> products = new List<Product2>{
    new Product2(
        Name = 'Sample Product 1',
        ProductCode = 'SP1',
        IsActive = true,
        Family = 'Sample',
        Image_URL__c = 'https://via.placeholder.com/150',
        Stock_Quantity__c = 100,
        Is_Top_Seller__c = true
    ),
    new Product2(
        Name = 'Sample Product 2',
        ProductCode = 'SP2',
        IsActive = true,
        Family = 'Sample',
        Image_URL__c = 'https://via.placeholder.com/150',
        Stock_Quantity__c = 200,
        Is_Top_Seller__c = false
    )
};
insert products;

// Add pricing via Pricebook Entries
List<PricebookEntry> pbes = new List<PricebookEntry>();
List<Decimal> prices = new List<Decimal>{19.99, 29.99};
for (Integer i = 0; i < products.size(); i++) {
    pbes.add(new PricebookEntry(
        Pricebook2Id = standardPB.Id,
        Product2Id = products[i].Id,
        UnitPrice = prices[i],
        IsActive = true
    ));
}
insert pbes;

// Create Account and Contact
Account acc = new Account(Name = 'Sample Account');
insert acc;

Contact con = new Contact(
    FirstName = 'Test',
    LastName = 'User',
    Email = 'test.user@example.com',
    AccountId = acc.Id
);
insert con;

// Create Shipping Address
Shipping_Address__c ship = new Shipping_Address__c(
    Account__c = acc.Id,
    Address_Label__c = 'Home',
    Street__c = '123 Sample St',
    City__c = 'Sample City',
    State__c = 'CA',
    Postal_Code__c = '12345',
    Country__c = 'USA',
    Is_Default__c = true
);
insert ship;

// Create Cart
Cart__c cart = new Cart__c(
    Contact__c = con.Id,
    Status__c = 'Open'
);
insert cart;

// Create Cart Items and compute totals
List<Cart_Item__c> items = new List<Cart_Item__c>();
Decimal subtotal = 0;
Integer totalItems = 0;
for (Integer i = 0; i < products.size(); i++) {
    Decimal unitPrice = prices[i];
    Integer quantity = 1;
    items.add(new Cart_Item__c(
        Cart__c = cart.Id,
        Product__c = products[i].Id,
        Quantity__c = quantity,
        Unit_Price__c = unitPrice,
        Line_Total__c = unitPrice * quantity
    ));
    subtotal += unitPrice * quantity;
    totalItems += quantity;
}
insert items;

cart.Subtotal__c = subtotal;
cart.Total_Items__c = totalItems;
update cart;

// Optional Order with Order Item
Order ord = new Order(
    Name = 'Sample Order',
    AccountId = acc.Id,
    Pricebook2Id = standardPB.Id,
    EffectiveDate = Date.today(),
    Status = 'Draft'
);
insert ord;

OrderItem oi = new OrderItem(
    OrderId = ord.Id,
    PricebookEntryId = pbes[0].Id,
    Quantity = 1,
    UnitPrice = pbes[0].UnitPrice
);
insert oi;

// Optional Opportunity and Quote with Quote Line Item
Opportunity opp = new Opportunity(
    Name = 'Sample Opportunity',
    AccountId = acc.Id,
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(30)
);
insert opp;

Quote quote = new Quote(
    Name = 'Sample Quote',
    OpportunityId = opp.Id,
    Pricebook2Id = standardPB.Id
);
insert quote;

QuoteLineItem qli = new QuoteLineItem(
    QuoteId = quote.Id,
    PricebookEntryId = pbes[1].Id,
    Quantity = 1,
    UnitPrice = pbes[1].UnitPrice
);
insert qli;

// Optional View Tracking record
View_Tracking__c vt = new View_Tracking__c(
    Product__c = products[0].Id,
    User_Contact__c = con.Id,
    Last_Viewed_Date__c = Date.today()
);
insert vt;

System.debug('Sample data loaded successfully.');

