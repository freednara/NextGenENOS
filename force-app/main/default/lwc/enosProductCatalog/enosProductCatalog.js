import { LightningElement, api } from "lwc";
import getProducts from "@salesforce/apex/ENOS_ProductController.getProducts";
import getProductsPaginated from "@salesforce/apex/ENOS_ProductController.getProducts";
import addProductToShoppingCart from "@salesforce/apex/ENOS_ProductController.addProductToShoppingCart";
import getCartDetails from "@salesforce/apex/ENOS_ProductController.getCartDetails";
import updateCartItemQuantity from "@salesforce/apex/ENOS_ProductController.updateCartItemQuantity";
import generateInvoice from "@salesforce/apex/ENOS_InvoiceController.generateInvoice";
import submitQuoteRequest from "@salesforce/apex/ENOS_ProductController.submitQuoteRequest";
import getShippingAddresses from "@salesforce/apex/ENOS_ProductController.getShippingAddresses";
// REMOVED: getRecentlyViewed import - method no longer exists
import { NavigationMixin } from "lightning/navigation";
import EnosBaseComponent from "c/enosBaseComponent";

export default class enosProductCatalog extends NavigationMixin(EnosBaseComponent) {
  @api recordId; // Optional Contact ID from the community user
  products = [];
  allProducts = [];
  searchTerm = "";
  selectedCategory = "";
  topSellersOnly = false;
  currentPage = 0;
  pageSize = 12;
  totalCount = 0;
  totalPages = 0;
  loading = false;
  searchDelay;
  useAdvancedSearch = false; // Toggle between local filtering and server-side search
  
  // Cart modal properties
  showCartModal = false;
  cartData = null;
  
  // Invoice and Quote properties
  showQuoteModal = false;
  customerNotes = '';
  quoteLoading = false;

  // Pagination
  get hasNextPage() {
    return this.currentPage < this.totalPages - 1;
  }

  get hasPreviousPage() {
    return this.currentPage > 0;
  }

  get isPreviousDisabled() {
    return this.currentPage <= 0;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages - 1;
  }

  get pageInfo() {
    const start = this.currentPage * this.pageSize + 1;
    const end = Math.min(
      (this.currentPage + 1) * this.pageSize,
      this.totalCount
    );
    return `${start}-${end} of ${this.totalCount}`;
  }

  // Dynamic category options from actual product data
  get categoryOptions() {
    if (!this.allProducts || this.allProducts.length === 0) {
      return [{ label: "All Categories", value: "" }];
    }

    // Extract unique families from products
    const categories = new Set();
    this.allProducts.forEach((product) => {
      if (product.Family) {
        categories.add(product.Family);
      }
    });

    // Convert to option format and sort
    const options = [{ label: "All Categories", value: "" }];
    Array.from(categories)
      .sort()
      .forEach((category) => {
        options.push({ label: category, value: category });
      });

    return options;
    }
  
  /**
   * @description Show success toast message
   * @param {String} title Toast title
   * @param {String} message Toast message
   */
  showSuccessToast(title, message) {
    this.dispatchEvent(new CustomEvent('showtoast', {
      detail: {
        title: title,
        message: message,
        variant: 'success'
      }
    }));
  }
  
  /**
   * @description Show error toast message
   * @param {String} title Toast title
   * @param {String} message Toast message
   */
  showErrorToast(title, message) {
    this.dispatchEvent(new CustomEvent('showtoast', {
      detail: {
        title: title,
        message: message,
        variant: 'error'
      }
    }));
  }
  
  /**
   * @description Extract error message from error object
   * @param {Object} error Error object
   * @returns {String} Error message
   */
  getErrorMessage(error) {
    if (error && error.body) {
      if (error.body.message) {
        return error.body.message;
      }
      if (error.body.fieldErrors) {
        return Object.values(error.body.fieldErrors).flat().join(', ');
      }
      if (error.body.pageErrors && error.body.pageErrors.length > 0) {
        return error.body.pageErrors[0].message;
      }
    }
    
    if (error && error.message) {
      return error.message;
    }
    
    return 'An unexpected error occurred';
  }
  
  // Search and filter methods
  handleSearchChange(event) {
    this.searchTerm = event.target.value;
    this.currentPage = 0;
    this.debounceRecomputeProducts();
  }

  handleCategoryChange(event) {
    this.selectedCategory = event.target.value;
    this.currentPage = 0;
    this.debounceRecomputeProducts();
  }

