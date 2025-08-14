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

    it('renders without errors', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(element.tagName.toLowerCase()).toBe('c-my-quotes');
        });
    });

    it('handles component lifecycle', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        
        document.body.appendChild(element);
        expect(element.isConnected).toBe(true);
        
        document.body.removeChild(element);
        expect(element.isConnected).toBe(false);
    });

    it('maintains component integrity', () => {
        const element = createElement('c-my-quotes', {
            is: MyQuotes
        });
        document.body.appendChild(element);

        expect(typeof element.tagName).toBe('string');
        expect(element.tagName.toLowerCase()).toBe('c-my-quotes');
    });
});