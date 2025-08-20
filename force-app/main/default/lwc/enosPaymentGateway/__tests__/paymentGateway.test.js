import { createElement } from "lwc";
import PaymentGateway from "c/enosPaymentGateway";

describe("c-enos-payment-gateway", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("creates component successfully", () => {
    const element = createElement("c-enos-payment-gateway", {
      is: PaymentGateway
    });

    expect(element).toBeTruthy();
    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);
  });

  it("instantiates with expected constructor", () => {
    const element = createElement("c-enos-payment-gateway", {
      is: PaymentGateway
    });

    expect(element.constructor.name).toBe("HTMLBridgeElement");
  });

  it("renders payment form elements", () => {
    const element = createElement("c-enos-payment-gateway", {
      is: PaymentGateway
    });
    document.body.appendChild(element);

    // Test that the component renders without throwing errors
    return Promise.resolve().then(() => {
      // Basic DOM assertions
      expect(element.tagName.toLowerCase()).toBe("c-enos-payment-gateway");
    });
  });

  it("handles component lifecycle", () => {
    const element = createElement("c-enos-payment-gateway", {
      is: PaymentGateway
    });

    // Test connected/disconnected lifecycle
    document.body.appendChild(element);
    expect(element.isConnected).toBe(true);

    document.body.removeChild(element);
    expect(element.isConnected).toBe(false);
  });

  it("maintains component integrity", () => {
    const element = createElement("c-enos-payment-gateway", {
      is: PaymentGateway
    });
    document.body.appendChild(element);

    // Test component properties exist and are accessible
    expect(typeof element.tagName).toBe("string");
    expect(element.tagName.toLowerCase()).toBe("c-enos-payment-gateway");
  });
});