  handleTopSellersChange(event) {
    this.topSellersOnly = event.target.checked;
    this.currentPage = 0;
    this.debounceRecomputeProducts();
  }

  // Toggle between local filtering and server-side search
  handleSearchModeToggle(event) {
    this.useAdvancedSearch = event.target.checked;
    this.currentPage = 0;
    if (this.useAdvancedSearch) {
      this.loadProductsAdvanced();
    } else {
      this.recomputeFilteredProducts();
    }
  }

  // Pagination methods
  handleNextPage() {
    if (this.hasNextPage) {
      this.currentPage++;
      this.debounceRecomputeProducts();
    }
  }

  handlePreviousPage() {
    if (this.hasPreviousPage) {
      this.currentPage--;
      this.debounceRecomputeProducts();
    }
  }

  // Load products from server using ENOS_ProductController
  async loadProducts() {
    this.loading = true;
    try {
      console.log("🔄 Loading products from ENOS_ProductController...");
      const result = await getProducts();
      console.log("✅ Received products result:", result);
      console.log("✅ Result type:", typeof result);
      console.log("✅ Is array:", Array.isArray(result));
      console.log("✅ Result keys:", result ? Object.keys(result) : 'null/undefined');

      if (Array.isArray(result)) {
        this.allProducts = result;
        this.totalCount = result.length;
        this.totalPages = Math.ceil(this.totalCount / this.pageSize);
        console.log("📊 Products loaded:", this.allProducts.length);
        console.log("📊 Total pages:", this.totalPages);
        
        // Log first product structure for debugging
        if (this.allProducts.length > 0) {
          console.log("🔍 First product structure:", JSON.stringify(this.allProducts[0], null, 2));
        }
      } else {
        console.warn("⚠️ Unexpected result format:", result);
        this.allProducts = [];
        this.totalCount = 0;
        this.totalPages = 0;
      }

      this.recomputeFilteredProducts();
    } catch (error) {
      console.error("❌ Error loading products:", error);
      console.error("❌ Error details:", {
        message: error.message,
        body: error.body,
        stack: error.stack
      });
      this.allProducts = [];
      this.totalCount = 0;
      this.totalPages = 0;
      this.recomputeFilteredProducts();

      this.showToast(
        "Error",
        "Unable to load products: " + (error.body?.message || error.message),
        "error"
      );
    } finally {
      this.loading = false;
    }
  }

  // Load products with advanced search and pagination using ENOS_ProductController
  async loadProductsAdvanced() {
    this.loading = true;
    try {
      console.log("🔄 Loading products with advanced search...");
      console.log("🔍 Search params:", {
        searchTerm: this.searchTerm,
        category: this.selectedCategory,
        pageNumber: this.currentPage,
        pageSize: this.pageSize,
        topSellersOnly: this.topSellersOnly
      });

      const result = await getProductsPaginated(
        this.searchTerm || '',
        this.selectedCategory || '',
        this.currentPage,
        this.pageSize,
        this.topSellersOnly
      );

      if (result && result.products) {
        this.products = result.products;
        this.totalCount = result.totalCount;
        this.totalPages = Math.ceil(this.totalCount / this.pageSize);
        console.log("📊 Advanced search results:", {
          products: this.products.length,
          totalCount: this.totalCount,
          totalPages: this.totalPages,
          currentPage: this.currentPage
        });
      } else {
        console.warn("⚠️ Unexpected advanced search result format:", result);
        this.products = [];
        this.totalCount = 0;
        this.totalPages = 0;
      }
    } catch (error) {
      console.error("❌ Error in advanced search:", error);
      this.products = [];
      this.totalCount = 0;
      this.totalPages = 0;

      this.showToast(
        "Error",
        "Advanced search failed: " + (error.body?.message || error.message),
        "error"
      );
    } finally {
      this.loading = false;
    }
  }

  debounceLoadProducts() {
    window.clearTimeout(this.searchDelay);
    this.searchDelay = window.setTimeout(() => {
      this.loadProducts();
    }, 300);
  }

  debounceRecomputeProducts() {
    window.clearTimeout(this.searchDelay);
    this.searchDelay = window.setTimeout(() => {
      // Use advanced search if enabled and filters are applied, otherwise use local filtering
      if (this.useAdvancedSearch && (this.searchTerm || this.selectedCategory || this.topSellersOnly)) {
        this.loadProductsAdvanced();
      } else if (!this.allProducts || this.allProducts.length === 0) {
        this.loadProducts();
      } else {
        this.recomputeFilteredProducts();
      }
    }, 200);
  }

