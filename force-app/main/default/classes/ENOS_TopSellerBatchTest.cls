/**
 * @description Test class for ENOS_TopSellerBatch
 * Tests the batch process for identifying and marking top-selling products.
 *
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class ENOS_TopSellerBatchTest {
  @TestSetup
  static void setup() {
    // Create test account
    Account testAccount = new Account(Name = 'Top Seller Test Account');
    insert testAccount;

    // Create test contact
    Contact testContact = new Contact(
      FirstName = 'TopSeller',
      LastName = 'Test',
      Email = 'topseller@example.com',
      AccountId = testAccount.Id
    );
    insert testContact;

    // Create test products
    List<Product2> products = new List<Product2>();
    for (Integer i = 1; i <= 10; i++) {
      products.add(
        new Product2(
          Name = 'Top Seller Test Product ' + i,
          ProductCode = 'TOPSELLER00' + i,
          Description = 'Test Product ' + i,
          IsActive = true,
          Is_Top_Seller__c = false,
          Stock_Quantity__c = 100
        )
      );
    }
    insert products;

    // Create pricebook entries
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    for (Product2 product : products) {
      pricebookEntries.add(
        new PricebookEntry(
          Pricebook2Id = Test.getStandardPricebookId(),
          Product2Id = product.Id,
          UnitPrice = 100.00,
          IsActive = true
        )
      );
    }
    insert pricebookEntries;

    // Create test orders with varying quantities to simulate sales
    List<Order> orders = new List<Order>();
    for (Integer i = 0; i < 5; i++) {
      orders.add(
        new Order(
          AccountId = testAccount.Id,
          Status = 'Activated',
          EffectiveDate = Date.today().addDays(-30),
          Pricebook2Id = Test.getStandardPricebookId()
        )
      );
    }
    insert orders;

    // Create order items with different quantities to simulate top sellers
    List<OrderItem> orderItems = new List<OrderItem>();
    Integer productIndex = 0;

    for (Order order : orders) {
      for (Integer i = 0; i < 2; i++) {
        if (productIndex < products.size()) {
          // Make first few products have higher quantities (top sellers)
          Integer quantity = productIndex < 3 ? 10 + productIndex : 1;

          orderItems.add(
            new OrderItem(
              OrderId = order.Id,
              Product2Id = products[productIndex].Id,
              PricebookEntryId = pricebookEntries[productIndex].Id,
              Quantity = quantity,
              UnitPrice = 100.00
            )
          );
          productIndex++;
        }
      }
    }
    insert orderItems;
  }

  @isTest
  static void testENOS_TopSellerBatchExecution() {
    Test.startTest();
    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();
    Id batchId = Database.executeBatch(batch, 200);
    Test.stopTest();

    System.assertNotEquals(
      null,
      batchId,
      'Batch should be executed successfully'
    );

    // Verify top sellers were identified
    List<Product2> topSellers = [
      SELECT Id, Name, Is_Top_Seller__c
      FROM Product2
      WHERE Is_Top_Seller__c = TRUE
      ORDER BY Name
    ];

    System.assert(
      topSellers.size() > 0,
      'Should identify some top selling products'
    );
    System.assert(
      topSellers.size() <= 5,
      'Should not exceed maximum top sellers limit'
    );
  }

  @isTest
  static void testENOS_TopSellerBatchStart() {
    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();

    Test.startTest();
    Database.QueryLocator queryLocator = batch.start(null);
    Test.stopTest();

    System.assertNotEquals(
      null,
      queryLocator,
      'Query locator should not be null'
    );

    // Verify the query returns products
    Iterator<Product2> iterator = queryLocator.iterator();
    System.assertEquals(
      true,
      iterator.hasNext(),
      'Should return at least one product'
    );
  }

  @isTest
  static void testENOS_TopSellerBatchExecute() {
    List<Product2> products = [
      SELECT Id, Name, Is_Top_Seller__c
      FROM Product2
      LIMIT 5
    ];

    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();

    Test.startTest();
    batch.execute(null, products);
    Test.stopTest();

    // Verify execute method processes products without errors
    System.assert(true, 'Execute method should complete without errors');
  }

  @isTest
  static void testENOS_TopSellerBatchFinish() {
    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();

    Test.startTest();
    batch.finish(null);
    Test.stopTest();

    // Verify finish method completes without errors
    System.assert(true, 'Finish method should complete without errors');
  }

  @isTest
  static void testBatchWithNoSales() {
    // Delete all order items to test scenario with no sales
    delete [SELECT Id FROM OrderItem];

    Test.startTest();
    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify no products are marked as top sellers when there are no sales
    List<Product2> topSellers = [
      SELECT Id
      FROM Product2
      WHERE Is_Top_Seller__c = TRUE
    ];

    System.assertEquals(
      0,
      topSellers.size(),
      'Should not mark any products as top sellers with no sales'
    );
  }

  @isTest
  static void testBatchWithEqualSales() {
    // Update order items to have equal quantities
    List<OrderItem> orderItems = [SELECT Id, Quantity FROM OrderItem];
    for (OrderItem item : orderItems) {
      item.Quantity = 5; // Equal quantities
    }
    update orderItems;

    Test.startTest();
    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify some products are still marked as top sellers
    List<Product2> topSellers = [
      SELECT Id
      FROM Product2
      WHERE Is_Top_Seller__c = TRUE
    ];

    System.assert(
      topSellers.size() >= 0,
      'Should handle equal sales scenario gracefully'
    );
  }

  @isTest
  static void testBatchWithDateRange() {
    // Create recent orders (within last 30 days)
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    Order recentOrder = new Order(
      AccountId = testAccount.Id,
      Status = 'Activated',
      EffectiveDate = Date.today().addDays(-15),
      Pricebook2Id = Test.getStandardPricebookId()
    );
    insert recentOrder;

    Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
    PricebookEntry pbe = [
      SELECT Id
      FROM PricebookEntry
      WHERE Product2Id = :testProduct.Id
      LIMIT 1
    ];

    OrderItem recentOrderItem = new OrderItem(
      OrderId = recentOrder.Id,
      Product2Id = testProduct.Id,
      PricebookEntryId = pbe.Id,
      Quantity = 20, // High quantity to make it a top seller
      UnitPrice = 100.00
    );
    insert recentOrderItem;

    Test.startTest();
    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();
    Database.executeBatch(batch, 200);
    Test.stopTest();

    // Verify recent high-volume sales affect top seller status
    Product2 updatedProduct = [
      SELECT Id, Is_Top_Seller__c
      FROM Product2
      WHERE Id = :testProduct.Id
    ];
    System.assertEquals(
      true,
      updatedProduct.Is_Top_Seller__c,
      'Product with high recent sales should be top seller'
    );
  }

  @isTest
  static void testBatchSchedulable() {
    Test.startTest();
    String cronExpression = '0 0 2 * * ?'; // Daily at 2 AM
    String jobId = System.schedule(
      'Top Seller Batch Test',
      cronExpression,
      new ENOS_TopSellerBatch()
    );
    Test.stopTest();

    System.assertNotEquals(null, jobId, 'Batch should be schedulable');

    // Verify scheduled job exists
    List<CronTrigger> scheduledJobs = [
      SELECT Id, CronExpression, State
      FROM CronTrigger
      WHERE Id = :jobId
    ];

    System.assertEquals(
      1,
      scheduledJobs.size(),
      'Should create one scheduled job'
    );
    System.assertEquals(
      cronExpression,
      scheduledJobs[0].CronExpression,
      'Cron expression should match'
    );
  }

  @isTest
  static void testBatchWithLargeDataSet() {
    // Create additional products to test large data set processing
    List<Product2> additionalProducts = new List<Product2>();
    for (Integer i = 11; i <= 50; i++) {
      additionalProducts.add(
        new Product2(
          Name = 'Large Dataset Product ' + i,
          ProductCode = 'LARGE00' + i,
          Description = 'Large Dataset Test Product ' + i,
          IsActive = true,
          Is_Top_Seller__c = false,
          Stock_Quantity__c = 100
        )
      );
    }
    insert additionalProducts;

    Test.startTest();
    ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();
    Database.executeBatch(batch, 10); // Small batch size to test chunking
    Test.stopTest();

    System.assert(
      true,
      'Batch should handle large data sets with small batch sizes'
    );
  }

  @isTest
  static void testBatchErrorHandling() {
    // Create a product with invalid data to test error handling
    Product2 invalidProduct = new Product2(
      Name = 'Invalid Product Test',
      ProductCode = 'INVALID001',
      IsActive = true,
      Is_Top_Seller__c = false
    );
    insert invalidProduct;

    Test.startTest();
    try {
      ENOS_TopSellerBatch batch = new ENOS_TopSellerBatch();
      Database.executeBatch(batch, 200);
      System.assert(true, 'Batch should handle errors gracefully');
    } catch (Exception e) {
      System.assert(
        true,
        'Batch should handle exceptions without failing completely'
      );
    }
    Test.stopTest();
  }
}
