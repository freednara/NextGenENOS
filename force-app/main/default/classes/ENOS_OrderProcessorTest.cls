/**
 * @description Unit tests for ENOS_OrderProcessor.
 */
@isTest
private class ENOS_OrderProcessorTest {
  @TestSetup
  static void setupData() {
    // Create account & contact
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    Contact con = new Contact(
      FirstName = 'Test',
      LastName = 'Buyer',
      AccountId = acc.Id
    );
    insert con;

    // Products and price book entries
    Id pbId = Test.getStandardPricebookId();
    Product2 p1 = new Product2(
      Name = 'Product1',
      ProductCode = 'P1',
      IsActive = true,
      Stock_Quantity__c = 5
    );
    insert p1;
    insert new PricebookEntry(
      Pricebook2Id = pbId,
      Product2Id = p1.Id,
      UnitPrice = 10,
      IsActive = true
    );

    // Cart with item
    Cart__c cart = new Cart__c(
      Contact__c = con.Id,
      Status__c = 'Active',
      Subtotal__c = 10,
      Total_Items__c = 1
    );
    insert cart;
    insert new Cart_Item__c(
      Cart__c = cart.Id,
      Product__c = p1.Id,
      Quantity__c = 1,
      Unit_Price__c = 10,
      Line_Total__c = 10
    );

    // Shipping address
    insert new Shipping_Address__c(
      Account__c = acc.Id,
      Street__c = '123 Main',
      City__c = 'City',
      State__c = 'CA',
      Postal_Code__c = '12345',
      Country__c = 'US'
    );

    // Create test user and grant permissions
    User u = ENOSTestUtils.createENOSUser(con.Id);
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'ENOS_Admin_Access'
      LIMIT 1
    ];
    insert new PermissionSetAssignment(
      AssigneeId = u.Id,
      PermissionSetId = ps.Id
    );
  }

  @isTest
  static void testCheckoutAndOrderFlows() {
    Cart__c cart = [SELECT Id FROM Cart__c LIMIT 1];
    Shipping_Address__c addr = [
      SELECT Id, Account__c
      FROM Shipping_Address__c
      LIMIT 1
    ];
    User u = [SELECT Id FROM User WHERE Email = 'storeuser@test.com' LIMIT 1];

    System.runAs(u) {
      Test.startTest();
      ENOS_OrderProcessor.OrderResult res = ENOS_OrderProcessor.processCheckout(
        cart.Id,
        addr.Id,
        'card'
      );
      Test.stopTest();

      System.assertNotEquals(null, res.orderId, 'Order Id should be returned');

      // Verify order details retrieval
      ENOS_OrderProcessor.OrderDetails details = ENOS_OrderProcessor.getOrderDetails(
        res.orderId
      );
      System.assertEquals(res.orderId, details.order.Id);

      // History
      List<Order> history = ENOS_OrderProcessor.getOrderHistory(
        addr.Account__c
      );
      System.assertEquals(1, history.size());

      // Cancel order
      Order ord = [SELECT Id, Status FROM Order WHERE Id = :res.orderId];
      ord.Status = 'Activated';
      update ord;
      ENOS_OrderProcessor.cancelOrder(res.orderId);
      System.assertEquals(
        'Cancelled',
        [SELECT Status FROM Order WHERE Id = :res.orderId].Status
      );
    }
  }
}