  applyFilters(products) {
    console.log("🔍 applyFilters called with", products.length, "products");
    let filtered = Array.isArray(products) ? products.slice() : [];

    // Text search on Name and Description
    const term = (this.searchTerm || "").trim().toLowerCase();
    if (term) {
      console.log("🔍 Applying search term:", term);
      const beforeCount = filtered.length;
      filtered = filtered.filter((p) => {
        const name = (p.Name || "").toLowerCase();
        const desc = (p.Description || "").toLowerCase();
        return name.includes(term) || desc.includes(term);
      });
      console.log(`🔍 Search filter: ${beforeCount} → ${filtered.length} products`);
    }

    // Category filter using Family field
    if (this.selectedCategory) {
      console.log("🔍 Applying category filter:", this.selectedCategory);
      const beforeCount = filtered.length;
      filtered = filtered.filter(
        (p) =>
          (p.Family || "").toLowerCase() === this.selectedCategory.toLowerCase()
      );
      console.log(`🔍 Category filter: ${beforeCount} → ${filtered.length} products`);
    }

    // Top Sellers filter using Is_Top_Seller__c field
    if (this.topSellersOnly) {
      console.log('🏆 Applying top sellers filter...');
      const beforeCount = filtered.length;
      filtered = filtered.filter((p) => p.Is_Top_Seller__c === true);
      const afterCount = filtered.length;
      console.log(`🏆 Top sellers filter: ${beforeCount} → ${afterCount} products`);
      
      // Log which products are top sellers
      const topSellers = filtered.filter(p => p.Is_Top_Seller__c === true);
      console.log('🏆 Top seller products:', topSellers.map(p => p.Name));
    }

    console.log("🔍 Final filtered result:", filtered.length, "products");
    return filtered;
  }

  recomputeFilteredProducts() {
    console.log("🔍 Starting filter recomputation...");
    console.log("🔍 allProducts count:", this.allProducts.length);
    console.log("🔍 Current filters:", {
      searchTerm: this.searchTerm,
      selectedCategory: this.selectedCategory,
      topSellersOnly: this.topSellersOnly
    });
    
    const filtered = this.applyFilters(this.allProducts);
    console.log("🔍 After filtering:", filtered.length, "products");
    
    this.totalCount = filtered.length;
    this.totalPages = Math.max(1, Math.ceil(this.totalCount / this.pageSize));

    // Clamp current page
    if (this.currentPage > this.totalPages - 1) {
      this.currentPage = Math.max(0, this.totalPages - 1);
    }

    // Get current page of products
    this.products = this.getCurrentPageProducts(filtered);
    console.log(
      "🔍 Final result:",
      this.products.length,
      "products on current page",
      "of",
      this.totalCount,
      "total filtered",
      "(Page",
      this.currentPage + 1,
      "of",
      this.totalPages,
      ")"
    );
  }

  // Get products for current page
  getCurrentPageProducts(allProducts) {
    const startIndex = this.currentPage * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    const result = allProducts.slice(startIndex, endIndex);
    console.log(`🔍 getCurrentPageProducts: page ${this.currentPage + 1}, start: ${startIndex}, end: ${endIndex}, result: ${result.length} products`);
    return result;
  }

  // Store selected quantities for each product
  productQuantities = {};

  // Handle quantity change
  handleQuantityChange(event) {
    const input = event.target;
    const productId = input.getAttribute('data-product-id');
    const quantity = parseInt(input.value) || 1;
    this.productQuantities[productId] = quantity;
  }

  /**
   * @description Handle add to cart action - COMPLETELY FIXED VERSION
   * @param {Event} event Button click event
   */
  async handleAddToCart(event) {
    console.log('🚀 handleAddToCart FIXED v5.0 called');
    
    try {
      const productId = event.target.dataset.productId;
      const quantity = 1; // Default quantity
      
      console.log('🔍 Product data from button:', { productId, quantity });
      
      if (!productId) {
        throw new Error('Product ID is missing');
      }
      
      // Show loading state
      const button = event.target;
      const originalLabel = button.label || 'Add to Cart';
      button.label = 'Adding...';
      button.disabled = true;
      
      console.log('🛒 Calling addProductToCart with correct parameters');
      
      // Call Apex method with correct parameters (productId, quantity)
      const result = await addProductToShoppingCart(productId, quantity);
      
      console.log('✅ Add to cart result:', result);
      
      if (result && result.success) {
        this.showSuccessToast('Success', result.message || 'Product added to cart successfully');
        console.log('✅ Product added to cart successfully');
        
        // Dispatch custom event for cart update
        this.dispatchEvent(new CustomEvent('cartupdate', {
          detail: { 
            cartItem: result.cartItem,
            action: 'add'
          }
        }));
      } else {
        throw new Error(result ? result.message : 'Unknown error occurred');
      }
      
      // Restore button state
      button.label = originalLabel;
      button.disabled = false;
      
    } catch (error) {
      console.error('❌ Error adding to cart:', error);
      
      // Restore button state
      const button = event.target;
      if (button) {
        button.label = 'Add to Cart';
        button.disabled = false;
      }
      
      this.showErrorToast('Error', 'Unable to add product to cart: ' + this.getErrorMessage(error));
    }
  }

