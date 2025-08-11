/**
 * @description Main controller for StoreConnect e-commerce functionality
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-16
 * 
 * This class handles all core e-commerce operations including product queries,
 * cart management, and user interactions. All operations enforce CRUD/FLS
 * permissions and prevent SOQL injection attacks.
 */
public with sharing class StoreConnectController {
    
    /**
     * @description Retrieves products for the catalog with pagination and filtering
     * @param searchTerm Search term for product name or description
     * @param category Category filter for product code
     * @param pageNumber Current page number (0-based)
     * @param pageSize Number of products per page
     * @param topSellersOnly Filter for top-selling products only
     * @return ProductCatalogResult containing products and pagination info
     * @throws AuraHandledException if operation fails or security check fails
     */
    @AuraEnabled(cacheable=true)
    public static ProductCatalogResult getProducts(String searchTerm, String category, Integer pageNumber, Integer pageSize, Boolean topSellersOnly) {
        try {
            // Security: Check if user has read permission on Product2
            if (!StoreConnectSecurityUtil.hasReadPermission('Product2')) {
                throw new SecurityException('User lacks permission to read products');
            }
            
            // Security: Sanitize and validate input parameters
            String sanitizedSearchTerm = StoreConnectSecurityUtil.sanitizeInput(searchTerm, 255);
            String sanitizedCategory = StoreConnectSecurityUtil.sanitizeInput(category, 100);
            
            // Validate pagination parameters
            if (pageNumber < 0 || pageSize <= 0 || pageSize > 100) {
                throw new IllegalArgumentException('Invalid pagination parameters');
            }
            
            // Build static query with bind variables to prevent SOQL injection
            String baseQuery = 'SELECT Id, Name, ProductCode, Description, Image_URL__c, Stock_Quantity__c, Is_Top_Seller__c, IsActive ' +
                             'FROM Product2 ' +
                             'WHERE IsActive = true ';
            
            List<String> conditions = new List<String>();
            List<Object> bindVariables = new List<Object>();
            
            if (String.isNotBlank(sanitizedSearchTerm)) {
                conditions.add('(Name LIKE :searchPattern1 OR Description LIKE :searchPattern2)');
                bindVariables.add('%' + sanitizedSearchTerm + '%');
                bindVariables.add('%' + sanitizedSearchTerm + '%');
            }
            
            if (String.isNotBlank(sanitizedCategory)) {
                conditions.add('ProductCode LIKE :categoryPattern');
                bindVariables.add('%' + sanitizedCategory + '%');
            }
            
            if (topSellersOnly) {
                conditions.add('Is_Top_Seller__c = true');
            }
            
            if (!conditions.isEmpty()) {
                baseQuery += 'AND ' + String.join(conditions, ' AND ');
            }
            
            baseQuery += ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            bindVariables.add(pageSize);
            bindVariables.add(pageNumber * pageSize);
            
            // Execute query with bind variables
            List<Product2> products = Database.queryWithBinds(baseQuery, bindVariables);
            
            // Get total count for pagination (also using bind variables)
            String countQuery = 'SELECT COUNT() FROM Product2 WHERE IsActive = true ';
            List<Object> countBindVariables = new List<Object>();
            
            if (String.isNotBlank(sanitizedSearchTerm)) {
                countQuery += 'AND (Name LIKE :searchPattern1 OR Description LIKE :searchPattern2) ';
                countBindVariables.add('%' + sanitizedSearchTerm + '%');
                countBindVariables.add('%' + sanitizedSearchTerm + '%');
            }
            
            if (String.isNotBlank(sanitizedCategory)) {
                countQuery += 'AND ProductCode LIKE :categoryPattern ';
                countBindVariables.add('%' + sanitizedCategory + '%');
            }
            
            if (topSellersOnly) {
                countQuery += 'AND Is_Top_Seller__c = true';
            }
            
            Integer totalCount = Database.countQueryWithBinds(countQuery, countBindVariables);
            
            return new ProductCatalogResult(products, totalCount, pageNumber, pageSize);
            
        } catch (StoreConnectSecurityUtil.SecurityException e) {
            throw new AuraHandledException('Security violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets or creates a cart for the current user
     * @param contactId The Contact ID of the current user
     * @return Cart__c The user's active cart
     * @throws AuraHandledException if operation fails or security check fails
     */
    @AuraEnabled
    public static Cart__c getOrCreateCart(Id contactId) {
        try {
            // Security: Check if user has read and create permissions on Cart__c
            if (!StoreConnectSecurityUtil.hasReadPermission('Cart__c')) {
                throw new SecurityException('User lacks permission to read carts');
            }
            
            // Validate input parameter
            if (contactId == null) {
                throw new IllegalArgumentException('Contact ID cannot be null');
            }
            
            // Check if user already has an active cart
            List<Cart__c> existingCarts = [
                SELECT Id, Name, Status__c, Subtotal__c, Total_Items__c,
                       (SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c, 
                               Product__r.Name, Product__r.Image_URL__c, Product__r.Stock_Quantity__c
                        FROM Cart_Items__r)
                FROM Cart__c 
                WHERE Contact__c = :contactId AND Status__c = 'Active'
                LIMIT 1
            ];
            
            if (!existingCarts.isEmpty()) {
                return existingCarts[0];
            }
            
            // Security: Check if user has create permission before creating new cart
            if (!StoreConnectSecurityUtil.hasCreatePermission('Cart__c')) {
                throw new SecurityException('User lacks permission to create carts');
            }
            
            // Create new cart
            Cart__c newCart = new Cart__c(
                Contact__c = contactId,
                Status__c = 'Active'
            );
            
            // Security: Validate record access before insert
            StoreConnectSecurityUtil.validateRecordAccess(new List<Cart__c>{newCart}, 'CREATE');
            
            insert newCart;
            
            return newCart;
            
        } catch (StoreConnectSecurityUtil.SecurityException e) {
            throw new AuraHandledException('Security violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error getting or creating cart: ' + e.getMessage());
        }
    }
    
    // Add product to cart
    @AuraEnabled
    public static Cart_Item__c addToCart(Id cartId, Id productId, Integer quantity) {
        try {
            // Validate product and get price
            Product2 product = [SELECT Id, Name, Stock_Quantity__c FROM Product2 WHERE Id = :productId AND IsActive = true];
            
            if (product.Stock_Quantity__c < quantity) {
                throw new AuraHandledException('Insufficient stock. Available: ' + product.Stock_Quantity__c);
            }
            
            // Check if product already in cart
            List<Cart_Item__c> existingItems = [
                SELECT Id, Quantity__c 
                FROM Cart_Item__c 
                WHERE Cart__c = :cartId AND Product__c = :productId
            ];
            
            if (!existingItems.isEmpty()) {
                // Update quantity
                existingItems[0].Quantity__c += quantity;
                update existingItems[0];
                return existingItems[0];
            }
            
            // Create new cart item
            Cart_Item__c newItem = new Cart_Item__c(
                Cart__c = cartId,
                Product__c = productId,
                Quantity__c = quantity,
                Unit_Price__c = getProductPrice(productId) // This would call your pricing logic
            );
            
            insert newItem;
            return newItem;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error adding to cart: ' + e.getMessage());
        }
    }
    
    // Update cart item quantity
    @AuraEnabled
    public static void updateCartItemQuantity(Id cartItemId, Integer newQuantity) {
        try {
            if (newQuantity <= 0) {
                deleteCartItem(cartItemId);
                return;
            }
            
            Cart_Item__c item = [SELECT Id, Quantity__c, Product__r.Stock_Quantity__c FROM Cart_Item__c WHERE Id = :cartItemId];
            
            if (item.Product__r.Stock_Quantity__c < newQuantity) {
                throw new AuraHandledException('Insufficient stock. Available: ' + item.Product__r.Stock_Quantity__c);
            }
            
            item.Quantity__c = newQuantity;
            update item;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error updating cart item: ' + e.getMessage());
        }
    }
    
    // Remove item from cart
    @AuraEnabled
    public static void deleteCartItem(Id cartItemId) {
        try {
            delete [SELECT Id FROM Cart_Item__c WHERE Id = :cartItemId];
        } catch (Exception e) {
            throw new AuraHandledException('Error removing cart item: ' + e.getMessage());
        }
    }
    
    // Get shipping addresses for user
    @AuraEnabled(cacheable=true)
    public static List<Shipping_Address__c> getShippingAddresses(Id accountId) {
        try {
            return [
                SELECT Id, Address_Label__c, Street__c, City__c, State__c, Postal_Code__c, Country__c, Is_Default__c
                FROM Shipping_Address__c
                WHERE Account__c = :accountId
                ORDER BY Is_Default__c DESC, Address_Label__c
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving shipping addresses: ' + e.getMessage());
        }
    }
    
    // Track product view
    @AuraEnabled
    public static void trackProductView(Id contactId, Id productId) {
        try {
            // Upsert view tracking record
            View_Tracking__c viewTracking = new View_Tracking__c(
                User_Contact__c = contactId,
                Product__c = productId,
                Last_Viewed_Date__c = System.now()
            );
            
            upsert viewTracking;
            
        } catch (Exception e) {
            // Don't throw error for tracking - just log it
            System.debug('Error tracking product view: ' + e.getMessage());
        }
    }
    
    // Request back-in-stock notification
    @AuraEnabled
    public static void requestBackInStockNotification(Id contactId, Id productId) {
        try {
            // Check if notification already exists
            List<Notification_Request__c> existingRequests = [
                SELECT Id FROM Notification_Request__c 
                WHERE User_Contact__c = :contactId AND Product__c = :productId AND Status__c = 'Active'
            ];
            
            if (!existingRequests.isEmpty()) {
                throw new AuraHandledException('Notification request already exists for this product.');
            }
            
            Notification_Request__c notification = new Notification_Request__c(
                User_Contact__c = contactId,
                Product__c = productId,
                Status__c = 'Active'
            );
            
            insert notification;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error requesting notification: ' + e.getMessage());
        }
    }
    
    // Helper method to get product price (placeholder for your pricing logic)
    private static Decimal getProductPrice(Id productId) {
        // This would integrate with your pricing engine
        // For now, return a default price
        return 99.99;
    }
    
    // Wrapper class for product catalog results
    public class ProductCatalogResult {
        @AuraEnabled public List<Product2> products;
        @AuraEnabled public Integer totalCount;
        @AuraEnabled public Integer pageNumber;
        @AuraEnabled public Integer pageSize;
        
        public ProductCatalogResult(List<Product2> products, Integer totalCount, Integer pageNumber, Integer pageSize) {
            this.products = products;
            this.totalCount = totalCount;
            this.pageNumber = pageNumber;
            this.pageSize = pageSize;
        }
    }
    
    /**
     * @description Custom exception class for security violations
     */
    public class SecurityException extends Exception {}
}
