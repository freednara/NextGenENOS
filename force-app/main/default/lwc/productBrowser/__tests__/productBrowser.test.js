import { createElement } from 'lwc';
import ProductBrowser from 'c/productBrowser';

describe('c-product-browser', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders component successfully', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        document.body.appendChild(element);

        expect(element).toBeTruthy();
        expect(element.shadowRoot).toBeTruthy();
    });

    it('renders basic structure', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const searchSection = element.shadowRoot.querySelector('.search-section, lightning-input, input');
            const productGrid = element.shadowRoot.querySelector('.product-grid, .products-container, .slds-grid');
            
            // At least one of these elements should be present
            expect(searchSection || productGrid || element.shadowRoot.querySelector('div')).toBeTruthy();
        });
    });

    it('has component tag name', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        document.body.appendChild(element);

        expect(element.tagName.toLowerCase()).toBe('c-product-browser');
    });

    it('can be created and destroyed without errors', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        document.body.appendChild(element);
        expect(element.isConnected).toBe(true);

        document.body.removeChild(element);
        expect(element.isConnected).toBe(false);
    });

    it('instantiates with expected constructor', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        // The constructor name is typically 'HTMLBridgeElement' in testing environment
        expect(element.constructor.name).toBe('HTMLBridgeElement');
    });

    it('has expected template structure', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const shadowRoot = element.shadowRoot;
            expect(shadowRoot).toBeTruthy();
            
            // Should have some kind of content
            const hasContent = shadowRoot.children.length > 0 || shadowRoot.textContent.trim().length > 0;
            expect(hasContent).toBe(true);
        });
    });

    it('renders without throwing errors', () => {
        expect(() => {
            const element = createElement('c-product-browser', {
                is: ProductBrowser
            });
            document.body.appendChild(element);
        }).not.toThrow();
    });

    it('handles multiple instances', () => {
        const element1 = createElement('c-product-browser', {
            is: ProductBrowser
        });
        const element2 = createElement('c-product-browser', {
            is: ProductBrowser
        });

        document.body.appendChild(element1);
        document.body.appendChild(element2);

        expect(element1).toBeTruthy();
        expect(element2).toBeTruthy();
        expect(element1).not.toBe(element2);
    });

    it('maintains shadow DOM isolation', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        document.body.appendChild(element);

        const shadowRoot = element.shadowRoot;
        expect(shadowRoot).toBeTruthy();
        expect(shadowRoot).not.toBe(document);
    });

    it('has correct custom element lifecycle', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });

        // Should exist before connection
        expect(element).toBeTruthy();

        // Connect to DOM
        document.body.appendChild(element);
        expect(element.isConnected).toBe(true);

        // Should have shadow root after connection
        expect(element.shadowRoot).toBeTruthy();
    });
});