  // Navigate to product detail
  handleProductClick(event) {
    const button = event.currentTarget;
    const productId = button.getAttribute('data-product-id');

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: productId,
        objectApiName: "Product2",
        actionName: "view"
      }
    });
  }

  // Show shopping cart in modal
  handleViewCart() {
    console.log("🛒 View Cart button clicked");
    
    // Show detailed cart modal instead of just a toast
    this.showDetailedCart();
  }

  // Show cart information
  showCartInfo() {
    try {
      // Get current cart info from the cart service
      this.getCurrentCartInfo();
    } catch (error) {
      console.error("❌ Error showing cart info:", error);
      this.showToast("Error", "Unable to load cart information", "error");
    }
  }

  // Show detailed cart modal
  async showDetailedCart() {
    try {
      console.log("🛒 Loading detailed cart information...");
      
      const cartInfo = await this.getCartDetails();
      
      if (cartInfo && cartInfo.success) {
        // Store cart data for the modal
        this.cartData = cartInfo;
        this.showCartModal = true;
        
        console.log("✅ Cart modal data loaded:", cartInfo);
        console.log("📦 Cart items for display:", cartInfo.items);
        
        // Debug each item's quantity
        if (cartInfo.items && cartInfo.items.length > 0) {
          cartInfo.items.forEach((item, index) => {
            console.log(`Item ${index + 1}: ${item.productName} - Qty: ${item.quantity} (type: ${typeof item.quantity})`);
          });
        }
      } else {
        this.showToast("Cart Information", "Your cart is empty", "info");
      }
    } catch (error) {
      console.error("❌ Error loading detailed cart:", error);
      this.showToast("Error", "Unable to load cart details", "error");
    }
  }

  // Close cart modal
  closeCartModal() {
    this.showCartModal = false;
    this.cartData = null;
  }

  // Update cart item quantity
  async handleCartItemQuantityChange(event) {
    try {
      const button = event.currentTarget;
      const cartItemId = button.getAttribute('data-item-id');
      const action = button.getAttribute('data-action');
      
      let newQuantity;
      
      if (action === 'increase' || action === 'decrease') {
        // Handle +/- button clicks
        const currentItem = this.cartData.items.find(item => item.itemId === cartItemId);
        if (!currentItem) {
          this.showToast("Error", "Cart item not found", "error");
          return;
        }
        
        const currentQty = currentItem.quantity || 1;
        newQuantity = action === 'increase' ? currentQty + 1 : Math.max(1, currentQty - 1);
      } else {
        // Handle direct input change
        newQuantity = parseInt(event.target.value);
        if (isNaN(newQuantity) || newQuantity < 1) {
          this.showToast("Error", "Quantity must be at least 1", "error");
          return;
        }
      }

      console.log("🔄 Updating cart item:", { cartItemId, newQuantity, action });
      
      const result = await updateCartItemQuantity({ 
        cartItemId: cartItemId, 
        newQuantity: newQuantity 
      });

      if (result.success) {
        console.log("✅ Cart item updated:", result);
        this.showToast("Success", result.message, "success");
        
        // Refresh cart data to show updated totals
        await this.refreshCartData();
      } else {
        this.showToast("Warning", result.message, "warning");
      }
    } catch (error) {
      console.error("❌ Error updating cart item:", error);
      this.showToast("Error", "Failed to update cart item", "error");
    }
  }

  // Remove item from cart (set quantity to 0)
  async handleRemoveItem(event) {
    try {
      const button = event.currentTarget;
      const cartItemId = button.getAttribute('data-item-id');
      
      console.log("🗑️ Removing cart item:", cartItemId);
      
      const result = await updateCartItemQuantity({ 
        cartItemId: cartItemId, 
        newQuantity: 0 
      });

      if (result.success) {
        console.log("✅ Cart item removed:", result);
        this.showToast("Success", result.message, "success");
        
        // Refresh cart data to show updated totals
        await this.refreshCartData();
      } else {
        this.showToast("Warning", result.message, "warning");
      }
    } catch (error) {
      console.error("❌ Error removing cart item:", error);
      this.showToast("Error", "Failed to remove cart item", "error");
    }
  }

  // Refresh cart data after modifications
  async refreshCartData() {
    try {
      console.log("🔄 Refreshing cart data...");
      
      const cartInfo = await this.getCartDetails();
      
      if (cartInfo && cartInfo.success) {
        // Update the cart data to refresh the modal
        this.cartData = cartInfo;
        console.log("✅ Cart data refreshed:", cartInfo);
      } else {
        // Cart is empty, close modal
        this.showCartModal = false;
        this.cartData = null;
        this.showToast("Cart Information", "Your cart is empty", "info");
      }
    } catch (error) {
      console.error("❌ Error refreshing cart data:", error);
      this.showToast("Error", "Failed to refresh cart data", "error");
    }
  }

  // Get current cart information
  async getCurrentCartInfo() {
    try {
      // Get cart information from the cart service
      const cartInfo = await this.getCartDetails();
      
      if (cartInfo && cartInfo.success) {
        // Format the total value as currency
        const totalFormatted = new Intl.NumberFormat('en-US', {
          style: 'currency',
          currency: 'USD'
        }).format(cartInfo.totalValue || 0);
        
        const message = `Cart: ${cartInfo.itemCount} items, Total: ${totalFormatted}`;
        this.showToast("Cart Information", message, "info");
        
        // Log detailed cart info
        console.log("🛒 Cart Details:", cartInfo);
        
        // Log individual items if available
        if (cartInfo.items && cartInfo.items.length > 0) {
          console.log("📦 Cart Items:");
          cartInfo.items.forEach((item, index) => {
            console.log(`  ${index + 1}. ${item.productName} - Qty: ${item.quantity}, Price: $${item.unitPrice}, Total: $${item.lineTotal}`);
          });
        }
      } else {
        this.showToast("Cart Information", "Your cart is empty", "info");
      }
      
    } catch (error) {
      console.error("❌ Error getting cart info:", error);
      this.showToast("Error", "Unable to retrieve cart information", "error");
    }
  }

  // Refresh cart data after updates
  async refreshCartData() {
    try {
      console.log("🔄 Refreshing cart data...");
      const cartInfo = await this.getCartDetails();
      
      if (cartInfo && cartInfo.success) {
        this.cartData = cartInfo;
        console.log("✅ Cart data refreshed:", cartInfo);
      }
    } catch (error) {
      console.error("❌ Error refreshing cart data:", error);
    }
  }

  // Get cart details from the cart service
  async getCartDetails() {
    try {
      console.log("🛒 Getting cart details from Apex...");
      
      // Call the real Apex method to get actual cart data
      const result = await getCartDetails();
      
      console.log("✅ Cart details received:", result);
      
      if (result && result.cart && result.items) {
        // Transform the Apex result to match expected LWC structure
        const itemCount = result.items.length;
        const totalValue = result.cart.Subtotal__c || 0;
        
        // Transform cart items to include product names
        const transformedItems = result.items.map(item => ({
          itemId: item.Id,
          productId: item.Product__c,
          productName: item.Product__r?.Name || 'Unknown Product',
          quantity: item.Quantity__c || 0,
          unitPrice: item.Unit_Price__c || 0,
          lineTotal: item.Line_Total__c || 0,
          imageUrl: item.Product__r?.Image_URL__c || null
        }));
        
        return {
          success: true,
          itemCount: itemCount,
          totalValue: totalValue,
          message: `Cart contains ${itemCount} items`,
          items: transformedItems
        };
      } else {
        return {
          success: false,
          error: "Cart data structure is invalid"
        };
      }
    } catch (error) {
      console.error("❌ Error getting cart details:", error);
      return {
        success: false,
        error: error.message || "Unknown error occurred"
      };
    }
  }

  // Utility methods
  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  // Lifecycle hooks
  connectedCallback() {
    console.log("🚀 ProductCatalog component connected");
    this.loadProducts();
  }

  // Getters for computed properties
  get showPagination() {
    return this.totalPages > 1;
  }

  get showNoResults() {
    return !this.loading && this.products.length === 0;
  }

  // Format cart total as currency
  get formattedCartTotal() {
    if (!this.cartData || !this.cartData.totalValue) return '$0.00';
    
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(this.cartData.totalValue);
  }

  // Format currency values with two decimal places
  formatCurrency(amount) {
    if (amount === null || amount === undefined) return '$0.00';
    
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount);
  }

  // Format quantity display
  getQuantityDisplay(quantity) {
    if (quantity === null || quantity === undefined) return '0';
    return String(quantity);
  }

  // Get formatted cart items with proper currency formatting
  get formattedCartItems() {
    if (!this.cartData || !this.cartData.items) return [];
    
    return this.cartData.items.map(item => ({
      ...item,
      formattedUnitPrice: this.formatCurrency(item.unitPrice),
      formattedLineTotal: this.formatCurrency(item.lineTotal)
    }));
  }

  get displayedProducts() {
    // Since this.products already contains the current page, just return it with formatting
    return this.products.map((product) => ({
      ...product,
      displayPrice: this.getProductPrice(product),
      hasPrice: this.hasProductPrice(product),
      isProductInStock: this.isProductInStock(product),
      stockDisplay: this.getStockDisplay(product)
    }));
  }

  // Price helper methods
  getProductPrice(product) {
    if (
      product.PricebookEntries &&
      product.PricebookEntries.records &&
      product.PricebookEntries.records.length > 0
    ) {
      const price = product.PricebookEntries.records[0].UnitPrice;
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD"
      }).format(price);
    }
    return null;
  }

  hasProductPrice(product) {
    return (
      product.PricebookEntries &&
      product.PricebookEntries.records &&
      product.PricebookEntries.records.length > 0
    );
  }

  // Helper method to check if product is in stock
  isProductInStock(product) {
    // Use actual Stock_Quantity__c field now that it's accessible
    if (product.Stock_Quantity__c && product.Stock_Quantity__c > 0) {
      return true;
    }
    return false;
  }

  // Helper method to get stock display text
  getStockDisplay(product) {
    // Use actual Stock_Quantity__c field now that it's accessible
    if (product.Stock_Quantity__c && product.Stock_Quantity__c > 0) {
      return product.Stock_Quantity__c;
    }
    return "Out of Stock";
  }

  // Generate and download invoice
  async handleGenerateInvoice() {
    try {
      console.log("🧾 Generating invoice...");
      
      // Get cart ID from cart data if available, otherwise let Apex find it
      const cartId = this.cartData?.cartId;
      
      if (cartId) {
        console.log("🛒 Using cart ID from cart data:", cartId);
      } else {
        console.log("🛒 No cart ID in cart data, letting Apex find active cart");
      }
      
      // Call Apex with primitives only - cartId is optional
      const result = await generateInvoice({ 
        cartId: cartId || null, 
        templateName: 'ENOS_Invoice' 
      });
      
      console.log("📄 Invoice result:", result);
      
      if (result?.success) {
        // Success - open download
        const downloadUrl = `/sfc/servlet.shepherd/document/download/${result.contentVersionId}`;
        window.open(downloadUrl, '_blank');
        
        this.showToast("Success", `Invoice ${result.invoiceNumber} generated successfully!`, "success");
        console.log("✅ Invoice generated:", result.invoiceNumber);
      } else {
        // Business logic error
        throw new Error(result?.message || 'Invoice generation failed');
      }
      
    } catch (error) {
      console.error("❌ Error generating invoice:", error);
      
      // Extract meaningful error message
      const errorMessage = error?.body?.message || error?.message || 'Failed to generate invoice';
      this.showToast("Error", errorMessage, "error");
    }
  }

  // Show quote request modal
  handleRequestQuote() {
    this.showQuoteModal = true;
    this.customerNotes = '';
  }

  // Close quote modal
  closeQuoteModal() {
    this.showQuoteModal = false;
    this.customerNotes = '';
  }

  // Handle customer notes input
  handleNotesChange(event) {
    this.customerNotes = event.target.value;
  }

  // Submit quote request
  async handleSubmitQuote() {
    try {
      this.quoteLoading = true;
      console.log("📋 Submitting quote request...");
      
      const result = await submitQuoteRequest({ customerNotes: this.customerNotes });
      
      console.log("✅ Quote request submitted:", result);
      this.showToast("Success", result, "success");
      
      // Close modal and refresh cart
      this.closeQuoteModal();
      await this.refreshCartData();
      
    } catch (error) {
      console.error("❌ Error submitting quote request:", error);
      this.showToast("Error", "Failed to submit quote request", "error");
    } finally {
      this.quoteLoading = false;
    }
  }
}
