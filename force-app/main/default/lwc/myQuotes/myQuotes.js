import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotes from '@salesforce/apex/QuoteService.getQuotes';
import getQuotesForAccount from '@salesforce/apex/QuoteService.getQuotesForAccount';
import createQuoteFromCart from '@salesforce/apex/QuoteService.createQuoteFromCart';
import createQuote from '@salesforce/apex/QuoteService.createQuote';

/**
 * @description My Quotes component displays and manages quotes for the current user or specified account.
 *
 * This component allows users to view a summary of their quotes, refresh the
 * list to get the latest data, and create new quotes. It can work in two modes:
 * - Standalone mode: Automatically gets current user's quotes
 * - Account mode: Gets quotes for a specific account (when recordId is provided)
 */
export default class MyQuotes extends LightningElement {
    // Public properties
    @api recordId; // Account Id - when provided, component works in account mode

    // Component state
    @track quotes = [];
    @track isLoading = false;
    @track hasError = false;
    @track errorMessage = '';

    // Summary data (computed getters)
    get totalQuotes() {
        return this.quotes.length;
    }

    get totalValue() {
        return this.quotes.reduce((sum, q) => sum + (q.GrandTotal || q.TotalPrice || 0), 0);
    }

    get quotesByStatus() {
        const statusMap = {};
        this.quotes.forEach(q => {
            const status = q.Status || 'Unknown';
            statusMap[status] = (statusMap[status] || 0) + 1;
        });
        return Object.keys(statusMap).map(key => ({ 
            key, 
            value: statusMap[key] 
        }));
    }

    get hasQuotes() {
        return this.quotes && this.quotes.length > 0;
    }

    get isAccountMode() {
        return !!this.recordId;
    }

    get createButtonLabel() {
        return this.isAccountMode ? 'Create New Quote' : 'Create Quote from Cart';
    }

    // Data table configuration
    columns = [
        { label: 'Quote Name', fieldName: 'Name', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        {
            label: 'Total',
            fieldName: 'GrandTotal',
            type: 'currency',
            typeAttributes: { currencyCode: 'USD' }
        },
        {
            label: 'Total Price',
            fieldName: 'TotalPrice', 
            type: 'currency',
            typeAttributes: { currencyCode: 'USD' }
        },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        {
            type: 'action',
            typeAttributes: { 
                rowActions: [
                    { label: 'View', name: 'view' }
                ] 
            }
        }
    ];

    /**
     * @description Lifecycle hook to load quotes when component is inserted.
     */
    connectedCallback() {
        this.loadQuotes();
    }

    /**
     * @description Loads the quotes from the server based on the component mode.
     */
    async loadQuotes() {
        this.isLoading = true;
        this.hasError = false;
        this.errorMessage = '';

        try {
            let data;
            if (this.isAccountMode) {
                // Account mode: get quotes for specific account
                data = await getQuotesForAccount({ accountId: this.recordId });
            } else {
                // Standalone mode: get quotes for current user
                data = await getQuotes();
            }
            
            this.quotes = data || [];
        } catch (error) {
            this.hasError = true;
            this.errorMessage = error?.body?.message || error.message || 'Unable to load quotes.';
            this.quotes = [];
            console.error('Error loading quotes:', error);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * @description Refreshes the quotes list.
     */
    refreshQuotes() {
        this.loadQuotes();
    }

    /**
     * @description Creates a new quote based on the component mode.
     */
    async handleCreateNewQuote() {
        this.isLoading = true;

        try {
            if (this.isAccountMode) {
                // Account mode: create simple quote for account
                await createQuote({ accountId: this.recordId });
                this.showToast('Quote Created', 'New quote has been created successfully.', 'success');
            } else {
                // Standalone mode: create quote from active cart
                await createQuoteFromCart();
                this.showToast('Quote Created', 'Your cart has been converted to a quote.', 'success');
            }
            
            await this.loadQuotes();
        } catch (error) {
            const message = error?.body?.message || error.message || 'Unable to create quote.';
            this.showToast('Error', message, 'error');
            console.error('Error creating quote:', error);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * @description Handles selection of rows in the quote table.
     * Currently logs selection for future enhancements.
     *
     * @param {Event} event - Datatable row selection event
     */
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('Selected quotes:', selectedRows);
        // Future: Could dispatch custom event for parent components
    }

    /**
     * @description Handles row actions from the quote table.
     * Currently logs the action for future enhancements.
     *
     * @param {Event} event - Datatable row action event
     */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('Row action:', actionName, row);
        
        if (actionName === 'view') {
            // Future: Navigate to quote detail or dispatch event
            this.showToast('View Quote', `Viewing quote: ${row.Name}`, 'info');
        }
    }

    /**
     * @description Displays a toast message.
     *
     * @param {string} title - Toast title
     * @param {string} message - Toast message
     * @param {string} variant - Toast variant (success, error, info, warning)
     */
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}