import { LightningElement, track, api, wire } from 'lwc';
import getOrCreateCart from '@salesforce/apex/StoreConnectController.getOrCreateCart';
import updateCartItemQuantity from '@salesforce/apex/StoreConnectController.updateCartItemQuantity';
import deleteCartItem from '@salesforce/apex/StoreConnectController.deleteCartItem';
import getShippingAddresses from '@salesforce/apex/StoreConnectController.getShippingAddresses';
import processCheckout from '@salesforce/apex/StoreConnectOrderProcessor.processCheckout';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ShoppingCart extends NavigationMixin(LightningElement) {
    @api recordId; // Contact ID from the community user
    @track cart;
    @track cartItems = [];
    @track shippingAddresses = [];
    @track selectedShippingAddress;
    @track loading = false;
    @track checkoutLoading = false;
    @track showCheckoutModal = false;
    
    // Cart totals
    get cartSubtotal() {
        return this.cart ? this.cart.Subtotal__c : 0;
    }
    
    get cartTotalItems() {
        return this.cart ? this.cart.Total_Items__c : 0;
    }
    
    get hasItems() {
        return this.cartItems && this.cartItems.length > 0;
    }
    
    get isCartEmpty() {
        return !this.hasItems;
    }
    
    // Lifecycle hooks
    connectedCallback() {
        this.loadCart();
        this.loadShippingAddresses();
    }
    
    // Load cart data
    async loadCart() {
        this.loading = true;
        try {
            this.cart = await getOrCreateCart({ contactId: this.recordId });
            this.cartItems = this.cart.Cart_Items__r || [];
        } catch (error) {
            this.showToast('Error', 'Failed to load cart: ' + error.body.message, 'error');
        } finally {
            this.loading = false;
        }
    }
    
    // Load shipping addresses
    async loadShippingAddresses() {
        try {
            this.shippingAddresses = await getShippingAddresses({ accountId: this.cart?.Contact__r?.AccountId });
            if (this.shippingAddresses.length > 0) {
                this.selectedShippingAddress = this.shippingAddresses[0].Id;
            }
        } catch (error) {
            this.showToast('Error', 'Failed to load shipping addresses: ' + error.body.message, 'error');
        }
    }
    
    // Update cart item quantity
    async handleQuantityChange(event) {
        const cartItemId = event.currentTarget.dataset.itemId;
        const newQuantity = parseInt(event.target.value);
        
        try {
            await updateCartItemQuantity({
                cartItemId: cartItemId,
                newQuantity: newQuantity
            });
            
            // Reload cart to get updated totals
            await this.loadCart();
            
            this.showToast('Success', 'Cart updated successfully', 'success');
            
        } catch (error) {
            this.showToast('Error', 'Failed to update cart: ' + error.body.message, 'error');
        }
    }
    
    // Remove item from cart
    async handleRemoveItem(event) {
        const cartItemId = event.currentTarget.dataset.itemId;
        
        try {
            await deleteCartItem({ cartItemId: cartItemId });
            
            // Reload cart
            await this.loadCart();
            
            this.showToast('Success', 'Item removed from cart', 'success');
            
        } catch (error) {
            this.showToast('Error', 'Failed to remove item: ' + error.body.message, 'error');
        }
    }
    
    // Handle shipping address selection
    handleShippingAddressChange(event) {
        this.selectedShippingAddress = event.target.value;
    }
    
    // Show checkout modal
    handleCheckout() {
        if (!this.selectedShippingAddress) {
            this.showToast('Error', 'Please select a shipping address', 'error');
            return;
        }
        this.showCheckoutModal = true;
    }
    
    // Close checkout modal
    handleCloseCheckoutModal() {
        this.showCheckoutModal = false;
    }
    
    // Process checkout
    async handleProcessCheckout() {
        this.checkoutLoading = true;
        try {
            const result = await processCheckout({
                cartId: this.cart.Id,
                shippingAddressId: this.selectedShippingAddress,
                paymentMethod: 'Credit Card' // This would come from a payment form
            });
            
            this.showToast('Success', `Order placed successfully! Order #${result.orderNumber}`, 'success');
            
            // Close modal and navigate to order confirmation
            this.showCheckoutModal = false;
            
            // Navigate to order detail page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result.orderId,
                    objectApiName: 'Order',
                    actionName: 'view'
                }
            });
            
        } catch (error) {
            this.showToast('Error', 'Checkout failed: ' + error.body.message, 'error');
        } finally {
            this.checkoutLoading = false;
        }
    }
    
    // Continue shopping
    handleContinueShopping() {
        // This would navigate back to the product catalog
        // For now, just dispatch an event
        this.dispatchEvent(new CustomEvent('continueshopping'));
    }
    
    // Utility methods
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
    
    // Format currency
    formatCurrency(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(amount || 0);
    }
    
    // Get shipping address display name
    getShippingAddressDisplay(addressId) {
        const address = this.shippingAddresses.find(addr => addr.Id === addressId);
        return address ? address.Address_Label__c : '';
    }
}
