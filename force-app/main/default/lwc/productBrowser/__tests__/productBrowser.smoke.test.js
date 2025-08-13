import { createElement } from 'lwc';
import ProductBrowser from "c/productBrowser";

describe("ProductBrowser Smoke Test", () => {
  it("should be able to instantiate the component class", () => {
    // Just test that the class can be instantiated without errors
    expect(() => {
      createElement("c-product-browser", {
        is: ProductBrowser
      });
    }).not.toThrow();
  });

  it("should create component without errors", () => {
    const element = createElement("c-product-browser", {
      is: ProductBrowser
    });

    // Check if the component is created without errors
    expect(element).toBeDefined();
    expect(element.tagName.toLowerCase()).toBe("c-product-browser");
  });

  it("should have basic DOM functionality", () => {
    const element = createElement("c-product-browser", {
      is: ProductBrowser
    });

    // Check if component has basic DOM methods
    expect(element.querySelector).toBeDefined();
    expect(element.addEventListener).toBeDefined();
    expect(element.setAttribute).toBeDefined();
  });

  it("should be an instance of the class", () => {
    const element = createElement("c-product-browser", {
      is: ProductBrowser
    });

    // Check if element is instance of LightningElement
    expect(element).toBeInstanceOf(Element);
  });
});
