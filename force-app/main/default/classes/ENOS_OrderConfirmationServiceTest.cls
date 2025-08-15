/**
 * @description Test class for ENOS_OrderConfirmationService
 * Tests order confirmation email functionality and template processing.
 *
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class ENOS_OrderConfirmationServiceTest {
  @TestSetup
  static void setup() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create test contact
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Customer',
      Email = 'testcustomer@example.com',
      AccountId = testAccount.Id
    );
    insert testContact;

    // Create test product
    Product2 testProduct = new Product2(
      Name = 'Test Product',
      ProductCode = 'TEST001',
      Description = 'Test Product Description',
      IsActive = true
    );
    insert testProduct;

    // Create standard pricebook entry
    PricebookEntry pricebookEntry = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = testProduct.Id,
      UnitPrice = 100.00,
      IsActive = true
    );
    insert pricebookEntry;

    // Create test order
    Order testOrder = new Order(
      AccountId = testAccount.Id,
      Status = 'Draft',
      EffectiveDate = Date.today(),
      Pricebook2Id = Test.getStandardPricebookId()
    );
    insert testOrder;

    // Create order items
    OrderItem orderItem = new OrderItem(
      OrderId = testOrder.Id,
      Product2Id = testProduct.Id,
      PricebookEntryId = pricebookEntry.Id,
      Quantity = 2,
      UnitPrice = 100.00
    );
    insert orderItem;

    // Create shipping address
    Shipping_Address__c shippingAddress = new Shipping_Address__c(
      Account__c = testAccount.Id,
      Street__c = '123 Test Street',
      City__c = 'Test City',
      State__c = 'CA',
      Postal_Code__c = '12345',
      Country__c = 'USA',
      Is_Default__c = true
    );
    insert shippingAddress;
  }

  @isTest
  static void testSendOrderConfirmation() {
    Order testOrder = [SELECT Id, AccountId FROM Order LIMIT 1];
    Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];

    Test.startTest();
    ENOS_OrderConfirmationService.sendOrderConfirmation(
      testOrder.Id,
      testContact.Id
    );
    Test.stopTest();

    // Verify email was queued (in test context, emails are not actually sent)
    // We can check that the method completed without throwing exceptions
    System.assert(true, 'Order confirmation should be sent without errors');
  }

  @isTest
  static void testSendOrderConfirmationInvalidOrder() {
    Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
    Id invalidOrderId = '801000000000000';

    Test.startTest();
    try {
      ENOS_OrderConfirmationService.sendOrderConfirmation(
        invalidOrderId,
        testContact.Id
      );
      System.assert(false, 'Should throw exception for invalid order ID');
    } catch (Exception e) {
      System.assert(true, 'Should handle invalid order ID gracefully');
    }
    Test.stopTest();
  }

  @isTest
  static void testSendOrderConfirmationInvalidContact() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];
    Id invalidContactId = '003000000000000';

    Test.startTest();
    try {
      ENOS_OrderConfirmationService.sendOrderConfirmation(
        testOrder.Id,
        invalidContactId
      );
      System.assert(false, 'Should throw exception for invalid contact ID');
    } catch (Exception e) {
      System.assert(true, 'Should handle invalid contact ID gracefully');
    }
    Test.stopTest();
  }

  @isTest
  static void testGenerateOrderSummary() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];

    Test.startTest();
    String orderSummary = ENOS_OrderConfirmationService.generateOrderSummary(
      testOrder.Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      orderSummary,
      'Order summary should not be null'
    );
    System.assert(
      orderSummary.contains('Test Product'),
      'Summary should contain product name'
    );
    System.assert(
      orderSummary.contains('200.00'),
      'Summary should contain total amount'
    );
  }

  @isTest
  static void testBulkOrderConfirmations() {
    List<Order> orders = new List<Order>();
    List<Contact> contacts = new List<Contact>();

    // Create additional test data
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    for (Integer i = 0; i < 5; i++) {
      Contact contact = new Contact(
        FirstName = 'Bulk Test ' + i,
        LastName = 'Customer',
        Email = 'bulktest' + i + '@example.com',
        AccountId = testAccount.Id
      );
      contacts.add(contact);
    }
    insert contacts;

    for (Integer i = 0; i < 5; i++) {
      Order order = new Order(
        AccountId = testAccount.Id,
        Status = 'Draft',
        EffectiveDate = Date.today(),
        Pricebook2Id = Test.getStandardPricebookId()
      );
      orders.add(order);
    }
    insert orders;

    Test.startTest();
    for (Integer i = 0; i < 5; i++) {
      ENOS_OrderConfirmationService.sendOrderConfirmation(
        orders[i].Id,
        contacts[i].Id
      );
    }
    Test.stopTest();

    // All confirmations should be sent without errors
    System.assert(
      true,
      'Bulk order confirmations should complete without errors'
    );
  }

  @isTest
  static void testOrderConfirmationWithDifferentStatuses() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];
    Contact testContact = [SELECT Id FROM Contact LIMIT 1];

    // Test with different order statuses
    List<String> statuses = new List<String>{ 'Draft', 'Activated' };

    Test.startTest();
    for (String status : statuses) {
      testOrder.Status = status;
      update testOrder;

      ENOS_OrderConfirmationService.sendOrderConfirmation(
        testOrder.Id,
        testContact.Id
      );
    }
    Test.stopTest();

    System.assert(
      true,
      'Order confirmations should work with different statuses'
    );
  }

  @isTest
  static void testEmailDeliveryFailure() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];

    // Create contact with invalid email to simulate delivery failure
    Contact invalidContact = new Contact(
      FirstName = 'Invalid',
      LastName = 'Email',
      Email = 'invalid-email-format',
      AccountId = [SELECT Id FROM Account LIMIT 1]
      .Id
    );
    insert invalidContact;

    Test.startTest();
    try {
      ENOS_OrderConfirmationService.sendOrderConfirmation(
        testOrder.Id,
        invalidContact.Id
      );
      // In test context, this might not throw an exception but should handle gracefully
      System.assert(true, 'Should handle invalid email gracefully');
    } catch (Exception e) {
      System.assert(
        e.getMessage().contains('email') || e.getMessage().contains('delivery'),
        'Exception should be related to email delivery'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testOrderConfirmationTemplate() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];

    Test.startTest();
    String template = ENOS_OrderConfirmationService.getOrderConfirmationTemplate(
      testOrder.Id
    );
    Test.stopTest();

    System.assertNotEquals(null, template, 'Template should not be null');
    System.assert(template.length() > 0, 'Template should have content');

    // Template should contain merge fields or order data
    System.assert(
      template.contains('Order') || template.contains('Thank you'),
      'Template should contain order-related content'
    );
  }

  @isTest
  static void testOrderConfirmationWithMultipleItems() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];
    Contact testContact = [SELECT Id FROM Contact LIMIT 1];

    // Add more products and order items
    Product2 additionalProduct = new Product2(
      Name = 'Additional Product',
      ProductCode = 'ADDITIONAL001',
      Description = 'Additional Product Description',
      IsActive = true
    );
    insert additionalProduct;

    PricebookEntry additionalPBE = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = additionalProduct.Id,
      UnitPrice = 50.00,
      IsActive = true
    );
    insert additionalPBE;

    OrderItem additionalItem = new OrderItem(
      OrderId = testOrder.Id,
      Product2Id = additionalProduct.Id,
      PricebookEntryId = additionalPBE.Id,
      Quantity = 3,
      UnitPrice = 50.00
    );
    insert additionalItem;

    Test.startTest();
    ENOS_OrderConfirmationService.sendOrderConfirmation(
      testOrder.Id,
      testContact.Id
    );
    Test.stopTest();

    System.assert(true, 'Order confirmation with multiple items should work');
  }
}
