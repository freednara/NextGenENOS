import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getProductById from '@salesforce/apex/ProductController.getProductById';
import addItemToCart from '@salesforce/apex/CartController.addItemToCart';

/**
 * @description Product Detail component for displaying comprehensive product information.
 * 
 * This component provides detailed product views with images, descriptions, pricing,
 * and add-to-cart functionality. It uses the @wire service for automatic data binding
 * and implements responsive design for optimal user experience.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
export default class ProductDetail extends LightningElement {
    @api recordId;
    quantity = 1;
    
    /**
     * @description Handles the Add to Cart button click.
     * This method calls the CartController to add the selected product to the user's cart.
     * 
     * @param {Event} event - The click event from the Add to Cart button
     */
    handleAddToCart(event) {
        if (!this.product || !this.product.data) {
            this.showToast('Error', 'Product information not available', 'error');
            return;
        }
        
        // Validate quantity before proceeding
        if (this.quantity < 1) {
            this.showToast('Invalid Quantity', 'Please select a valid quantity', 'error');
            return;
        }
        
        // Check stock availability
        if (this.product.data.Stock_Quantity__c && this.quantity > this.product.data.Stock_Quantity__c) {
            this.showToast('Insufficient Stock', 'Requested quantity exceeds available stock', 'error');
            return;
        }
        
        // Set loading state
        this.isAddingToCart = true;
        
        // Call the CartController to add the item to cart
        addItemToCart({ 
            productId: this.recordId, 
            quantity: this.quantity 
        })
        .then(result => {
            // Success - item added to cart
            this.isAddingToCart = false;
            
            this.showToast(
                'Success', 
                `${this.quantity} x ${this.product.data.Name} added to cart!`, 
                'success'
            );
            
            // Reset quantity to 1 for next addition
            this.quantity = 1;
            
            // TODO: Future enhancements
            // 1. Update cart display if cart component is visible
            // 2. Show cart preview or mini-cart
            // 3. Navigate to cart page
            // 4. Update cart count in header
            
        })
        .catch(error => {
            // Error occurred while adding to cart
            this.isAddingToCart = false;
            
            console.error('Error adding to cart:', error);
            
            // Show user-friendly error message
            this.showToast(
                'Error Adding to Cart', 
                error.body ? error.body.message : 'Unable to add item to cart. Please try again.', 
                'error'
            );
        });
    }
    
    /**
     * @description Handles the Go Back button click.
     * Navigates the user back to the products page.
     * 
     * @param {Event} event - The click event from the Go Back button
     */
    handleGoBack(event) {
        // Navigate back to the products page
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/products' // This will be configured based on your site structure
            }
        });
        
        // Alternative navigation method for Experience Cloud sites
        // this[NavigationMixin.Navigate]({
        //     type: 'comm__namedPage',
        //     attributes: {
        //         name: 'Products' // The name of your products page
        //     }
        // });
    }
    
    /**
     * @description Handles image loading errors gracefully.
     * Shows a placeholder when product images fail to load.
     * 
     * @param {Event} event - The error event from the image element
     */
    handleImageError(event) {
        const imageContainer = event.currentTarget.closest('.product-image-container');
        
        if (imageContainer) {
            // Replace the broken image with a placeholder
            imageContainer.innerHTML = `
                <div class="slds-var-p-around_large slds-text-align_center placeholder-image">
                    <lightning-icon 
                        icon-name="standard:products" 
                        size="x-large" 
                        alternative-text="Image Unavailable">
                    </lightning-icon>
                    <p class="slds-var-p-top_small slds-text-color_weak">Image unavailable</p>
                </div>
            `;
        }
    }
    
    /**
     * @description Shows a toast notification to the user.
     * Provides consistent user feedback for various actions and errors.
     * 
     * @param {string} title - The title of the toast message
     * @param {string} message - The message content
     * @param {string} variant - The toast variant (success, error, warning, info)
     */
    showToast(title, message, variant = 'info') {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    
    /**
     * @description Getter for computed properties and data transformation.
     * These getters provide reactive data that automatically updates when the source changes.
     */
    
    /**
     * @description Returns whether the product is currently loading.
     * Used to show/hide the loading spinner.
     */
    get isLoading() {
        return !this.product || (!this.product.data && !this.product.error);
    }
    
    /**
     * @description Returns whether there's an error to display.
     * Used to show error messages when API calls fail.
     */
    get hasError() {
        return this.product && this.product.error;
    }
    
    /**
     * @description Returns whether the product data is available.
     * Used to show the product detail content.
     */
    get hasProductData() {
        return this.product && this.product.data;
    }
    
    /**
     * @description Returns whether the product has a price.
     * Used to show/hide pricing information.
     */
    get hasPrice() {
        return this.product && 
               this.product.data && 
               this.product.data.PricebookEntries && 
               this.product.data.PricebookEntries.records && 
               this.product.data.PricebookEntries.records.length > 0;
    }
    
    /**
     * @description Returns the product price for display.
     * Provides the price from the first available PricebookEntry.
     */
    get productPrice() {
        if (this.hasPrice) {
            return this.product.data.PricebookEntries.records[0].UnitPrice;
        }
        return null;
    }
    
    /**
     * @description Returns whether the product has stock information.
     * Used to show/hide stock-related features.
     */
    get hasStockInfo() {
        return this.product && 
               this.product.data && 
               this.product.data.Stock_Quantity__c !== undefined && 
               this.product.data.Stock_Quantity__c !== null;
    }
    
    /**
     * @description Returns whether the product is a top seller.
     * Used to show the top seller badge.
     */
    get isTopSeller() {
        return this.product && 
               this.product.data && 
               this.product.data.Is_Top_Seller__c === true;
    }
    
    /**
     * @description Returns whether the add to cart button should be disabled.
     * Disables the button when loading or when quantity is invalid.
     */
    get isAddToCartDisabled() {
        return this.isAddingToCart || 
               this.quantity < 1 || 
               (this.hasStockInfo && this.quantity > this.product.data.Stock_Quantity__c);
    }
}
