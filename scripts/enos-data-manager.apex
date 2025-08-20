/**
 * @description ENOS Data Manager - Consolidated script for data management operations
 * Replaces multiple individual scripts with a single, configurable solution
 * @author ENOS Development Team
 * @version 1.0.0
 */
public class ENOS_DataManager {
    
    // Configuration options
    public enum OperationType {
        CREATE_PRODUCTS,
        ADD_STOCK,
        CREATE_CATEGORIES,
        CREATE_ACCOUNTS,
        CREATE_CONTACTS,
        ACTIVATE_PRICEBOOK,
        VERIFY_DATA,
        CLEANUP_DATA
    }
    
    public enum DataScope {
        MINIMAL,      // Basic test data
        STANDARD,     // Standard test data
        COMPREHENSIVE, // Full test data set
        CUSTOM        // Custom configuration
    }
    
    // Configuration parameters
    public class ConfigParams {
        public OperationType operation = OperationType.CREATE_PRODUCTS;
        public DataScope scope = DataScope.STANDARD;
        public Integer productCount = 10;
        public Integer categoryCount = 3;
        public Integer accountCount = 2;
        public Integer contactCountPerAccount = 1;
        public String productFamily = 'Technology';
        public Boolean activatePricebook = true;
        public Boolean addStockData = true;
        public Boolean verboseLogging = true;
    }
    
    // Main execution method
    public static void execute(ConfigParams config) {
        try {
            ENOS_LoggingUtils.info('=== ENOS DATA MANAGER EXECUTION STARTED ===');
            ENOS_LoggingUtils.info('Operation: ' + config.operation);
            ENOS_LoggingUtils.info('Scope: ' + config.scope);
            
            Long startTime = System.currentTimeMillis();
            
            switch on config.operation {
                when CREATE_PRODUCTS {
                    createProducts(config);
                }
                when ADD_STOCK {
                    addStockData(config);
                }
                when CREATE_CATEGORIES {
                    createCategories(config);
                }
                when CREATE_ACCOUNTS {
                    createAccounts(config);
                }
                when CREATE_CONTACTS {
                    createContacts(config);
                }
                when ACTIVATE_PRICEBOOK {
                    activatePricebook(config);
                }
                when VERIFY_DATA {
                    verifyData(config);
                }
                when CLEANUP_DATA {
                    cleanupData(config);
                }
            }
            
            Long duration = System.currentTimeMillis() - startTime;
            ENOS_LoggingUtils.info('=== ENOS DATA MANAGER EXECUTION COMPLETED ===');
            ENOS_LoggingUtils.info('Total duration: ' + duration + 'ms');
            
        } catch (Exception e) {
            ENOS_LoggingUtils.error('Error in ENOS Data Manager execution', e);
            throw e;
        }
    }
    
    // Default execution with standard configuration
    public static void execute() {
        ConfigParams defaultConfig = new ConfigParams();
        execute(defaultConfig);
    }
    
    // ============================================================================
    // PRODUCT MANAGEMENT
    // ============================================================================
    
    private static void createProducts(ConfigParams config) {
        ENOS_LoggingUtils.info('Creating products with scope: ' + config.scope);
        
        List<Product2> products = new List<Product2>();
        
        switch on config.scope {
            when MINIMAL {
                products = ENOS_TestDataFactory.createTestProducts(5, config.productFamily);
            }
            when STANDARD {
                products = ENOS_TestDataFactory.createTestProducts(10, config.productFamily);
            }
            when COMPREHENSIVE {
                products = ENOS_TestDataFactory.createTestProducts(20, config.productFamily);
            }
            when CUSTOM {
                products = ENOS_TestDataFactory.createTestProducts(config.productCount, config.productFamily);
            }
        }
        
        insert products;
        ENOS_LoggingUtils.info('Successfully created ' + products.size() + ' products');
        
        // Create pricebook entries if requested
        if (config.activatePricebook) {
            createPricebookEntries(products);
        }
        
        // Add stock data if requested
        if (config.addStockData) {
            addStockToProducts(products);
        }
    }
    
    private static void createPricebookEntries(List<Product2> products) {
        ENOS_LoggingUtils.info('Creating pricebook entries for ' + products.size() + ' products');
        
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> entries = new List<PricebookEntry>();
        
        for (Product2 product : products) {
            entries.add(new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = product.Id,
                UnitPrice = 99.99,
                IsActive = true
            ));
        }
        
