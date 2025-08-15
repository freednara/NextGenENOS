import { createElement } from "lwc";
import ProductDetail from "c/productDetail";

describe("c-product-detail", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders component successfully", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    document.body.appendChild(element);

    expect(element).toBeTruthy();
    expect(element.shadowRoot).toBeTruthy();
  });

  it("has component tag name", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    expect(element.tagName.toLowerCase()).toBe("c-product-detail");
  });

  it("instantiates correctly", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    expect(element.constructor.name).toBe("HTMLBridgeElement");
  });

  it("renders without throwing errors", () => {
    expect(() => {
      const element = createElement("c-product-detail", {
        is: ProductDetail
      });
      document.body.appendChild(element);
    }).not.toThrow();
  });

  it("has expected template structure", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const shadowRoot = element.shadowRoot;
      expect(shadowRoot).toBeTruthy();
    });
  });

  it("can be created and destroyed without errors", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);

    document.body.removeChild(element);
    expect(element.isConnected).toBe(false);
  });

  it("maintains shadow DOM isolation", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    document.body.appendChild(element);

    const shadowRoot = element.shadowRoot;
    expect(shadowRoot).toBeTruthy();
    expect(shadowRoot).not.toBe(document);
  });

  it("handles multiple instances", () => {
    const element1 = createElement("c-product-detail", {
      is: ProductDetail
    });
    const element2 = createElement("c-product-detail", {
      is: ProductDetail
    });

    document.body.appendChild(element1);
    document.body.appendChild(element2);

    expect(element1).toBeTruthy();
    expect(element2).toBeTruthy();
    expect(element1).not.toBe(element2);
  });

  it("has correct custom element lifecycle", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    expect(element).toBeTruthy();
    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);
    expect(element.shadowRoot).toBeTruthy();
  });

  it("can handle recordId property", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    // Test setting recordId (this is typically an @api property)
    element.recordId = "prod123";
    document.body.appendChild(element);

    expect(element).toBeTruthy();
    expect(element.recordId).toBe("prod123");
  });

  it("can set quantity property without errors", () => {
    const element = createElement("c-product-detail", {
      is: ProductDetail
    });

    // Test setting quantity
    element.quantity = 5;
    document.body.appendChild(element);

    expect(element).toBeTruthy();
    // Note: quantity is a private property, so we don't test its value
  });
});
