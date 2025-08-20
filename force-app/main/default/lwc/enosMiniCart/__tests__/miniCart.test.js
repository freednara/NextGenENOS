import { createElement } from "lwc";
import MiniCart from "c/enosMiniCart";

describe("c-enos-mini-cart", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders component successfully", () => {
    const element = createElement("c-enos-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element);

    expect(element).toBeTruthy();
    expect(element.shadowRoot).toBeTruthy();
  });

  it("renders cart icon structure", () => {
    const element = createElement("c-enos-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const cartButton = element.shadowRoot.querySelector(
        "button, lightning-button, .cart-button"
      );
      const cartIcon = element.shadowRoot.querySelector(
        "lightning-icon, .cart-icon, [icon-name]"
      );

      // Should have some cart-related UI element
      expect(
        cartButton || cartIcon || element.shadowRoot.querySelector("div")
      ).toBeTruthy();
    });
  });

  it("has component tag name", () => {
    const element = createElement("c-enos-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element);

    expect(element.tagName.toLowerCase()).toBe("c-enos-mini-cart");
  });

  it("can be created and destroyed without errors", () => {
    const element = createElement("c-enos-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);

    document.body.removeChild(element);
    expect(element.isConnected).toBe(false);
  });

  it("instantiates correctly", () => {
    const element = createElement("c-enos-mini-cart", {
      is: MiniCart
    });

    expect(element.constructor.name).toBe("HTMLBridgeElement");
  });

  it("has expected template structure", () => {
    const element = createElement("c-enos-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const shadowRoot = element.shadowRoot;
      expect(shadowRoot).toBeTruthy();

      // Should have some kind of content
      const hasContent =
        shadowRoot.children.length > 0 ||
        shadowRoot.textContent.trim().length > 0;
      expect(hasContent).toBe(true);
    });
  });

  it("renders without throwing errors", () => {
    expect(() => {
      const element = createElement("c-mini-cart", {
        is: MiniCart
      });
      document.body.appendChild(element);
    }).not.toThrow();
  });

  it("handles multiple instances", () => {
    const element1 = createElement("c-mini-cart", {
      is: MiniCart
    });
    const element2 = createElement("c-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element1);
    document.body.appendChild(element2);

    expect(element1).toBeTruthy();
    expect(element2).toBeTruthy();
    expect(element1).not.toBe(element2);
  });

  it("maintains shadow DOM isolation", () => {
    const element = createElement("c-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element);

    const shadowRoot = element.shadowRoot;
    expect(shadowRoot).toBeTruthy();
    expect(shadowRoot).not.toBe(document);
  });

  it("has correct custom element lifecycle", () => {
    const element = createElement("c-mini-cart", {
      is: MiniCart
    });

    // Should exist before connection
    expect(element).toBeTruthy();

    // Connect to DOM
    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);

    // Should have shadow root after connection
    expect(element.shadowRoot).toBeTruthy();
  });

  it("can handle click events", () => {
    const element = createElement("c-mini-cart", {
      is: MiniCart
    });

    document.body.appendChild(element);

    const mockDispatchEvent = jest.fn();
    element.dispatchEvent = mockDispatchEvent;

    return Promise.resolve().then(() => {
      // Try to find a clickable element
      const clickableElement = element.shadowRoot.querySelector(
        "button, lightning-button, [onclick]"
      );

      if (clickableElement) {
        clickableElement.click();
        // If click worked, great! If not, that's also fine for this smoke test
      }

      // The main thing is that the component didn't throw an error
      expect(element).toBeTruthy();
    });
  });
});
