import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
import CART_UPDATE_CHANNEL from '@salesforce/messageChannel/CartUpdate__c';
import getCartItems from '@salesforce/apex/CartController.getCartItems';
import updateItemQuantity from '@salesforce/apex/CartController.updateItemQuantity';
import deleteCartItem from '@salesforce/apex/CartController.deleteCartItem';

/**
 * @description Full Cart component for comprehensive cart management.
 * 
 * This component displays all cart items in a data table, allows users to
 * update quantities, delete items, and proceed to checkout. It integrates
 * with the LMS to notify other components of cart changes.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */

// Define columns for the datatable
const columns = [
    { 
        label: 'Product', 
        fieldName: 'ProductName', 
        type: 'text',
        sortable: true,
        wrapText: true
    },
    { 
        label: 'Quantity', 
        fieldName: 'Quantity__c', 
        type: 'number', 
        editable: true,
        sortable: true,
        initialWidth: 100
    },
    { 
        label: 'Unit Price', 
        fieldName: 'Unit_Price__c', 
        type: 'currency', 
        typeAttributes: { currencyCode: 'USD' },
        sortable: true,
        initialWidth: 120
    },
    { 
        label: 'Line Total', 
        fieldName: 'Line_Total__c', 
        type: 'currency', 
        typeAttributes: { currencyCode: 'USD' },
        sortable: true,
        initialWidth: 120
    },
    { 
        type: 'button-icon', 
        typeAttributes: { 
            iconName: 'utility:delete', 
            name: 'delete', 
            title: 'Delete Item',
            variant: 'bare',
            alternativeText: 'Delete'
        },
        initialWidth: 80
    }
];

export default class FullCart extends NavigationMixin(LightningElement) {
    
    // Data table configuration
    columns = columns;
    draftValues = [];
    
    // Wire service results
    wiredCartResult;
    
    // Component state
    isLoading = false;
    hasError = false;
    errorMessage = '';

    // Wire the MessageContext for publishing cart updates
    @wire(MessageContext)
    messageContext;

    // Wire the cart items from Apex
    @wire(getCartItems)
    wiredCart(result) {
        this.wiredCartResult = result;
        
        if (result.data) {
            this.hasError = false;
            this.errorMessage = '';
        } else if (result.error) {
            this.hasError = true;
            this.errorMessage = result.error.body ? result.error.body.message : 'Unable to load cart items.';
            console.error('Error loading cart items:', result.error);
        }
    }

    /**
     * @description Computed property to flatten the data for the datatable.
     * Maps the Product__r.Name to ProductName for display.
     * 
     * @returns {Array} Array of cart items with flattened product names
     */
    get cartItems() {
        if (!this.wiredCartResult?.data) {
            return [];
        }
        
        return this.wiredCartResult.data.map(item => ({
            ...item,
            ProductName: item.Product__r?.Name || 'Unknown Product'
        }));
    }

    /**
     * @description Computed property for the cart's subtotal.
     * Calculates the sum of all line totals.
     * 
     * @returns {number} The total value of all cart items
     */
    get subtotal() {
        if (!this.cartItems || this.cartItems.length === 0) {
            return 0;
        }
        
        return this.cartItems.reduce((total, item) => {
            const lineTotal = item.Line_Total__c || 0;
            return total + lineTotal;
        }, 0);
    }

    /**
     * @description Computed property for the total number of items.
     * Calculates the sum of all quantities.
     * 
     * @returns {number} The total number of items in the cart
     */
    get totalItems() {
        if (!this.cartItems || this.cartItems.length === 0) {
            return 0;
        }
        
        return this.cartItems.reduce((total, item) => {
            const quantity = item.Quantity__c || 0;
            return total + quantity;
        }, 0);
    }

    /**
     * @description Computed property to determine if the cart is empty.
     * 
     * @returns {boolean} True if the cart has no items
     */
    get isCartEmpty() {
        return !this.cartItems || this.cartItems.length === 0;
    }

    /**
     * @description Computed property to determine if the cart has items.
     * 
     * @returns {boolean} True if the cart has items
     */
    get hasCartItems() {
        return !this.isCartEmpty;
    }

    /**
     * @description Handles row actions from the data table.
     * Currently supports delete operations.
     * 
     * @param {Event} event - The row action event from the datatable
     */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'delete') {
            this.handleDeleteItem(row.Id);
        }
    }

    /**
     * @description Handles deleting a cart item.
     * Calls the Apex method and refreshes the cart display.
     * 
     * @param {string} cartItemId - The ID of the cart item to delete
     */
    handleDeleteItem(cartItemId) {
        this.isLoading = true;
        
        deleteCartItem({ cartItemId: cartItemId })
            .then(() => {
                this.showSuccessToast('Item Removed', 'Item has been removed from your cart.');
                this.refreshCart();
            })
            .catch(error => {
                this.showErrorToast('Error Removing Item', error.body ? error.body.message : 'Unable to remove item from cart.');
                console.error('Error deleting cart item:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /**
     * @description Handles saving changes from the data table.
     * Processes quantity updates and refreshes the cart.
     * 
     * @param {Event} event - The save event from the datatable
     */
    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        
        if (!updatedFields || updatedFields.length === 0) {
            return;
        }
        
        this.isLoading = true;
        
        // Process all updates in parallel
        const promises = updatedFields.map(field => {
            const cartItemId = field.Id;
            const quantity = parseInt(field.Quantity__c, 10);
            
            // Validate quantity
            if (isNaN(quantity) || quantity < 0) {
                return Promise.reject(new Error('Invalid quantity value.'));
            }
            
            return updateItemQuantity({ cartItemId, quantity });
        });

        Promise.all(promises)
            .then(() => {
                this.draftValues = []; // Clear draft values
                this.showSuccessToast('Cart Updated', 'Your cart has been updated successfully.');
                this.refreshCart();
            })
            .catch(error => {
                this.showErrorToast('Error Updating Cart', error.message || 'Unable to update cart items.');
                console.error('Error updating cart items:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /**
     * @description Refreshes the cart data and notifies other components.
     * Uses refreshApex to update the wire service and publishes an LMS message.
     */
    refreshCart() {
        // Refresh the Apex wire service
        if (this.wiredCartResult) {
            refreshApex(this.wiredCartResult);
        }
        
        // Publish message to update other components like the mini-cart
        if (this.messageContext) {
            const payload = { source: 'FullCart' };
            publish(this.messageContext, CART_UPDATE_CHANNEL, payload);
        }
    }

    /**
     * @description Handles the proceed to checkout button click.
     * Navigates to the Checkout Screen Flow for shipping address selection.
     */
    handleProceedToCheckout() {
        // Navigate to the Checkout Flow
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/flow/Checkout'
            }
        });
    }

    /**
     * @description Handles the continue shopping button click.
     * Navigates back to the product catalog.
     */
    handleContinueShopping() {
        // TODO: Implement navigation to product catalog
        this.showInfoToast('Navigation', 'Continue shopping functionality will be implemented.');
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
