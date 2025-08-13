import { LightningElement, api } from 'lwc';

/**
 * @description My Quotes component - Simplified version for StoreConnect
 * Note: Quote functionality requires Enterprise Edition features
 */
export default class MyQuotes extends LightningElement {
    @api recordId; // Account Id - when provided, component works in account mode

    get isAccountMode() {
        return !!this.recordId;
    }

    get message() {
        return this.isAccountMode 
            ? 'Quote functionality requires Enterprise Edition features. Please contact your administrator.'
            : 'Quote functionality requires Enterprise Edition features. Please contact your administrator.';
    }

    get showUpgradeMessage() {
        return true;
    }
}
