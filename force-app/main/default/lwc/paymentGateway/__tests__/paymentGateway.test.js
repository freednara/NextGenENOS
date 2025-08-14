import { createElement } from 'lwc';
import PaymentGateway from 'c/paymentGateway';

describe('c-payment-gateway', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('creates component successfully', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        expect(element).toBeTruthy();
        document.body.appendChild(element);
        expect(element.isConnected).toBe(true);
    });

    it('instantiates with expected constructor', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        expect(element.constructor.name).toBe('HTMLBridgeElement');
    });

    it('initializes with default values', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        expect(element.cardNumber).toBe('');
        expect(element.cardholderName).toBe('');
        expect(element.expiryDate).toBe('');
        expect(element.cvc).toBe('');
        expect(element.isProcessing).toBe(false);
        expect(element.hasErrors).toBe(false);
        expect(element.isSuccess).toBe(false);
    });

    it('handles card number formatting', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const mockEvent = {
            target: { value: '1234567890123456' }
        };

        element.handleCardNumberChange(mockEvent);
        expect(element.cardNumber).toBe('1234 5678 9012 3456');
    });

    it('removes non-digits from card number', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const mockEvent = {
            target: { value: '1234-5678-9012-3456' }
        };

        element.handleCardNumberChange(mockEvent);
        expect(element.cardNumber).toBe('1234 5678 9012 3456');
    });

    it('handles cardholder name input', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const mockEvent = {
            target: { value: 'John Doe' }
        };

        element.handleCardholderNameChange(mockEvent);
        expect(element.cardholderName).toBe('John Doe');
    });

    it('formats expiry date correctly', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const mockEvent = {
            target: { value: '1225' }
        };

        element.handleExpiryDateChange(mockEvent);
        expect(element.expiryDate).toBe('12/25');
    });

    it('handles CVC input', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const mockEvent = {
            target: { value: '123' }
        };

        element.handleCvcChange(mockEvent);
        expect(element.cvc).toBe('123');
    });

    it('handles billing address inputs', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const streetEvent = { target: { value: '123 Main St' } };
        const cityEvent = { target: { value: 'Anytown' } };
        const stateEvent = { target: { value: 'CA' } };
        const postalEvent = { target: { value: '12345' } };
        const countryEvent = { target: { value: 'USA' } };

        element.handleBillingStreetChange(streetEvent);
        element.handleBillingCityChange(cityEvent);
        element.handleBillingStateChange(stateEvent);
        element.handleBillingPostalCodeChange(postalEvent);
        element.handleBillingCountryChange(countryEvent);

        expect(element.billingStreet).toBe('123 Main St');
        expect(element.billingCity).toBe('Anytown');
        expect(element.billingState).toBe('CA');
        expect(element.billingPostalCode).toBe('12345');
        expect(element.billingCountry).toBe('USA');
    });

    it('validates form correctly with valid data', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        // Set valid form data
        element.cardNumber = '4111 1111 1111 1111';
        element.cardholderName = 'John Doe';
        element.expiryDate = '12/25';
        element.cvc = '123';
        element.billingStreet = '123 Main St';
        element.billingCity = 'Anytown';
        element.billingState = 'CA';
        element.billingPostalCode = '12345';
        element.billingCountry = 'USA';

        const isValid = element.validateForm();
        expect(isValid).toBe(true);
        expect(element.hasErrors).toBe(false);
    });

    it('validates form correctly with invalid data', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        // Leave required fields empty
        const isValid = element.validateForm();
        expect(isValid).toBe(false);
        expect(element.hasErrors).toBe(true);
        expect(element.errorMessage).toContain('required');
    });

    it('validates credit card number format', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        expect(element.validateCreditCard('4111 1111 1111 1111')).toBe(true);
        expect(element.validateCreditCard('1234 5678 9012 3456')).toBe(false);
        expect(element.validateCreditCard('411')).toBe(false);
    });

    it('detects card type correctly', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        expect(element.getCardType('4111111111111111')).toBe('Visa');
        expect(element.getCardType('5555555555554444')).toBe('Mastercard');
        expect(element.getCardType('378282246310005')).toBe('American Express');
        expect(element.getCardType('6011111111111117')).toBe('Discover');
        expect(element.getCardType('1234567890123456')).toBe('Unknown');
    });

    it('validates expiry date correctly', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        // Future date should be valid
        const futureYear = new Date().getFullYear() + 2;
        expect(element.validateExpiryDate(`12/${futureYear.toString().slice(-2)}`)).toBe(true);

        // Past date should be invalid
        expect(element.validateExpiryDate('12/20')).toBe(false);

        // Invalid format should be invalid
        expect(element.validateExpiryDate('13/25')).toBe(false);
        expect(element.validateExpiryDate('00/25')).toBe(false);
    });

    it('handles payment processing', async () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        // Set valid form data
        element.cardNumber = '4111 1111 1111 1111';
        element.cardholderName = 'John Doe';
        element.expiryDate = '12/25';
        element.cvc = '123';
        element.billingStreet = '123 Main St';
        element.billingCity = 'Anytown';
        element.billingState = 'CA';
        element.billingPostalCode = '12345';
        element.billingCountry = 'USA';

        await element.handleSubmit();

        expect(element.isSuccess).toBe(true);
        expect(element.paymentToken).toBeTruthy();
    });

    it('handles payment processing with invalid data', async () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        // Leave form empty
        await element.handleSubmit();

        expect(element.hasErrors).toBe(true);
        expect(element.isSuccess).toBe(false);
    });

    it('clears form correctly', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        // Set form data
        element.cardNumber = '4111 1111 1111 1111';
        element.cardholderName = 'John Doe';
        element.expiryDate = '12/25';
        element.cvc = '123';

        element.clearForm();

        expect(element.cardNumber).toBe('');
        expect(element.cardholderName).toBe('');
        expect(element.expiryDate).toBe('');
        expect(element.cvc).toBe('');
        expect(element.hasErrors).toBe(false);
        expect(element.isSuccess).toBe(false);
    });

    it('handles error display correctly', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const errorMessage = 'Test error message';
        element.showError(errorMessage);

        expect(element.hasErrors).toBe(true);
        expect(element.errorMessage).toBe(errorMessage);
        expect(element.isSuccess).toBe(false);
    });

    it('handles success display correctly', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        const successMessage = 'Payment processed successfully';
        element.showSuccess(successMessage);

        expect(element.isSuccess).toBe(true);
        expect(element.successMessage).toBe(successMessage);
        expect(element.hasErrors).toBe(false);
    });

    it('generates secure payment token', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        const token = element.generatePaymentToken();
        expect(token).toBeTruthy();
        expect(typeof token).toBe('string');
        expect(token.length).toBeGreaterThan(10);
    });

    it('handles processing state correctly', async () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });
        document.body.appendChild(element);

        // Set valid form data
        element.cardNumber = '4111 1111 1111 1111';
        element.cardholderName = 'John Doe';
        element.expiryDate = '12/25';
        element.cvc = '123';
        element.billingStreet = '123 Main St';
        element.billingCity = 'Anytown';
        element.billingState = 'CA';
        element.billingPostalCode = '12345';
        element.billingCountry = 'USA';

        expect(element.isProcessing).toBe(false);

        const submitPromise = element.handleSubmit();
        expect(element.isProcessing).toBe(true);

        await submitPromise;
        expect(element.isProcessing).toBe(false);
    });

    it('handles luhn algorithm validation', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        // Valid test card numbers
        expect(element.luhnCheck('4111111111111111')).toBe(true);
        expect(element.luhnCheck('5555555555554444')).toBe(true);
        expect(element.luhnCheck('378282246310005')).toBe(true);

        // Invalid card numbers
        expect(element.luhnCheck('4111111111111112')).toBe(false);
        expect(element.luhnCheck('1234567890123456')).toBe(false);
    });

    it('sanitizes input data', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        const maliciousInput = '<script>alert("xss")</script>John Doe';
        const sanitized = element.sanitizeInput(maliciousInput);
        
        expect(sanitized).not.toContain('<script>');
        expect(sanitized).toContain('John Doe');
    });

    it('validates postal code formats', () => {
        const element = createElement('c-payment-gateway', {
            is: PaymentGateway
        });

        // US format
        expect(element.validatePostalCode('12345', 'USA')).toBe(true);
        expect(element.validatePostalCode('12345-6789', 'USA')).toBe(true);

        // Canada format
        expect(element.validatePostalCode('K1A 0A6', 'CA')).toBe(true);

        // Invalid formats
        expect(element.validatePostalCode('1234', 'USA')).toBe(false);
        expect(element.validatePostalCode('ABCDE', 'USA')).toBe(false);
    });
});
