/**
 * @description Test class for ENOS_PayGovService
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@IsTest
private class ENOS_PayGovServiceTest {
  /**
   * @description Test data setup method
   */
  @TestSetup
  static void setupTestData() {
    // Create basic test data without user creation to avoid profile issues
    // Create test products
    List<Product2> products = new List<Product2>{
      new Product2(
        Name = 'Test Product 1',
        ProductCode = 'TEST001',
        Description = 'Test Product Description 1',
        IsActive = true,
        Stock_Quantity__c = 100
      )
    };
    insert products;

    // Create standard pricebook entries
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    Id standardPricebookId = Test.getStandardPricebookId();

    for (Product2 product : products) {
      pricebookEntries.add(
        new PricebookEntry(
          Pricebook2Id = standardPricebookId,
          Product2Id = product.Id,
          UnitPrice = 25.00,
          IsActive = product.IsActive
        )
      );
    }
    insert pricebookEntries;

    // Create test account and contact
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'User',
      AccountId = testAccount.Id,
      Email = 'test@example.com'
    );
    insert testContact;
  }

  /**
   * @description Test successful payment initiation with Pay.gov
   */
  @IsTest
  static void testInitiatePaymentSuccess() {
    // Create payment request
    ENOS_PayGovService.PayGovRequest paymentRequest = new ENOS_PayGovService.PayGovRequest(
      'TEST_AGENCY_123',
      'ORDER-' + System.currentTimeMillis(),
      100.00,
      'jane.smith@agency.gov',
      'TOKEN-ABC'
    );

    paymentRequest.description = 'Test Payment Description';
    paymentRequest.successUrl = 'https://test.gov/success';
    paymentRequest.cancelUrl = 'https://test.gov/cancel';

    Test.startTest();

    // Mock the HTTP response for Pay.gov
    Test.setMock(HttpCalloutMock.class, new PayGovSuccessHttpMock());

    // Test payment initiation
    ENOS_PayGovService.PayGovResponse response = ENOS_PayGovService.initiatePayment(
      paymentRequest
    );

    Test.stopTest();

    // Verify response
    System.assert(response.success, 'Payment initiation should succeed');
    System.assertNotEquals(
      null,
      response.transactionId,
      'Transaction ID should be returned'
    );
    System.assertNotEquals(
      null,
      response.redirectUrl,
      'Redirect URL should be returned'
    );
    System.assertEquals(
      'INITIATED',
      response.status,
      'Status should be INITIATED'
    );
  }

  /**
   * @description Test payment initiation failure with Pay.gov
   */
  @IsTest
  static void testInitiatePaymentFailure() {
    // Create invalid payment request (missing required fields)
    ENOS_PayGovService.PayGovRequest paymentRequest = new ENOS_PayGovService.PayGovRequest(
      null, // Invalid agency ID
      'ORDER-TEST',
      100.00,
      'jane.smith@agency.gov',
      'TOKEN-ABC'
    );

    Test.startTest();

    try {
      ENOS_PayGovService.initiatePayment(paymentRequest);
      System.assert(false, 'Exception should be thrown for invalid request');
    } catch (ENOS_PayGovService.PayGovException e) {
      System.assert(
        e.getMessage().contains('Agency ID'),
        'Exception should mention Agency ID'
      );
    }

    Test.stopTest();
  }

  /**
   * @description Test payment status check
   */
  @IsTest
  static void testCheckPaymentStatus() {
    String testTransactionId = 'PAYGOV_12345';

    Test.startTest();

    // Mock the HTTP response for status check
    Test.setMock(HttpCalloutMock.class, new PayGovStatusHttpMock());

    // Test status check
    ENOS_PayGovService.PayGovStatusResponse response = ENOS_PayGovService.checkPaymentStatus(
      testTransactionId
    );

    Test.stopTest();

    // Verify response
    System.assert(response.success, 'Status check should succeed');
    System.assertEquals(
      testTransactionId,
      response.transactionId,
      'Transaction ID should match'
    );
    System.assertEquals(
      'COMPLETED',
      response.status,
      'Status should be COMPLETED'
    );
    System.assertEquals(100.00, response.amount, 'Amount should match');
  }

  /**
   * @description Test refund processing
   */
  @IsTest
  static void testProcessRefund() {
    // Create refund request
    ENOS_PayGovService.PayGovRefundRequest refundRequest = new ENOS_PayGovService.PayGovRefundRequest(
      'PAYGOV_ORIGINAL_12345',
      50.00,
      'Customer requested refund'
    );

    Test.startTest();

    // Mock the HTTP response for refund
    Test.setMock(HttpCalloutMock.class, new PayGovRefundHttpMock());

    // Test refund processing
    ENOS_PayGovService.PayGovRefundResponse response = ENOS_PayGovService.processRefund(
      refundRequest
    );

    Test.stopTest();

    // Verify response
    System.assert(response.success, 'Refund should succeed');
    System.assertNotEquals(
      null,
      response.refundTransactionId,
      'Refund transaction ID should be returned'
    );
    System.assertEquals(
      'PROCESSED',
      response.status,
      'Refund status should be PROCESSED'
    );
    System.assertEquals(
      50.00,
      response.refundAmount,
      'Refund amount should match'
    );
  }

  /**
   * @description Test payment request validation
   */
  @IsTest
  static void testPaymentRequestValidation() {
    Test.startTest();

    // Test null request
    try {
      ENOS_PayGovService.initiatePayment(null);
      System.assert(false, 'Exception should be thrown for null request');
    } catch (ENOS_PayGovService.PayGovException e) {
      System.assert(
        e.getMessage().contains('cannot be null'),
        'Exception should mention null request'
      );
    }

    // Test invalid amount
    try {
      ENOS_PayGovService.PayGovRequest invalidRequest = new ENOS_PayGovService.PayGovRequest(
        'TEST_AGENCY',
        'ORDER-TEST',
        -10.00, // Invalid negative amount
        'test@agency.gov',
        'TOKEN-ABC'
      );
      ENOS_PayGovService.initiatePayment(invalidRequest);
      System.assert(false, 'Exception should be thrown for negative amount');
    } catch (ENOS_PayGovService.PayGovException e) {
      System.assert(
        e.getMessage().contains('greater than zero'),
        'Exception should mention amount validation'
      );
    }

    // Test amount limit
    try {
      ENOS_PayGovService.PayGovRequest limitRequest = new ENOS_PayGovService.PayGovRequest(
        'TEST_AGENCY',
        'ORDER-TEST',
        1000000.00, // Exceeds limit
        'test@agency.gov',
        'TOKEN-ABC'
      );
      ENOS_PayGovService.initiatePayment(limitRequest);
      System.assert(
        false,
        'Exception should be thrown for amount exceeding limit'
      );
    } catch (ENOS_PayGovService.PayGovException e) {
      System.assert(
        e.getMessage().contains('maximum allowed limit'),
        'Exception should mention limit'
      );
    }

    // Test missing payment token
    try {
      ENOS_PayGovService.PayGovRequest noTokenRequest = new ENOS_PayGovService.PayGovRequest(
        'TEST_AGENCY',
        'ORDER-TEST',
        50.00,
        'test@agency.gov',
        null
      );
      ENOS_PayGovService.initiatePayment(noTokenRequest);
      System.assert(
        false,
        'Exception should be thrown for missing payment token'
      );
    } catch (ENOS_PayGovService.PayGovException e) {
      System.assert(
        e.getMessage().contains('Payment token'),
        'Exception should mention payment token'
      );
    }

    Test.stopTest();
  }

  /**
   * @description Test refund request validation
   */
  @IsTest
  static void testRefundRequestValidation() {
    Test.startTest();

    // Test invalid refund request (missing transaction ID)
    try {
      ENOS_PayGovService.PayGovRefundRequest invalidRefund = new ENOS_PayGovService.PayGovRefundRequest(
        null, // Missing original transaction ID
        25.00,
        'Test refund'
      );
      ENOS_PayGovService.processRefund(invalidRefund);
      System.assert(
        false,
        'Exception should be thrown for missing transaction ID'
      );
    } catch (ENOS_PayGovService.PayGovException e) {
      System.assert(
        e.getMessage().contains('transaction ID'),
        'Exception should mention transaction ID'
      );
    }

    Test.stopTest();
  }

  // ============================================================================
  // HTTP MOCK CLASSES FOR TESTING
  // ============================================================================

  /**
   * @description Mock HTTP response for successful Pay.gov payment initiation
   */
  public class PayGovSuccessHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'text/xml');

      String responseBody =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" ' +
        'xmlns:pay="http://www.pay.gov/paygov">' +
        '<soap:Body>' +
        '<pay:InitiatePaymentResponse>' +
        '<pay:TransactionId>PAYGOV_TEST_12345</pay:TransactionId>' +
        '<pay:RedirectUrl>https://qa.pay.gov/redirect?token=abc123</pay:RedirectUrl>' +
        '<pay:Status>INITIATED</pay:Status>' +
        '</pay:InitiatePaymentResponse>' +
        '</soap:Body>' +
        '</soap:Envelope>';

      response.setBody(responseBody);
      return response;
    }
  }

  /**
   * @description Mock HTTP response for Pay.gov payment status check
   */
  public class PayGovStatusHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'text/xml');

      String responseBody =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" ' +
        'xmlns:pay="http://www.pay.gov/paygov">' +
        '<soap:Body>' +
        '<pay:CheckPaymentStatusResponse>' +
        '<pay:TransactionId>PAYGOV_12345</pay:TransactionId>' +
        '<pay:PaymentStatus>COMPLETED</pay:PaymentStatus>' +
        '<pay:Amount>100.00</pay:Amount>' +
        '<pay:CompletedDate>2024-12-01T10:00:00Z</pay:CompletedDate>' +
        '</pay:CheckPaymentStatusResponse>' +
        '</soap:Body>' +
        '</soap:Envelope>';

      response.setBody(responseBody);
      return response;
    }
  }

  /**
   * @description Mock HTTP response for Pay.gov refund processing
   */
  public class PayGovRefundHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      HttpResponse response = new HttpResponse();
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'text/xml');

      String responseBody =
        '<?xml version="1.0" encoding="UTF-8"?>' +
        '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" ' +
        'xmlns:pay="http://www.pay.gov/paygov">' +
        '<soap:Body>' +
        '<pay:ProcessRefundResponse>' +
        '<pay:RefundTransactionId>PAYGOV_REFUND_12345</pay:RefundTransactionId>' +
        '<pay:RefundStatus>PROCESSED</pay:RefundStatus>' +
        '<pay:RefundAmount>50.00</pay:RefundAmount>' +
        '</pay:ProcessRefundResponse>' +
        '</soap:Body>' +
        '</soap:Envelope>';

      response.setBody(responseBody);
      return response;
    }
  }
}
