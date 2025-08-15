import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { subscribe, MessageContext } from "lightning/messageService";
import CART_UPDATE_CHANNEL from "@salesforce/messageChannel/CartUpdate__c";
import getCurrentUserCart from "@salesforce/apex/ENOS_CartController.getCurrentUserCart";
import updateCartItemQuantity from "@salesforce/apex/ENOS_CartController.updateCartItemQuantity";
import removeCartItem from "@salesforce/apex/ENOS_CartController.removeCartItem";

export default class ShoppingCart extends NavigationMixin(LightningElement) {
  @api recordId; // Contact ID from the community user

  // Wire message context for Lightning Message Service
  @wire(MessageContext)
  messageContext;

  // Cart data
  @track cart = null;
  @track cartItems = [];
  @track loading = false;
  @track checkoutLoading = false;
  @track showCheckoutModal = false;

  // Subscription for cart updates
  cartUpdateSubscription = null;

  // Cart totals
  get cartSubtotal() {
    return this.cart ? this.cart.Subtotal__c || 0 : 0;
  }

  get cartTotalItems() {
    return this.cart ? this.cart.Total_Items__c || 0 : 0;
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
    this.subscribeToCartUpdates();
  }

  disconnectedCallback() {
    // Unsubscribe from cart updates when component is destroyed
    if (this.cartUpdateSubscription) {
      this.cartUpdateSubscription = null;
    }
  }

  // Load cart data
  async loadCart() {
    this.loading = true;
    try {
      const result = await getCurrentUserCart();

      if (result) {
        this.cart = {
          cartId: result.cartId,
          subtotal: result.subtotal,
          totalItems: result.totalItems
        };
        this.cartItems = result.cartItems || [];
      } else {
        // Empty cart
        this.cart = null;
        this.cartItems = [];
      }
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error loading cart:", error);
      const errorMessage = error.body?.message || "Failed to load cart";
      this.showToast("Error", errorMessage, "error");
    } finally {
      this.loading = false;
    }
  }

  // Subscribe to cart update messages
  subscribeToCartUpdates() {
    this.cartUpdateSubscription = subscribe(
      this.messageContext,
      CART_UPDATE_CHANNEL,
      () => {
        // Reload cart when updates are received
        this.loadCart();
      }
    );
  }

  // Load shipping addresses - simplified version
  async loadShippingAddresses() {
    try {
      // For now, create mock shipping addresses
      this.shippingAddresses = [
        {
          Id: "mock-address-1",
          Address_Label__c: "Home Address",
          Street__c: "123 Main St",
          City__c: "San Francisco",
          State__c: "CA",
          PostalCode__c: "94105"
        }
      ];
      if (this.shippingAddresses.length > 0) {
        this.selectedShippingAddress = this.shippingAddresses[0].Id;
      }
    } catch {
      this.showToast(
        "Error",
        "Failed to load shipping addresses: Feature not yet implemented",
        "error"
      );
    }
  }

  // Update cart item quantity
  async handleQuantityChange(event) {
    const cartItemId = event.target.dataset.itemId;
    const newQuantity = parseInt(event.target.value, 10);

    if (isNaN(newQuantity) || newQuantity < 1) {
      this.showToast(
        "Error",
        "Please enter a valid quantity (1 or greater)",
        "error"
      );
      return;
    }

    try {
      await updateCartItemQuantity({
        cartItemId: cartItemId,
        newQuantity: newQuantity
      });

      this.showToast("Success", "Cart updated successfully", "success");

      // Reload cart to reflect changes
      await this.loadCart();
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error updating cart item:", error);
      const errorMessage = error.body?.message || "Failed to update cart item";
      this.showToast("Error", errorMessage, "error");
    }
  }

  // Remove item from cart
  async handleRemoveItem(event) {
    const cartItemId = event.target.dataset.itemId;
    const productName = event.target.dataset.productName;

    if (!cartItemId) {
      this.showToast("Error", "Unable to identify item to remove", "error");
      return;
    }

    try {
      await removeCartItem({
        cartItemId: cartItemId
      });

      this.showToast(
        "Success",
        `${productName || "Item"} removed from cart`,
        "success"
      );

      // Reload cart to reflect changes
      await this.loadCart();
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error removing cart item:", error);
      const errorMessage =
        error.body?.message || "Failed to remove item from cart";
      this.showToast("Error", errorMessage, "error");
    }
  }

  // Handle shipping address selection
  handleShippingAddressChange(event) {
    this.selectedShippingAddress = event.target.value;
  }

  // Show checkout modal
  handleCheckout() {
    if (!this.selectedShippingAddress) {
      this.showToast("Error", "Please select a shipping address", "error");
      return;
    }
    this.showCheckoutModal = true;
  }

  // Close checkout modal
  handleCloseCheckoutModal() {
    this.showCheckoutModal = false;
  }

  // Process checkout - simplified version
  async handleProcessCheckout() {
    this.checkoutLoading = true;
    try {
      // For now, just show a success message
      this.showToast(
        "Success",
        "Checkout functionality coming soon!",
        "success"
      );

      // Close modal
      this.showCheckoutModal = false;
    } catch {
      this.showToast(
        "Error",
        "Checkout failed: Feature not yet implemented",
        "error"
      );
    } finally {
      this.checkoutLoading = false;
    }
  }

  // Continue shopping
  handleContinueShopping() {
    // This would navigate back to the product catalog
    // For now, just dispatch an event
    this.dispatchEvent(new CustomEvent("continueshopping"));
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

  // Format currency
  formatCurrency(amount) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(amount || 0);
  }

  // Get shipping address display name
  getShippingAddressDisplay(addressId) {
    const address = this.shippingAddresses.find(
      (addr) => addr.Id === addressId
    );
    return address ? address.Address_Label__c : "";
  }
}
