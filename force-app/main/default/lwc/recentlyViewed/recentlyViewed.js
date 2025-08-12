import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRecentlyViewed from '@salesforce/apex/ProductController.getRecentlyViewed';

/**
 * @description Recently Viewed component for displaying products the user has recently viewed.
 * 
 * This component shows products based on View_Tracking__c records, providing
 * personalized recommendations based on user browsing behavior.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */

export default class RecentlyViewed extends LightningElement {
    
    // Wire service results
    wiredRecentlyViewedResult;
    
    // Component state
    isLoading = false;
    hasError = false;
    errorMessage = '';

    // Wire the recently viewed products from Apex
    @wire(getRecentlyViewed)
    wiredRecentlyViewed(result) {
        this.wiredRecentlyViewedResult = result;
        
        if (result.data) {
            this.hasError = false;
            this.errorMessage = '';
        } else if (result.error) {
            this.hasError = true;
            this.errorMessage = result.error.body ? result.error.body.message : 'Unable to load recently viewed products.';
            console.error('Error loading recently viewed products:', result.error);
        }
    }

    /**
     * @description Computed property to get the recently viewed products data.
     * 
     * @returns {Array} Array of recently viewed products
     */
    get recentlyViewed() {
        return this.wiredRecentlyViewedResult?.data || [];
    }

    /**
     * @description Computed property to determine if there are recently viewed products to display.
     * 
     * @returns {boolean} True if there are recently viewed products available
     */
    get hasRecentlyViewed() {
        return this.recentlyViewed && this.recentlyViewed.length > 0;
    }

    /**
     * @description Computed property to determine if the recently viewed list is empty.
     * 
     * @returns {boolean} True if there are no recently viewed products
     */
    get isRecentlyViewedEmpty() {
        return !this.hasRecentlyViewed;
    }

    /**
     * @description Computed property to get the total number of recently viewed products.
     * 
     * @returns {number} The total number of recently viewed products
     */
    get totalRecentlyViewed() {
        return this.recentlyViewed ? this.recentlyViewed.length : 0;
    }

    /**
     * @description Refreshes the recently viewed products data.
     * Uses refreshApex to update the wire service.
     */
    refreshRecentlyViewed() {
        this.isLoading = true;
        
        if (this.wiredRecentlyViewedResult) {
            refreshApex(this.wiredRecentlyViewedResult)
                .then(() => {
                    this.showSuccessToast('Recently Viewed Refreshed', 'Recently viewed products have been updated.');
                })
                .catch(error => {
                    this.showErrorToast('Refresh Failed', 'Unable to refresh recently viewed products.');
                    console.error('Error refreshing recently viewed products:', error);
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } else {
            this.isLoading = false;
        }
    }

    /**
     * @description Handles clicking on a recently viewed product.
     * Navigates to the product detail page.
     * 
     * @param {Event} event - The click event from the product card
     */
    handleProductClick(event) {
        const productId = event.currentTarget.dataset.productId;
        if (productId) {
            // Navigate to product detail page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: productId,
                    actionName: 'view'
                }
            });
        }
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
}

