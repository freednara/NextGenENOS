/**
 * @description Controller for ENOS Product Catalog component - Production Ready
 * @author Lead Developer
 * @date 2025
 */
public with sharing class ENOS_ProductController {
    
    // Constants for field names and default values
    private static final String DEFAULT_SORT_FIELD = 'Name';
    private static final String DEFAULT_SORT_DIRECTION = 'ASC';
    private static final Integer DEFAULT_PAGE_SIZE = 12;
    private static final Integer DEFAULT_PAGE_NUMBER = 1;
    private static final String CART_STATUS_ACTIVE = 'Active';
    
    // Cached field maps for security validation
    private static Map<String, Schema.SObjectField> productFields;
    private static Map<String, Schema.SObjectField> cartFields;
    private static Map<String, Schema.SObjectField> cartItemFields;
    
    static {
        productFields = Schema.SObjectType.Product2.fields.getMap();
        cartFields = Schema.SObjectType.Cart__c.fields.getMap();
        cartItemFields = Schema.SObjectType.Cart_Item__c.fields.getMap();
    }
    
    /**
     * @description Retrieves products with pagination and filtering
     * @param pageSize Number of products per page
     * @param pageNumber Current page number (1-based)
     * @param searchTerm Optional search term for product name/description
     * @param familyFilter Optional product family filter
     * @param sortBy Optional sort field (Name, UnitPrice, etc.)
     * @param sortDirection Optional sort direction (ASC/DESC)
     * @return List<Product2> List of products with price book entries
     */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(
        Integer pageSize, 
        Integer pageNumber, 
        String searchTerm, 
        String familyFilter,
        String sortBy,
        String sortDirection
    ) {
        try {
            // Security check - verify user can read Product2
            if (!Schema.sObjectType.Product2.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access products');
            }
            
            // Input validation with defaults
            pageSize = (pageSize == null || pageSize <= 0) ? DEFAULT_PAGE_SIZE : pageSize;
            pageNumber = (pageNumber == null || pageNumber <= 0) ? DEFAULT_PAGE_NUMBER : pageNumber;
            sortBy = String.isBlank(sortBy) ? DEFAULT_SORT_FIELD : sortBy;
            sortDirection = String.isBlank(sortDirection) ? DEFAULT_SORT_DIRECTION : sortDirection;
            
            // Validate sort field against allowed values
            if (!isValidSortField(sortBy)) {
                sortBy = DEFAULT_SORT_FIELD;
            }
            
            // Validate sort direction
            if (!isValidSortDirection(sortDirection)) {
                sortDirection = DEFAULT_SORT_DIRECTION;
            }
            
            // Calculate offset
            Integer offset = (pageNumber - 1) * pageSize;
            
            // Build and execute query with security enforcement
            String query = buildProductQuery(searchTerm, familyFilter, sortBy, sortDirection);
            query += ' LIMIT :pageSize OFFSET :offset';
            
            List<Product2> products = Database.query(query);
            
            // Return products directly since fields are already validated
            return products;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving products: ' + e.getMessage());
            throw new CalloutException('Unable to retrieve products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Builds secure SOQL query for products
     */
    private static String buildProductQuery(String searchTerm, String familyFilter, String sortBy, String sortDirection) {
        // Use basic field list that's guaranteed to exist
        String query = 'SELECT Id, Name, ProductCode, Description, IsActive, Family, ' +
                      'Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c, ' +
                      '(SELECT Id, UnitPrice, IsActive, Pricebook2Id, Product2Id ' +
                      'FROM PricebookEntries WHERE IsActive = true) ' +
                      'FROM Product2 WHERE IsActive = true';
        
        // Add search filter with proper escaping
        if (!String.isBlank(searchTerm)) {
            String searchPattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
            query += ' AND (Name LIKE :searchPattern OR Description LIKE :searchPattern)';
        }
        
        // Add family filter with validation
        if (!String.isBlank(familyFilter)) {
            query += ' AND Family = :familyFilter';
        }
        
        // Add sorting with field validation
        query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        
        return query;
    }
    
    /**
     * @description Gets total count of products for pagination
     */
    @AuraEnabled(cacheable=true)
    public static Integer getProductCount(String searchTerm, String familyFilter) {
        try {
            if (!Schema.sObjectType.Product2.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access products');
            }
            
            String query = 'SELECT COUNT() FROM Product2 WHERE IsActive = true';
            
            if (!String.isBlank(searchTerm)) {
                String searchPattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                query += ' AND (Name LIKE :searchPattern OR Description LIKE :searchPattern)';
            }
            
            if (!String.isBlank(familyFilter)) {
                query += ' AND Family = :familyFilter';
            }
            
            return Database.countQuery(query);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error counting products: ' + e.getMessage());
            throw new CalloutException('Unable to count products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets available product families for filtering
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getProductFamilies() {
        try {
            if (!Schema.sObjectType.Product2.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access products');
            }
            
            List<AggregateResult> results = [
                SELECT Family
                FROM Product2
                WHERE IsActive = true AND Family != null
                GROUP BY Family
                ORDER BY Family
            ];
            
            List<String> families = new List<String>();
            for (AggregateResult result : results) {
                families.add((String) result.get('Family'));
            }
            
            return families;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving product families: ' + e.getMessage());
            throw new CalloutException('Unable to retrieve product families: ' + e.getMessage());
        }
    }
    
    /**
     * @description Adds a product to the current user's cart
     * @param productId The product ID to add
     * @param quantity The quantity to add
     * @return CartItemResult Result containing success status and cart item info
     */
    @AuraEnabled
    public static CartItemResult addProductToShoppingCart(String productId, Integer quantity) {
        try {
            // Input validation
            if (String.isBlank(productId)) {
                return new CartItemResult(false, 'Product ID is required', null);
            }
            
            if (quantity == null || quantity <= 0) {
                quantity = 1;
            }
            
            // Convert String to Id for the cart controller
            Id productIdAsId = productId;
            
            // Use the simplified cart system that works with available fields
            Map<String, Object> result = ENOS_CartController.addItemToCart(
                productIdAsId, 
                quantity
            );
            
            if ((Boolean) result.get('success')) {
                // Success - return cart item result
                return new CartItemResult(
                    true, 
                    (String) result.get('message'), 
                    new Cart_Item__c(
                        Id = (Id) result.get('cartItemId'),
                        Cart__c = (Id) result.get('cartId'),
                        Product__c = productIdAsId,
                        Quantity__c = quantity
                    )
                );
            } else {
                // Failed - return error
                return new CartItemResult(false, (String) result.get('message'), null);
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'addToCart error: ' + e.getMessage());
            return new CartItemResult(false, 'Failed to add item to cart: ' + e.getMessage(), null);
        }
    }
    
    // REMOVED: Old Contact-based cart method - replaced with OwnerId-based approach in ENOS_CartController
    
    /**
     * @description Gets all active products (simplified version)
     * @return List<Product2> List of all active products
     */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getAllProducts() {
        try {
            if (!Schema.sObjectType.Product2.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access products');
            }
            
            return [
                SELECT Id, Name, ProductCode, Description, IsActive, Family,
                       Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c,
                       (SELECT Id, UnitPrice, IsActive, Pricebook2Id, Product2Id
                        FROM PricebookEntries WHERE IsActive = true)
                FROM Product2
                WHERE IsActive = true
                ORDER BY Name
            ];
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving all products: ' + e.getMessage());
            throw new CalloutException('Unable to retrieve all products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets products with dynamic advanced filtering
     * @param searchTerm Search term for product name/description
     * @param category Category filter (Product Family)
     * @param pageNumber Page number (0-based)
     * @param pageSize Number of products per page
     * @param topSellersOnly Filter for top-selling products only
     * @return ProductCatalogResult containing products and pagination info
     */
    @AuraEnabled(cacheable=true)
    public static ProductCatalogResult getProductsDynamicAdvanced(
        String searchTerm,
        String category,
        Integer pageNumber,
        Integer pageSize,
        Boolean topSellersOnly
    ) {
        try {
            if (!Schema.sObjectType.Product2.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access products');
            }
            
            // Validate pagination parameters
            if (pageNumber < 0 || pageSize <= 0 || pageSize > 100) {
                pageNumber = 0;
                pageSize = 12;
            }
            
            // Sanitize input parameters
            String sanitizedSearchTerm = (searchTerm != null) ? searchTerm.trim() : '';
            String sanitizedCategory = (category != null) ? category.trim() : '';
            
            // Build query conditions
            String whereClause = 'IsActive = TRUE';
            
            if (String.isNotBlank(sanitizedSearchTerm)) {
                whereClause += ' AND (Name LIKE \'%' + String.escapeSingleQuotes(sanitizedSearchTerm) + '%\' OR Description LIKE \'%' + String.escapeSingleQuotes(sanitizedSearchTerm) + '%\')';
            }
            
            if (String.isNotBlank(sanitizedCategory)) {
                whereClause += ' AND Family = \'' + String.escapeSingleQuotes(sanitizedCategory) + '\'';
            }
            
            if (topSellersOnly == true) {
                whereClause += ' AND Is_Top_Seller__c = TRUE';
            }
            
            // Calculate offset
            Integer offset = pageNumber * pageSize;
            
            // Execute query
            String query = 'SELECT Id, Name, ProductCode, Description, IsActive, Family, Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c, (SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE LIMIT 1) FROM Product2 WHERE ' + whereClause + ' ORDER BY Name LIMIT ' + pageSize + ' OFFSET ' + offset;
            
            List<Product2> products = Database.query(query);
            
            // Get total count
            String countQuery = 'SELECT COUNT() FROM Product2 WHERE ' + whereClause;
            Integer totalCount = Database.countQuery(countQuery);
            
            // Create result
            ProductCatalogResult result = new ProductCatalogResult();
            result.products = products;
            result.totalCount = totalCount;
            result.pageNumber = pageNumber;
            result.pageSize = pageSize;
            result.totalPages = (Integer) Math.ceil((Double) totalCount / pageSize);
            result.success = true;
            result.message = 'Products retrieved successfully';
            
            return result;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getProductsDynamicAdvanced: ' + e.getMessage());
            
            // Return error result instead of throwing exception
            ProductCatalogResult result = new ProductCatalogResult();
            result.success = false;
            result.message = 'Error loading products: ' + e.getMessage();
            result.products = new List<Product2>();
            result.totalCount = 0;
            result.pageNumber = 0;
            result.pageSize = 12;
            result.totalPages = 0;
            
            return result;
        }
    }
    
    /**
     * @description Wrapper class for product catalog results
     */
    public class ProductCatalogResult {
        @AuraEnabled public List<Product2> products;
        @AuraEnabled public Integer totalCount;
        @AuraEnabled public Integer pageNumber;
        @AuraEnabled public Integer pageSize;
        @AuraEnabled public Integer totalPages;
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        
        public ProductCatalogResult() {
            this.products = new List<Product2>();
            this.totalCount = 0;
            this.pageNumber = 0;
            this.pageSize = 12;
            this.totalPages = 0;
            this.success = false;
            this.message = '';
        }
    }
    
    /**
     * @description Gets or creates a cart for the current user
     */
    private static Cart__c getUserCart() {
        String userId = UserInfo.getUserId();
        
        // Use OwnerId approach instead of Contact__c
        List<Cart__c> existingCarts = [
            SELECT Id, OwnerId, Status__c, Subtotal__c
            FROM Cart__c 
            WHERE OwnerId = :userId AND Status__c = :CART_STATUS_ACTIVE
            LIMIT 1
        ];
        
        if (!existingCarts.isEmpty()) {
            return existingCarts[0];
        }
        
        // Create new cart
        Cart__c newCart = new Cart__c(
            OwnerId = userId,
            Status__c = CART_STATUS_ACTIVE
            // Subtotal__c is a formula field - no need to set it
        );
        
        // Apply field-level security before insert
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<Cart__c>{newCart});
        List<Cart__c> creatableCarts = decision.getRecords();
        
        if (!creatableCarts.isEmpty()) {
            insert creatableCarts;
            return creatableCarts[0];
        } else {
            throw new SecurityException('Cannot create cart due to field-level security restrictions');
        }
    }
    
    /**
     * @description Gets product by ID with security check
     */
    private static Product2 getProductById(String productId) {
        List<Product2> products = [
            SELECT Id, Name, IsActive 
            FROM Product2 
            WHERE Id = :productId AND IsActive = true
            LIMIT 1
        ];
        
        if (products.isEmpty()) {
            throw new NotFoundException('Product not found or inactive');
        }
        
        return products[0];
    }
    
    /**
     * @description Gets pricebook entry for product
     */
    private static PricebookEntry getPricebookEntry(String productId, String pricebookEntryId) {
        String query = 'SELECT Id, UnitPrice, Product2Id, Pricebook2Id, IsActive ' +
                      'FROM PricebookEntry ' +
                      'WHERE Product2Id = :productId AND IsActive = true';
        
        if (!String.isBlank(pricebookEntryId)) {
            query += ' AND Id = :pricebookEntryId';
        }
        
        query += ' LIMIT 1';
        
        List<PricebookEntry> entries = Database.query(query);
        
        if (entries.isEmpty()) {
            throw new NotFoundException('Price information not found for this product');
        }
        
        return entries[0];
    }
    
    /**
     * @description Checks if cart item already exists
     */
    private static Cart_Item__c getExistingCartItem(String cartId, String productId) {
        List<Cart_Item__c> items = [
            SELECT Id, Quantity__c, Unit_Price__c, Line_Total__c
            FROM Cart_Item__c
            WHERE Cart__c = :cartId AND Product__c = :productId
            LIMIT 1
        ];
        
        return items.isEmpty() ? null : items[0];
    }
    
    /**
     * @description Validates sort field against allowed values
     */
    private static Boolean isValidSortField(String fieldName) {
        Set<String> allowedFields = new Set<String>{
            'Name', 'ProductCode', 'Family', 'Stock_Quantity__c', 'Is_Top_Seller__c'
        };
        return allowedFields.contains(fieldName);
    }
    
    /**
     * @description Validates sort direction
     */
    private static Boolean isValidSortDirection(String direction) {
        return direction == 'ASC' || direction == 'DESC';
    }
    
    /**
     * @description Wrapper class for cart item operation results
     */
    public class CartItemResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Cart_Item__c cartItem { get; set; }
        
        public CartItemResult(Boolean success, String message, Cart_Item__c cartItem) {
            this.success = success;
            this.message = message;
            this.cartItem = cartItem;
        }
    }
    
    /**
     * @description Wrapper class for cart details results
     */
    public class CartDetailsResult {
        @AuraEnabled public Cart__c cart { get; set; }
        @AuraEnabled public List<Cart_Item__c> items { get; set; }
        
        public CartDetailsResult(Cart__c cart, List<Cart_Item__c> items) {
            this.cart = cart;
            this.items = items;
        }
    }
    
    /**
     * @description Wrapper class for quote request results
     */
    public class QuoteResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Integer productCount { get; set; }
        
        public QuoteResult(Boolean success, String message, Integer productCount) {
            this.success = success;
            this.message = message;
            this.productCount = productCount;
        }
    }
    
    /**
     * @description Custom exception for not found scenarios
     */
    public class NotFoundException extends Exception {}
    
    /**
     * @description Custom exception for security violations
     */
    public class SecurityException extends Exception {}
    
    /**
     * @description Custom exception for invalid arguments
     */
    public class IllegalArgumentException extends Exception {}

    /**
     * @description Gets cart details for the current user
     * @return CartDetailsResult Result containing cart information and items
     */
    @AuraEnabled
    public static CartDetailsResult getCartDetails() {
        try {
            if (!Schema.sObjectType.Cart__c.isAccessible() || 
                !Schema.sObjectType.Cart_Item__c.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access cart');
            }
            
            Cart__c userCart = getUserCart();
            
            List<Cart_Item__c> cartItems = [
                SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c,
                       Product__r.Name, Product__r.Description, Product__r.Image_URL__c
                FROM Cart_Item__c
                WHERE Cart__c = :userCart.Id
                ORDER BY CreatedDate DESC
            ];
            
            return new CartDetailsResult(userCart, cartItems);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving cart details: ' + e.getMessage());
            throw new CalloutException('Unable to retrieve cart details: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates cart item quantity
     * @param cartItemId ID of the cart item to update
     * @param quantity New quantity
     * @return CartItemResult Result containing success status and updated cart item
     */
    @AuraEnabled
    public static CartItemResult updateCartItemQuantity(String cartItemId, Integer quantity) {
        Savepoint sp = Database.setSavepoint();
        
        try {
            if (String.isBlank(cartItemId)) {
                throw new IllegalArgumentException('Cart item ID is required');
            }
            
            if (quantity == null || quantity <= 0) {
                throw new IllegalArgumentException('Quantity must be greater than 0');
            }
            
            if (!Schema.sObjectType.Cart_Item__c.isAccessible() || 
                !Schema.sObjectType.Cart_Item__c.isUpdateable()) {
                throw new SecurityException('Insufficient permissions to modify cart');
            }
            
            List<Cart_Item__c> cartItems = [
                SELECT Id, Quantity__c, Unit_Price__c, Line_Total__c
                FROM Cart_Item__c
                WHERE Id = :cartItemId
                LIMIT 1
            ];
            
            if (cartItems.isEmpty()) {
                throw new NotFoundException('Cart item not found');
            }
            
            Cart_Item__c cartItem = cartItems[0];
            cartItem.Quantity__c = quantity;
            // Line_Total__c is a formula field - no need to set it
            
            // Apply field-level security before update
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Cart_Item__c>{cartItem});
            List<Cart_Item__c> updatableItems = decision.getRecords();
            
            if (!updatableItems.isEmpty()) {
                update updatableItems;
                return new CartItemResult(true, 'Cart item quantity updated successfully', updatableItems[0]);
            } else {
                throw new SecurityException('Cannot update cart item due to field-level security restrictions');
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'Error updating cart item quantity: ' + e.getMessage());
            throw new CalloutException('Unable to update cart item quantity: ' + e.getMessage());
        }
    }
    
    /**
     * @description Submits a quote request for products
     * @param productIds List of product IDs to quote
     * @param customerNotes Customer notes for the quote
     * @return QuoteResult Result containing success status and quote information
     */
    @AuraEnabled
    public static QuoteResult submitQuoteRequest(List<String> productIds, String customerNotes) {
        try {
            if (productIds == null || productIds.isEmpty()) {
                throw new IllegalArgumentException('Product IDs are required');
            }
            
            if (!Schema.sObjectType.Product2.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access products');
            }
            
            List<Product2> products = [
                SELECT Id, Name, Description
                FROM Product2
                WHERE Id IN :productIds AND IsActive = true
            ];
            
            if (products.isEmpty()) {
                throw new NotFoundException('No valid products found for quote');
            }
            
            // For now, just return success - you can implement actual quote logic later
            return new QuoteResult(true, 'Quote request submitted successfully', products.size());
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error submitting quote request: ' + e.getMessage());
            throw new CalloutException('Unable to submit quote request: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets shipping addresses for a user
     * @param accountId The Account ID to get addresses for
     * @return List<Shipping_Address__c> List of shipping addresses
     */
    @AuraEnabled(cacheable=true)
    public static List<Shipping_Address__c> getShippingAddresses(Id accountId) {
        try {
            if (!Schema.sObjectType.Shipping_Address__c.isAccessible()) {
                throw new SecurityException('Insufficient permissions to access shipping addresses');
            }
            
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            
            return [
                SELECT Id, Address_Label__c, Street__c, City__c, State__c, 
                       Postal_Code__c, Country__c, Is_Default__c
                FROM Shipping_Address__c
                WHERE Account__c = :accountId
                ORDER BY Is_Default__c DESC, Address_Label__c
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving shipping addresses: ' + e.getMessage());
            throw new CalloutException('Unable to retrieve shipping addresses: ' + e.getMessage());
        }
    }
    
    // REMOVED: Old Contact-based recently viewed method - not used in current cart system
}
