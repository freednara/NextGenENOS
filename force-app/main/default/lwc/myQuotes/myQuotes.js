import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getQuotes from '@salesforce/apex/QuoteService.getQuotes';

/**
 * @description My Quotes component for displaying user's quote history.
 * 
 * This component shows all quotes for the current user's account in a data table,
 * with options to view quote details and track quote status.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */

// Define columns for the quotes datatable
const columns = [
    { 
        label: 'Quote Name', 
        fieldName: 'Name', 
        type: 'text',
        sortable: true,
        wrapText: true
    },
    { 
        label: 'Status', 
        fieldName: 'Status', 
        type: 'text',
        sortable: true,
        initialWidth: 120
    },
    { 
        label: 'Total Amount', 
        fieldName: 'GrandTotal', 
        type: 'currency', 
        typeAttributes: { currencyCode: 'USD' },
        sortable: true,
        initialWidth: 140
    },
    { 
        label: 'Created Date', 
        fieldName: 'CreatedDate', 
        type: 'date',
        typeAttributes: { 
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        },
        sortable: true,
        initialWidth: 140
    },
    { 
        label: 'Expiration Date', 
        fieldName: 'ExpirationDate', 
        type: 'date',
        typeAttributes: { 
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        },
        sortable: true,
        initialWidth: 140
    }
];

export default class MyQuotes extends LightningElement {
    
    // Data table configuration
    columns = columns;
    
    // Wire service results
    wiredQuotesResult;
    
    // Component state
    isLoading = false;
    hasError = false;
    errorMessage = '';

    // Wire the quotes from Apex
    @wire(getQuotes)
    wiredQuotes(result) {
        this.wiredQuotesResult = result;
        
        if (result.data) {
            this.hasError = false;
            this.errorMessage = '';
        } else if (result.error) {
            this.hasError = true;
            this.errorMessage = result.error.body ? result.error.body.message : 'Unable to load quotes.';
            console.error('Error loading quotes:', result.error);
        }
    }

    /**
     * @description Computed property to get the quotes data for the datatable.
     * 
     * @returns {Array} Array of quote records
     */
    get quotes() {
        return this.wiredQuotesResult?.data || [];
    }

    /**
     * @description Computed property to determine if there are quotes to display.
     * 
     * @returns {boolean} True if there are quotes available
     */
    get hasQuotes() {
        return this.quotes && this.quotes.length > 0;
    }

    /**
     * @description Computed property to determine if the quotes list is empty.
     * 
     * @returns {boolean} True if there are no quotes
     */
    get isQuotesEmpty() {
        return !this.hasQuotes;
    }

    /**
     * @description Computed property to get the total number of quotes.
     * 
     * @returns {number} The total number of quotes
     */
    get totalQuotes() {
        return this.quotes ? this.quotes.length : 0;
    }

    /**
     * @description Computed property to get the total value of all quotes.
     * 
     * @returns {number} The total value of all quotes
     */
    get totalValue() {
        if (!this.quotes || this.quotes.length === 0) {
            return 0;
        }
        
        return this.quotes.reduce((total, quote) => {
            const grandTotal = quote.GrandTotal || 0;
            return total + grandTotal;
        }, 0);
    }

    /**
     * @description Computed property to get quotes by status for summary display.
     * 
     * @returns {Object} Object with counts for each quote status
     */
    get quotesByStatus() {
        if (!this.quotes || this.quotes.length === 0) {
            return {};
        }
        
        const statusCounts = {};
        this.quotes.forEach(quote => {
            const status = quote.Status || 'Unknown';
            statusCounts[status] = (statusCounts[status] || 0) + 1;
        });
        
        return statusCounts;
    }

    /**
     * @description Handles row selection in the datatable.
     * Currently logs the selection for future enhancement.
     * 
     * @param {Event} event - The row selection event from the datatable
     */
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('Selected quotes:', selectedRows);
        
        // TODO: Implement quote detail view or bulk actions
        if (selectedRows.length > 0) {
            this.showInfoToast('Quote Selected', `${selectedRows.length} quote(s) selected.`);
        }
    }

    /**
     * @description Handles row actions from the datatable.
     * Currently supports view operations for future enhancement.
     * 
     * @param {Event} event - The row action event from the datatable
     */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'view') {
            this.handleViewQuote(row.Id);
        }
    }

    /**
     * @description Handles viewing a specific quote.
     * Currently shows a toast message for future enhancement.
     * 
     * @param {string} quoteId - The ID of the quote to view
     */
    handleViewQuote(quoteId) {
        // TODO: Implement quote detail view navigation
        this.showInfoToast('Quote View', `Viewing quote: ${quoteId}`);
    }

    /**
     * @description Refreshes the quotes data.
     * Uses refreshApex to update the wire service.
     */
    refreshQuotes() {
        this.isLoading = true;
        
        if (this.wiredQuotesResult) {
            refreshApex(this.wiredQuotesResult)
                .then(() => {
                    this.showSuccessToast('Quotes Refreshed', 'Your quotes have been updated.');
                })
                .catch(error => {
                    this.showErrorToast('Refresh Failed', 'Unable to refresh quotes.');
                    console.error('Error refreshing quotes:', error);
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } else {
            this.isLoading = false;
        }
    }

    /**
     * @description Handles the create new quote button click.
     * Currently shows a toast message for future enhancement.
     */
    handleCreateNewQuote() {
        // TODO: Implement navigation to quote creation
        this.showInfoToast('Create Quote', 'Quote creation functionality will be implemented.');
    }

    /**
     * @description Shows a success toast notification.
     * 
     * @param {string} title - The toast title
     * @param {string} message - The toast message
     */
    showSuccessToast(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success'
        }));
    }

    /**
     * @description Shows an error toast notification.
     * 
     * @param {string} title - The toast title
     * @param {string} message - The toast message
     */
    showErrorToast(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error'
        }));
    }

    /**
     * @description Shows an info toast notification.
     * 
     * @param {string} title - The toast title
     * @param {string} message - The toast message
     */
    showInfoToast(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'info'
        }));
    }
}
