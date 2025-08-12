public with sharing class StoreConnectOrderProcessor {
    
    // Process checkout and create order
    @AuraEnabled
    public static OrderResult processCheckout(Id cartId, Id shippingAddressId, String paymentMethod) {
        try {
            // Get cart with items
            Cart__c cart = [
                SELECT Id, Contact__c, Contact__r.AccountId, Subtotal__c, Total_Items__c,
                       (SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c,
                               Product__r.Name, Product__r.Stock_Quantity__c
                        FROM Cart_Items__r)
                FROM Cart__c 
                WHERE Id = :cartId AND Status__c = 'Active'
            ];
            
            if (cart.Cart_Items__r.isEmpty()) {
                throw new AuraHandledException('Cart is empty');
            }
            
            // Validate inventory
            validateInventory(cart.Cart_Items__r);
            
            // Get shipping address
            Shipping_Address__c shippingAddress = [
                SELECT Street__c, City__c, State__c, Postal_Code__c, Country__c
                FROM Shipping_Address__c 
                WHERE Id = :shippingAddressId
            ];
            
            // Create order
            Order order = createOrder(cart, shippingAddress);
            
            // Create order items
            List<OrderItem> orderItems = createOrderItems(order.Id, cart.Cart_Items__r);
            
            // Update inventory
            updateInventory(cart.Cart_Items__r);
            
            // Update cart status
            cart.Status__c = 'Converted';
            update cart;
            
            // Process payment (placeholder for your payment integration)
            processPayment(order.Id, cart.Subtotal__c, paymentMethod);
            
            return new OrderResult(order.Id, order.OrderNumber, 'Success');
            
        } catch (Exception e) {
            throw new AuraHandledException('Error processing checkout: ' + e.getMessage());
        }
    }
    
    // Validate inventory availability
    private static void validateInventory(List<Cart_Item__c> cartItems) {
        for (Cart_Item__c item : cartItems) {
            if (item.Product__r.Stock_Quantity__c < item.Quantity__c) {
                throw new AuraHandledException('Insufficient stock for ' + item.Product__r.Name + 
                                            '. Available: ' + item.Product__r.Stock_Quantity__c + 
                                            ', Requested: ' + item.Quantity__c);
            }
        }
    }
    
    // Create order record
    private static Order createOrder(Cart__c cart, Shipping_Address__c shippingAddress) {
        Order order = new Order(
            AccountId = cart.Contact__r.AccountId,
            EffectiveDate = System.today(),
            Status = 'Draft',
            ShippingStreet = shippingAddress.Street__c,
            ShippingCity = shippingAddress.City__c,
            ShippingState = shippingAddress.State__c,
            ShippingPostalCode = shippingAddress.Postal_Code__c,
            ShippingCountry = shippingAddress.Country__c,
            Type = 'Customer - Direct'
        );
        
        insert order;
        return order;
    }
    
    // Create order items
    private static List<OrderItem> createOrderItems(Id orderId, List<Cart_Item__c> cartItems) {
        List<OrderItem> orderItems = new List<OrderItem>();
        
        for (Cart_Item__c cartItem : cartItems) {
            OrderItem orderItem = new OrderItem(
                OrderId = orderId,
                Product2Id = cartItem.Product__c,
                Quantity = cartItem.Quantity__c,
                UnitPrice = cartItem.Unit_Price__c
            );
            orderItems.add(orderItem);
        }
        
        insert orderItems;
        return orderItems;
    }
    
    // Update inventory levels
    private static void updateInventory(List<Cart_Item__c> cartItems) {
        Map<Id, Decimal> productQuantityMap = new Map<Id, Decimal>();
        
        for (Cart_Item__c item : cartItems) {
            if (productQuantityMap.containsKey(item.Product__c)) {
                productQuantityMap.put(item.Product__c, productQuantityMap.get(item.Product__c) + item.Quantity__c);
            } else {
                productQuantityMap.put(item.Product__c, item.Quantity__c);
            }
        }
        
        List<Product2> productsToUpdate = new List<Product2>();
        for (Id productId : productQuantityMap.keySet()) {
            productsToUpdate.add(new Product2(
                Id = productId,
                Stock_Quantity__c = [SELECT Stock_Quantity__c FROM Product2 WHERE Id = :productId].Stock_Quantity__c - productQuantityMap.get(productId)
            ));
        }
        
        update productsToUpdate;
    }
    
    // Process payment (placeholder for your payment integration)
    private static void processPayment(Id orderId, Decimal amount, String paymentMethod) {
        // This would integrate with your payment processor
        // For now, just log the payment attempt
        System.debug('Processing payment for order ' + orderId + ': $' + amount + ' via ' + paymentMethod);
        
        // You might want to create a custom payment record here
        // or integrate with a payment gateway
    }
    
    // Get order details
    @AuraEnabled(cacheable=true)
    public static OrderDetails getOrderDetails(Id orderId) {
        try {
            Order order = [
                SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount,
                       ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                       (SELECT Id, Product2Id, Product2.Name, Product2.Image_URL__c, Quantity, UnitPrice, TotalPrice
                        FROM OrderItems)
                FROM Order 
                WHERE Id = :orderId
            ];
            
            return new OrderDetails(order);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order details: ' + e.getMessage());
        }
    }
    
    // Get order history for user
    @AuraEnabled(cacheable=true)
    public static List<Order> getOrderHistory(Id accountId) {
        try {
            return [
                SELECT Id, OrderNumber, Status, EffectiveDate, TotalAmount
                FROM Order 
                WHERE AccountId = :accountId
                ORDER BY EffectiveDate DESC
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving order history: ' + e.getMessage());
        }
    }
    
    // Cancel order
    @AuraEnabled
    public static void cancelOrder(Id orderId) {
        try {
            Order order = [SELECT Id, Status FROM Order WHERE Id = :orderId];
            
            if (order.Status == 'Activated') {
                order.Status = 'Cancelled';
                update order;
            } else {
                throw new AuraHandledException('Order cannot be cancelled in its current status');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error cancelling order: ' + e.getMessage());
        }
    }
    
    // Wrapper classes
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
