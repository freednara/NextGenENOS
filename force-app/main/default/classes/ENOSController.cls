/**
 * @description Main controller for ENOS e-commerce functionality
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-16
 *
 * This class handles all core e-commerce operations including product queries,
 * cart management, and user interactions. All operations enforce CRUD/FLS
 * permissions and prevent SOQL injection attacks.
 */
public with sharing class ENOSController {
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
  public static ProductCatalogResult getProducts(
    String searchTerm,
    String category,
    Integer pageNumber,
    Integer pageSize,
    Boolean topSellersOnly
  ) {
    try {
      // Security: Check ENOS permissions
      ENOS_SecurityUtils.validateENOSAccess(false, false);

      // Security: Check object-level permissions
      ENOS_SecurityUtils.checkObjectReadable('Product2');
      ENOS_SecurityUtils.checkObjectReadable('Pricebook2');
      ENOS_SecurityUtils.checkObjectReadable('PricebookEntry');

      // Security: Sanitize and validate input parameters
      String sanitizedSearchTerm = ENOS_SecurityUtils.sanitizeInput(searchTerm);
      String sanitizedCategory = ENOS_SecurityUtils.sanitizeInput(category);

      // Validate pagination parameters
      if (pageNumber < 0 || pageSize <= 0 || pageSize > 100) {
        throw new IllegalArgumentException('Invalid pagination parameters');
      }

      // Use static queries with bind variables to prevent SOQL injection
      String searchPattern;
      String categoryPattern;
      List<Product2> products;
      Integer totalCount;

      // Determine query type based on filters
      Boolean hasSearch = String.isNotBlank(sanitizedSearchTerm);
      Boolean hasCategory = String.isNotBlank(sanitizedCategory);

      if (hasSearch) {
        searchPattern = '%' + sanitizedSearchTerm + '%';
      }
      if (hasCategory) {
        categoryPattern = '%' + sanitizedCategory + '%';
      }

      Integer offset = pageNumber * pageSize;

      // Execute static query based on filter combination to avoid dynamic SOQL
      if (hasSearch && hasCategory) {
        products = [
          SELECT
            Id,
            Name,
            ProductCode,
            Description,
            IsActive,
            Stock_Quantity__c,
            Image_URL__c,
            Is_Top_Seller__c,
            (
              SELECT UnitPrice
              FROM PricebookEntries
              WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE
              LIMIT 1
            )
          FROM Product2
          WHERE
            IsActive = TRUE
            AND (Name LIKE :searchPattern
            OR Description LIKE :searchPattern)
            AND ProductCode LIKE :categoryPattern
          WITH USER_MODE
          ORDER BY Name
          LIMIT :pageSize
          OFFSET :offset
        ];

        totalCount = [
          SELECT COUNT()
          FROM Product2
          WHERE
            IsActive = TRUE
            AND (Name LIKE :searchPattern
            OR Description LIKE :searchPattern)
            AND ProductCode LIKE :categoryPattern
          WITH USER_MODE
        ];
      } else if (hasSearch) {
        products = [
          SELECT
            Id,
            Name,
            ProductCode,
            Description,
            IsActive,
            Stock_Quantity__c,
            Image_URL__c,
            Is_Top_Seller__c,
            (
              SELECT UnitPrice
              FROM PricebookEntries
              WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE
              LIMIT 1
            )
          FROM Product2
          WHERE
            IsActive = TRUE
            AND (Name LIKE :searchPattern
            OR Description LIKE :searchPattern)
          WITH USER_MODE
          ORDER BY Name
          LIMIT :pageSize
          OFFSET :offset
        ];

        totalCount = [
          SELECT COUNT()
          FROM Product2
          WHERE
            IsActive = TRUE
            AND (Name LIKE :searchPattern
            OR Description LIKE :searchPattern)
          WITH USER_MODE
        ];
      } else if (hasCategory) {
        products = [
          SELECT
            Id,
            Name,
            ProductCode,
            Description,
            IsActive,
            Stock_Quantity__c,
            Image_URL__c,
            Is_Top_Seller__c,
            (
              SELECT UnitPrice
              FROM PricebookEntries
              WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE
              LIMIT 1
            )
          FROM Product2
          WHERE IsActive = TRUE AND ProductCode LIKE :categoryPattern
          WITH USER_MODE
          ORDER BY Name
          LIMIT :pageSize
          OFFSET :offset
        ];

        totalCount = [
          SELECT COUNT()
          FROM Product2
          WHERE IsActive = TRUE AND ProductCode LIKE :categoryPattern
          WITH USER_MODE
        ];
      } else {
        products = [
          SELECT
            Id,
            Name,
            ProductCode,
            Description,
            IsActive,
            Stock_Quantity__c,
            Image_URL__c,
            Is_Top_Seller__c,
            (
              SELECT UnitPrice
              FROM PricebookEntries
              WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE
              LIMIT 1
            )
          FROM Product2
          WHERE IsActive = TRUE
          WITH USER_MODE
          ORDER BY Name
          LIMIT :pageSize
          OFFSET :offset
        ];

        totalCount = [
          SELECT COUNT()
          FROM Product2
          WHERE IsActive = TRUE
          WITH USER_MODE
        ];
      }

      return new ProductCatalogResult(
        products,
        totalCount,
        pageNumber,
        pageSize
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error in getProducts: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Error retrieving products: ' + e.getMessage()
      );
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
      // Security: Check ENOS permissions
      ENOS_SecurityUtils.validateENOSAccess(false, false);

      // CRUD checks
      ENOS_SecurityUtils.checkObjectReadable('Cart__c');
      ENOS_SecurityUtils.checkObjectCreateable('Cart__c');

      // Security: Check if user has read and create permissions on Cart__c
      ENOS_SecurityUtils.checkObjectReadable('Cart__c');

      // Validate input parameter
      if (contactId == null) {
        throw new IllegalArgumentException('Contact ID cannot be null');
      }

      // Check if user already has an active cart
      List<Cart__c> existingCarts = [
        SELECT
          Id,
          Name,
          Status__c,
          Subtotal__c,
          Total_Items__c,
          (
            SELECT
              Id,
              Product__c,
              Quantity__c,
              Unit_Price__c,
              Line_Total__c,
              Product__r.Name,
              Product__r.Image_URL__c,
              Product__r.Stock_Quantity__c
            FROM Cart_Items__r
          )
        FROM Cart__c
        WHERE Contact__c = :contactId AND Status__c = 'Active'
        WITH USER_MODE
        LIMIT 1
      ];

      if (!existingCarts.isEmpty()) {
        return existingCarts[0];
      }

      // Security: Check if user has create permission before creating new cart
      ENOS_SecurityUtils.checkObjectCreateable('Cart__c');

      // Create new cart
      Cart__c newCart = new Cart__c(
        Contact__c = contactId,
        Status__c = 'Active'
      );

      // Security: Validate record access before insert
      // Record access validation is handled by checkObjectCreateable above

      ENOS_SecurityUtils.checkObjectCreateAccess('Cart__c');
      insert newCart;

      return newCart;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error getting or creating cart: ' + e.getMessage()
      );
    }
  }

  // Add product to cart
  @AuraEnabled
  public static Cart_Item__c addToCart(
    Id cartId,
    Id productId,
    Integer quantity
  ) {
    try {
      // Security: Check ENOS permissions
      ENOS_SecurityUtils.validateENOSAccess(false, false);

      // CRUD checks
      ENOS_SecurityUtils.checkObjectReadable('Product2');
      ENOS_SecurityUtils.checkObjectReadable('Cart_Item__c');
      ENOS_SecurityUtils.checkObjectUpdateable('Cart__c');
      ENOS_SecurityUtils.checkObjectCreateable('Cart_Item__c');

      // Atomic inventory check and cart update to prevent race conditions
      Savepoint sp = Database.setSavepoint();

      try {
        // Validate product and get price with FOR UPDATE to lock the record
        Product2 product = [
          SELECT Id, Name, Stock_Quantity__c
          FROM Product2
          WHERE Id = :productId AND IsActive = TRUE
          WITH USER_MODE
          FOR UPDATE
        ];

        // Check if product already in cart
        List<Cart_Item__c> existingItems = [
          SELECT Id, Quantity__c
          FROM Cart_Item__c
          WHERE Cart__c = :cartId AND Product__c = :productId
          WITH USER_MODE
        ];

        Integer totalRequestedQuantity = quantity;
        if (!existingItems.isEmpty()) {
          totalRequestedQuantity += Integer.valueOf(
            existingItems[0].Quantity__c
          );
        }

        // Validate total quantity against available stock
        if (product.Stock_Quantity__c < totalRequestedQuantity) {
          throw new AuraHandledException(
            'Insufficient stock. Available: ' +
              product.Stock_Quantity__c +
              ', Requested: ' +
              totalRequestedQuantity
          );
        }

        if (!existingItems.isEmpty()) {
          // Update quantity
          existingItems[0].Quantity__c = totalRequestedQuantity;
          ENOS_SecurityUtils.checkObjectUpdateable('Cart_Item__c');
          update existingItems[0];
          return existingItems[0];
        } else {
          // Create new cart item with proper price lookup
          Decimal unitPrice = getProductPriceFromStandardPricebook(productId);
          if (unitPrice == null) {
            throw new AuraHandledException('Product pricing not available.');
          }

          Cart_Item__c newItem = new Cart_Item__c(
            Cart__c = cartId,
            Product__c = productId,
            Quantity__c = quantity,
            Unit_Price__c = unitPrice
          );

          insert newItem;
          return newItem;
        }
      } catch (Exception e) {
        Database.rollback(sp);
        throw e;
      }
    } catch (Exception e) {
      throw new AuraHandledException('Error adding to cart: ' + e.getMessage());
    }
  }

  // Update cart item quantity
  @AuraEnabled
  public static void updateCartItemQuantity(
    Id cartItemId,
    Integer newQuantity
  ) {
    try {
      ENOS_SecurityUtils.checkObjectUpdateable('Cart_Item__c');
      if (newQuantity <= 0) {
        deleteCartItem(cartItemId);
        return;
      }

      Cart_Item__c item = [
        SELECT Id, Quantity__c, Product__r.Stock_Quantity__c
        FROM Cart_Item__c
        WHERE Id = :cartItemId
        WITH USER_MODE
      ];

      if (item.Product__r.Stock_Quantity__c < newQuantity) {
        throw new AuraHandledException(
          'Insufficient stock. Available: ' + item.Product__r.Stock_Quantity__c
        );
      }

      item.Quantity__c = newQuantity;
      update item;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error updating cart item: ' + e.getMessage()
      );
    }
  }

  // Remove item from cart
  @AuraEnabled
  public static void deleteCartItem(Id cartItemId) {
    try {
      ENOS_SecurityUtils.checkObjectDeletable('Cart_Item__c');
      delete [
        SELECT Id
        FROM Cart_Item__c
        WHERE Id = :cartItemId
        WITH USER_MODE
      ];
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error removing cart item: ' + e.getMessage()
      );
    }
  }

  // Get shipping addresses for user
  @AuraEnabled(cacheable=true)
  public static List<Shipping_Address__c> getShippingAddresses(Id accountId) {
    try {
      ENOS_SecurityUtils.checkObjectReadable('Shipping_Address__c');
      return [
        SELECT
          Id,
          Address_Label__c,
          Street__c,
          City__c,
          State__c,
          Postal_Code__c,
          Country__c,
          Is_Default__c
        FROM Shipping_Address__c
        WHERE Account__c = :accountId
        WITH USER_MODE
        ORDER BY Is_Default__c DESC, Address_Label__c
      ];
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error retrieving shipping addresses: ' + e.getMessage()
      );
    }
  }

  // Get recently viewed products
  @AuraEnabled(cacheable=true)
  public static List<RecentlyViewedProduct> getRecentlyViewed(Id contactId) {
    try {
      // Security checks are handled by checkObjectReadable below
      ENOS_SecurityUtils.checkObjectReadable('View_Tracking__c');
      ENOS_SecurityUtils.checkObjectReadable('Product2');

      if (contactId == null) {
        throw new IllegalArgumentException('Contact ID cannot be null');
      }

      Integer limitSize = 5;

      List<View_Tracking__c> views = [
        SELECT Product__c, Last_Viewed_Date__c
        FROM View_Tracking__c
        WHERE User_Contact__c = :contactId
        WITH USER_MODE
        ORDER BY Last_Viewed_Date__c DESC
        LIMIT :limitSize
      ];

      if (views.isEmpty()) {
        return new List<RecentlyViewedProduct>();
      }

      Set<Id> productIds = new Set<Id>();
      for (View_Tracking__c vt : views) {
        productIds.add(vt.Product__c);
      }

      Map<Id, Product2> products = new Map<Id, Product2>(
        [
          SELECT
            Id,
            Name,
            Image_URL__c,
            (
              SELECT UnitPrice
              FROM PricebookEntries
              WHERE Pricebook2.IsStandard = TRUE
              LIMIT 1
            )
          FROM Product2
          WHERE Id IN :productIds AND IsActive = TRUE
          WITH USER_MODE
        ]
      );

      List<RecentlyViewedProduct> results = new List<RecentlyViewedProduct>();
      for (View_Tracking__c vt : views) {
        Product2 p = products.get(vt.Product__c);
        if (p != null) {
          Decimal unitPrice = (p.PricebookEntries.isEmpty()
            ? null
            : p.PricebookEntries[0].UnitPrice);
          results.add(
            new RecentlyViewedProduct(p.Id, p.Name, p.Image_URL__c, unitPrice)
          );
        }
      }
      return results;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error in getRecentlyViewed: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Error retrieving recently viewed products: ' + e.getMessage()
      );
    }
  }

  // Track product view
  @AuraEnabled
  public static void trackProductView(Id contactId, Id productId) {
    try {
      ENOS_SecurityUtils.checkObjectCreateable('View_Tracking__c');
      // Upsert view tracking record
      View_Tracking__c viewTracking = new View_Tracking__c(
        User_Contact__c = contactId,
        Product__c = productId,
        Last_Viewed_Date__c = System.now()
      );

      upsert viewTracking;
    } catch (Exception e) {
      // Don't throw error for tracking - just log it
      System.debug(
        LoggingLevel.ERROR,
        'Error tracking product view: ' + e.getMessage()
      );
    }
  }

  // Request back-in-stock notification
  @AuraEnabled
  public static void requestBackInStockNotification(
    Id contactId,
    Id productId
  ) {
    try {
      ENOS_SecurityUtils.checkObjectReadable('Notification_Request__c');
      ENOS_SecurityUtils.checkObjectCreateable('Notification_Request__c');
      // Check if notification already exists
      List<Notification_Request__c> existingRequests = [
        SELECT Id
        FROM Notification_Request__c
        WHERE
          User_Contact__c = :contactId
          AND Product__c = :productId
          AND Status__c = 'Active'
        WITH USER_MODE
      ];

      if (!existingRequests.isEmpty()) {
        throw new AuraHandledException(
          'Notification request already exists for this product.'
        );
      }

      Notification_Request__c notification = new Notification_Request__c(
        User_Contact__c = contactId,
        Product__c = productId,
        Status__c = 'Active'
      );

      insert notification;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error requesting notification: ' + e.getMessage()
      );
    }
  }

  // Helper method to get product price (placeholder for your pricing logic)
  private static Decimal getProductPrice(Id productId) {
    // This would integrate with your pricing engine
    // For now, return a default price
    return 99.99;
  }

  // Wrapper class for recently viewed products
  public class RecentlyViewedProduct {
    @AuraEnabled
    public Id productId;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public String imageUrl;
    @AuraEnabled
    public Decimal unitPrice;

    public RecentlyViewedProduct(
      Id id,
      String name,
      String imageUrl,
      Decimal unitPrice
    ) {
      this.productId = id;
      this.productName = name;
      this.imageUrl = imageUrl;
      this.unitPrice = unitPrice;
    }
  }

  // Wrapper class for product catalog results
  public class ProductCatalogResult {
    @AuraEnabled
    public List<Product2> products;
    @AuraEnabled
    public Integer totalCount;
    @AuraEnabled
    public Integer pageNumber;
    @AuraEnabled
    public Integer pageSize;

    public ProductCatalogResult(
      List<Product2> products,
      Integer totalCount,
      Integer pageNumber,
      Integer pageSize
    ) {
      this.products = products;
      this.totalCount = totalCount;
      this.pageNumber = pageNumber;
      this.pageSize = pageSize;
    }
  }

  /**
   * @description Custom exception class for security violations
   */
  public class SecurityException extends Exception {
  }

  /**
   * @description Gets product price from standard pricebook
   * @param productId Product ID to get price for
   * @return Unit price or null if not found
   */
  private static Decimal getProductPriceFromStandardPricebook(Id productId) {
    try {
      List<PricebookEntry> entries = [
        SELECT UnitPrice
        FROM PricebookEntry
        WHERE
          Product2Id = :productId
          AND Pricebook2.IsStandard = TRUE
          AND IsActive = TRUE
        WITH USER_MODE
        LIMIT 1
      ];

      return entries.isEmpty() ? null : entries[0].UnitPrice;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error getting product price: ' + e.getMessage()
      );
      return null;
    }
  }

  /**
   * @description Simple getAllProducts method for components that don't need pagination
   * @return List<Product2> List of active products with pricing
   * @throws AuraHandledException if operation fails
   */
  @AuraEnabled(cacheable=true)
  public static List<Product2> getAllProducts() {
    try {
      // Basic security checks
      if (!Schema.sObjectType.Product2.isAccessible()) {
        throw new AuraHandledException('No access to Product2');
      }

      // Query products with standard fields only (avoid custom fields that may not exist)
      List<Product2> products = [
        SELECT
          Id,
          Name,
          ProductCode,
          Description,
          IsActive,
          Family,
          (
            SELECT UnitPrice
            FROM PricebookEntries
            WHERE Pricebook2.IsStandard = TRUE AND IsActive = TRUE
            LIMIT 1
          )
        FROM Product2
        WHERE IsActive = TRUE
        WITH USER_MODE
        ORDER BY Name
        LIMIT 50
      ];

      return products;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error in getAllProducts(): ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Unable to retrieve products: ' + e.getMessage()
      );
    }
  }

  // ============================================================================
  // DYNAMIC APEX METHODS
  // ============================================================================

  /**
   * @description Retrieves products with dynamic field selection and advanced filtering
   * @param fields List of fields to select (if null, uses default fields)
   * @param filters Map of field names to filter values
   * @param sortBy Field to sort by
   * @param sortDirection Sort direction ('ASC' or 'DESC')
   * @param limitClause Maximum number of records to return
   * @return List of Product2 records with selected fields
   * @throws AuraHandledException if dynamic query fails
   */
  @AuraEnabled(cacheable=true)
  public static List<Product2> getProductsDynamicAdvanced(List<String> fields, Map<String, Object> filters, 
                                                        String sortBy, String sortDirection, Integer limitClause) {
    try {
      // 1. Security validation using dynamic methods
      ENOS_SecurityUtils.checkDynamicObjectAccess('Product2', 'read');
      
      // 2. Use default fields if none specified
      if (fields == null || fields.isEmpty()) {
        fields = new List<String>{
          'Id', 'Name', 'ProductCode', 'Description', 'IsActive', 'Family', 'Stock_Quantity__c', 'Image_URL__c'
        };
      }
      
      // 3. Validate field access
      ENOS_SecurityUtils.checkDynamicFieldAccess('Product2', fields);
      
      // 4. Build dynamic WHERE clause from filters
      String whereClause = 'IsActive = true';
      if (filters != null && !filters.isEmpty()) {
        for (String fieldName : filters.keySet()) {
          Object filterValue = filters.get(fieldName);
          if (filterValue != null) {
            // Validate field name
            if (ENOS_SecurityUtils.isValidFieldName(fieldName)) {
              String sanitizedValue = String.escapeSingleQuotes(String.valueOf(filterValue));
              whereClause += ' AND ' + fieldName + ' = \'' + sanitizedValue + '\'';
            }
          }
        }
      }
      
      // 5. Validate and sanitize sort parameters
      String orderByClause = '';
      if (String.isNotBlank(sortBy) && ENOS_SecurityUtils.isValidFieldName(sortBy)) {
        String direction = (sortDirection == 'DESC') ? 'DESC' : 'ASC';
        orderByClause = sortBy + ' ' + direction;
      } else {
        orderByClause = 'Name ASC';
      }
      
      // 6. Execute dynamic query
      List<SObject> results = ENOS_DynamicUtils.executeDynamicQuery(
        'Product2', 
        fields, 
        whereClause, 
        orderByClause, 
        limitClause
      );
      
      // 7. Cast results to Product2
      List<Product2> products = new List<Product2>();
      for (SObject obj : results) {
        products.add((Product2) obj);
      }
      
      return products;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Dynamic advanced query failed in ENOS_Controller.getProductsDynamicAdvanced(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'Dynamic product query failed: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Gets comprehensive metadata for multiple objects
   * @param objectNames List of object names to get metadata for
   * @return Map containing metadata for all requested objects
   * @throws AuraHandledException if metadata retrieval fails
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getMultiObjectMetadata(List<String> objectNames) {
    try {
      Map<String, Object> allMetadata = new Map<String, Object>();
      
      for (String objectName : objectNames) {
        try {
          // 1. Security validation
          ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'read');
          
          // 2. Get object metadata
          Schema.DescribeSObjectResult objectDesc = ENOS_DynamicUtils.getObjectMetadata(objectName);
          
          // 3. Get accessible fields
          List<String> readableFields = ENOS_SecurityUtils.getDynamicAccessibleFields(objectName, 'read');
          List<String> editableFields = ENOS_SecurityUtils.getDynamicAccessibleFields(objectName, 'edit');
          
          // 4. Build metadata response for this object
          Map<String, Object> objectMetadata = new Map<String, Object>();
          objectMetadata.put('objectName', objectDesc.getName());
          objectMetadata.put('objectLabel', objectDesc.getLabel());
          objectMetadata.put('readableFields', readableFields);
          objectMetadata.put('editableFields', editableFields);
          objectMetadata.put('totalFields', readableFields.size());
          
          allMetadata.put(objectName, objectMetadata);
          
        } catch (Exception e) {
          // Log error but continue with other objects
          System.debug(
            LoggingLevel.ERROR,
            'Failed to get metadata for object ' + objectName + ': ' + e.getMessage()
          );
          allMetadata.put(objectName, new Map<String, Object>{
            'error' => e.getMessage(),
            'objectName' => objectName
          });
        }
      }
      
      return allMetadata;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Multi-object metadata retrieval failed: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Multi-object metadata retrieval failed: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Creates a record dynamically with comprehensive validation
   * @param objectName The SObject API name
   * @param fieldValues Map of field names to values
   * @return The created SObject record
   * @throws AuraHandledException if creation fails
   */
  @AuraEnabled
  public static SObject createRecordDynamic(String objectName, Map<String, Object> fieldValues) {
    try {
      // 1. Security validation
      ENOS_SecurityUtils.checkDynamicObjectAccess(objectName, 'create');
      
      // 2. Validate field names
      List<String> fieldNames = new List<String>(fieldValues.keySet());
      ENOS_SecurityUtils.checkDynamicFieldAccess(objectName, fieldNames);
      
      // 3. Create record dynamically
      SObject newRecord = ENOS_DynamicUtils.createDynamicRecord(objectName, fieldValues);
      
      return newRecord;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Dynamic record creation failed: ' + e.getMessage()
      );
      throw new AuraHandledException(
        'Record creation failed: ' + e.getMessage()
      );
    }
  }
}
