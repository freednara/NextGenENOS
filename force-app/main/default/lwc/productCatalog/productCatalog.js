import { LightningElement, api } from "lwc";
import getProducts from "@salesforce/apex/StoreConnectController.getProducts";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class ProductCatalog extends NavigationMixin(LightningElement) {
  @api recordId; // Contact ID from the community user
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

  // Pagination
  get hasNextPage() {
    return this.currentPage < this.totalPages - 1;
  }

  get hasPreviousPage() {
    return this.currentPage > 0;
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

    // Extract unique categories from products
    const categories = new Set();
    this.allProducts.forEach(product => {
      if (product.Category__c) {
        categories.add(product.Category__c);
      }
    });

    // Convert to option format and sort
    const options = [{ label: "All Categories", value: "" }];
    Array.from(categories).sort().forEach(category => {
      options.push({ label: category, value: category });
    });

    return options;
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

  // Load products from server
  async loadProducts() {
    this.loading = true;
    try {
      // Simplified call to getProducts without complex parameters
      const result = await getProducts();

      // Handle the result based on what's actually returned
      if (Array.isArray(result)) {
        this.allProducts = result;
      } else if (result && result.products) {
        this.allProducts = result.products;
      } else {
        this.allProducts = [];
      }

      this.recomputeFilteredProducts();
    } catch {
      this.allProducts = [];
      this.recomputeFilteredProducts();
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
      if (!this.allProducts || this.allProducts.length === 0) {
        this.loadProducts();
      } else {
        this.recomputeFilteredProducts();
      }
    }, 200);
  }

  applyFilters(products) {
    let filtered = Array.isArray(products) ? products.slice() : [];

    // Text search on Name and Description
    const term = (this.searchTerm || "").trim().toLowerCase();
    if (term) {
      filtered = filtered.filter((p) => {
        const name = (p.Name || "").toLowerCase();
        const desc = (p.Description || "").toLowerCase();
        return name.includes(term) || desc.includes(term);
      });
    }

    // Category filter using actual Category__c field
    if (this.selectedCategory) {
      filtered = filtered.filter(
        (p) => (p.Category__c || "").toLowerCase() === this.selectedCategory.toLowerCase()
      );
    }

    // Top sellers only
    if (this.topSellersOnly) {
      filtered = filtered.filter((p) => !!p.Is_Top_Seller__c);
    }

    return filtered;
  }

  recomputeFilteredProducts() {
    const filtered = this.applyFilters(this.allProducts);
    this.totalCount = filtered.length;
    this.totalPages = Math.max(1, Math.ceil(this.totalCount / this.pageSize));

    // Clamp current page
    if (this.currentPage > this.totalPages - 1) {
      this.currentPage = Math.max(0, this.totalPages - 1);
    }

    this.products = filtered;
  }

  // Add to cart - simplified version
  async handleAddToCart(event) {
    const quantity = parseInt(event.currentTarget.dataset.quantity, 10) || 1;

    if (isNaN(quantity) || quantity < 1) {
      this.showToast("Error", "Invalid quantity", "error");
      return;
    }

    try {
      // For now, just show a success message
      this.showToast(
        "Success",
        "Product added to cart! (Cart functionality coming soon)",
        "success"
      );

      // Dispatch event to update cart display
      this.dispatchEvent(new CustomEvent("cartupdated"));
    } catch (error) {
      this.showToast(
        "Error",
        "Failed to add to cart: " + (error.body?.message || error.message),
        "error"
      );
    }
  }

  // Track product view - simplified version
  async handleProductView() {
    try {
      // For now, just log the view
    } catch {
      // Don't show error for tracking - just log it
    }
  }

  // Navigate to product detail
  handleProductClick(event) {
    const productId = event.currentTarget.dataset.productId;

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: productId,
        objectApiName: "Product2",
        actionName: "view"
      }
    });
  }

  // Request back-in-stock notification
  async handleBackInStock() {
    try {
      // This would call the notification request method
      // For now, just show a message
      this.showToast("Info", "Back-in-stock notification requested", "info");
    } catch {
      this.showToast("Error", "Failed to request notification", "error");
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
    this.loadProducts();
  }

  // Getters for computed properties
  get showPagination() {
    return this.totalPages > 1;
  }

  get showNoResults() {
    return !this.loading && this.products.length === 0;
  }

  get displayedProducts() {
    const start = this.currentPage * this.pageSize;
    const end = Math.min(start + this.pageSize, this.products.length);
    return this.products.slice(start, end);
  }
}
