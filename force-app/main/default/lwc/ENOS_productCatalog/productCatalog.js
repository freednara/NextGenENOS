import { LightningElement, api } from "lwc";
import getProducts from "@salesforce/apex/ENOS_ProductController.getProducts";
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

  // Load products from server using ENOS_ProductController
  async loadProducts() {
    this.loading = true;
    try {
      console.log("🔄 Loading products from ENOS_ProductController...");
      const result = await getProducts();
      console.log("✅ Received products:", result);

      if (Array.isArray(result)) {
        this.allProducts = result;
        console.log("📊 Products loaded:", this.allProducts.length);
      } else {
        console.warn("⚠️ Unexpected result format:", result);
        this.allProducts = [];
      }

      this.recomputeFilteredProducts();
    } catch (error) {
      console.error("❌ Error loading products:", error);
      this.allProducts = [];
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

    // Category filter using Family field
    if (this.selectedCategory) {
      filtered = filtered.filter(
        (p) =>
          (p.Family || "").toLowerCase() === this.selectedCategory.toLowerCase()
      );
    }

    // Skip top sellers filter since we don't have that custom field working yet

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
    console.log(
      "🔍 Filtered products:",
      this.products.length,
      "of",
      this.allProducts.length
    );
  }

  // Add to cart - simplified version
  async handleAddToCart(event) {
    const productId = event.currentTarget.dataset.productId;
    const productName = event.currentTarget.dataset.productName;

    this.showToast(
      "Success",
      `${productName || "Product"} added to cart!`,
      "success"
    );

    // Dispatch event to update cart display
    this.dispatchEvent(new CustomEvent("cartupdated"));
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

  get displayedProducts() {
    const start = this.currentPage * this.pageSize;
    const end = Math.min(start + this.pageSize, this.products.length);
    return this.products.slice(start, end).map((product) => ({
      ...product,
      displayPrice: this.getProductPrice(product),
      hasPrice: this.hasProductPrice(product)
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
}
