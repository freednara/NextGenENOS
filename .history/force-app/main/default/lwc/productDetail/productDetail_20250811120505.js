import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductById from '@salesforce/apex/ProductController.getProductById';
import addItemToCart from '@salesforce/apex/CartController.addItemToCart';

export default class ProductDetail extends LightningElement {
    @api recordId;
    quantity = 1;

    @wire(getProductById, { productId: '$recordId' })
    product;

    handleQuantityChange(event) {
        this.quantity = event.target.value;
    }

    handleAddToCart() {
        addItemToCart({ productId: this.recordId, quantity: this.quantity })
            .then(result => {
                // Success
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Item added to cart!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                // Error
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
