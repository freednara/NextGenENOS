import { createElement } from 'lwc';
import OrderHistory from 'c/orderHistory';

describe('OrderHistory Smoke Test', () => {
    it('should be able to instantiate the component class', () => {
        // Just test that the class can be instantiated without errors
        expect(() => {
            const element = createElement('c-order-history', {
                is: OrderHistory
            });
        }).not.toThrow();
    });

    it('should have the expected component structure', () => {
        const element = createElement('c-order-history', {
            is: OrderHistory
        });
        expect(element.isLoading).toBeDefined();
        expect(element.hasError).toBeDefined();
        expect(element.errorMessage).toBeDefined();
        expect(element.columns).toBeDefined();
        expect(element.defaultSortBy).toBeDefined();
        expect(element.defaultSortDirection).toBeDefined();
    });

    it('should have the expected methods', () => {
        const element = createElement('c-order-history', {
            is: OrderHistory
        });
        expect(typeof element.connectedCallback).toBe('function');
        expect(typeof element.handleRowSelection).toBe('function');
        expect(typeof element.handleSort).toBe('function');
        expect(typeof element.refreshOrders).toBe('function');
        expect(typeof element.showSuccessToast).toBe('function');
        expect(typeof element.showErrorToast).toBe('function');
        expect(typeof element.handleRefresh).toBe('function');
        expect(typeof element.handleContinueShopping).toBe('function');
    });

    it('should have the expected computed properties', () => {
        const element = createElement('c-order-history', {
            is: OrderHistory
        });
        expect(typeof element.orders).toBe('function');
        expect(typeof element.hasOrders).toBe('function');
        expect(typeof element.isLoadingComputed).toBe('function');
        expect(typeof element.hasErrorComputed).toBe('function');
        expect(typeof element.totalOrders).toBe('function');
        expect(typeof element.totalOrderValue).toBe('function');
        expect(typeof element.averageOrderValue).toBe('function');
    });
});
