import { LightningElement, api, track } from 'lwc';

/**
 * @description Secure Payment Gateway component for PCI-compliant payment processing.
 * 
 * This component handles payment information collection and securely communicates
 * with payment gateways without storing sensitive data on Salesforce servers.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
export default class PaymentGateway extends LightningElement {
    
    // @api property exposed to Flow for output
    @api paymentToken;
    
    // Tracked properties for form data
    @track cardNumber = '';
    @track cardholderName = '';
    @track expiryDate = '';
    @track cvc = '';
    @track billingStreet = '';
    @track billingCity = '';
    @track billingState = '';
    @track billingPostalCode = '';
    @track billingCountry = '';
    
    // Component state
    @track isProcessing = false;
    @track hasErrors = false;
    @track errorMessage = '';

    /**
     * @description Handles card number input changes with formatting
     * @param {Event} event - The input change event
     */
    handleCardNumberChange(event) {
        let value = event.target.value.replace(/\s/g, ''); // Remove spaces
        value = value.replace(/\D/g, ''); // Remove non-digits
        
        // Format with spaces every 4 digits
        if (value.length > 0) {
            value = value.match(/.{1,4}/g).join(' ');
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
        let value = event.target.value.replace(/\D/g, ''); // Remove non-digits
        
        // Format as MM/YY
        if (value.length >= 2) {
            value = value.substring(0, 2) + '/' + value.substring(2, 4);
        }
        
        this.expiryDate = value;
        this.validateForm();
    }

    /**
     * @description Handles CVC input changes
     * @param {Event} event - The input change event
     */
    handleCVCChange(event) {
        this.cvc = event.target.value.replace(/\D/g, ''); // Remove non-digits
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
        const hasAllFields = requiredFields.every(field => field && field.trim().length > 0);
        
        // Validate card number (basic Luhn algorithm check)
        const isValidCardNumber = this.validateCardNumber(this.cardNumber.replace(/\s/g, ''));
        
        // Validate expiry date format
        const isValidExpiry = this.validateExpiryDate(this.expiryDate);
        
        // Validate CVC length
        const isValidCVC = this.cvc.length >= 3 && this.cvc.length <= 4;

        this.hasErrors = !(hasAllFields && isValidCardNumber && isValidExpiry && isValidCVC);
        
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

        const [month, year] = expiryDate.split('/');
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
        if (expYear < currentYear || (expYear === currentYear && expMonth < currentMonth)) {
            return false;
        }

        return true;
    }

    /**
     * @description Handles the confirm payment button click
     * Securely processes payment and generates token for Flow
     */
    async handleConfirmPayment() {
        // Validate form before processing
        if (!this.validateForm()) {
            this.showError('Please complete all required fields correctly.');
            return;
        }

        this.isProcessing = true;
        this.hasErrors = false;
        this.errorMessage = '';

        try {
            // In a real implementation, this would call the payment gateway's JavaScript library
            // For example: const result = await stripe.createToken(cardElement);
            
            // Simulate payment gateway call with delay
            await this.simulatePaymentGatewayCall();
            
            // Generate secure payment token (in real implementation, this comes from gateway)
            this.paymentToken = this.generateSecureToken();
            
            // Navigate to next Flow screen
            this.navigateToNextScreen();
            
        } catch {
            this.showError('Payment processing failed. Please try again.');
        } finally {
            this.isProcessing = false;
        }
    }

    /**
     * @description Simulates a payment gateway API call
     * In production, this would be replaced with actual gateway integration
     * @returns {Promise} Simulated API response
     */
    simulatePaymentGatewayCall() {
        return new Promise((resolve, reject) => {
            // Simulate network delay
            setTimeout(() => {
                // Simulate 95% success rate
                if (Math.random() > 0.05) {
                    resolve({ success: true });
                } else {
                    reject(new Error('Payment gateway temporarily unavailable'));
                }
            }, 1500);
        });
    }

    /**
     * @description Generates a secure payment token
     * In production, this would come from the payment gateway
     * @returns {string} Secure payment token
     */
    generateSecureToken() {
        const timestamp = Date.now().toString(36);
        const random = Math.random().toString(36).substr(2, 9);
        return `tok_${timestamp}_${random}`;
    }

    /**
     * @description Shows error message to user
     * @param {string} message - Error message to display
     */
    showError(message) {
        this.hasErrors = true;
        this.errorMessage = message;
        
        // Auto-hide error after 5 seconds
        setTimeout(() => {
            this.hasErrors = false;
            this.errorMessage = '';
        }, 5000);
    }

    /**
     * @description Navigates to the next Flow screen
     * Dispatches Flow navigation event
     */
    navigateToNextScreen() {
        const navigateNextEvent = new CustomEvent('flowstatuschange', {
            bubbles: true,
            composed: true,
            detail: {
                status: 'FINISHED'
            }
        });
        this.dispatchEvent(navigateNextEvent);
    }

    /**
     * @description Handles the back button click
     * Navigates to previous Flow screen
     */
    handleBack() {
        const navigateBackEvent = new CustomEvent('flowstatuschange', {
            bubbles: true,
            composed: true,
            detail: {
                status: 'BACK'
            }
        });
        this.dispatchEvent(navigateBackEvent);
    }

    /**
     * @description Computed property to determine if form is complete
     * @returns {boolean} True if all required fields are filled
     */
    get isFormComplete() {
        return this.cardNumber && this.cardholderName && this.expiryDate && 
               this.cvc && this.billingStreet && this.billingCity && 
               this.billingState && this.billingPostalCode && this.billingCountry;
    }

    /**
     * @description Computed property for card number display (masked for security)
     * @returns {string} Masked card number for display
     */
    get maskedCardNumber() {
        if (!this.cardNumber) return '';
        const cleanNumber = this.cardNumber.replace(/\s/g, '');
        if (cleanNumber.length < 4) return cleanNumber;
        return '**** **** **** ' + cleanNumber.slice(-4);
    }
}
