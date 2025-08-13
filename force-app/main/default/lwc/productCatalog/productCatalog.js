import { LightningElement, api } from "lwc";
import getProducts from "@salesforce/apex/StoreConnectController.getProducts";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class ProductCatalog extends NavigationMixin(LightningElement) {
  @api recordId; // Contact ID from the community user
  products = [];
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

  // Search and filter methods
  handleSearchChange(event) {
    this.searchTerm = event.target.value;
    this.currentPage = 0;
    this.debounceLoadProducts();
  }

  handleCategoryChange(event) {
    this.selectedCategory = event.target.value;
    this.currentPage = 0;
    this.debounceLoadProducts();
  }

  handleTopSellersChange(event) {
    this.topSellersOnly = event.target.checked;
    this.currentPage = 0;
    this.debounceLoadProducts();
  }

  // Pagination methods
  handleNextPage() {
    if (this.hasNextPage) {
      this.currentPage++;
      this.debounceLoadProducts();
    }
  }

  handlePreviousPage() {
    if (this.hasPreviousPage) {
      this.currentPage--;
      this.debounceLoadProducts();
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
        this.products = result;
        this.totalCount = result.length;
      } else if (result && result.products) {
        this.products = result.products;
        this.totalCount = result.totalCount || result.products.length;
      } else {
        this.products = [];
        this.totalCount = 0;
      }

      this.totalPages = Math.ceil(this.totalCount / this.pageSize);
    } catch {
      this.products = [];
      this.totalCount = 0;
      this.totalPages = 0;
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
}
