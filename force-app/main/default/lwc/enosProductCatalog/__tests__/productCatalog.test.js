import { createElement } from "lwc";
import ProductCatalog from "c/enosProductCatalog";

describe("c-enos-product-catalog", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders component successfully", () => {
    const element = createElement("c-enos-product-catalog", {
      is: ProductCatalog
    });

    document.body.appendChild(element);

    expect(element).toBeTruthy();
    expect(element.shadowRoot).toBeTruthy();
  });

  it("has component tag name", () => {
    const element = createElement("c-enos-product-catalog", {
      is: ProductCatalog
    });

    expect(element.tagName.toLowerCase()).toBe("c-enos-product-catalog");
  });

  it("instantiates correctly", () => {
    const element = createElement("c-enos-product-catalog", {
      is: ProductCatalog
    });

    expect(element.constructor.name).toBe("HTMLBridgeElement");
  });

  it("renders without throwing errors", () => {
    expect(() => {
      const element = createElement("c-enos-product-catalog", {
        is: ProductCatalog
      });
      document.body.appendChild(element);
    }).not.toThrow();
  });

  it("has expected template structure", () => {
    const element = createElement("c-enos-product-catalog", {
      is: ProductCatalog
    });

    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const shadowRoot = element.shadowRoot;
      expect(shadowRoot).toBeTruthy();
    });
  });

  it("can be created and destroyed without errors", () => {
    const element = createElement("c-enos-product-catalog", {
      is: ProductCatalog
    });

    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);

    document.body.removeChild(element);
    expect(element.isConnected).toBe(false);
  });

  it("maintains shadow DOM isolation", () => {
    const element = createElement("c-product-catalog", {
      is: ProductCatalog
    });

    document.body.appendChild(element);

    const shadowRoot = element.shadowRoot;
    expect(shadowRoot).toBeTruthy();
    expect(shadowRoot).not.toBe(document);
  });

  it("handles multiple instances", () => {
    const element1 = createElement("c-product-catalog", {
      is: ProductCatalog
    });
    const element2 = createElement("c-product-catalog", {
      is: ProductCatalog
    });

    document.body.appendChild(element1);
    document.body.appendChild(element2);

    expect(element1).toBeTruthy();
    expect(element2).toBeTruthy();
    expect(element1).not.toBe(element2);
  });

  it("has correct custom element lifecycle", () => {
    const element = createElement("c-product-catalog", {
      is: ProductCatalog
    });

    expect(element).toBeTruthy();
    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);
    expect(element.shadowRoot).toBeTruthy();
  });

  it("can handle recordId property", () => {
    const element = createElement("c-product-catalog", {
      is: ProductCatalog
    });

    // Test setting recordId (this is typically an @api property)
    element.recordId = "contact123";
    document.body.appendChild(element);

    expect(element).toBeTruthy();
    expect(element.recordId).toBe("contact123");
  });

  it("can handle properties without errors", () => {
    const element = createElement("c-product-catalog", {
      is: ProductCatalog
    });

    // Test setting various properties
    element.searchTerm = "test";
    element.selectedCategory = "electronics";
    element.currentPage = 1;

    document.body.appendChild(element);

    expect(element).toBeTruthy();
    expect(element.searchTerm).toBe("test");
    expect(element.selectedCategory).toBe("electronics");
    expect(element.currentPage).toBe(1);
  });
});
