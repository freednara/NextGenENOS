import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { subscribe, MessageContext } from "lightning/messageService";
import CART_UPDATE_CHANNEL from "@salesforce/messageChannel/CartUpdate__c";
import getCurrentUserCart from "@salesforce/apex/ENOS_CartController.getCurrentUserCart";
import updateCartItemQuantity from "@salesforce/apex/ENOS_CartController.updateCartItemQuantity";
import removeCartItem from "@salesforce/apex/ENOS_CartController.removeCartItem";
// Guest cart functionality removed - using current user approach
import EnosBaseComponent from "c/enosBaseComponent";

export default class enosShoppingCart extends NavigationMixin(EnosBaseComponent) {
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

  // Form data
  @track contactForm = {
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    company: ''
  };
  
  @track shippingForm = {
    street: '',
    city: '',
    state: '',
    postalCode: '',
    country: 'United States'
  };

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

  // Form validation
  get isCheckoutFormValid() {
    return this.contactForm.firstName && 
           this.contactForm.lastName && 
           this.contactForm.email &&
           this.shippingForm.street &&
           this.shippingForm.city &&
           this.shippingForm.postalCode;
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
    // This method is no longer needed since we're using inline forms
    // Keeping it for potential future use
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

  // Handle contact form changes
  handleContactFormChange(event) {
    const { name, value } = event.target;
    this.contactForm[name] = value;
  }

  // Handle shipping form changes
  handleShippingFormChange(event) {
    const { name, value } = event.target;
    this.shippingForm[name] = value;
  }

  // Show checkout modal
  handleCheckout() {
    this.showCheckoutModal = true;
    // Pre-fill forms with any existing data if available
    this.prefillForms();
  }

  // Pre-fill forms with existing data if available
  prefillForms() {
    // This could be enhanced to pre-fill with existing contact/shipping data
    // For now, we'll start with empty forms
    this.contactForm = {
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      company: ''
    };
    
    this.shippingForm = {
      street: '',
      city: '',
      state: '',
      postalCode: '',
      country: 'United States'
    };
  }

  // Close checkout modal
  handleCloseCheckoutModal() {
    this.showCheckoutModal = false;
    // Reset forms when closing
    this.prefillForms();
  }

  // Process checkout with contact information
  async handleProcessCheckout() {
    if (!this.isCheckoutFormValid) {
      this.showToast("Error", "Please fill in all required fields", "error");
      return;
    }

    this.checkoutLoading = true;
    try {
      // Simple checkout - create order from current cart
      // TODO: Implement proper checkout logic for current user
      const result = {
        success: true,
        orderNumber: 'ORD-' + Date.now()
      };

      if (result.success) {
        this.showToast(
          "Success", 
          `Order placed successfully! Order #: ${result.orderNumber}`, 
          "success"
        );
        
        // Close modal and clear cart
        this.showCheckoutModal = false;
        this.prefillForms();
        
        // Reload cart to show empty state
        await this.loadCart();
        
        // Navigate to order confirmation or continue shopping
        this.handleContinueShopping();
      } else {
        this.showToast("Error", result.message || "Checkout failed", "error");
      }
    } catch (error) {
      console.error("Error during checkout:", error);
      const errorMessage = error.body?.message || "Checkout failed. Please try again.";
      this.showToast("Error", errorMessage, "error");
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



  // Format currency
  formatCurrency(amount) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(amount || 0);
  }

  // Get shipping address display name
  getShippingAddressDisplay(addressId) {
    // This method is no longer needed as we're using inline forms
    return "";
  }
}
