import { LightningElement, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { publish, MessageContext } from "lightning/messageService";
import { refreshApex } from "@salesforce/apex";
import CART_UPDATE_CHANNEL from "@salesforce/messageChannel/CartUpdate__c";
import getProducts from "@salesforce/apex/ENOS_ProductController.getProducts";
import addProductToShoppingCart from "@salesforce/apex/ENOS_ProductController.addProductToShoppingCart";
import EnosBaseComponent from "c/enosBaseComponent";

/**
 * @description Product Browser component for ENOS e-commerce platform
 * Displays products in a responsive grid with search and filtering capabilities
 * @author ENOS Development Team
 * @version 1.0.0
 */
export default class ProductBrowser extends NavigationMixin(EnosBaseComponent) {
  // Wire service result holder (do not overwrite, used for refreshApex)
  @wire(getProducts)
  wiredProducts;

  // Wire message context for Lightning Message Service
  @wire(MessageContext)
  messageContext;

  // Track component state
  @track isAddingToCart = false;
  @track searchTerm = "";
  @track debounceTimer;
  @track manualProducts = null; // set when a search is performed
  @track manualError = null;

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
        // Call the getProducts method with search parameters
        // Parameters: (pageSize, pageNumber, searchTerm, familyFilter, sortBy, sortDirection)
        const searchResults = await getProducts(50, 1, searchTerm.trim(), null, 'Name', 'ASC');
        this.manualProducts = Array.isArray(searchResults) ? searchResults : [];
        this.manualError = null;
      } else {
        // If no search term, refresh the original products
        this.refreshProducts();
      }
    } catch (e) {
      // Error logging handled by conditional logging utility
      this.manualProducts = null;
      this.manualError = e;
      this.showToast(
        "Error",
        "Unable to search products. Please try again.",
        "error"
      );
    }
  }

  /**
   * @description Refreshes the products list by calling the original wire method.
   * This is used when clearing search results or handling errors.
   */
  refreshProducts() {
    // Clear manual results and refresh wired data
    this.manualProducts = null;
    this.manualError = null;
    try {
      if (this.wiredProducts) {
        refreshApex(this.wiredProducts);
      }
    } catch {
      // no-op
    }
  }

  /**
   * @description Handles the "Show All Products" button click.
   * Clears the search and shows all available products.
   */
  handleShowAllProducts() {
    this.searchTerm = "";
    this.refreshProducts();

    // Clear the search input field
    const searchInput = this.template.querySelector("lightning-input");
    if (searchInput) {
      searchInput.value = "";
    }
  }

  /**
   * @description Handles adding a product to the shopping cart.
   * Integrates with ProductController to add products and updates cart display.
   *
   * @param {Event} event - The click event from the Add to Cart button
   */
  async handleAddToCart(event) {
    // Prevent event bubbling to avoid triggering navigation
    event.stopPropagation();

    const productId = event.currentTarget.dataset.productId;
    const productName = event.currentTarget.dataset.productName;

    if (!productId) {
      this.showToast("Error", "Product information not available.", "error");
      return;
    }

    // Set loading state
    this.isAddingToCart = true;

    try {
      // Get the product data to find the PricebookEntry ID
      const products = this.manualProducts || this.wiredProducts?.data || [];
      const product = products.find(p => p.Id === productId);
      
      if (!product || !product.PricebookEntries || product.PricebookEntries.length === 0) {
        throw new Error("Product pricing not available");
      }
      
      const pricebookEntryId = product.PricebookEntries[0].Id;
      
      // Call Apex method with correct parameters: (productId, quantity, pricebookEntryId)
              const result = await addProductToShoppingCart(productId, 1);

      // Show success message
      if (result?.success) {
        this.showToast(
          "Success",
          result.message || `${productName || "Product"} added to cart successfully!`,
          "success"
        );
        
        // Publish cart update message for other components
        this.publishCartUpdate();
      } else {
        throw new Error(result?.message || "Failed to add product to cart");
      }
    } catch (error) {
      // Error logging handled by conditional logging utility
      // Show user-friendly error message
      const errorMessage =
        error.body?.message || error.message || "Unable to add item to cart. Please try again.";
      this.showToast("Error", errorMessage, "error");
    } finally {
      // Reset loading state
      this.isAddingToCart = false;
    }
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
      type: "standard__recordPage",
      attributes: {
        recordId: productId,
        objectApiName: "Product2",
        actionName: "view"
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
    const imageContainer = event.currentTarget.closest(
      ".product-image-container"
    );

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
   * @description Publishes cart update message to notify other components.
   * Uses Lightning Message Service to update cart displays across the app.
   */
  publishCartUpdate() {
    const payload = {
      operation: "add",
      timestamp: new Date().toISOString()
    };

    publish(this.messageContext, CART_UPDATE_CHANNEL, payload);
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
    if (this.manualProducts !== null || this.manualError !== null) {
      return false;
    }
    return !(this.wiredProducts?.data || this.wiredProducts?.error);
  }

  /**
   * @description Returns whether there are any products to display.
   * Used to show the "no products" message when appropriate.
   */
  get hasProducts() {
    const list = this.currentProductsRaw;
    return Array.isArray(list) && list.length > 0;
  }

  /**
   * @description Returns whether there's an error to display.
   * Used to show error messages when API calls fail.
   */
  get hasError() {
    return this.manualProducts === null && !!this.wiredProducts?.error;
  }

  /**
   * @description Returns the error message for display.
   * Provides user-friendly error information.
   */
  get errorMessage() {
    return (
      this.manualError?.body?.message ||
      this.wiredProducts?.error?.body?.message ||
      ""
    );
  }

  /**
   * @description Returns products with enhanced data for display.
   * Adds computed properties like price and formatted data.
   */
  get currentProductsRaw() {
    return this.manualProducts ?? this.wiredProducts?.data ?? [];
  }

  get enhancedProducts() {
    const list = this.currentProductsRaw;
    if (!Array.isArray(list)) {
      return [];
    }
    return list.map((product) => ({
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
    const price = product?.PricebookEntries?.records?.[0]?.UnitPrice;
    return price != null
      ? new Intl.NumberFormat("en-US", {
          style: "currency",
          currency: "USD"
        }).format(price)
      : null;
  }

  /**
   * @description Checks if a product has a price.
   * @param {Object} product - The product record
   * @returns {boolean} True if product has a price
   */
  hasProductPrice(product) {
    return !!product?.PricebookEntries?.records?.length;
  }
}
