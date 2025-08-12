import { LightningElement, api, track } from 'lwc';
import getQuotes from '@salesforce/apex/QuoteService.getQuotes';
import createQuote from '@salesforce/apex/QuoteService.createQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyQuotes extends LightningElement {
    @api recordId; // Account Id
    @track quotes = [];
    @track isLoading = false;
    @track errorMessage;

    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Total', fieldName: 'TotalPrice', type: 'currency' },
        { label: 'Created', fieldName: 'CreatedDate', type: 'date' }
    ];

    get hasQuotes() {
        return this.quotes.length > 0;
    }

    get hasError() {
        return !!this.errorMessage;
    }

    get totalQuotes() {
        return this.quotes.length;
    }

    get totalValue() {
        return this.quotes.reduce((sum, q) => sum + (q.TotalPrice || 0), 0);
    }

    get quotesByStatus() {
        const map = {};
        this.quotes.forEach(q => {
            map[q.Status] = (map[q.Status] || 0) + 1;
        });
        return Object.keys(map).map(key => ({ key, value: map[key] }));
    }

    connectedCallback() {
        this.loadQuotes();
    }

    async loadQuotes() {
        this.isLoading = true;
        try {
            this.quotes = await getQuotes({ accountId: this.recordId });
            this.errorMessage = undefined;
        } catch (e) {
            this.errorMessage = e.body ? e.body.message : e.message;
            this.quotes = [];
        } finally {
            this.isLoading = false;
        }
    }

    refreshQuotes() {
        this.loadQuotes();
    }

    async handleCreateNewQuote() {
        this.isLoading = true;
        try {
            await createQuote({ accountId: this.recordId });
            this.showToast('Success', 'Quote created', 'success');
            await this.loadQuotes();
        } catch (e) {
            this.showToast('Error', e.body ? e.body.message : e.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
