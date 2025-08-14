/**
 * @description Test class for PayGovService
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@IsTest
private class PayGovServiceTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test data using utility class (includes test user)
        StoreConnectTestUtils.TestDataContainer testData = StoreConnectTestUtils.createStoreConnectTestData();
    }

    /**
     * @description Test successful payment initiation with Pay.gov
     */
    @IsTest
    static void testInitiatePaymentSuccess() {
        // Create payment request
        PayGovService.PayGovRequest paymentRequest = new PayGovService.PayGovRequest(
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
        PayGovService.PayGovResponse response = PayGovService.initiatePayment(paymentRequest);
        
        Test.stopTest();

        // Verify response
        System.assert(response.success, 'Payment initiation should succeed');
        System.assertNotEquals(null, response.transactionId, 'Transaction ID should be returned');
        System.assertNotEquals(null, response.redirectUrl, 'Redirect URL should be returned');
        System.assertEquals('INITIATED', response.status, 'Status should be INITIATED');
    }

    /**
     * @description Test payment initiation failure with Pay.gov
     */
    @IsTest
    static void testInitiatePaymentFailure() {
        // Create invalid payment request (missing required fields)
        PayGovService.PayGovRequest paymentRequest = new PayGovService.PayGovRequest(
            null, // Invalid agency ID
            'ORDER-TEST',
            100.00,
            'jane.smith@agency.gov',
            'TOKEN-ABC'
        );

        Test.startTest();
        
        try {
            PayGovService.initiatePayment(paymentRequest);
            System.assert(false, 'Exception should be thrown for invalid request');
        } catch (PayGovService.PayGovException e) {
            System.assert(e.getMessage().contains('Agency ID'), 'Exception should mention Agency ID');
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
        PayGovService.PayGovStatusResponse response = PayGovService.checkPaymentStatus(testTransactionId);
        
        Test.stopTest();

        // Verify response
        System.assert(response.success, 'Status check should succeed');
        System.assertEquals(testTransactionId, response.transactionId, 'Transaction ID should match');
        System.assertEquals('COMPLETED', response.status, 'Status should be COMPLETED');
        System.assertEquals(100.00, response.amount, 'Amount should match');
    }

    /**
     * @description Test refund processing
     */
    @IsTest
    static void testProcessRefund() {
        // Create refund request
        PayGovService.PayGovRefundRequest refundRequest = new PayGovService.PayGovRefundRequest(
            'PAYGOV_ORIGINAL_12345',
            50.00,
            'Customer requested refund'
        );

        Test.startTest();
        
        // Mock the HTTP response for refund
        Test.setMock(HttpCalloutMock.class, new PayGovRefundHttpMock());
        
        // Test refund processing
        PayGovService.PayGovRefundResponse response = PayGovService.processRefund(refundRequest);
        
        Test.stopTest();

        // Verify response
        System.assert(response.success, 'Refund should succeed');
        System.assertNotEquals(null, response.refundTransactionId, 'Refund transaction ID should be returned');
        System.assertEquals('PROCESSED', response.status, 'Refund status should be PROCESSED');
        System.assertEquals(50.00, response.refundAmount, 'Refund amount should match');
    }

    /**
     * @description Test payment request validation
     */
    @IsTest
    static void testPaymentRequestValidation() {
        Test.startTest();
        
        // Test null request
        try {
            PayGovService.initiatePayment(null);
            System.assert(false, 'Exception should be thrown for null request');
        } catch (PayGovService.PayGovException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Exception should mention null request');
        }
        
        // Test invalid amount
        try {
            PayGovService.PayGovRequest invalidRequest = new PayGovService.PayGovRequest(
                'TEST_AGENCY',
                'ORDER-TEST',
                -10.00, // Invalid negative amount
                'test@agency.gov',
                'TOKEN-ABC'
            );
            PayGovService.initiatePayment(invalidRequest);
            System.assert(false, 'Exception should be thrown for negative amount');
        } catch (PayGovService.PayGovException e) {
            System.assert(e.getMessage().contains('greater than zero'), 'Exception should mention amount validation');
        }
        
        // Test amount limit
        try {
            PayGovService.PayGovRequest limitRequest = new PayGovService.PayGovRequest(
                'TEST_AGENCY',
                'ORDER-TEST',
                1000000.00, // Exceeds limit
                'test@agency.gov',
                'TOKEN-ABC'
            );
            PayGovService.initiatePayment(limitRequest);
            System.assert(false, 'Exception should be thrown for amount exceeding limit');
        } catch (PayGovService.PayGovException e) {
            System.assert(e.getMessage().contains('maximum allowed limit'), 'Exception should mention limit');
        }

        // Test missing payment token
        try {
            PayGovService.PayGovRequest noTokenRequest = new PayGovService.PayGovRequest(
                'TEST_AGENCY',
                'ORDER-TEST',
                50.00,
                'test@agency.gov',
                null
            );
            PayGovService.initiatePayment(noTokenRequest);
            System.assert(false, 'Exception should be thrown for missing payment token');
        } catch (PayGovService.PayGovException e) {
            System.assert(e.getMessage().contains('Payment token'), 'Exception should mention payment token');
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
            PayGovService.PayGovRefundRequest invalidRefund = new PayGovService.PayGovRefundRequest(
                null, // Missing original transaction ID
                25.00,
                'Test refund'
            );
            PayGovService.processRefund(invalidRefund);
            System.assert(false, 'Exception should be thrown for missing transaction ID');
        } catch (PayGovService.PayGovException e) {
            System.assert(e.getMessage().contains('transaction ID'), 'Exception should mention transaction ID');
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
            
            String responseBody = '<?xml version="1.0" encoding="UTF-8"?>' +
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
            
            String responseBody = '<?xml version="1.0" encoding="UTF-8"?>' +
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
            
            String responseBody = '<?xml version="1.0" encoding="UTF-8"?>' +
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