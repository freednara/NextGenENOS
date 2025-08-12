import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import LMS resources
import { publish, MessageContext } from 'lightning/messageService';
import CART_UPDATE_CHANNEL from '@salesforce/messageChannel/CartUpdate';
// Import Apex
import getProductById from '@salesforce/apex/ProductController.getProductById';
import addItemToCart from '@salesforce/apex/CartController.addItemToCart';

export default class ProductDetail extends LightningElement {
    @api recordId;
    quantity = 1;

    // Wire the MessageContext for publishing
    @wire(MessageContext)
    messageContext;

    @wire(getProductById, { productId: '$recordId' })
    product;

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    handleAddToCart() {
        addItemToCart({ productId: this.recordId, quantity: this.quantity })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Item added to cart!',
                        variant: 'success'
                    })
                );
                // Publish a message on the LMS channel
                const payload = { source: 'ProductDetail' };
                publish(this.messageContext, CART_UPDATE_CHANNEL, payload);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Adding to Cart',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}
