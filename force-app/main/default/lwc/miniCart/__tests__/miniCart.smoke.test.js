import { createElement } from 'lwc';
import MiniCart from 'c/miniCart';

describe('MiniCart Smoke Test', () => {
    it('should be able to instantiate the component class', () => {
        // Just test that the class can be instantiated without errors
        expect(() => {
            const element = createElement('c-mini-cart', {
                is: MiniCart
            });
        }).not.toThrow();
    });

    it('should have the expected component structure', () => {
        const element = createElement('c-mini-cart', {
            is: MiniCart
        });
        expect(element.subscription).toBeDefined();
        expect(element.wiredCartResult).toBeDefined();
        expect(element.messageContext).toBeDefined();
    });

    it('should have the expected methods', () => {
        const element = createElement('c-mini-cart', {
            is: MiniCart
        });
        expect(typeof element.connectedCallback).toBe('function');
        expect(typeof element.disconnectedCallback).toBe('function');
        expect(typeof element.handleCartUpdate).toBe('function');
        expect(typeof element.wiredCart).toBe('function');
    });

    it('should have the expected computed properties', () => {
        const element = createElement('c-mini-cart', {
            is: MiniCart
        });
        expect(typeof element.itemCount).toBe('function');
        expect(typeof element.hasItems).toBe('function');
        expect(typeof element.isLoading).toBe('function');
        expect(typeof element.hasError).toBe('function');
    });
});
