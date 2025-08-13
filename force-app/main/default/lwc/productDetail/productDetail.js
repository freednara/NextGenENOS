import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { publish, MessageContext } from 'lightning/messageService';
import CartUpdate from '@salesforce/messageChannel/CartUpdate__c';

// Import fields - only use standard fields that exist
import PRODUCT_NAME from '@salesforce/schema/Product2.Name';
import PRODUCT_DESCRIPTION from '@salesforce/schema/Product2.Description';

export default class ProductDetail extends LightningElement {
    @api recordId;
    
    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: [PRODUCT_NAME, PRODUCT_DESCRIPTION] })
    product;

    quantity = 1;

    get productName() {
        return this.product.data ? this.product.data.fields.Name.value : '';
    }

    get productDescription() {
        return this.product.data ? this.product.data.fields.Description.value : '';
    }

    get productImage() {
        // Use a placeholder image since Image_URL__c field doesn't exist
        return 'https://via.placeholder.com/400x300?text=Product+Image';
    }

    get productStock() {
        // Default to in-stock since Stock_Quantity__c field doesn't exist
        return 100;
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
                action: 'add'
            };
            
            publish(this.messageContext, CartUpdate, message);
            
            // Show success message
            this.dispatchEvent(new CustomEvent('addtocart', {
                detail: { productId: this.recordId, quantity: this.quantity }
            }));
        }
    }
}
