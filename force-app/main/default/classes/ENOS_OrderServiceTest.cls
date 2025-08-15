@IsTest
private class ENOS_OrderServiceTest {
  class PayGovOrderMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'text/xml');
      String body =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pay="http://www.pay.gov/paygov">' +
        '<soap:Body>' +
        '<pay:InitiatePaymentResponse>' +
        '<pay:TransactionId>PAYGOV_TEST_1</pay:TransactionId>' +
        '<pay:RedirectUrl>https://pay.gov/redirect</pay:RedirectUrl>' +
        '<pay:Status>INITIATED</pay:Status>' +
        '</pay:InitiatePaymentResponse>' +
        '</soap:Body>' +
        '</soap:Envelope>';
      res.setBody(body);
      return res;
    }
  }

  @TestSetup
  static void setupData() {
    // Account and Contact
    Account acc = new Account(Name = 'Gov Account');
    insert acc;
    Contact con = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john.doe@example.com',
      AccountId = acc.Id
    );
    insert con;

    // User
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User u = new User(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john.doe@example.com',
      Username = 'john.doe@example.com.test',
      Alias = 'jdoe',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/New_York',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ContactId = con.Id
    );
    insert u;

    // Shipping address
    Shipping_Address__c addr = new Shipping_Address__c(
      Account__c = acc.Id,
      Street__c = '1 Main',
      City__c = 'City',
      State__c = 'CA',
      Postal_Code__c = '90001',
      Country__c = 'USA'
    );
    insert addr;

    // Product and pricebook
    Product2 prod = new Product2(
      Name = 'Widget',
      ProductCode = 'W1',
      IsActive = true
    );
    insert prod;
    Id stdPb = Test.getStandardPricebookId();
    PricebookEntry pbe = new PricebookEntry(
      Product2Id = prod.Id,
      Pricebook2Id = stdPb,
      UnitPrice = 10,
      IsActive = true
    );
    insert pbe;

    // Cart with item
    Cart__c cart1 = new Cart__c(Contact__c = con.Id, Status__c = 'Active');
    insert cart1;
    Cart_Item__c item1 = new Cart_Item__c(
      Cart__c = cart1.Id,
      Product__c = prod.Id,
      Quantity__c = 1,
      Unit_Price__c = 10,
      Line_Total__c = 10
    );
    insert item1;

    // Second cart for bulk test
    Cart__c cart2 = new Cart__c(Contact__c = con.Id, Status__c = 'Active');
    insert cart2;
    Cart_Item__c item2 = new Cart_Item__c(
      Cart__c = cart2.Id,
      Product__c = prod.Id,
      Quantity__c = 2,
      Unit_Price__c = 10,
      Line_Total__c = 20
    );
    insert item2;
  }

  @IsTest
  static void testCreateOrderSuccessBulkAndHistory() {
    User u = [
      SELECT Id
      FROM User
      WHERE Username = 'john.doe@example.com.test'
      LIMIT 1
    ];
    Shipping_Address__c addr = [SELECT Id FROM Shipping_Address__c LIMIT 1];
    List<Cart__c> carts = [SELECT Id FROM Cart__c ORDER BY CreatedDate];

    ENOS_OrderService.CreateOrderRequest req1 = new ENOS_OrderService.CreateOrderRequest();
    req1.cartId = carts[0].Id;
    req1.shippingAddressId = addr.Id;
    req1.paymentToken = 'TOKEN-1';

    ENOS_OrderService.CreateOrderRequest req2 = new ENOS_OrderService.CreateOrderRequest();
    req2.cartId = carts[1].Id;
    req2.shippingAddressId = addr.Id;
    req2.paymentToken = 'TOKEN-2';

    Test.setMock(HttpCalloutMock.class, new PayGovOrderMock());
    List<ENOS_OrderService.CreateOrderResponse> responses;
    System.runAs(u) {
      Test.startTest();
      responses = ENOS_OrderService.createOrder(
        new List<ENOS_OrderService.CreateOrderRequest>{ req1, req2 }
      );
      Test.stopTest();
    }
    System.assertEquals(2, responses.size(), 'Two responses expected');
    for (ENOS_OrderService.CreateOrderResponse r : responses) {
      System.assert(r.isSuccess, 'Order should succeed');
      System.assertNotEquals(null, r.orderId, 'Order id expected');
    }

    // verify orders persisted and cart deleted
    System.assertEquals(2, [SELECT COUNT() FROM Order]);
    System.assertEquals(
      0,
      [
        SELECT COUNT()
        FROM Cart__c
        WHERE Id IN :new List<Id>{ carts[0].Id, carts[1].Id }
      ]
    );

    // order history retrieval
    System.runAs(u) {
      List<Order> orders = ENOS_OrderService.getOrders();
      System.assertEquals(
        2,
        orders.size(),
        'Order history should return two orders'
      );
    }
  }

  @IsTest
  static void testCreateOrderMissingPaymentToken() {
    User u = [
      SELECT Id
      FROM User
      WHERE Username = 'john.doe@example.com.test'
      LIMIT 1
    ];
    Shipping_Address__c addr = [SELECT Id FROM Shipping_Address__c LIMIT 1];
    Cart__c cart = [SELECT Id FROM Cart__c LIMIT 1];

    ENOS_OrderService.CreateOrderRequest req = new ENOS_OrderService.CreateOrderRequest();
    req.cartId = cart.Id;
    req.shippingAddressId = addr.Id;
    req.paymentToken = null; // missing token

    Test.setMock(HttpCalloutMock.class, new PayGovOrderMock());
    List<ENOS_OrderService.CreateOrderResponse> responses;
    System.runAs(u) {
      responses = ENOS_OrderService.createOrder(
        new List<ENOS_OrderService.CreateOrderRequest>{ req }
      );
    }
    System.assertEquals(1, responses.size());
    System.assertEquals(false, responses[0].isSuccess);
    System.assert(
      responses[0].message.contains('Payment Token'),
      'Error should mention payment token'
    );
  }

  @IsTest
  static void testCreateOrderNoItems() {
    // create cart without items
    User u = [
      SELECT Id
      FROM User
      WHERE Username = 'john.doe@example.com.test'
      LIMIT 1
    ];
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Contact con = [SELECT Id FROM Contact LIMIT 1];
    Cart__c emptyCart = new Cart__c(Contact__c = con.Id, Status__c = 'Active');
    insert emptyCart;
    Shipping_Address__c addr = [SELECT Id FROM Shipping_Address__c LIMIT 1];

    ENOS_OrderService.CreateOrderRequest req = new ENOS_OrderService.CreateOrderRequest();
    req.cartId = emptyCart.Id;
    req.shippingAddressId = addr.Id;
    req.paymentToken = 'TOKEN-3';

    Test.setMock(HttpCalloutMock.class, new PayGovOrderMock());
    List<ENOS_OrderService.CreateOrderResponse> responses;
    System.runAs(u) {
      responses = ENOS_OrderService.createOrder(
        new List<ENOS_OrderService.CreateOrderRequest>{ req }
      );
    }
    System.assertEquals(1, responses.size());
    System.assertEquals(false, responses[0].isSuccess);
    System.assert(
      responses[0].message.contains('Cart must contain at least one item')
    );
  }
}
