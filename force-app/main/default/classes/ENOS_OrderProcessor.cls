/**
 * @description Handles checkout and order processing for ENOS.
 * This class manages the complete order lifecycle from cart to fulfillment.
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_OrderProcessor {
    /**
     * @description Performs checkout for the supplied cart and creates an
     *              Order with OrderItems. Inventory is adjusted and the cart
     *              marked as converted.
     * @param cartId            Id of the cart to checkout
     * @param shippingAddressId Shipping address to use
     * @param paymentMethod     Token or description of payment method
     * @return                  Wrapper containing the created order details
     */
    @AuraEnabled
    public static OrderResult processCheckout(Id cartId, Id shippingAddressId, String paymentMethod) {
        try {
            // Permission check – payment processing requires the custom perm
            ENOS_SecurityUtils.validateENOSAccess(false, true);

            if (cartId == null || shippingAddressId == null || String.isBlank(paymentMethod)) {
                ENOS_ExceptionUtils.throwMissingData('checkout information');
            }

            // CRUD checks for objects accessed - using batch validation
            ENOS_SecurityUtils.validateOrderAccess();
            ENOS_SecurityUtils.checkObjectReadable('Shipping_Address__c');

            // FLS checks for fields we will read
            ENOS_SecurityUtils.checkFieldReadAccess('Cart__c', new List<String>{
                'Id','Contact__c','Contact__r.AccountId','Subtotal__c','Total_Items__c','Status__c'
            });
            ENOS_SecurityUtils.checkFieldReadAccess('Cart_Item__c', new List<String>{
                'Id','Product__c','Quantity__c','Unit_Price__c','Line_Total__c',
                'Product__r.Name','Product__r.Stock_Quantity__c'
            });
            ENOS_SecurityUtils.checkFieldReadAccess('Shipping_Address__c', new List<String>{
                'Street__c','City__c','State__c','Postal_Code__c','Country__c'
            });

            // Load cart and related items with security enforced
            Cart__c cart = [
                SELECT Id, Contact__c, Contact__r.AccountId, Subtotal__c, Total_Items__c, Status__c,
                       (SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c,
                               Product__r.Name, Product__r.Stock_Quantity__c
                          FROM Cart_Items__r)
                FROM Cart__c
                WHERE Id = :cartId AND Status__c = 'Active'
                LIMIT 1
            ];

            if (cart.Cart_Items__r.isEmpty()) {
                ENOS_ExceptionUtils.throwBusinessRuleViolation('Cart Validation', 'Cart must contain items to process checkout');
            }

            validateInventory(cart.Cart_Items__r);

            // Load shipping address
            Shipping_Address__c shippingAddress = [
                SELECT Street__c, City__c, State__c, Postal_Code__c, Country__c
                FROM Shipping_Address__c
                WHERE Id = :shippingAddressId
                LIMIT 1
            ];

            // Create order and order items
            Order order = createOrder(cart, shippingAddress);
            createOrderItems(order.Id, cart.Cart_Items__r);

            // Adjust inventory
            updateInventory(cart.Cart_Items__r);

            // Mark cart as converted
            ENOS_SecurityUtils.checkObjectUpdateable('Cart__c');
            ENOS_SecurityUtils.checkFieldEditAccess('Cart__c', new List<String>{'Status__c'});
            cart.Status__c = 'Converted';
            update cart;

            // Process payment (integration placeholder)
            processPayment(order.Id, cart.Subtotal__c, paymentMethod);

            return new OrderResult(order.Id, order.OrderNumber, 'Success');
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('process checkout', e);
            return null;
        }
    }

    // Ensure requested quantities do not exceed inventory
    private static void validateInventory(List<Cart_Item__c> cartItems) {
        for (Cart_Item__c item : cartItems) {
            if (item.Product__r.Stock_Quantity__c < item.Quantity__c) {
                ENOS_ExceptionUtils.throwBusinessRuleViolation('Inventory Check', 'Insufficient stock for ' + item.Product__r.Name);
            }
        }
    }

    // Create Order record with FLS checks
    private static Order createOrder(Cart__c cart, Shipping_Address__c shippingAddress) {
        ENOS_SecurityUtils.checkFieldEditAccess('Order', new List<String>{
            'AccountId','EffectiveDate','Status','ShippingStreet','ShippingCity',
            'ShippingState','ShippingPostalCode','ShippingCountry','Type'
        });

        Order order = new Order(
            AccountId        = cart.Contact__r.AccountId,
            EffectiveDate    = System.today(),
            Status           = 'Draft',
            ShippingStreet   = shippingAddress.Street__c,
            ShippingCity     = shippingAddress.City__c,
            ShippingState    = shippingAddress.State__c,
            ShippingPostalCode = shippingAddress.Postal_Code__c,
            ShippingCountry  = shippingAddress.Country__c,
            Type             = 'Customer - Direct'
        );
        insert order;
        return order;
    }

    // Create OrderItem records for each cart line
    private static void createOrderItems(Id orderId, List<Cart_Item__c> cartItems) {
        ENOS_SecurityUtils.checkFieldEditAccess('OrderItem', new List<String>{
            'OrderId','Product2Id','Quantity','UnitPrice'
        });

        List<OrderItem> orderItems = new List<OrderItem>();
        for (Cart_Item__c cartItem : cartItems) {
            orderItems.add(new OrderItem(
                OrderId   = orderId,
                Product2Id= cartItem.Product__c,
                Quantity  = cartItem.Quantity__c,
                UnitPrice = cartItem.Unit_Price__c
            ));
        }
        if (!orderItems.isEmpty()) {
            insert orderItems;
        }
    }

    // Decrement inventory for products in the cart
    private static void updateInventory(List<Cart_Item__c> cartItems) {
        ENOS_SecurityUtils.checkObjectUpdateable('Product2');
        ENOS_SecurityUtils.checkFieldEditAccess('Product2', new List<String>{'Stock_Quantity__c'});

        Map<Id, Decimal> qtyByProduct = new Map<Id, Decimal>();
        for (Cart_Item__c item : cartItems) {
            qtyByProduct.put(item.Product__c,
                             qtyByProduct.get(item.Product__c) + item.Quantity__c);
        }

        List<Product2> products = [
            SELECT Id, Stock_Quantity__c
            FROM Product2
            WHERE Id IN :qtyByProduct.keySet()
            WITH USER_MODE
        ];
        for (Product2 p : products) {
            p.Stock_Quantity__c = p.Stock_Quantity__c - qtyByProduct.get(p.Id);
        }
        if (!products.isEmpty()) {
            update products;
        }
    }

    // Placeholder payment processing - integrate with gateway as needed
    private static void processPayment(Id orderId, Decimal amount, String paymentMethod) {
        System.debug(LoggingLevel.INFO, 'Processing payment for order ' + orderId);
    }

    /**
     * Retrieves full order details including items.
     */
    @AuraEnabled(cacheable=true)
    public static OrderDetails getOrderDetails(Id orderId) {
        try {
            ENOS_SecurityUtils.validateENOSAccess(false, false);
            ENOS_SecurityUtils.checkObjectReadable('Order');
            ENOS_SecurityUtils.checkObjectReadable('OrderItem');
            ENOS_SecurityUtils.checkFieldReadAccess('Order', new List<String>{
                'Id','OrderNumber','Status','EffectiveDate','TotalAmount',
                'ShippingStreet','ShippingCity','ShippingState','ShippingPostalCode','ShippingCountry'
            });
            ENOS_SecurityUtils.checkFieldReadAccess('OrderItem', new List<String>{
                'Id','Product2Id','Product2.Name','Product2.Image_URL__c','Quantity','UnitPrice','TotalPrice'
            });

            Order ord = [
                SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount,
                       ShippingStreet, ShippingCity, ShippingState,
                       ShippingPostalCode, ShippingCountry,
                       (SELECT Id, Product2Id, Product2.Name, Product2.Image_URL__c,
                               Quantity, UnitPrice, TotalPrice FROM OrderItems)
                FROM Order
                WHERE Id = :orderId
                LIMIT 1
            ];
            return new OrderDetails(ord);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('retrieve order details', e);
            return null;
        }
    }

    /**
     * Retrieves recent orders for an Account.
     */
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrderHistory(Id accountId) {
        try {
            ENOS_SecurityUtils.validateENOSAccess(false, false);
            ENOS_SecurityUtils.checkObjectReadable('Order');
            ENOS_SecurityUtils.checkFieldReadAccess('Order', new List<String>{
                'Id','OrderNumber','Status','EffectiveDate','TotalAmount'
            });

            return [
                SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount
                FROM Order
                WHERE AccountId = :accountId
                ORDER BY EffectiveDate DESC
                LIMIT 50
            ];
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('retrieve order history', e);
            return new List<Order>();
        }
    }

    /**
     * Cancels an activated order.
     */
    @AuraEnabled
    public static void cancelOrder(Id orderId) {
        try {
            ENOS_SecurityUtils.validateENOSAccess(true, false);
            ENOS_SecurityUtils.checkObjectReadable('Order');
            ENOS_SecurityUtils.checkObjectUpdateable('Order');
            ENOS_SecurityUtils.checkFieldReadAccess('Order', new List<String>{'Status'});
            ENOS_SecurityUtils.checkFieldEditAccess('Order', new List<String>{'Status'});

            Order ord = [SELECT Id, Status FROM Order WHERE Id = :orderId WITH USER_MODE LIMIT 1];
            if (ord.Status == 'Activated') {
                ord.Status = 'Cancelled';
                update ord;
            } else {
                ENOS_ExceptionUtils.throwBusinessRuleViolation('Order Cancellation', 'Order cannot be cancelled in its current status');
            }
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            ENOS_ExceptionUtils.throwOperationFailure('cancel order', e);
        }
    }

    // Wrapper classes -----------------------------------------------------
    public class OrderResult {
        @AuraEnabled public Id orderId;
        @AuraEnabled public String orderNumber;
        @AuraEnabled public String status;

        public OrderResult(Id orderId, String orderNumber, String status) {
            this.orderId = orderId;
            this.orderNumber = orderNumber;
            this.status = status;
        }
    }

    public class OrderDetails {
        @AuraEnabled public Order order;
        @AuraEnabled public List<OrderItem> orderItems;

        public OrderDetails(Order order) {
            this.order = order;
            this.orderItems = order.OrderItems;
        }
    }
}

