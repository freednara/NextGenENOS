import { createElement } from 'lwc';
import ProductBrowser from 'c/productBrowser';

describe('ProductBrowser Smoke Test', () => {
    it('should be able to instantiate the component class', () => {
        // Just test that the class can be instantiated without errors
        expect(() => {
            const element = createElement('c-product-browser', {
                is: ProductBrowser
            });
        }).not.toThrow();
    });

    it('should have the expected component structure', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });
        
        // Check if the component has the expected properties
        expect(element.products).toBeDefined();
        expect(element.isAddingToCart).toBeDefined();
        expect(element.searchTerm).toBeDefined();
    });

    it('should have the expected methods', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });
        
        // Check if the component has the expected methods
        expect(typeof element.handleSearch).toBe('function');
        expect(typeof element.performSearch).toBe('function');
        expect(typeof element.refreshProducts).toBe('function');
        expect(typeof element.handleShowAllProducts).toBe('function');
        expect(typeof element.handleAddToCart).toBe('function');
        expect(typeof element.handleProductClick).toBe('function');
        expect(typeof element.handleImageError).toBe('function');
        expect(typeof element.showToast).toBe('function');
    });

    it('should have the expected computed properties', () => {
        const element = createElement('c-product-browser', {
            is: ProductBrowser
        });
        
        // Check if the component has the expected getters
        expect(typeof element.isLoading).toBe('function');
        expect(typeof element.hasProducts).toBe('function');
        expect(typeof element.hasError).toBe('function');
        expect(typeof element.errorMessage).toBe('function');
        expect(typeof element.enhancedProducts).toBe('function');
    });
});
