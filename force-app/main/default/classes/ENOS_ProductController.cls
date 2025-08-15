/**
 * @description Product controller for ENOS e-commerce platform
 * Provides secure access to product data with comprehensive security validation
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_ProductController {
  /**
   * @description Fetches a list of active products for display in the store.
   * **UPDATED** to support contract pricing via custom Price Books.
   * This method is cacheable to improve performance and reduce server calls.
   *
   * Security: Uses ENOS_SecurityUtils.checkFieldReadAccess() to validate FLS permissions
   * before executing any queries. This ensures compliance with AppExchange standards.
   *
   * Contract Pricing: Automatically detects the user's assigned price book from their Account
   * and displays negotiated contract prices instead of standard list prices.
   *
   * @return A list of Product2 records with their associated PricebookEntry data.
   * @throws AuraHandledException if the user lacks permission to read required fields.
   *
   * @example
   * // In LWC: @wire(getProducts) products;
   * // This will automatically call this method and cache the results.
   */
  @AuraEnabled(cacheable=true)
  public static List<Product2> getProducts() {
    try {
      // 1. Define the fields needed by the LWC for security checks.
      // These are the exact fields we will query and display.
      List<String> fieldsToCheck = new List<String>{
        'Id',
        'Name',
        'ProductCode',
        'Description',
        'IsActive'
      };

      // 2. Enforce FLS read access before executing the query.
      // This is our security-first approach - check permissions before any data access.
      ENOS_SecurityUtils.checkFieldReadAccess('Product2', fieldsToCheck);

      // We also need to check access on PricebookEntry since we're querying related records.
      ENOS_SecurityUtils.checkFieldReadAccess(
        'PricebookEntry',
        new List<String>{ 'UnitPrice', 'IsActive', 'Pricebook2Id' }
      );

      // CRUD checks before SOQL queries
      ENOS_SecurityUtils.checkObjectReadable('User');
      ENOS_SecurityUtils.checkObjectReadable('Account');
      ENOS_SecurityUtils.checkObjectReadable('Pricebook2');
      ENOS_SecurityUtils.checkObjectReadable('Product2');
      ENOS_SecurityUtils.checkObjectReadable('PricebookEntry');

      // Get the appropriate price book for the current user
      Id pricebookIdToUse = getUserPricebookId();

      // 3. ** MODIFIED QUERY ** - Now uses dynamic pricebookIdToUse variable.
      // The subquery dynamically selects the correct price book for contract pricing.
      List<Product2> products = [
        SELECT
          Id,
          Name,
          ProductCode,
          Description,
          IsActive,
          Family,
          (
            SELECT UnitPrice, IsActive, Pricebook2Id
            FROM PricebookEntries
            WHERE Pricebook2Id = :pricebookIdToUse AND IsActive = TRUE
            LIMIT 1
          )
        FROM Product2
        WHERE IsActive = TRUE
        WITH USER_MODE
        ORDER BY Name
        LIMIT 50
      ];

      // 4. Return the products with their pricing information.
      // The LWC will handle the display logic and error states.
      return products;
    } catch (SecurityException e) {
      ENOS_SecurityUtils.handleSecurityException('ENOS_ProductController.getProducts', e);
      return new List<Product2>(); // Return empty list on security exception
    } catch (Exception e) {
      ENOS_SecurityUtils.handleUnexpectedException('ENOS_ProductController.getProducts', e);
      return new List<Product2>(); // Return empty list on unexpected exception
    }
  }

  /**
   * @description Fetches a single product by ID for detailed product views.
   * **UPDATED** to support contract pricing via custom Price Books.
   * This method is used when users click on a product to see more details.
   *
   * Security: Implements the same security pattern as getProducts().
   * Contract Pricing: Automatically detects the user's assigned price book from their Account
   * and displays negotiated contract prices instead of standard list prices.
   *
   * @param productId The ID of the product to retrieve.
   * @return A single Product2 record with full details and pricing.
   * @throws AuraHandledException if the user lacks permission or the product is not found.
   */
  @AuraEnabled(cacheable=true)
  public static Product2 getProductById(Id productId) {
    try {
      // 1. Validate input parameters for security and data integrity.
      ENOS_SecurityUtils.validateRequiredId(productId, 'Product ID');

      // 2. Define fields for security validation.
      List<String> fieldsToCheck = new List<String>{
        'Id',
        'Name',
        'ProductCode',
        'Description',
        'IsActive'
      };

      // 3. Enforce FLS read access.
      ENOS_SecurityUtils.checkFieldReadAccess('Product2', fieldsToCheck);
      ENOS_SecurityUtils.checkFieldReadAccess(
        'PricebookEntry',
        new List<String>{ 'UnitPrice', 'IsActive', 'Pricebook2Id' }
      );

      // CRUD checks before SOQL queries
      ENOS_SecurityUtils.checkObjectReadable('User');
      ENOS_SecurityUtils.checkObjectReadable('Account');
      ENOS_SecurityUtils.checkObjectReadable('Pricebook2');
      ENOS_SecurityUtils.checkObjectReadable('Product2');
      ENOS_SecurityUtils.checkObjectReadable('PricebookEntry');

      // Get the appropriate price book for the current user
      Id pricebookIdToUse = getUserPricebookId();

      // 4. ** MODIFIED QUERY ** - Now uses dynamic pricebookIdToUse variable.
      // The subquery dynamically selects the correct price book for contract pricing.
      List<Product2> products = [
        SELECT
          Id,
          Name,
          ProductCode,
          Description,
          IsActive,
          (
            SELECT UnitPrice, IsActive, Pricebook2Id
            FROM PricebookEntries
            WHERE Pricebook2Id = :pricebookIdToUse AND IsActive = TRUE
            LIMIT 1
          )
        FROM Product2
        WHERE Id = :productId AND IsActive = TRUE
        WITH USER_MODE
        LIMIT 1
      ];

      // 5. Return the product or throw an error if not found.
      if (products.isEmpty()) {
        throw new AuraHandledException(
          'Product not found or is no longer available.'
        );
      }

      return products[0];
    } catch (SecurityException e) {
      ENOS_SecurityUtils.handleSecurityException('ENOS_ProductController.getProductById', e);
      return null; // Return null on security exception
    } catch (AuraHandledException e) {
      throw e;
    } catch (Exception e) {
      ENOS_SecurityUtils.handleUnexpectedException('ENOS_ProductController.getProductById', e);
      return null; // Return null on unexpected exception
    }
  }

  /**
   * @description Searches products by name or description for the search functionality.
   * **UPDATED** to support contract pricing via custom Price Books.
   * This method supports the product search feature in the LWC.
   *
   * Security: Implements the same security pattern as other methods.
   * Contract Pricing: Automatically detects the user's assigned price book from their Account
   * and displays negotiated contract prices instead of standard list prices.
   *
   * @param searchTerm The search term to look for in product names and descriptions.
   * @return A list of Product2 records matching the search criteria.
   * @throws AuraHandledException if the user lacks permission or search fails.
   */
  @AuraEnabled(cacheable=true)
  public static List<Product2> searchProducts(String searchTerm) {
    try {
      // 1. Validate input parameters.
      if (String.isBlank(searchTerm)) {
        return getProducts(); // Return all products if no search term.
      }

      // 2. Sanitize the search term to prevent SOQL injection.
      // We use a simple LIKE query with proper escaping.
      String sanitizedSearchTerm =
        '%' +
        String.escapeSingleQuotes(searchTerm.trim()) +
        '%';

      // 3. Define fields for security validation.
      List<String> fieldsToCheck = new List<String>{
        'Id',
        'Name',
        'ProductCode',
        'Description',
        'IsActive'
      };

      // 4. Enforce FLS read access.
      ENOS_SecurityUtils.checkFieldReadAccess('Product2', fieldsToCheck);
      ENOS_SecurityUtils.checkFieldReadAccess(
        'PricebookEntry',
        new List<String>{ 'UnitPrice', 'IsActive', 'Pricebook2Id' }
      );

      // CRUD checks before SOQL queries - using batch validation
      ENOS_SecurityUtils.validateProductAccess();

      // Get the appropriate price book for the current user
      Id pricebookIdToUse = getUserPricebookId();

      // 5. ** MODIFIED QUERY ** - Now uses dynamic pricebookIdToUse variable.
      // The subquery dynamically selects the correct price book for contract pricing.
      List<Product2> products = [
        SELECT
          Id,
          Name,
          ProductCode,
          Description,
          IsActive,
          Family,
          (
            SELECT UnitPrice, IsActive, Pricebook2Id
            FROM PricebookEntries
            WHERE Pricebook2Id = :pricebookIdToUse AND IsActive = TRUE
            LIMIT 1
          )
        FROM Product2
        WHERE
          IsActive = TRUE
          AND (Name LIKE :sanitizedSearchTerm
          OR Description LIKE :sanitizedSearchTerm)
        WITH USER_MODE
        ORDER BY Name
        LIMIT 50
      ];

      return products;
    } catch (SecurityException e) {
      ENOS_SecurityUtils.handleUnexpectedException('ENOS_ProductController.searchProducts', e);
      return new List<Product2>(); // Return empty list on security exception
    } catch (Exception e) {
      ENOS_SecurityUtils.handleUnexpectedException('ENOS_ProductController.searchProducts', e);
      return new List<Product2>(); // Return empty list on unexpected exception
    }
  }

  // ============================================================================
  // DYNAMIC APEX METHODS
  // ============================================================================

  /**
   * @description Retrieves products using dynamic field selection and filtering
   * This method demonstrates the use of ENOS_DynamicUtils for flexible queries
   * @param fields List of fields to select (if null, uses default fields)
   * @param searchTerm Optional search term for filtering
   * @param category Optional category filter
   * @param limitClause Maximum number of records to return
   * @return List of Product2 records with selected fields
   * @throws AuraHandledException if dynamic query fails
   */
  @AuraEnabled(cacheable=true)
  public static List<Product2> getProductsDynamic(List<String> fields, String searchTerm, 
                                                String category, Integer limitClause) {
    try {
      // 1. Security validation using dynamic methods
      ENOS_SecurityUtils.checkDynamicObjectAccess('Product2', 'read');
      
      // 2. Use default fields if none specified
      if (fields == null || fields.isEmpty()) {
        fields = new List<String>{
          'Id', 'Name', 'ProductCode', 'Description', 'IsActive', 'Family'
        };
      }
      
      // 3. Validate field access
      ENOS_SecurityUtils.checkDynamicFieldAccess('Product2', fields);
      
      // 4. Build dynamic WHERE clause
      String whereClause = 'IsActive = true';
      if (String.isNotBlank(searchTerm)) {
        String sanitizedSearch = String.escapeSingleQuotes(searchTerm.trim());
        whereClause += ' AND (Name LIKE \'%' + sanitizedSearch + '%\' OR Description LIKE \'%' + sanitizedSearch + '%\')';
      }
      if (String.isNotBlank(category)) {
        String sanitizedCategory = String.escapeSingleQuotes(category.trim());
        whereClause += ' AND ProductCode LIKE \'%' + sanitizedCategory + '%\'';
      }
      
      // 5. Execute dynamic query
      List<SObject> results = ENOS_DynamicUtils.executeDynamicQuery(
        'Product2', 
        fields, 
        whereClause, 
        'Name ASC', 
        limitClause
      );
      
      // 6. Cast results to Product2
      List<Product2> products = new List<Product2>();
      for (SObject obj : results) {
        products.add((Product2) obj);
      }
      
      return products;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Dynamic query failed in ENOS_ProductController.getProductsDynamic(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'Dynamic product query failed: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Gets product metadata information dynamically
   * @return Map containing object and field metadata
   * @throws AuraHandledException if metadata retrieval fails
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getProductMetadata() {
    try {
      // 1. Security validation
      ENOS_SecurityUtils.checkDynamicObjectAccess('Product2', 'read');
      
      // 2. Get object metadata
      Schema.DescribeSObjectResult objectDesc = ENOS_DynamicUtils.getObjectMetadata('Product2');
      
      // 3. Get accessible fields
      List<String> readableFields = ENOS_SecurityUtils.getDynamicAccessibleFields('Product2', 'read');
      List<String> editableFields = ENOS_SecurityUtils.getDynamicAccessibleFields('Product2', 'edit');
      
      // 4. Build metadata response
      Map<String, Object> metadata = new Map<String, Object>();
      metadata.put('objectName', objectDesc.getName());
      metadata.put('objectLabel', objectDesc.getLabel());
      metadata.put('readableFields', readableFields);
      metadata.put('editableFields', editableFields);
      metadata.put('totalFields', readableFields.size());
      
      return metadata;
      
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Metadata retrieval failed in ENOS_ProductController.getProductMetadata(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'Product metadata retrieval failed: ' + e.getMessage()
      );
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /**
   * @description Gets the appropriate price book ID for the current user
   * @return Price book ID to use for pricing queries
   */
  private static Id getUserPricebookId() {
    try {
      // Validate FLS for traversed field
      ENOS_SecurityUtils.checkFieldReadAccess(
        'User',
        new List<String>{ 'AccountId' }
      );
      Id userAccountId = [
        SELECT AccountId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH USER_MODE
        LIMIT 1
      ]
      .AccountId;

      if (userAccountId != null) {
        // Check the user's Account for an assigned price book ID
        ENOS_SecurityUtils.checkFieldReadAccess(
          'Account',
          new List<String>{ 'Assigned_Price_Book_ID__c' }
        );
        Account userAccount = [
          SELECT Assigned_Price_Book_ID__c
          FROM Account
          WHERE Id = :userAccountId
          WITH USER_MODE
          LIMIT 1
        ];
        if (String.isNotBlank(userAccount.Assigned_Price_Book_ID__c)) {
          return userAccount.Assigned_Price_Book_ID__c;
        }
      }

      // If no custom price book is assigned, default to the standard one
      ENOS_SecurityUtils.checkFieldReadAccess(
        'Pricebook2',
        new List<String>{ 'IsStandard', 'Id' }
      );
      return [
        SELECT Id
        FROM Pricebook2
        WHERE IsStandard = TRUE
        WITH USER_MODE
        LIMIT 1
      ]
      .Id;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error getting user price book: ' + e.getMessage()
      );
      // Return standard price book as fallback
      return [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
    }
  }
}
