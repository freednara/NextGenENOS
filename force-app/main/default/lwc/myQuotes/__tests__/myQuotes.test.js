import { createElement } from 'lwc';
import MyQuotes from 'c/myQuotes';

describe('c-my-quotes', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('creates component successfully', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });

        expect(element).toBeTruthy();
        document.body.appendChild(element);
        expect(element.isConnected).toBe(true);
    });

    it('instantiates with expected constructor', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });

        expect(element.constructor.name).toBe('HTMLBridgeElement');
    });

    it('shows upgrade message by default', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        document.body.appendChild(element);

        expect(element.showUpgradeMessage).toBe(true);
    });

    it('displays correct message in non-account mode', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        document.body.appendChild(element);

        expect(element.isAccountMode).toBe(false);
        expect(element.message).toContain('Enterprise Edition features');
    });

    it('displays correct message in account mode', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        element.recordId = 'test-account-id';
        document.body.appendChild(element);

        expect(element.isAccountMode).toBe(true);
        expect(element.message).toContain('Enterprise Edition features');
    });

    it('handles recordId property correctly', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        
        // Initially no recordId
        expect(element.isAccountMode).toBe(false);
        
        // Set recordId
        element.recordId = 'test-record-id';
        expect(element.isAccountMode).toBe(true);
        
        // Clear recordId
        element.recordId = null;
        expect(element.isAccountMode).toBe(false);
    });

    it('handles empty recordId correctly', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        element.recordId = '';
        
        expect(element.isAccountMode).toBe(false);
    });

    it('handles undefined recordId correctly', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        element.recordId = undefined;
        
        expect(element.isAccountMode).toBe(false);
    });

    it('provides consistent message regardless of mode', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        
        // Test without recordId
        const messageWithoutRecord = element.message;
        
        // Test with recordId
        element.recordId = 'test-id';
        const messageWithRecord = element.message;
        
        expect(messageWithoutRecord).toBe(messageWithRecord);
        expect(messageWithRecord).toContain('Enterprise Edition');
    });

    it('maintains showUpgradeMessage state', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        
        expect(element.showUpgradeMessage).toBe(true);
        
        // Set recordId and verify state persists
        element.recordId = 'test-id';
        expect(element.showUpgradeMessage).toBe(true);
    });

    it('handles multiple instances independently', () => {
        const element1 = createElement('c-my-quotes', {
            is: MyQuotes
        });
        const element2 = createElement('c-my-quotes', {
            is: MyQuotes
        });
        
        element1.recordId = 'account-1';
        element2.recordId = null;
        
        document.body.appendChild(element1);
        document.body.appendChild(element2);

        expect(element1.isAccountMode).toBe(true);
        expect(element2.isAccountMode).toBe(false);
    });

    it('provides accessible message content', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        document.body.appendChild(element);

        const message = element.message;
        expect(message).toBeTruthy();
        expect(message.length).toBeGreaterThan(0);
        expect(message).toContain('contact your administrator');
    });
});
