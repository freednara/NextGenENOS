/**
 * @description Service class for handling order confirmations and notifications.
 * 
 * This service manages post-order processing including email notifications,
 * order confirmation displays, and integration with external systems.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class OrderConfirmationService {
    
    /**
     * @description Sends order confirmation email to customer
     * 
     * @param orderId The ID of the order to send confirmation for
     * @return Boolean indicating success of email sending
     */
    @AuraEnabled
    public static Boolean sendOrderConfirmation(Id orderId) {
        try {
            // Security check - ensure user can read Order records
            SecurityUtils.checkObjectReadable('Order');
            SecurityUtils.checkFieldReadAccess(
                'Order',
                new List<String>{
                    'Id',
                    'OrderNumber',
                    'EffectiveDate',
                    'Status',
                    'TotalAmount',
                    'Account.Name',
                    'ShippingStreet',
                    'ShippingCity',
                    'ShippingState',
                    'ShippingPostalCode'
                }
            );
            
            // Get order with related data
            Order orderRecord = getOrderWithDetails(orderId);
            if (orderRecord == null) {
                throw new AuraHandledException('Order not found or access denied');
            }
            
            // Get contact information for email
            Contact customerContact = getCustomerContact(orderRecord.AccountId);
            if (customerContact == null) {
                throw new AuraHandledException('Customer contact not found');
            }
            
            // Send confirmation email
            Boolean emailSent = sendConfirmationEmail(orderRecord, customerContact);
            
            // Log confirmation activity
            System.debug(LoggingLevel.INFO, 
                'Order confirmation processed for Order: ' + orderRecord.OrderNumber + 
                ', Email sent: ' + emailSent);
            
            return emailSent;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending order confirmation: ' + e.getMessage());
            throw new AuraHandledException('Unable to send order confirmation: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves order details for confirmation display
     * 
     * @param orderId The ID of the order to retrieve
     * @return OrderConfirmationData wrapper with order and line item details
     */
    @AuraEnabled(cacheable=true)
    public static OrderConfirmationData getOrderConfirmationData(Id orderId) {
        try {
            // Security checks
            SecurityUtils.checkObjectReadable('Order');
            SecurityUtils.checkObjectReadable('OrderItem');
            
            // Get current user's account to verify order access
            Id userAccountId = getCurrentUserAccountId();
            if (userAccountId == null) {
                throw new AuraHandledException('User account not found');
            }
            
            // Query order with line items
            List<Order> orders = [
                SELECT Id, OrderNumber, EffectiveDate, Status, TotalAmount,
                       ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                       Description, Account.Name,
                       (SELECT Id, Product2.Name, Quantity, UnitPrice, TotalPrice
                        FROM OrderItems
                        ORDER BY Product2.Name)
                FROM Order
                WHERE Id = :orderId AND AccountId = :userAccountId
                LIMIT 1
            ];
            
            if (orders.isEmpty()) {
                throw new AuraHandledException('Order not found or access denied');
            }
            
            Order orderRecord = orders[0];
            
            // Extract Pay.gov transaction ID from description
            String payGovTransactionId = extractPayGovTransactionId(orderRecord.Description);
            
            // Build confirmation data
            OrderConfirmationData confirmationData = new OrderConfirmationData();
            confirmationData.orderId = orderRecord.Id;
            confirmationData.orderNumber = orderRecord.OrderNumber;
            confirmationData.orderDate = orderRecord.EffectiveDate;
            confirmationData.status = orderRecord.Status;
            confirmationData.totalAmount = orderRecord.TotalAmount;
            confirmationData.accountName = orderRecord.Account.Name;
            confirmationData.payGovTransactionId = payGovTransactionId;
            
            // Build shipping address
            confirmationData.shippingAddress = buildShippingAddressString(orderRecord);
            
            // Build line items
            confirmationData.orderItems = new List<OrderItemData>();
            for (OrderItem item : orderRecord.OrderItems) {
                OrderItemData itemData = new OrderItemData();
                itemData.productName = item.Product2.Name;
                itemData.quantity = item.Quantity;
                itemData.unitPrice = item.UnitPrice;
                itemData.totalPrice = item.TotalPrice;
                confirmationData.orderItems.add(itemData);
            }
            
            return confirmationData;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving order confirmation data: ' + e.getMessage());
            throw new AuraHandledException('Unable to retrieve order details: ' + e.getMessage());
        }
    }
    
    /**
     * @description Tracks order confirmation view for analytics
     * 
     * @param orderId The ID of the order being viewed
     */
    @AuraEnabled
    public static void trackOrderConfirmationView(Id orderId) {
        try {
            // Get current user's contact ID
            Id userContactId = getCurrentUserContactId();
            if (userContactId == null) {
                return; // Don't fail if contact not found, just skip tracking
            }
            
            // In a full implementation, this would create a tracking record
            // For now, just log the view
            System.debug(LoggingLevel.INFO, 
                'Order confirmation viewed - Order: ' + orderId + 
                ', Contact: ' + userContactId);
                
        } catch (Exception e) {
            // Don't fail the confirmation display if tracking fails
            System.debug(LoggingLevel.ERROR, 'Error tracking confirmation view: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // PRIVATE HELPER METHODS
    // ============================================================================
    
    /**
     * @description Retrieves order with necessary details for confirmation
     */
    private static Order getOrderWithDetails(Id orderId) {
        List<Order> orders = [
            SELECT Id, OrderNumber, EffectiveDate, Status, TotalAmount,
                   AccountId, Account.Name,
                   ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
                   Description,
                   (SELECT Id, Product2.Name, Quantity, UnitPrice, TotalPrice
                    FROM OrderItems
                    ORDER BY Product2.Name)
            FROM Order
            WHERE Id = :orderId
            LIMIT 1
        ];
        
        return orders.isEmpty() ? null : orders[0];
    }
    
    /**
     * @description Retrieves customer contact information for the account
     */
    private static Contact getCustomerContact(Id accountId) {
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY CreatedDate
            LIMIT 1
        ];
        
        return contacts.isEmpty() ? null : contacts[0];
    }
    
    /**
     * @description Sends confirmation email to customer
     */
    private static Boolean sendConfirmationEmail(Order orderRecord, Contact customerContact) {
        try {
            // Create email template
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(customerContact.Id);
            email.setSubject('Order Confirmation - ' + orderRecord.OrderNumber);
            
            // Build email body
            String emailBody = buildConfirmationEmailBody(orderRecord, customerContact);
            email.setHtmlBody(emailBody);
            
            // Set sender (use organization-wide address in production)
            email.setSenderDisplayName('StoreConnect Customer Service');
            email.setReplyTo('noreply@storeconnect.gov');
            
            // Send email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            
            return results[0].isSuccess();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending confirmation email: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Builds HTML email body for order confirmation
     */
    private static String buildConfirmationEmailBody(Order orderRecord, Contact customerContact) {
        String emailBody = '<html><body style="font-family: Arial, sans-serif;">';
        emailBody += '<h2>Order Confirmation</h2>';
        emailBody += '<p>Dear ' + customerContact.FirstName + ' ' + customerContact.LastName + ',</p>';
        emailBody += '<p>Thank you for your order. Your payment has been processed through Pay.gov.</p>';
        
        emailBody += '<h3>Order Details</h3>';
        emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
        emailBody += '<tr><td><strong>Order Number:</strong></td><td>' + orderRecord.OrderNumber + '</td></tr>';
        emailBody += '<tr><td><strong>Order Date:</strong></td><td>' + orderRecord.EffectiveDate.format() + '</td></tr>';
        emailBody += '<tr><td><strong>Total Amount:</strong></td><td>$' + orderRecord.TotalAmount.setScale(2) + '</td></tr>';
        emailBody += '<tr><td><strong>Status:</strong></td><td>' + orderRecord.Status + '</td></tr>';
        emailBody += '</table>';
        
        // Add shipping address
        emailBody += '<h3>Shipping Address</h3>';
        emailBody += '<p>' + buildShippingAddressString(orderRecord) + '</p>';
        
        // Add order items
        if (!orderRecord.OrderItems.isEmpty()) {
            emailBody += '<h3>Order Items</h3>';
            emailBody += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">';
            emailBody += '<tr><th>Product</th><th>Quantity</th><th>Unit Price</th><th>Total</th></tr>';
            
            for (OrderItem item : orderRecord.OrderItems) {
                emailBody += '<tr>';
                emailBody += '<td>' + item.Product2.Name + '</td>';
                emailBody += '<td>' + item.Quantity.intValue() + '</td>';
                emailBody += '<td>$' + item.UnitPrice.setScale(2) + '</td>';
                emailBody += '<td>$' + item.TotalPrice.setScale(2) + '</td>';
                emailBody += '</tr>';
            }
            emailBody += '</table>';
        }
        
        // Add Pay.gov information
        String payGovTransactionId = extractPayGovTransactionId(orderRecord.Description);
        if (String.isNotBlank(payGovTransactionId)) {
            emailBody += '<h3>Payment Information</h3>';
            emailBody += '<p><strong>Pay.gov Transaction ID:</strong> ' + payGovTransactionId + '</p>';
            emailBody += '<p>Your payment was processed securely through the federal Pay.gov system.</p>';
        }
        
        emailBody += '<p>Thank you for your business!</p>';
        emailBody += '<p>StoreConnect Customer Service Team</p>';
        emailBody += '</body></html>';
        
        return emailBody;
    }
    
    /**
     * @description Builds formatted shipping address string
     */
    private static String buildShippingAddressString(Order orderRecord) {
        List<String> addressParts = new List<String>();
        
        if (String.isNotBlank(orderRecord.ShippingStreet)) {
            addressParts.add(orderRecord.ShippingStreet);
        }
        if (String.isNotBlank(orderRecord.ShippingCity)) {
            addressParts.add(orderRecord.ShippingCity);
        }
        if (String.isNotBlank(orderRecord.ShippingState)) {
            addressParts.add(orderRecord.ShippingState);
        }
        if (String.isNotBlank(orderRecord.ShippingPostalCode)) {
            addressParts.add(orderRecord.ShippingPostalCode);
        }
        
        return String.join(addressParts, ', ');
    }
    
    /**
     * @description Extracts Pay.gov transaction ID from order description
     */
    private static String extractPayGovTransactionId(String description) {
        if (String.isBlank(description)) {
            return null;
        }
        
        String prefix = 'Pay.gov Transaction ID: ';
        Integer startIndex = description.indexOf(prefix);
        if (startIndex == -1) {
            return null;
        }
        
        String transactionId = description.substring(startIndex + prefix.length());
        // Clean up any extra text after the transaction ID
        Integer endIndex = transactionId.indexOf(' ');
        if (endIndex != -1) {
            transactionId = transactionId.substring(0, endIndex);
        }
        
        return transactionId;
    }
    
    /**
     * @description Gets the current user's contact ID
     */
    private static Id getCurrentUserContactId() {
        List<User> users = [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        return users.isEmpty() ? null : users[0].ContactId;
    }
    
    /**
     * @description Gets the current user's account ID
     */
    private static Id getCurrentUserAccountId() {
        List<User> users = [
            SELECT Contact.AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        return users.isEmpty() ? null : users[0].Contact?.AccountId;
    }
    
    // ============================================================================
    // WRAPPER CLASSES FOR DATA TRANSFER
    // ============================================================================
    
    /**
     * @description Wrapper class for order confirmation data
     */
    public class OrderConfirmationData {
        @AuraEnabled
        public Id orderId;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public Date orderDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Decimal totalAmount;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String shippingAddress;
        @AuraEnabled
        public String payGovTransactionId;
        @AuraEnabled
        public List<OrderItemData> orderItems;
    }
    
    /**
     * @description Wrapper class for order item data
     */
    public class OrderItemData {
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public Decimal quantity;
        @AuraEnabled
        public Decimal unitPrice;
        @AuraEnabled
        public Decimal totalPrice;
    }
}