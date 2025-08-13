/**
 * @description Controller to handle all server-side logic related to products.
 *
 * This controller implements the SecurityUtils pattern to ensure 100% FLS/CRUD
 * compliance. Every method checks permissions before executing business logic.
 *
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class ProductController {
  /**
   * @description Fetches a list of active products for display in the store.
   * **UPDATED** to support contract pricing via custom Price Books.
   * This method is cacheable to improve performance and reduce server calls.
   *
   * Security: Uses SecurityUtils.checkFieldReadAccess() to validate FLS permissions
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
      SecurityUtils.checkFieldReadAccess('Product2', fieldsToCheck);

      // We also need to check access on PricebookEntry since we're querying related records.
      SecurityUtils.checkFieldReadAccess(
        'PricebookEntry',
        new List<String>{ 'UnitPrice', 'IsActive', 'Pricebook2Id' }
      );

      // CRUD checks before SOQL queries
      SecurityUtils.checkObjectReadable('User');
      SecurityUtils.checkObjectReadable('Account');
      SecurityUtils.checkObjectReadable('Pricebook2');
      SecurityUtils.checkObjectReadable('Product2');
      SecurityUtils.checkObjectReadable('PricebookEntry');

      // ** START: NEW LOGIC FOR CONTRACT PRICING **
      Id pricebookIdToUse;
      // Validate FLS for traversed field
      SecurityUtils.checkFieldReadAccess('User', new List<String>{ 'AccountId' });
      Id userAccountId = [
        SELECT AccountId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .AccountId;

      if (userAccountId != null) {
        // Check the user's Account for an assigned price book ID.
        SecurityUtils.checkFieldReadAccess('Account', new List<String>{ 'Assigned_Price_Book_ID__c' });
        Account userAccount = [
          SELECT Assigned_Price_Book_ID__c
          FROM Account
          WHERE Id = :userAccountId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ];
        if (String.isNotBlank(userAccount.Assigned_Price_Book_ID__c)) {
          pricebookIdToUse = userAccount.Assigned_Price_Book_ID__c;
        }
      }

      // If no custom price book is assigned, default to the standard one.
      if (pricebookIdToUse == null) {
        SecurityUtils.checkFieldReadAccess('Pricebook2', new List<String>{ 'IsStandard', 'Id' });
        pricebookIdToUse = [
          SELECT Id
          FROM Pricebook2
          WHERE IsStandard = TRUE
          WITH SECURITY_ENFORCED
          LIMIT 1
        ]
        .Id;
      }
      // ** END: NEW LOGIC FOR CONTRACT PRICING **

      // 3. ** MODIFIED QUERY ** - Now uses dynamic pricebookIdToUse variable.
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
        WHERE IsActive = TRUE
        WITH SECURITY_ENFORCED
        ORDER BY Name
        LIMIT 50
      ];

      // 4. Return the products with their pricing information.
      // The LWC will handle the display logic and error states.
      return products;
    } catch (SecurityException e) {
      // Log security violations for monitoring and compliance.
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ProductController.getProducts(): ' +
        e.getMessage()
      );

      // Throw a user-friendly error message that doesn't expose system details.
      throw new AuraHandledException(
        'You do not have permission to view products. Please contact your administrator.'
      );
    } catch (Exception e) {
      // Log unexpected errors for debugging and monitoring.
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ProductController.getProducts(): ' + e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );

      // Throw a user-friendly error message for unexpected issues.
      throw new AuraHandledException(
        'Unable to load products at this time. Please try again later.'
      );
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
      if (productId == null) {
        throw new AuraHandledException('Product ID is required.');
      }

      // 2. Define fields for security validation.
      List<String> fieldsToCheck = new List<String>{
        'Id',
        'Name',
        'ProductCode',
        'Description',
        'IsActive'
      };

      // 3. Enforce FLS read access.
      SecurityUtils.checkFieldReadAccess('Product2', fieldsToCheck);
      SecurityUtils.checkFieldReadAccess(
        'PricebookEntry',
        new List<String>{ 'UnitPrice', 'IsActive', 'Pricebook2Id' }
      );

      // CRUD checks before SOQL queries
      SecurityUtils.checkObjectReadable('User');
      SecurityUtils.checkObjectReadable('Account');
      SecurityUtils.checkObjectReadable('Pricebook2');
      SecurityUtils.checkObjectReadable('Product2');
      SecurityUtils.checkObjectReadable('PricebookEntry');

      // ** START: NEW LOGIC FOR CONTRACT PRICING **
      Id pricebookIdToUse;
      SecurityUtils.checkFieldReadAccess('User', new List<String>{ 'AccountId' });
      Id userAccountId = [
        SELECT AccountId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .AccountId;

      if (userAccountId != null) {
        // Check the user's Account for an assigned price book ID.
        SecurityUtils.checkFieldReadAccess('Account', new List<String>{ 'Assigned_Price_Book_ID__c' });
        Account userAccount = [
          SELECT Assigned_Price_Book_ID__c
          FROM Account
          WHERE Id = :userAccountId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ];
        if (String.isNotBlank(userAccount.Assigned_Price_Book_ID__c)) {
          pricebookIdToUse = userAccount.Assigned_Price_Book_ID__c;
        }
      }

      // If no custom price book is assigned, default to the standard one.
      if (pricebookIdToUse == null) {
        SecurityUtils.checkFieldReadAccess('Pricebook2', new List<String>{ 'IsStandard', 'Id' });
        pricebookIdToUse = [
          SELECT Id
          FROM Pricebook2
          WHERE IsStandard = TRUE
          WITH SECURITY_ENFORCED
          LIMIT 1
        ]
        .Id;
      }
      // ** END: NEW LOGIC FOR CONTRACT PRICING **

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
        WITH SECURITY_ENFORCED
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
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ProductController.getProductById(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to view this product. Please contact your administrator.'
      );
    } catch (AuraHandledException e) {
      // Re-throw AuraHandledException as-is for user-friendly error messages.
      throw e;
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ProductController.getProductById(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to load product details at this time. Please try again later.'
      );
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
      SecurityUtils.checkFieldReadAccess('Product2', fieldsToCheck);
      SecurityUtils.checkFieldReadAccess(
        'PricebookEntry',
        new List<String>{ 'UnitPrice', 'IsActive', 'Pricebook2Id' }
      );

      // CRUD checks before SOQL queries
      SecurityUtils.checkObjectReadable('User');
      SecurityUtils.checkObjectReadable('Account');
      SecurityUtils.checkObjectReadable('Pricebook2');
      SecurityUtils.checkObjectReadable('Product2');
      SecurityUtils.checkObjectReadable('PricebookEntry');

      // ** START: NEW LOGIC FOR CONTRACT PRICING **
      Id pricebookIdToUse;
      SecurityUtils.checkFieldReadAccess('User', new List<String>{ 'AccountId' });
      Id userAccountId = [
        SELECT AccountId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .AccountId;

      if (userAccountId != null) {
        // Check the user's Account for an assigned price book ID.
        SecurityUtils.checkFieldReadAccess('Account', new List<String>{ 'Assigned_Price_Book_ID__c' });
        Account userAccount = [
          SELECT Assigned_Price_Book_ID__c
          FROM Account
          WHERE Id = :userAccountId
          WITH SECURITY_ENFORCED
          LIMIT 1
        ];
        if (String.isNotBlank(userAccount.Assigned_Price_Book_ID__c)) {
          pricebookIdToUse = userAccount.Assigned_Price_Book_ID__c;
        }
      }

      // If no custom price book is assigned, default to the standard one.
      if (pricebookIdToUse == null) {
        SecurityUtils.checkFieldReadAccess('Pricebook2', new List<String>{ 'IsStandard', 'Id' });
        pricebookIdToUse = [
          SELECT Id
          FROM Pricebook2
          WHERE IsStandard = TRUE
          WITH SECURITY_ENFORCED
          LIMIT 1
        ]
        .Id;
      }
      // ** END: NEW LOGIC FOR CONTRACT PRICING **

      // 5. ** MODIFIED QUERY ** - Now uses dynamic pricebookIdToUse variable.
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
        WHERE
          IsActive = TRUE
          AND (Name LIKE :sanitizedSearchTerm
          OR Description LIKE :sanitizedSearchTerm)
        WITH SECURITY_ENFORCED
        ORDER BY Name
        LIMIT 50
      ];

      return products;
    } catch (SecurityException e) {
      System.debug(
        LoggingLevel.ERROR,
        'Security violation in ProductController.searchProducts(): ' +
        e.getMessage()
      );
      throw new AuraHandledException(
        'You do not have permission to search products. Please contact your administrator.'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Unexpected error in ProductController.searchProducts(): ' +
        e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Unable to search products at this time. Please try again later.'
      );
    }
  }
}
