import { LightningElement, track } from 'lwc';
import getRecentlyViewed from '@salesforce/apex/StoreConnectController.getRecentlyViewed';
import { NavigationMixin } from 'lightning/navigation';

export default class RecentlyViewed extends NavigationMixin(LightningElement) {
    @track recentlyViewed = [];
    @track isLoading = false;
    @track hasError = false;
    @track errorMessage;

    get hasRecentlyViewed() {
        return this.recentlyViewed && this.recentlyViewed.length > 0;
    }

    connectedCallback() {
        this.refreshRecentlyViewed();
    }

    async refreshRecentlyViewed() {
        this.isLoading = true;
        this.hasError = false;
        try {
            const products = await getRecentlyViewed();
            this.recentlyViewed = (products || []).map((p) => {
                const unitPrice =
                    p.PricebookEntries && p.PricebookEntries.length > 0
                        ? p.PricebookEntries[0].UnitPrice
                        : null;
                return { ...p, UnitPrice: unitPrice };
            });
        } catch (error) {
            this.hasError = true;
            this.errorMessage = error.body ? error.body.message : error.message;
        } finally {
            this.isLoading = false;
        }
    }

    handleProductClick(event) {
        const productId = event.currentTarget.dataset.productId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });
    }
}
