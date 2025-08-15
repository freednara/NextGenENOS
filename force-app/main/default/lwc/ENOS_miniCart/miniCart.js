import { LightningElement, wire } from "lwc";
// Import LMS resources and refreshApex
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import CART_UPDATE_CHANNEL from "@salesforce/messageChannel/CartUpdate__c";
import { refreshApex } from "@salesforce/apex";
// Import Apex
import getCartItemCount from "@salesforce/apex/ENOS_CartController.getCartItemCount";

/**
 * @description Mini Cart component for ENOS e-commerce platform
 * Displays cart item count and provides real-time updates via Lightning Message Service
 * @author ENOS Development Team
 * @version 1.0.0
 */
export default class MiniCart extends LightningElement {
  // Subscription to the LMS channel
  subscription = null;

  // Store the wired result for refreshApex
  wiredCartResult;

  // Wire the MessageContext for subscribing to messages
  @wire(MessageContext)
  messageContext;

  // Wire the initial item count from Apex
  @wire(getCartItemCount)
  wiredCart(result) {
    this.wiredCartResult = result;

    // Handle any errors from the wire service
    if (result.error) {
      // Don't show error to user for mini cart - just log it
    }
  }

  /**
   * @description Lifecycle hook called when the component is inserted into the DOM.
   * Sets up the subscription to the CartUpdate message channel.
   */
  connectedCallback() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        CART_UPDATE_CHANNEL,
        (message) => this.handleCartUpdate(message)
      );
    }
  }

  /**
   * @description Lifecycle hook called when the component is removed from the DOM.
   * Cleans up the subscription to prevent memory leaks.
   */
  disconnectedCallback() {
    if (this.subscription) {
      unsubscribe(this.subscription);
      this.subscription = null;
    }
  }

  /**
   * @description Handles cart update messages received from the LMS channel.
   * When a message is received, it refreshes the cart count data.
   *
   * @param {Object} message - The message received from the LMS channel
   */
  handleCartUpdate() {
    // Refresh the Apex wire service to get updated cart count
    if (this.wiredCartResult) {
      refreshApex(this.wiredCartResult);
    }
  }

  /**
   * @description Getter for the cart item count.
   * Provides the current count from the wired Apex result.
   *
   * @returns {number} The number of items in the cart, or 0 if no data
   */
  get itemCount() {
    return this.wiredCartResult?.data ?? 0;
  }

  /**
   * @description Getter for determining if the cart has items.
   * Used for conditional styling and display logic.
   *
   * @returns {boolean} True if the cart has items, false otherwise
   */
  get hasItems() {
    return this.itemCount > 0;
  }

  /**
   * @description Getter for determining if the cart count is loading.
   * Used to show loading states or prevent premature display.
   *
   * @returns {boolean} True if the cart count is still loading
   */
  get isLoading() {
    return (
      !this.wiredCartResult ||
      (!this.wiredCartResult.data && !this.wiredCartResult.error)
    );
  }

  /**
   * @description Getter for determining if there's an error loading the cart count.
   * Used for error handling and fallback display.
   *
   * @returns {boolean} True if there's an error loading the cart count
   */
  get hasError() {
    return this.wiredCartResult && this.wiredCartResult.error;
  }
}
