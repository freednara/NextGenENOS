import { LightningElement, api, track } from "lwc";
import getRecentlyViewed from "@salesforce/apex/StoreConnectController.getRecentlyViewed";
import { NavigationMixin } from "lightning/navigation";

export default class RecentlyViewed extends NavigationMixin(LightningElement) {
  @api recordId; // Contact Id
  @track recentlyViewed = [];
  @track isLoading = false;
  @track errorMessage;

  get hasRecentlyViewed() {
    return this.recentlyViewed.length > 0;
  }

  get hasError() {
    return !!this.errorMessage;
  }

  connectedCallback() {
    this.loadRecentlyViewed();
  }

  async loadRecentlyViewed() {
    this.isLoading = true;
    try {
      this.recentlyViewed = await getRecentlyViewed({
        contactId: this.recordId
      });
      this.errorMessage = undefined;
    } catch (e) {
      this.errorMessage = e.body ? e.body.message : e.message;
      this.recentlyViewed = [];
    } finally {
      this.isLoading = false;
    }
  }

  refreshRecentlyViewed() {
    this.loadRecentlyViewed();
  }

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
}
