import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuotes from '@salesforce/apex/QuoteService.getQuotes';
import createQuote from '@salesforce/apex/QuoteService.createQuote';

/**
 * @description My Quotes component displays and manages quotes for the current user.
 *
 * This component allows users to view a summary of their quotes, refresh the
 * list to get the latest data, and create new quotes from the active cart.
 */
export default class MyQuotes extends LightningElement {
    // Component state
    quotes = [];
    isLoading = false;
    hasError = false;
    errorMessage = '';

    // Summary data
    totalQuotes = 0;
    totalValue = 0;
    quotesByStatus = [];

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
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        {
            type: 'action',
            typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] }
        }
    ];

    /**
     * @description Lifecycle hook to load quotes when component is inserted.
     */
    connectedCallback() {
        this.refreshQuotes();
    }

    /**
     * @description Loads the quotes from the server and calculates summary fields.
     */
    async refreshQuotes() {
        this.isLoading = true;
        this.hasError = false;
        this.errorMessage = '';

        try {
            const data = await getQuotes();
            this.quotes = data || [];
            this.calculateSummaries();
        } catch (error) {
            this.hasError = true;
            this.errorMessage = error?.body?.message || error.message || 'Unable to load quotes.';
            console.error('Error loading quotes:', error);
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * @description Creates a new quote from the active cart and refreshes the list.
     */
    async handleCreateNewQuote() {
        this.isLoading = true;

        try {
            await createQuote();
            this.showToast('Quote Created', 'Your cart has been converted to a quote.', 'success');
            await this.refreshQuotes();
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
    }

    /**
     * @description Calculates summary information for the quotes list.
     */
    calculateSummaries() {
        this.totalQuotes = this.quotes.length;
        this.totalValue = this.quotes.reduce((sum, q) => sum + (q.GrandTotal || 0), 0);

        const statusMap = {};
        this.quotes.forEach(q => {
            const status = q.Status || 'Unknown';
            statusMap[status] = (statusMap[status] || 0) + 1;
        });
        this.quotesByStatus = Object.keys(statusMap).map(key => ({ key, value: statusMap[key] }));
    }

    /**
     * @description Convenience getter to check if there are quotes.
     */
    get hasQuotes() {
        return this.quotes && this.quotes.length > 0;
    }

    /**
     * @description Displays a toast message.
     *
     * @param {string} title - Toast title
     * @param {string} message - Toast message
     * @param {string} variant - Toast variant (success, error, etc.)
     */
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
