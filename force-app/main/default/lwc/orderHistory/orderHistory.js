import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrders from '@salesforce/apex/OrderService.getOrders';

/**
 * @description Order History component for displaying user's past orders.
 * 
 * This component shows a comprehensive list of all orders placed by the current user,
 * including order details, status, and amounts.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
export default class OrderHistory extends LightningElement {
    
    // Wire service result for storing and refreshing
    wiredOrdersResult;
    
    // Component state
    isLoading = false;
    hasError = false;
    errorMessage = '';

    // Data table columns configuration
    columns = [
        { label: 'Order Number', fieldName: 'OrderNumber', type: 'text', sortable: true },
        { label: 'Order Date', fieldName: 'EffectiveDate', type: 'date', sortable: true },
        { label: 'Status', fieldName: 'Status', type: 'text', sortable: true },
        { label: 'Total Amount', fieldName: 'TotalAmount', type: 'currency', sortable: true, 
          typeAttributes: { currencyCode: 'USD' } }
    ];

    // Default sorting configuration
    defaultSortBy = 'EffectiveDate';
    defaultSortDirection = 'desc';

    // Wire the orders from Apex
    @wire(getOrders)
    wiredOrders(result) {
        this.wiredOrdersResult = result;
        
        if (result.data) {
            this.hasError = false;
            this.errorMessage = '';
        } else if (result.error) {
            this.hasError = true;
            this.errorMessage = result.error.body ? result.error.body.message : 'Unable to load orders.';
            console.error('Error loading orders:', result.error);
        }
    }

    /**
     * @description Computed property for the orders data.
     * Provides the current orders from the wired Apex result.
     * 
     * @returns {Array} Array of order records, or empty array if no data
     */
    get orders() {
        return this.wiredOrdersResult?.data ?? [];
    }

    /**
     * @description Computed property to determine if there are orders to display.
     * 
     * @returns {boolean} True if there are orders, false otherwise
     */
    get hasOrders() {
        return this.orders && this.orders.length > 0;
    }

    /**
     * @description Computed property to determine if the orders are loading.
     * 
     * @returns {boolean} True if orders are still loading
     */
    get isLoading() {
        return !this.wiredOrdersResult || (!this.wiredOrdersResult.data && !this.wiredOrdersResult.error);
    }

    /**
     * @description Computed property to determine if there's an error loading orders.
     * 
     * @returns {boolean} True if there's an error loading orders
     */
    get hasError() {
        return this.wiredOrdersResult && this.wiredOrdersResult.error;
    }

    /**
     * @description Computed property for the total number of orders.
     * 
     * @returns {number} The total number of orders
     */
    get totalOrders() {
        return this.orders.length;
    }

    /**
     * @description Computed property for the total value of all orders.
     * 
     * @returns {number} The total value of all orders
     */
    get totalOrderValue() {
        if (!this.orders || this.orders.length === 0) {
            return 0;
        }
        
        return this.orders.reduce((total, order) => {
            const amount = order.TotalAmount || 0;
            return total + amount;
        }, 0);
    }

    /**
     * @description Computed property for the average order value.
     * 
     * @returns {number} The average order value
     */
    get averageOrderValue() {
        if (!this.hasOrders) {
            return 0;
        }
        
        return this.totalOrderValue / this.totalOrders;
    }

    /**
     * @description Handles row selection in the data table.
     * Currently logs the selection for future enhancement.
     * 
     * @param {Event} event - The row selection event
     */
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('Selected orders:', selectedRows);
        
        // TODO: Implement order detail view or actions
        // This could open a modal, navigate to order detail page, etc.
    }

    /**
     * @description Handles sorting in the data table.
     * Currently logs the sorting for future enhancement.
     * 
     * @param {Event} event - The sorting event
     */
    handleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        console.log('Sorting by:', fieldName, 'Direction:', sortDirection);
        
        // TODO: Implement custom sorting logic if needed
        // The lightning-datatable handles basic sorting automatically
    }

    /**
     * @description Refreshes the orders data.
     * Uses refreshApex to update the wire service.
     */
    refreshOrders() {
        this.isLoading = true;
        
        // Use refreshApex to update the wire service
        if (this.wiredOrdersResult) {
            refreshApex(this.wiredOrdersResult);
        }
        this.isLoading = false;
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
     * @description Handles the refresh button click.
     * Refreshes the orders data and shows a success message.
     */
    handleRefresh() {
        this.refreshOrders();
        this.showSuccessToast('Orders Refreshed', 'Your order history has been updated.');
    }

    /**
     * @description Handles the continue shopping button click.
     * Navigates back to the product catalog.
     */
    handleContinueShopping() {
        // TODO: Implement navigation to product catalog
        this.showSuccessToast('Navigation', 'Continue shopping functionality will be implemented.');
    }
}
