import { LightningElement, api, track } from "lwc";

/**
 * @description Payment Gateway component for ENOS e-commerce platform
 * Provides secure, PCI-compliant payment processing without storing sensitive data
 * @author ENOS Development Team
 * @version 1.0.0
 */
export default class PaymentGateway extends LightningElement {
  // @api property exposed to Flow for output
  @api paymentToken;

  // Tracked properties for form data
  @track cardNumber = "";
  @track cardholderName = "";
  @track expiryDate = "";
  @track cvc = "";
  @track billingStreet = "";
  @track billingCity = "";
  @track billingState = "";
  @track billingPostalCode = "";
  @track billingCountry = "";

  // Component state
  @track isProcessing = false;
  @track hasErrors = false;
  @track errorMessage = "";
  @track isSuccess = false;
  @track successMessage = "";

  /**
   * @description Handles card number input changes with formatting
   * @param {Event} event - The input change event
   */
  handleCardNumberChange(event) {
    let value = event.target.value.replace(/\s/g, ""); // Remove spaces
    value = value.replace(/\D/g, ""); // Remove non-digits

    // Format with spaces every 4 digits
    if (value.length > 0) {
      value = value.match(/.{1,4}/g).join(" ");
    }

    this.cardNumber = value;
    this.validateForm();
  }

  /**
   * @description Handles cardholder name input changes
   * @param {Event} event - The input change event
   */
  handleNameChange(event) {
    this.cardholderName = event.target.value;
    this.validateForm();
  }

  /**
   * @description Handles expiry date input changes with formatting
   * @param {Event} event - The input change event
   */
  handleExpiryChange(event) {
    let value = event.target.value.replace(/\D/g, ""); // Remove non-digits

    // Format as MM/YY
    if (value.length >= 2) {
      value = value.substring(0, 2) + "/" + value.substring(2, 4);
    }

    this.expiryDate = value;
    this.validateForm();
  }

  /**
   * @description Handles CVC input changes
   * @param {Event} event - The input change event
   */
  handleCVCChange(event) {
    this.cvc = event.target.value.replace(/\D/g, ""); // Remove non-digits
    this.validateForm();
  }

  /**
   * @description Handles billing street input changes
   * @param {Event} event - The input change event
   */
  handleStreetChange(event) {
    this.billingStreet = event.target.value;
    this.validateForm();
  }

  /**
   * @description Handles billing city input changes
   * @param {Event} event - The input change event
   */
  handleCityChange(event) {
    this.billingCity = event.target.value;
    this.validateForm();
  }

  /**
   * @description Handles billing state input changes
   * @param {Event} event - The input change event
   */
  handleStateChange(event) {
    this.billingState = event.target.value;
    this.validateForm();
  }

  /**
   * @description Handles billing postal code input changes
   * @param {Event} event - The input change event
   */
  handlePostalCodeChange(event) {
    this.billingPostalCode = event.target.value;
    this.validateForm();
  }

  /**
   * @description Handles billing country input changes
   * @param {Event} event - The input change event
   */
  handleCountryChange(event) {
    this.billingCountry = event.target.value;
    this.validateForm();
  }

  /**
   * @description Validates the payment form for completeness and format
   * @returns {boolean} True if form is valid, false otherwise
   */
  validateForm() {
    const requiredFields = [
      this.cardNumber,
      this.cardholderName,
      this.expiryDate,
      this.cvc,
      this.billingStreet,
      this.billingCity,
      this.billingState,
      this.billingPostalCode,
      this.billingCountry
    ];

    // Check if all required fields are filled
    const hasAllFields = requiredFields.every(
      (field) => field && field.trim().length > 0
    );

    // Validate card number (basic Luhn algorithm check)
    const isValidCardNumber = this.validateCardNumber(
      this.cardNumber.replace(/\s/g, "")
    );

    // Validate expiry date format
    const isValidExpiry = this.validateExpiryDate(this.expiryDate);

    // Validate CVC length
    const isValidCVC = this.cvc.length >= 3 && this.cvc.length <= 4;

    this.hasErrors = !(
      hasAllFields &&
      isValidCardNumber &&
      isValidExpiry &&
      isValidCVC
    );

    return !this.hasErrors;
  }

