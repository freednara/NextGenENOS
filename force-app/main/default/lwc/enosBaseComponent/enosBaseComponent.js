import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/**
 * @description Base component for all ENOS LWC components
 * Provides common functionality to eliminate code duplication
 * @author ENOS Development Team
 * @version 1.0.0
 */
export default class EnosBaseComponent extends LightningElement {
    
    // Common component state
    @track isLoading = false;
    @track error = null;
    @track loadingMessage = 'Loading...';
    
    // Common computed properties
    get showSpinner() {
        return this.isLoading;
    }
    
    get hasError() {
        return this.error !== null;
    }
    
    get errorMessage() {
        return this.error ? this.getErrorMessage(this.error) : '';
    }
    
    // Common utility methods
    
    /**
     * @description Shows a toast notification
     * @param title The toast title
     * @param message The toast message
     * @param variant The toast variant (success, error, warning, info)
     */
    showToast(title, message, variant = 'info') {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
    /**
     * @description Shows a success toast
     * @param title The toast title
     * @param message The toast message
     */
    showSuccessToast(title, message) {
        this.showToast(title, message, 'success');
    }
    
    /**
     * @description Shows an error toast
     * @param title The toast title
     * @param message The toast message
     */
    showErrorToast(title, message) {
        this.showToast(title, message, 'error');
    }
    
    /**
     * @description Shows a warning toast
     * @param title The toast title
     * @param message The toast message
     */
    showWarningToast(title, message) {
        this.showToast(title, message, 'warning');
    }
    
    /**
     * @description Shows an info toast
     * @param title The toast title
     * @param message The toast message
     */
    showInfoToast(title, message) {
        this.showToast(title, message, 'info');
    }
    
    /**
     * @description Handles errors consistently across all components
     * @param error The error object
     * @param context Optional context for logging
     */
    handleError(error, context = '') {
        this.error = error;
        
        // Log error for debugging
        console.error('Component error:', error);
        if (context) {
            console.error('Error context:', context);
        }
        
        // Show user-friendly error message
        this.showErrorToast('Error', this.getErrorMessage(error));
        
        // Update UI state
        this.updateErrorState();
    }
    
    /**
     * @description Gets a user-friendly error message from an error object
     * @param error The error object
     * @return String The user-friendly error message
     */
    getErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        }
        if (error.message) {
            return error.message;
        }
        if (error.detail && error.detail.detail) {
            return error.detail.detail;
        }
        return 'An unexpected error occurred. Please try again.';
    }
    
    /**
     * @description Clears the current error state
     */
    clearError() {
        this.error = null;
        this.updateErrorState();
    }
    
    /**
     * @description Updates the UI error state
     */
    updateErrorState() {
        // Override in child components if needed
        // This provides a hook for custom error state management
    }
    
    /**
     * @description Sets loading state with optional message
     * @param loading Whether to show loading state
     * @param message Optional loading message
     */
    setLoading(loading, message = 'Loading...') {
        this.isLoading = loading;
        this.loadingMessage = message;
    }
    
    /**
     * @description Starts loading with optional message
     * @param message Optional loading message
     */
    startLoading(message = 'Loading...') {
        this.setLoading(true, message);
    }
    
    /**
     * @description Stops loading
     */
    stopLoading() {
        this.setLoading(false);
    }
    
    /**
     * @description Executes an async operation with loading state and error handling
     * @param operation The async operation to execute
     * @param loadingMessage Optional loading message
     * @param context Optional context for error handling
     * @return Promise The result of the operation
     */
    async executeWithLoading(operation, loadingMessage = 'Processing...', context = '') {
        this.startLoading(loadingMessage);
        
        try {
            const result = await operation();
            this.clearError();
            return result;
        } catch (error) {
            this.handleError(error, context);
            throw error;
        } finally {
            this.stopLoading();
        }
    }
    
    /**
     * @description Validates required fields in a form
     * @param formData The form data object
     * @param requiredFields Array of required field names
     * @return Object Validation result with isValid boolean and missingFields array
     */
    validateRequiredFields(formData, requiredFields) {
        const missingFields = [];
        
        for (const field of requiredFields) {
            if (!formData[field] || 
                (typeof formData[field] === 'string' && formData[field].trim() === '') ||
                (Array.isArray(formData[field]) && formData[field].length === 0)) {
                missingFields.push(field);
            }
        }
        
        return {
            isValid: missingFields.length === 0,
            missingFields: missingFields
        };
    }
    
    /**
     * @description Shows validation error for missing required fields
     * @param missingFields Array of missing field names
     */
    showValidationError(missingFields) {
        const fieldList = missingFields.join(', ');
        this.showErrorToast(
            'Validation Error', 
            `Please fill in the following required fields: ${fieldList}`
        );
    }
    
    /**
     * @description Formats currency values consistently
     * @param amount The amount to format
     * @param currencyCode The currency code (default: USD)
     * @return String The formatted currency string
     */
    formatCurrency(amount, currencyCode = 'USD') {
        if (amount === null || amount === undefined) {
            return '$0.00';
        }
        
        const numAmount = parseFloat(amount);
        if (isNaN(numAmount)) {
            return '$0.00';
        }
        
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: currencyCode
        }).format(numAmount);
    }
    
    /**
     * @description Formats dates consistently
     * @param date The date to format
     * @param options Intl.DateTimeFormatOptions for formatting
     * @return String The formatted date string
     */
    formatDate(date, options = {}) {
        if (!date) {
            return '';
        }
        
        const defaultOptions = {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        };
        
        const formatOptions = { ...defaultOptions, ...options };
        
        try {
            const dateObj = new Date(date);
            return new Intl.DateTimeFormat('en-US', formatOptions).format(dateObj);
        } catch (error) {
            console.error('Error formatting date:', error);
            return '';
        }
    }
    
    /**
     * @description Debounces function calls to improve performance
     * @param func The function to debounce
     * @param wait The wait time in milliseconds
     * @return Function The debounced function
     */
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    /**
     * @description Throttles function calls to improve performance
     * @param func The function to throttle
     * @param limit The time limit in milliseconds
     * @return Function The throttled function
     */
    throttle(func, limit) {
        let inThrottle;
        return function executedFunction(...args) {
            if (!inThrottle) {
                func.apply(this, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    }
}
