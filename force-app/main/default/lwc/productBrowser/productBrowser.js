import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getProducts from '@salesforce/apex/ProductController.getProducts';
import searchProducts from '@salesforce/apex/ProductController.searchProducts';

/**
 * @description Product Browser component for displaying and searching products.
 * 
 * This component provides a responsive grid layout for products with search functionality,
 * error handling, and user interaction features. It uses the @wire service for
 * automatic data binding and caching.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
export default class ProductBrowser extends NavigationMixin(LightningElement) {
    
    // Wire service for fetching products - automatically handles caching and server calls
    @wire(getProducts)
    products;
    
    // Track component state
    @track isAddingToCart = false;
    @track searchTerm = '';
    @track debounceTimer;
    
    /**
     * @description Handles search input changes with debouncing for performance.
     * Debouncing prevents excessive API calls while the user is typing.
     * 
     * @param {Event} event - The change event from the search input
     */
    handleSearch(event) {
        // Clear any existing timer
        if (this.debounceTimer) {
            clearTimeout(this.debounceTimer);
        }
        
        // Set a new timer to execute search after user stops typing
        this.debounceTimer = setTimeout(() => {
            this.performSearch(event.target.value);
        }, 300); // 300ms delay for optimal user experience
    }
    
    /**
     * @description Performs the actual search operation.
     * This method calls the Apex search method and updates the component state.
     * 
     * @param {string} searchTerm - The search term to look for
     */
    async performSearch(searchTerm) {
        try {
            this.searchTerm = searchTerm;
            
            if (searchTerm && searchTerm.trim().length > 0) {
                // Call the search method and update the products data
                const searchResults = await searchProducts({ searchTerm: searchTerm.trim() });
                this.products = { data: searchResults, error: undefined };
            } else {
                // If no search term, refresh the original products
                this.refreshProducts();
            }
        } catch {
            // Log error for debugging (remove in production)
            this.showToast('Error', 'Unable to search products. Please try again.', 'error');
        }
    }
    
    /**
     * @description Refreshes the products list by calling the original wire method.
     * This is used when clearing search results or handling errors.
     */
    refreshProducts() {
        // Force a refresh of the wire service
        this.products = undefined;
        // The @wire decorator will automatically re-execute
    }
    
    /**
     * @description Handles the "Show All Products" button click.
     * Clears the search and shows all available products.
     */
    handleShowAllProducts() {
        this.searchTerm = '';
        this.refreshProducts();
        
        // Clear the search input field
        const searchInput = this.template.querySelector('lightning-input');
        if (searchInput) {
            searchInput.value = '';
        }
    }
    
    /**
     * @description Handles adding a product to the shopping cart.
     * This method will be implemented in future sprints when cart functionality is added.
     * 
     * @param {Event} event - The click event from the Add to Cart button
     */
    handleAddToCart(event) {
        // Prevent event bubbling to avoid triggering navigation
        event.stopPropagation();
        
        // For now, show a toast message indicating the feature is coming soon
        this.showToast(
            'Coming Soon', 
            'Add to Cart functionality will be available in the next update!', 
            'info'
        );
        
        // TODO: Implement cart functionality in future sprint
        // This will include:
        // 1. Calling the cart controller to add the product
        // 2. Updating the cart display
        // 3. Showing success/error messages
        // 4. Handling inventory validation
    }
    
    /**
     * @description Handles product card clicks for navigation to product detail page.
     * 
     * @param {Event} event - The click event from the product card
     */
    handleProductClick(event) {
        const productId = event.currentTarget.dataset.productId;
        
        // Navigate to the product detail page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });
    }
    
    /**
     * @description Handles image loading errors gracefully.
     * Shows a placeholder icon when product images fail to load.
     * 
     * @param {Event} event - The error event from the image element
     */
    handleImageError(event) {
        const imageContainer = event.currentTarget.closest('.product-image-container');
        
        if (imageContainer) {
            // Replace the broken image with a placeholder
            imageContainer.innerHTML = `
                <div class="slds-var-p-around_medium slds-text-align_center">
                    <lightning-icon 
                        icon-name="standard:products" 
                        size="large" 
                        alternative-text="Image Unavailable">
                    </lightning-icon>
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
     * @description Returns whether products are currently loading.
     * Used to show/hide the loading spinner.
     */
    get isLoading() {
        return !this.products || (!this.products.data && !this.products.error);
    }
    
    /**
     * @description Returns whether there are any products to display.
     * Used to show the "no products" message when appropriate.
     */
    get hasProducts() {
        return this.products && this.products.data && this.products.data.length > 0;
    }
    
    /**
     * @description Returns whether there's an error to display.
     * Used to show error messages when API calls fail.
     */
    get hasError() {
        return this.products && this.products.error;
    }
    
    /**
     * @description Returns the error message for display.
     * Provides user-friendly error information.
     */
    get errorMessage() {
        return this.products && this.products.error ? this.products.error.body.message : '';
    }

    /**
     * @description Returns products with enhanced data for display.
     * Adds computed properties like price and formatted data.
     */
    get enhancedProducts() {
        if (!this.products || !this.products.data) {
            return [];
        }
        
        return this.products.data.map(product => ({
            ...product,
            displayPrice: this.getProductPrice(product),
            hasPrice: this.hasProductPrice(product)
        }));
    }

    /**
     * @description Gets the display price for a product.
     * @param {Object} product - The product record
     * @returns {string} Formatted price or null
     */
    getProductPrice(product) {
        if (product.PricebookEntries && 
            product.PricebookEntries.records && 
            product.PricebookEntries.records.length > 0) {
            const price = product.PricebookEntries.records[0].UnitPrice;
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(price);
        }
        return null;
    }

    /**
     * @description Checks if a product has a price.
     * @param {Object} product - The product record
     * @returns {boolean} True if product has a price
     */
    hasProductPrice(product) {
        return product.PricebookEntries && 
               product.PricebookEntries.records && 
               product.PricebookEntries.records.length > 0;
    }
}
