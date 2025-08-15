/**
 * @description Service class for Pay.gov integration to process federal payments securely.
 *
 * This service handles all interactions with the Pay.gov SOAP web service API,
 * providing secure payment processing for federal agencies. The implementation
 * follows federal security standards and compliance requirements.
 *
 * Pay.gov handles sensitive payment data so that Salesforce never touches
 * credit card numbers, bank account details, or other PII, reducing security risks.
 *
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class ENOS_PayGovService {
  // Pay.gov API configuration constants
  private static final String PAYGOV_QA_ENDPOINT = 'https://pay.gov/cgi-bin/webscr?cmd=_notify-validate-qa';
  private static final String PAYGOV_PROD_ENDPOINT = 'https://pay.gov/cgi-bin/webscr?cmd=_notify-validate';
  private static final String CERTIFICATE_NAME = 'PayGov_Client_Certificate';
  private static final Integer TIMEOUT_MILLISECONDS = 30000; // 30 seconds

  // Payment status constants based on Pay.gov documentation
  public enum PaymentStatus {
    INITIATED,
    PROCESSING,
    COMPLETED,
    FAILED,
    CANCELLED,
    REFUNDED,
    ERROR
  }

  /**
   * @description Initiates a payment transaction with Pay.gov
   *
   * @param paymentRequest The payment request containing amount, order details, and user info
   * @return PayGovResponse containing transaction ID and redirect URL
   * @throws PayGovException if the payment initiation fails
   */
  public static PayGovResponse initiatePayment(PayGovRequest paymentRequest) {
    try {
      // Input validation
      if (paymentRequest == null) {
        throw new PayGovException('Payment request cannot be null');
      }

      validatePaymentRequest(paymentRequest);

      // Build the SOAP request for Pay.gov
      String soapRequest = buildInitiatePaymentRequest(paymentRequest);

      // Make the callout to Pay.gov
      HttpResponse response = makePayGovCallout(soapRequest, 'InitiatePayment');

      // Parse and return the response
      return parsePayGovResponse(response);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error initiating Pay.gov payment: ' + e.getMessage()
      );
      throw new PayGovException(
        'Failed to initiate payment: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Checks the status of a Pay.gov payment transaction
   *
   * @param transactionId The Pay.gov transaction ID to check
   * @return PayGovStatusResponse containing the current payment status
   * @throws PayGovException if the status check fails
   */
  public static PayGovStatusResponse checkPaymentStatus(String transactionId) {
    try {
      if (String.isBlank(transactionId)) {
        throw new PayGovException('Transaction ID is required');
      }

      // Build status check request
      String soapRequest = buildStatusCheckRequest(transactionId);

      // Make callout to Pay.gov
      HttpResponse response = makePayGovCallout(
        soapRequest,
        'CheckPaymentStatus'
      );

      // Parse and return status
      return parseStatusResponse(response);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error checking Pay.gov payment status: ' + e.getMessage()
      );
      throw new PayGovException(
        'Failed to check payment status: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Processes a refund through Pay.gov
   *
   * @param refundRequest The refund request containing original transaction details
   * @return PayGovRefundResponse containing refund transaction details
   * @throws PayGovException if the refund processing fails
   */
  public static PayGovRefundResponse processRefund(
    PayGovRefundRequest refundRequest
  ) {
    try {
      if (refundRequest == null) {
        throw new PayGovException('Refund request cannot be null');
      }

      validateRefundRequest(refundRequest);

      // Build refund request
      String soapRequest = buildRefundRequest(refundRequest);

      // Make callout to Pay.gov
      HttpResponse response = makePayGovCallout(soapRequest, 'ProcessRefund');

      // Parse and return refund response
      return parseRefundResponse(response);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error processing Pay.gov refund: ' + e.getMessage()
      );
      throw new PayGovException('Failed to process refund: ' + e.getMessage());
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /**
   * @description Validates the payment request before sending to Pay.gov
   */
  private static void validatePaymentRequest(PayGovRequest request) {
    if (request.amount == null || request.amount <= 0) {
      throw new PayGovException('Payment amount must be greater than zero');
    }

    if (String.isBlank(request.orderId)) {
      throw new PayGovException('Order ID is required');
    }

    if (String.isBlank(request.customerEmail)) {
      throw new PayGovException('Customer email is required');
    }

    if (String.isBlank(request.paymentToken)) {
      throw new PayGovException('Payment token is required');
    }

    if (String.isBlank(request.agencyId)) {
      throw new PayGovException(
        'Agency ID is required for Pay.gov integration'
      );
    }

    // Validate amount limits (Pay.gov typically has transaction limits)
    Decimal maxPaymentAmount = getMaxPaymentAmount();
    if (request.amount > maxPaymentAmount) {
      throw new PayGovException(
        'Payment amount exceeds maximum allowed limit of $' + maxPaymentAmount
      );
    }
  }

  /**
   * @description Validates refund request parameters
   */
  private static void validateRefundRequest(PayGovRefundRequest request) {
    if (String.isBlank(request.originalTransactionId)) {
      throw new PayGovException(
        'Original transaction ID is required for refunds'
      );
    }

    if (request.refundAmount == null || request.refundAmount <= 0) {
      throw new PayGovException('Refund amount must be greater than zero');
    }

    if (String.isBlank(request.reason)) {
      throw new PayGovException('Refund reason is required');
    }
  }

  /**
   * @description Builds SOAP request for payment initiation
   */
  private static String buildInitiatePaymentRequest(PayGovRequest request) {
    // Build SOAP envelope for Pay.gov payment initiation
    String soapRequest =
      '<?xml version="1.0" encoding="UTF-8"?>' +
      '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" ' +
      'xmlns:pay="http://www.pay.gov/paygov">' +
      '<soap:Header/>' +
      '<soap:Body>' +
      '<pay:InitiatePaymentRequest>' +
      '<pay:AgencyId>' +
      String.escapeSingleQuotes(request.agencyId) +
      '</pay:AgencyId>' +
      '<pay:OrderId>' +
      String.escapeSingleQuotes(request.orderId) +
      '</pay:OrderId>' +
      '<pay:Amount>' +
      request.amount +
      '</pay:Amount>' +
      '<pay:Currency>USD</pay:Currency>' +
      '<pay:CustomerEmail>' +
      String.escapeSingleQuotes(request.customerEmail) +
      '</pay:CustomerEmail>' +
      '<pay:PaymentToken>' +
      String.escapeSingleQuotes(request.paymentToken) +
      '</pay:PaymentToken>' +
      '<pay:Description>' +
      String.escapeSingleQuotes(request.description) +
      '</pay:Description>' +
      '<pay:SuccessUrl>' +
      String.escapeSingleQuotes(request.successUrl) +
      '</pay:SuccessUrl>' +
      '<pay:CancelUrl>' +
      String.escapeSingleQuotes(request.cancelUrl) +
      '</pay:CancelUrl>' +
      '<pay:Timestamp>' +
      Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +
      '</pay:Timestamp>' +
      '</pay:InitiatePaymentRequest>' +
      '</soap:Body>' +
      '</soap:Envelope>';

    return soapRequest;
  }

  /**
   * @description Builds SOAP request for payment status check
   */
  private static String buildStatusCheckRequest(String transactionId) {
    String soapRequest =
      '<?xml version="1.0" encoding="UTF-8"?>' +
      '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" ' +
      'xmlns:pay="http://www.pay.gov/paygov">' +
      '<soap:Header/>' +
      '<soap:Body>' +
      '<pay:CheckPaymentStatusRequest>' +
      '<pay:TransactionId>' +
      String.escapeSingleQuotes(transactionId) +
      '</pay:TransactionId>' +
      '</pay:CheckPaymentStatusRequest>' +
      '</soap:Body>' +
      '</soap:Envelope>';

    return soapRequest;
  }

  /**
   * @description Builds SOAP request for refund processing
   */
  private static String buildRefundRequest(PayGovRefundRequest request) {
    String soapRequest =
      '<?xml version="1.0" encoding="UTF-8"?>' +
      '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" ' +
      'xmlns:pay="http://www.pay.gov/paygov">' +
      '<soap:Header/>' +
      '<soap:Body>' +
      '<pay:ProcessRefundRequest>' +
      '<pay:OriginalTransactionId>' +
      String.escapeSingleQuotes(request.originalTransactionId) +
      '</pay:OriginalTransactionId>' +
      '<pay:RefundAmount>' +
      request.refundAmount +
      '</pay:RefundAmount>' +
      '<pay:Reason>' +
      String.escapeSingleQuotes(request.reason) +
      '</pay:Reason>' +
      '<pay:Timestamp>' +
      Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +
      '</pay:Timestamp>' +
      '</pay:ProcessRefundRequest>' +
      '</soap:Body>' +
      '</soap:Envelope>';

    return soapRequest;
  }

  /**
   * @description Makes secure HTTP callout to Pay.gov using client certificates
   */
  private static HttpResponse makePayGovCallout(
    String soapRequest,
    String action
  ) {
    HttpRequest request = new HttpRequest();

    try {
      // Configure request for Pay.gov SOAP API
      request.setEndpoint('callout:PayGov_API'); // Uses Named Credential
      request.setMethod('POST');
      request.setHeader('Content-Type', 'text/xml; charset=utf-8');
      request.setHeader(
        'SOAPAction',
        '"http://www.pay.gov/paygov/' + action + '"'
      );
      request.setTimeout(TIMEOUT_MILLISECONDS);
      request.setBody(soapRequest);

      // Add request tracking for audit purposes
      System.debug(
        LoggingLevel.INFO,
        'Making Pay.gov callout for action: ' + action
      );

      Http http = new Http();
      HttpResponse response = http.send(request);

      // Log response status for monitoring
      System.debug(
        LoggingLevel.INFO,
        'Pay.gov response status: ' + response.getStatusCode()
      );

      if (response.getStatusCode() != 200) {
        throw new PayGovException(
          'Pay.gov API returned error status: ' +
            response.getStatusCode() +
            ' - ' +
            response.getStatus()
        );
      }

      return response;
    } catch (CalloutException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Pay.gov callout failed: ' + e.getMessage()
      );
      throw new PayGovException(
        'Payment service unavailable. Named Credential may not be configured: ' +
        e.getMessage()
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in Pay.gov callout: ' + e.getMessage()
      );
      throw new PayGovException('Payment processing error: ' + e.getMessage());
    }
  }

  /**
   * @description Parses Pay.gov initiate payment response
   */
  private static PayGovResponse parsePayGovResponse(HttpResponse response) {
    PayGovResponse payGovResponse = new PayGovResponse();

    try {
      // Parse XML response from Pay.gov
      Dom.Document doc = response.getBodyDocument();
      Dom.XMLNode rootNode = doc.getRootElement();

      // Navigate to response elements (simplified parsing)
      Dom.XMLNode bodyNode = rootNode.getChildElement(
        'Body',
        'http://schemas.xmlsoap.org/soap/envelope/'
      );
      Dom.XMLNode responseNode = bodyNode.getChildElement(
        'InitiatePaymentResponse',
        'http://www.pay.gov/paygov'
      );

      if (responseNode != null) {
        payGovResponse.success = true;
        payGovResponse.transactionId = getElementValue(
          responseNode,
          'TransactionId'
        );
        payGovResponse.redirectUrl = getElementValue(
          responseNode,
          'RedirectUrl'
        );
        payGovResponse.status = getElementValue(responseNode, 'Status');
      } else {
        // Check for fault/error
        Dom.XMLNode faultNode = bodyNode.getChildElement(
          'Fault',
          'http://schemas.xmlsoap.org/soap/envelope/'
        );
        if (faultNode != null) {
          payGovResponse.success = false;
          payGovResponse.errorMessage = getElementValue(
            faultNode,
            'faultstring'
          );
        }
      }
    } catch (Exception e) {
      payGovResponse.success = false;
      payGovResponse.errorMessage =
        'Failed to parse Pay.gov response: ' + e.getMessage();
    }

    return payGovResponse;
  }

  /**
   * @description Parses Pay.gov status check response
   */
  private static PayGovStatusResponse parseStatusResponse(
    HttpResponse response
  ) {
    PayGovStatusResponse statusResponse = new PayGovStatusResponse();

    try {
      Dom.Document doc = response.getBodyDocument();
      Dom.XMLNode rootNode = doc.getRootElement();

      Dom.XMLNode bodyNode = rootNode.getChildElement(
        'Body',
        'http://schemas.xmlsoap.org/soap/envelope/'
      );
      Dom.XMLNode responseNode = bodyNode.getChildElement(
        'CheckPaymentStatusResponse',
        'http://www.pay.gov/paygov'
      );

      if (responseNode != null) {
        statusResponse.success = true;
        statusResponse.transactionId = getElementValue(
          responseNode,
          'TransactionId'
        );
        statusResponse.status = getElementValue(responseNode, 'PaymentStatus');
        statusResponse.amount = Decimal.valueOf(
          getElementValue(responseNode, 'Amount')
        );
        statusResponse.completedDate = getElementValue(
          responseNode,
          'CompletedDate'
        );
      }
    } catch (Exception e) {
      statusResponse.success = false;
      statusResponse.errorMessage =
        'Failed to parse status response: ' + e.getMessage();
    }

    return statusResponse;
  }

  /**
   * @description Parses Pay.gov refund response
   */
  private static PayGovRefundResponse parseRefundResponse(
    HttpResponse response
  ) {
    PayGovRefundResponse refundResponse = new PayGovRefundResponse();

    try {
      Dom.Document doc = response.getBodyDocument();
      Dom.XMLNode rootNode = doc.getRootElement();

      Dom.XMLNode bodyNode = rootNode.getChildElement(
        'Body',
        'http://schemas.xmlsoap.org/soap/envelope/'
      );
      Dom.XMLNode responseNode = bodyNode.getChildElement(
        'ProcessRefundResponse',
        'http://www.pay.gov/paygov'
      );

      if (responseNode != null) {
        refundResponse.success = true;
        refundResponse.refundTransactionId = getElementValue(
          responseNode,
          'RefundTransactionId'
        );
        refundResponse.status = getElementValue(responseNode, 'RefundStatus');
        refundResponse.refundAmount = Decimal.valueOf(
          getElementValue(responseNode, 'RefundAmount')
        );
      }
    } catch (Exception e) {
      refundResponse.success = false;
      refundResponse.errorMessage =
        'Failed to parse refund response: ' + e.getMessage();
    }

    return refundResponse;
  }

  /**
   * @description Helper method to extract element value from XML
   */
  private static String getElementValue(
    Dom.XMLNode parentNode,
    String elementName
  ) {
    Dom.XMLNode element = parentNode.getChildElement(
      elementName,
      'http://www.pay.gov/paygov'
    );
    return element != null ? element.getText() : null;
  }

  // ============================================================================
  // WRAPPER CLASSES FOR REQUEST/RESPONSE
  // ============================================================================

  /**
   * @description Wrapper class for Pay.gov payment initiation requests
   */
  public class PayGovRequest {
    public String agencyId;
    public String orderId;
    public Decimal amount;
    public String customerEmail;
    /**
     * Secure token representing the payment method. Never log this value.
     */
    public String paymentToken;
    public String description;
    public String successUrl;
    public String cancelUrl;

    public PayGovRequest(
      String agencyId,
      String orderId,
      Decimal amount,
      String customerEmail,
      String paymentToken
    ) {
      this.agencyId = agencyId;
      this.orderId = orderId;
      this.amount = amount;
      this.customerEmail = customerEmail;
      this.paymentToken = paymentToken;
    }
  }

  /**
   * @description Get the maximum payment amount allowed from configuration
   * @return Maximum payment amount, defaults to $999,999.99 if not configured
   */
  private static Decimal getMaxPaymentAmount() {
    try {
      List<PayGov_Configuration__mdt> configs = [
        SELECT Max_Payment_Amount__c
        FROM PayGov_Configuration__mdt
        WHERE DeveloperName = 'Default'
        WITH USER_MODE
        LIMIT 1
      ];

      if (!configs.isEmpty() && configs[0].Max_Payment_Amount__c != null) {
        return configs[0].Max_Payment_Amount__c;
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.WARN,
        'Unable to retrieve max payment amount from configuration: ' +
        e.getMessage()
      );
    }

    // Default to standard Pay.gov limit if configuration not available
    Decimal maxAmount = ENOS_ConfigurationUtils.getMaxPaymentAmount();
    return maxAmount != null ? maxAmount : 999999.99;
  }

  /**
   * @description Wrapper class for Pay.gov payment responses
   */
  public class PayGovResponse {
    public Boolean success;
    public String transactionId;
    public String redirectUrl;
    public String status;
    public String errorMessage;
  }

  /**
   * @description Wrapper class for Pay.gov status check responses
   */
  public class PayGovStatusResponse {
    public Boolean success;
    public String transactionId;
    public String status;
    public Decimal amount;
    public String completedDate;
    public String errorMessage;
  }

  /**
   * @description Wrapper class for Pay.gov refund requests
   */
  public class PayGovRefundRequest {
    public String originalTransactionId;
    public Decimal refundAmount;
    public String reason;

    public PayGovRefundRequest(
      String originalTransactionId,
      Decimal refundAmount,
      String reason
    ) {
      this.originalTransactionId = originalTransactionId;
      this.refundAmount = refundAmount;
      this.reason = reason;
    }
  }

  /**
   * @description Wrapper class for Pay.gov refund responses
   */
  public class PayGovRefundResponse {
    public Boolean success;
    public String refundTransactionId;
    public String status;
    public Decimal refundAmount;
    public String errorMessage;
  }

  /**
   * @description Custom exception class for Pay.gov integration errors
   */
  public class PayGovException extends Exception {
  }
}