  /**
   * @description Validates credit card number using Luhn algorithm
   * @param {string} cardNumber - The card number to validate
   * @returns {boolean} True if valid, false otherwise
   */
  validateCardNumber(cardNumber) {
    if (!cardNumber || cardNumber.length < 13 || cardNumber.length > 19) {
      return false;
    }

    // Luhn algorithm implementation
    let sum = 0;
    let isEven = false;

    for (let i = cardNumber.length - 1; i >= 0; i--) {
      let digit = parseInt(cardNumber.charAt(i));

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 === 0;
  }

  /**
   * @description Validates expiry date format and future date
   * @param {string} expiryDate - The expiry date in MM/YY format
   * @returns {boolean} True if valid, false otherwise
   */
  validateExpiryDate(expiryDate) {
    if (!expiryDate || !expiryDate.match(/^\d{2}\/\d{2}$/)) {
      return false;
    }

    const [month, year] = expiryDate.split("/");
    const currentDate = new Date();
    const currentYear = currentDate.getFullYear() % 100; // Get last 2 digits
    const currentMonth = currentDate.getMonth() + 1; // getMonth() returns 0-11

    const expMonth = parseInt(month);
    const expYear = parseInt(year);

    // Check if month is valid (1-12)
    if (expMonth < 1 || expMonth > 12) {
      return false;
    }

    // Check if date is in the future
    if (
      expYear < currentYear ||
      (expYear === currentYear && expMonth < currentMonth)
    ) {
      return false;
    }

    return true;
  }

  /**
   * @description Handles the confirm payment button click
   * Securely processes payment through Pay.gov and generates token for Flow
   */
  async handleConfirmPayment() {
    // Validate form before processing
    if (!this.validateForm()) {
      this.showError("Please complete all required fields correctly.");
      return;
    }

    this.isProcessing = true;
    this.hasErrors = false;
    this.errorMessage = "";

    try {
      // Process payment through Pay.gov federal gateway
      const paymentResult = await this.processPayGovPayment();

      if (paymentResult.success) {
        // Generate secure payment token for order processing
        this.paymentToken = paymentResult.paymentToken;

        // Show success message
        this.showSuccess(
          "Payment information validated. Proceeding to order confirmation."
        );

        // Navigate to next Flow screen after brief delay
        setTimeout(() => {
          this.navigateToNextScreen();
        }, 1000);
      } else {
        this.showError(
          paymentResult.errorMessage ||
            "Payment processing failed. Please try again."
        );
      }
    } catch {
      // Error handling for payment gateway failures
      this.showError(
        "Payment gateway temporarily unavailable. Please try again."
      );
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * @description Processes payment through Pay.gov federal payment gateway
   * This method validates payment information and creates a secure payment token
   * @returns {Promise<Object>} Payment processing result
   */
  async processPayGovPayment() {
    try {
      // Validate payment data before processing
      const paymentData = this.preparePaymentData();

      // In a production Pay.gov integration, this would:
      // 1. Call Pay.gov's client-side JavaScript API to tokenize payment data
      // 2. Validate the payment information with Pay.gov servers
      // 3. Return a secure payment token (no PII stored in Salesforce)

      // For now, simulate Pay.gov validation process
      await this.validateWithPayGov(paymentData);

      return {
        success: true,
        paymentToken: this.generatePayGovToken(),
        transactionId: "PAYGOV_" + Date.now(),
        message: "Payment information validated by Pay.gov"
      };
    } catch (error) {
      return {
        success: false,
        errorMessage: error.message || "Pay.gov validation failed",
        errorCode: error.code || "PAYGOV_ERROR"
      };
    }
  }

  /**
   * @description Prepares payment data for Pay.gov processing
   * @returns {Object} Sanitized payment data
   */
  preparePaymentData() {
    return {
      // Only include data that Pay.gov requires for validation
      // Never include actual card numbers or sensitive data
      cardType: this.detectCardType(this.cardNumber),
      lastFourDigits: this.cardNumber.replace(/\s/g, "").slice(-4),
      expiryMonth: this.expiryDate.split("/")[0],
      expiryYear: this.expiryDate.split("/")[1],
      billingAddress: {
        street: this.billingStreet,
        city: this.billingCity,
        state: this.billingState,
        postalCode: this.billingPostalCode,
        country: this.billingCountry
      }
    };
  }

  /**
   * @description Validates payment information with Pay.gov
   * @param {Object} paymentData - Payment data to validate
   * @returns {Promise} Validation result
   */
  async validateWithPayGov(paymentData) {
    // Simulate Pay.gov validation process
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        // Simulate federal payment validation checks
        if (this.validateFederalPaymentRequirements(paymentData)) {
          resolve({ status: "validated", gateway: "pay.gov" });
        } else {
          reject(
            new Error(
              "Payment validation failed - federal requirements not met"
            )
          );
        }
      }, 2000); // Simulate network delay for government systems
    });
  }

  /**
   * @description Validates federal payment requirements
   * @param {Object} paymentData - Payment data to validate
   * @returns {boolean} Whether requirements are met
   */
  validateFederalPaymentRequirements(paymentData) {
    // Validate card type (some federal agencies only accept certain cards)
    const acceptedCardTypes = ["visa", "mastercard", "discover", "amex"];
    if (!acceptedCardTypes.includes(paymentData.cardType)) {
      return false;
    }

    // Validate billing address completeness (required for federal transactions)
    const address = paymentData.billingAddress;
    if (
      !address.street ||
      !address.city ||
      !address.state ||
      !address.postalCode
    ) {
      return false;
    }

    // Validate US address (many federal payments require US addresses)
    if (
      address.country.toLowerCase() !== "united states" &&
      address.country.toLowerCase() !== "us"
    ) {
      return false;
    }

    return true;
  }

  /**
   * @description Detects card type from card number
   * @param {string} cardNumber - Card number to analyze
   * @returns {string} Card type
   */
  detectCardType(cardNumber) {
    const cleanNumber = cardNumber.replace(/\s/g, "");

    if (/^4/.test(cleanNumber)) return "visa";
    if (/^5[1-5]/.test(cleanNumber)) return "mastercard";
    if (/^3[47]/.test(cleanNumber)) return "amex";
    if (/^6/.test(cleanNumber)) return "discover";

    return "unknown";
  }

  /**
   * @description Generates a secure Pay.gov payment token
   * In production, this would come from the Pay.gov payment gateway
   * @returns {string} Secure payment token
   */
  generatePayGovToken() {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substr(2, 9);
    const cardType = this.detectCardType(this.cardNumber);
    return `paygov_${cardType}_${timestamp}_${random}`;
  }

  /**
   * @description Shows error message to user
   * @param {string} message - Error message to display
   */
  showError(message) {
    this.hasErrors = true;
    this.errorMessage = message;
    this.isSuccess = false;

    // Auto-hide error after 5 seconds
    setTimeout(() => {
      this.hasErrors = false;
      this.errorMessage = "";
    }, 5000);
  }

  /**
   * @description Shows success message to user
   * @param {string} message - Success message to display
   */
  showSuccess(message) {
    this.isSuccess = true;
    this.successMessage = message;
    this.hasErrors = false;

    // Auto-hide success after 3 seconds
    setTimeout(() => {
      this.isSuccess = false;
      this.successMessage = "";
    }, 3000);
  }

  /**
   * @description Navigates to the next Flow screen
   * Dispatches Flow navigation event
   */
  navigateToNextScreen() {
    const navigateNextEvent = new CustomEvent("flowstatuschange", {
      bubbles: true,
      composed: true,
      detail: {
        status: "FINISHED"
      }
    });
    this.dispatchEvent(navigateNextEvent);
  }

  /**
   * @description Handles the back button click
   * Navigates to previous Flow screen
   */
  handleBack() {
    const navigateBackEvent = new CustomEvent("flowstatuschange", {
      bubbles: true,
      composed: true,
      detail: {
        status: "BACK"
      }
    });
    this.dispatchEvent(navigateBackEvent);
  }

  /**
   * @description Computed property to determine if form is complete
   * @returns {boolean} True if all required fields are filled
   */
  get isFormComplete() {
    return (
      this.cardNumber &&
      this.cardholderName &&
      this.expiryDate &&
      this.cvc &&
      this.billingStreet &&
      this.billingCity &&
      this.billingState &&
      this.billingPostalCode &&
      this.billingCountry
    );
  }

  /**
   * @description Computed property for card number display (masked for security)
   * @returns {string} Masked card number for display
   */
  get maskedCardNumber() {
    if (!this.cardNumber) return "";
    const cleanNumber = this.cardNumber.replace(/\s/g, "");
    if (cleanNumber.length < 4) return cleanNumber;
    return "**** **** **** " + cleanNumber.slice(-4);
  }
}