        insert entries;
        ENOS_LoggingUtils.info('Successfully created ' + entries.size() + ' pricebook entries');
    }
    
    private static void addStockToProducts(List<Product2> products) {
        ENOS_LoggingUtils.info('Adding stock data to ' + products.size() + ' products');
        
        for (Product2 product : products) {
            product.Stock_Quantity__c = ENOS_ConfigurationUtils.getStockQuantity(product.ProductCode);
        }
        
        update products;
        ENOS_LoggingUtils.info('Successfully updated stock for ' + products.size() + ' products');
    }
    
    // ============================================================================
    // STOCK DATA MANAGEMENT
    // ============================================================================
    
    private static void addStockData(ConfigParams config) {
        ENOS_LoggingUtils.info('Adding stock data to existing products');
        
        List<Product2> products = [
            SELECT Id, Name, ProductCode, Stock_Quantity__c
            FROM Product2 
            WHERE IsActive = true 
            ORDER BY Name
        ];
        
        ENOS_LoggingUtils.info('Found ' + products.size() + ' products to update');
        
        for (Product2 product : products) {
            product.Stock_Quantity__c = ENOS_ConfigurationUtils.getStockQuantity(product.ProductCode);
            if (config.verboseLogging) {
                ENOS_LoggingUtils.info('Setting stock for ' + product.Name + ' (' + product.ProductCode + ') to: ' + product.Stock_Quantity__c);
            }
        }
        
        update products;
        ENOS_LoggingUtils.info('Successfully updated stock for ' + products.size() + ' products');
    }
    
    // ============================================================================
    // CATEGORY MANAGEMENT
    // ============================================================================
    
    private static void createCategories(ConfigParams config) {
        ENOS_LoggingUtils.info('Creating categories with scope: ' + config.scope);
        
        List<Category__c> categories = new List<Category__c>();
        
        switch on config.scope {
            when MINIMAL {
                categories = ENOS_TestDataFactory.createTestCategories(2);
            }
            when STANDARD {
                categories = ENOS_TestDataFactory.createTestCategories(3);
            }
            when COMPREHENSIVE {
                categories = ENOS_TestDataFactory.createTestCategories(5);
            }
            when CUSTOM {
                categories = ENOS_TestDataFactory.createTestCategories(config.categoryCount);
            }
        }
        
        insert categories;
        ENOS_LoggingUtils.info('Successfully created ' + categories.size() + ' categories');
    }
    
    // ============================================================================
    // ACCOUNT MANAGEMENT
    // ============================================================================
    
    private static void createAccounts(ConfigParams config) {
        ENOS_LoggingUtils.info('Creating accounts with scope: ' + config.scope);
        
        List<Account> accounts = new List<Account>();
        
        switch on config.scope {
            when MINIMAL {
                accounts = ENOS_TestDataFactory.createTestAccounts(2);
            }
            when STANDARD {
                accounts = ENOS_TestDataFactory.createTestAccounts(3);
            }
            when COMPREHENSIVE {
                accounts = ENOS_TestDataFactory.createTestAccounts(5);
            }
            when CUSTOM {
                accounts = ENOS_TestDataFactory.createTestAccounts(config.accountCount);
            }
        }
        
        insert accounts;
        ENOS_LoggingUtils.info('Successfully created ' + accounts.size() + ' accounts');
    }
    
    // ============================================================================
    // CONTACT MANAGEMENT
    // ============================================================================
    
    private static void createContacts(ConfigParams config) {
        ENOS_LoggingUtils.info('Creating contacts with scope: ' + config.scope);
        
        // First ensure we have accounts
        List<Account> accounts = [SELECT Id FROM Account LIMIT 5];
        if (accounts.isEmpty()) {
            ENOS_LoggingUtils.warn('No accounts found, creating default account first');
            Account defaultAccount = ENOS_TestDataFactory.createTestAccount();
            insert defaultAccount;
            accounts.add(defaultAccount);
        }
        
        List<Contact> allContacts = new List<Contact>();
        
        for (Account account : accounts) {
            List<Contact> contacts = ENOS_TestDataFactory.createTestContacts(
                config.contactCountPerAccount, 
                account.Id
            );
            allContacts.addAll(contacts);
        }
        
        insert allContacts;
        ENOS_LoggingUtils.info('Successfully created ' + allContacts.size() + ' contacts');
    }
    
    // ============================================================================
    // PRICEBOOK ACTIVATION
    // ============================================================================
    
    private static void activatePricebook(ConfigParams config) {
        ENOS_LoggingUtils.info('Activating standard pricebook');
        
        try {
            // Get the standard pricebook
            Id standardPricebookId = Test.getStandardPricebookId();
            
            // Update the standard pricebook to make it active
            Pricebook2 standardPricebook = new Pricebook2(
                Id = standardPricebookId,
                IsActive = true
            );
            
            update standardPricebook;
            ENOS_LoggingUtils.info('Successfully activated standard pricebook');
            
        } catch (Exception e) {
            ENOS_LoggingUtils.error('Error activating standard pricebook', e);
            throw e;
        }
    }
    
    // ============================================================================
    // DATA VERIFICATION
    // ============================================================================
    
    private static void verifyData(ConfigParams config) {
        ENOS_LoggingUtils.info('Verifying data integrity');
        
        // Count products
        Integer productCount = [SELECT COUNT() FROM Product2 WHERE IsActive = true];
        ENOS_LoggingUtils.info('Active products: ' + productCount);
        
        // Count categories
        Integer categoryCount = [SELECT COUNT() FROM Category__c];
        ENOS_LoggingUtils.info('Categories: ' + categoryCount);
        
        // Count accounts
        Integer accountCount = [SELECT COUNT() FROM Account];
        ENOS_LoggingUtils.info('Accounts: ' + accountCount);
        
        // Count contacts
        Integer contactCount = [SELECT COUNT() FROM Contact];
        ENOS_LoggingUtils.info('Contacts: ' + contactCount);
        
        // Count pricebook entries
        Integer pricebookEntryCount = [SELECT COUNT() FROM PricebookEntry WHERE IsActive = true];
        ENOS_LoggingUtils.info('Active pricebook entries: ' + pricebookEntryCount);
        
        // Verify stock quantities
        List<Product2> productsWithStock = [
            SELECT Id, Name, ProductCode, Stock_Quantity__c 
            FROM Product2 
            WHERE Stock_Quantity__c > 0 AND IsActive = true
        ];
        ENOS_LoggingUtils.info('Products with stock: ' + productsWithStock.size());
        
        if (config.verboseLogging) {
            for (Product2 product : productsWithStock) {
                ENOS_LoggingUtils.info(product.Name + ' (' + product.ProductCode + '): Stock = ' + product.Stock_Quantity__c);
            }
        }
    }
    
    // ============================================================================
    // DATA CLEANUP
    // ============================================================================
    
    private static void cleanupData(ConfigParams config) {
        ENOS_LoggingUtils.info('Cleaning up test data');
        
        try {
            // Delete in reverse order of dependencies
            List<Cart_Item__c> cartItems = [SELECT Id FROM Cart_Item__c];
            if (!cartItems.isEmpty()) {
                delete cartItems;
                ENOS_LoggingUtils.info('Deleted ' + cartItems.size() + ' cart items');
            }
            
            List<Cart__c> carts = [SELECT Id FROM Cart__c];
            if (!carts.isEmpty()) {
                delete carts;
                ENOS_LoggingUtils.info('Deleted ' + carts.size() + ' carts');
            }
            
            List<Shipping_Address__c> addresses = [SELECT Id FROM Shipping_Address__c];
            if (!addresses.isEmpty()) {
                delete addresses;
                ENOS_LoggingUtils.info('Deleted ' + addresses.size() + ' shipping addresses');
            }
            
            List<Contact> contacts = [SELECT Id FROM Contact];
            if (!contacts.isEmpty()) {
                delete contacts;
                ENOS_LoggingUtils.info('Deleted ' + contacts.size() + ' contacts');
            }
            
            List<PricebookEntry> entries = [SELECT Id FROM PricebookEntry WHERE IsActive = true];
            if (!entries.isEmpty()) {
                delete entries;
                ENOS_LoggingUtils.info('Deleted ' + entries.size() + ' pricebook entries');
            }
            
            List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true];
            if (!products.isEmpty()) {
                delete products;
                ENOS_LoggingUtils.info('Deleted ' + products.size() + ' products');
            }
            
            List<Category__c> categories = [SELECT Id FROM Category__c];
            if (!categories.isEmpty()) {
                delete categories;
                ENOS_LoggingUtils.info('Deleted ' + categories.size() + ' categories');
            }
            
            List<Account> accounts = [SELECT Id FROM Account];
            if (!accounts.isEmpty()) {
                delete accounts;
                ENOS_LoggingUtils.info('Deleted ' + accounts.size() + ' accounts');
            }
            
            ENOS_LoggingUtils.info('Data cleanup completed successfully');
            
        } catch (Exception e) {
            ENOS_LoggingUtils.error('Error during data cleanup', e);
            throw e;
        }
    }
    
    // ============================================================================
    // UTILITY METHODS
    // ============================================================================
    
    /**
     * @description Creates a minimal test data set
     */
    public static void createMinimalDataSet() {
        ConfigParams config = new ConfigParams();
        config.scope = DataScope.MINIMAL;
        config.operation = OperationType.CREATE_PRODUCTS;
        execute(config);
    }
    
    /**
     * @description Creates a standard test data set
     */
    public static void createStandardDataSet() {
        ConfigParams config = new ConfigParams();
        config.scope = DataScope.STANDARD;
        config.operation = OperationType.CREATE_PRODUCTS;
        execute(config);
    }
    
    /**
     * @description Creates a comprehensive test data set
     */
    public static void createComprehensiveDataSet() {
        ConfigParams config = new ConfigParams();
        config.scope = DataScope.COMPREHENSIVE;
        config.operation = OperationType.CREATE_PRODUCTS;
        execute(config);
    }
    
    /**
     * @description Adds stock data to existing products
     */
    public static void addStockData() {
        ConfigParams config = new ConfigParams();
        config.operation = OperationType.ADD_STOCK;
        execute(config);
    }
    
    /**
     * @description Activates the standard pricebook
     */
    public static void activatePricebook() {
        ConfigParams config = new ConfigParams();
        config.operation = OperationType.ACTIVATE_PRICEBOOK;
        execute(config);
    }
    
    /**
     * @description Verifies data integrity
     */
    public static void verifyData() {
        ConfigParams config = new ConfigParams();
        config.operation = OperationType.VERIFY_DATA;
        execute(config);
    }
    
    /**
     * @description Cleans up all test data
     */
    public static void cleanupData() {
        ConfigParams config = new ConfigParams();
        config.operation = OperationType.CLEANUP_DATA;
        execute(config);
    }
}
