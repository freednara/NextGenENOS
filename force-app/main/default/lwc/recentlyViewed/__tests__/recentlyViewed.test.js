import { createElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import RecentlyViewed from 'c/recentlyViewed';
import getRecentlyViewed from '@salesforce/apex/StoreConnectController.getRecentlyViewed';

// Mock the Apex method
jest.mock(
    '@salesforce/apex/StoreConnectController.getRecentlyViewed',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

// Mock NavigationMixin
const mockNavigate = jest.fn();
NavigationMixin.Navigate = mockNavigate;

describe('c-recently-viewed', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Clear all mocks
        jest.clearAllMocks();
    });

    it('creates component successfully', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });

        expect(element).toBeTruthy();
        document.body.appendChild(element);
        expect(element.isConnected).toBe(true);
    });

    it('instantiates with expected constructor', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });

        expect(element.constructor.name).toBe('HTMLBridgeElement');
    });

    it('handles recordId property correctly', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        
        const testRecordId = 'test-contact-id-123';
        element.recordId = testRecordId;
        
        expect(element.recordId).toBe(testRecordId);
    });

    it('shows loading state initially', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        
        // Initially loading should be false until connectedCallback
        expect(element.isLoading).toBe(false);
    });

    it('handles empty recently viewed list', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        
        expect(element.hasRecentlyViewed).toBe(false);
        expect(element.recentlyViewed).toEqual([]);
    });

    it('handles recently viewed data correctly', async () => {
        const mockData = [
            {
                Id: 'prod1',
                Name: 'Test Product 1',
                LastViewedDate: '2024-01-01'
            },
            {
                Id: 'prod2',
                Name: 'Test Product 2',
                LastViewedDate: '2024-01-02'
            }
        ];

        getRecentlyViewed.mockResolvedValue(mockData);

        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        element.recordId = 'test-contact-id';
        document.body.appendChild(element);

        // Wait for async operations
        await Promise.resolve();

        expect(element.hasRecentlyViewed).toBe(true);
        expect(element.recentlyViewed.length).toBe(2);
    });

    it('handles API errors gracefully', async () => {
        const mockError = {
            body: { message: 'Test error message' },
            message: 'Fallback error'
        };

        getRecentlyViewed.mockRejectedValue(mockError);

        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        element.recordId = 'test-contact-id';
        document.body.appendChild(element);

        // Wait for async operations
        await Promise.resolve();

        expect(element.hasError).toBe(true);
        expect(element.errorMessage).toBe('Test error message');
        expect(element.hasRecentlyViewed).toBe(false);
    });

    it('handles API errors without body gracefully', async () => {
        const mockError = {
            message: 'Simple error message'
        };

        getRecentlyViewed.mockRejectedValue(mockError);

        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        element.recordId = 'test-contact-id';
        document.body.appendChild(element);

        // Wait for async operations
        await Promise.resolve();

        expect(element.hasError).toBe(true);
        expect(element.errorMessage).toBe('Simple error message');
    });

    it('handles refresh functionality', async () => {
        const mockData = [
            { Id: 'prod1', Name: 'Test Product 1' }
        ];

        getRecentlyViewed.mockResolvedValue(mockData);

        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        element.recordId = 'test-contact-id';
        document.body.appendChild(element);

        // Initial load
        await Promise.resolve();
        expect(getRecentlyViewed).toHaveBeenCalledTimes(1);

        // Trigger refresh
        element.refreshRecentlyViewed();
        await Promise.resolve();
        
        expect(getRecentlyViewed).toHaveBeenCalledTimes(2);
    });

    it('handles product click navigation', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        document.body.appendChild(element);

        // Mock event
        const mockEvent = {
            currentTarget: {
                dataset: {
                    productId: 'test-product-id-123'
                }
            }
        };

        element.handleProductClick(mockEvent);

        expect(mockNavigate).toHaveBeenCalledWith({
            type: 'standard__recordPage',
            attributes: {
                recordId: 'test-product-id-123',
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });
    });

    it('clears error on successful reload', async () => {
        // First, cause an error
        getRecentlyViewed.mockRejectedValue({ message: 'Error' });
        
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        element.recordId = 'test-contact-id';
        document.body.appendChild(element);

        await Promise.resolve();
        expect(element.hasError).toBe(true);

        // Now mock success
        getRecentlyViewed.mockResolvedValue([]);
        element.refreshRecentlyViewed();
        await Promise.resolve();

        expect(element.hasError).toBe(false);
        expect(element.errorMessage).toBeUndefined();
    });

    it('manages loading state correctly', async () => {
        getRecentlyViewed.mockImplementation(() => 
            new Promise(resolve => setTimeout(() => resolve([]), 100))
        );

        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        element.recordId = 'test-contact-id';
        document.body.appendChild(element);

        // Should be loading after connectedCallback starts
        expect(element.isLoading).toBe(true);

        // Wait for completion
        await new Promise(resolve => setTimeout(resolve, 150));
        
        expect(element.isLoading).toBe(false);
    });

    it('handles navigation mixin correctly', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        
        // Verify NavigationMixin is applied
        expect(typeof element[NavigationMixin.Navigate]).toBe('function');
    });

    it('handles multiple refresh calls', async () => {
        getRecentlyViewed.mockResolvedValue([]);

        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        element.recordId = 'test-contact-id';
        document.body.appendChild(element);

        // Initial load
        await Promise.resolve();

        // Multiple refresh calls
        element.refreshRecentlyViewed();
        element.refreshRecentlyViewed();
        element.refreshRecentlyViewed();

        await Promise.resolve();

        // Should handle multiple calls gracefully
        expect(getRecentlyViewed).toHaveBeenCalledTimes(4); // 1 initial + 3 refresh
    });

    it('handles empty dataset correctly', () => {
        const element = createElement('c-recently-viewed', {
            is: RecentlyViewed
        });
        
        expect(element.hasRecentlyViewed).toBe(false);
        expect(element.hasError).toBe(false);
    });
});
