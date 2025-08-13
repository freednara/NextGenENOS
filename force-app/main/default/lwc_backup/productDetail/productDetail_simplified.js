import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import CartUpdate from "@salesforce/messageChannel/CartUpdate__c";

// Import fields
import PRODUCT_NAME from "@salesforce/schema/Product2.Name";
import PRODUCT_DESCRIPTION from "@salesforce/schema/Product2.Description";
import PRODUCT_IMAGE from "@salesforce/schema/Product2.Image_URL__c";
import PRODUCT_STOCK from "@salesforce/schema/Product2.Stock_Quantity__c";

export default class ProductDetail extends LightningElement {
  @api recordId;

  @wire(MessageContext)
  messageContext;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [PRODUCT_NAME, PRODUCT_DESCRIPTION, PRODUCT_IMAGE, PRODUCT_STOCK]
  })
  product;

  quantity = 1;

  get productName() {
    return this.product.data ? this.product.data.fields.Name.value : "";
  }

  get productDescription() {
    return this.product.data ? this.product.data.fields.Description.value : "";
  }

  get productImage() {
    return this.product.data ? this.product.data.fields.Image_URL__c.value : "";
  }

  get productStock() {
    return this.product.data
      ? this.product.data.fields.Stock_Quantity__c.value
      : 0;
  }

  get isInStock() {
    return this.productStock > 0;
  }

  handleQuantityChange(event) {
    this.quantity = parseInt(event.target.value);
  }

  handleAddToCart() {
    if (this.quantity > 0 && this.isInStock) {
      // Publish message to add item to cart
      const message = {
        productId: this.recordId,
        quantity: this.quantity,
        action: "add"
      };

      publish(this.messageContext, CartUpdate, message);

      // Show success message
      this.dispatchEvent(
        new CustomEvent("addtocart", {
          detail: { productId: this.recordId, quantity: this.quantity }
        })
      );
    }
  }
}
