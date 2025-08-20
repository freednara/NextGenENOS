# ENOS Data Manager - Consolidated Script Documentation

## Overview

The **ENOS_DataManager** is a consolidated, configurable script that replaces multiple individual scripts for data management operations. This eliminates script maintenance debt and provides a single, consistent interface for all data operations.

## What It Replaces

The ENOS_DataManager consolidates the following scripts:

### **Product Management Scripts**
- `create_sample_products.apex` → `ENOS_DataManager.createStandardDataSet()`
- `create_simple_products.apex` → `ENOS_DataManager.createMinimalDataSet()`
- `add-stock-data.apex` → `ENOS_DataManager.addStockData()`

### **Category Management Scripts**
- Individual category creation scripts → `ENOS_DataManager.createCategories()`

### **Account & Contact Scripts**
- Individual account/contact scripts → `ENOS_DataManager.createAccounts()`, `ENOS_DataManager.createContacts()`

### **Pricebook Scripts**
- `activate_standard_pricebook.apex` → `ENOS_DataManager.activatePricebook()`

### **Data Verification Scripts**
- Various verification scripts → `ENOS_DataManager.verifyData()`

### **Cleanup Scripts**
- Individual cleanup scripts → `ENOS_DataManager.cleanupData()`

## Quick Start

### **Basic Usage**

```apex
// Create standard test data set (10 products, 3 categories, 2 accounts, 2 contacts)
ENOS_DataManager.execute();

// Create minimal test data set (5 products, 2 categories, 2 accounts, 1 contact)
ENOS_DataManager.createMinimalDataSet();

// Create comprehensive test data set (20 products, 5 categories, 5 accounts, 10 contacts)
ENOS_DataManager.createComprehensiveDataSet();
```

### **Custom Configuration**

```apex
// Create custom data set
ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
config.operation = ENOS_DataManager.OperationType.CREATE_PRODUCTS;
config.scope = ENOS_DataManager.DataScope.CUSTOM;
config.productCount = 15;
config.productFamily = 'Electronics';
config.activatePricebook = true;
config.addStockData = true;
config.verboseLogging = true;

ENOS_DataManager.execute(config);
```

## Configuration Options

### **Operation Types**

| Operation | Description | Example |
|-----------|-------------|---------|
| `CREATE_PRODUCTS` | Creates products with optional categories, accounts, contacts | `ENOS_DataManager.createStandardDataSet()` |
| `ADD_STOCK` | Adds stock data to existing products | `ENOS_DataManager.addStockData()` |
| `CREATE_CATEGORIES` | Creates only categories | `ENOS_DataManager.createCategories()` |
| `CREATE_ACCOUNTS` | Creates only accounts | `ENOS_DataManager.createAccounts()` |
| `CREATE_CONTACTS` | Creates only contacts | `ENOS_DataManager.createContacts()` |
| `ACTIVATE_PRICEBOOK` | Activates the standard pricebook | `ENOS_DataManager.activatePricebook()` |
| `VERIFY_DATA` | Verifies data integrity | `ENOS_DataManager.verifyData()` |
| `CLEANUP_DATA` | Cleans up all test data | `ENOS_DataManager.cleanupData()` |

### **Data Scopes**

| Scope | Products | Categories | Accounts | Contacts |
|-------|----------|------------|----------|----------|
| `MINIMAL` | 5 | 2 | 2 | 2 |
| `STANDARD` | 10 | 3 | 2 | 2 |
| `COMPREHENSIVE` | 20 | 5 | 5 | 10 |
| `CUSTOM` | Configurable | Configurable | Configurable | Configurable |

### **Configuration Parameters**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `operation` | `OperationType` | `CREATE_PRODUCTS` | Type of operation to perform |
| `scope` | `DataScope` | `STANDARD` | Data set scope |
| `productCount` | `Integer` | 10 | Number of products to create (CUSTOM scope) |
| `categoryCount` | `Integer` | 3 | Number of categories to create (CUSTOM scope) |
| `accountCount` | `Integer` | 2 | Number of accounts to create (CUSTOM scope) |
| `contactCountPerAccount` | `Integer` | 1 | Number of contacts per account (CUSTOM scope) |
| `productFamily` | `String` | 'Technology' | Product family for created products |
| `activatePricebook` | `Boolean` | true | Whether to create pricebook entries |
| `addStockData` | `Boolean` | true | Whether to add stock data to products |
| `verboseLogging` | `Boolean` | true | Whether to enable verbose logging |

## Common Use Cases

### **1. Development Environment Setup**

```apex
// Quick setup for development
ENOS_DataManager.createStandardDataSet();
```

### **2. Testing Environment Setup**

```apex
// Comprehensive setup for testing
ENOS_DataManager.createComprehensiveDataSet();
```

### **3. Product Testing Only**

```apex
// Create only products for testing
ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
config.operation = ENOS_DataManager.OperationType.CREATE_PRODUCTS;
config.scope = ENOS_DataManager.DataScope.MINIMAL;
config.activatePricebook = false;
config.addStockData = false;

ENOS_DataManager.execute(config);
```

### **4. Stock Data Management**

```apex
// Add stock data to existing products
ENOS_DataManager.addStockData();
```

### **5. Data Verification**

```apex
// Verify data integrity
ENOS_DataManager.verifyData();
```

### **6. Cleanup After Testing**

```apex
// Clean up all test data
ENOS_DataManager.cleanupData();
```

## Integration with Other ENOS Components

### **ENOS_TestDataFactory Integration**

The ENOS_DataManager uses ENOS_TestDataFactory for consistent test data creation:

```apex
// All test data is created through the factory
List<Product2> products = ENOS_TestDataFactory.createTestProducts(10, 'Technology');
```

### **ENOS_LoggingUtils Integration**

All operations are logged using ENOS_LoggingUtils:

```apex
// Consistent logging across all operations
ENOS_LoggingUtils.info('Creating products with scope: ' + config.scope);
```

### **ENOS_ConfigurationUtils Integration**

Stock quantities and other configuration values are retrieved from ENOS_ConfigurationUtils:

```apex
// Configuration-driven stock quantities
product.Stock_Quantity__c = ENOS_ConfigurationUtils.getStockQuantity(product.ProductCode);
```

## Error Handling

The ENOS_DataManager includes comprehensive error handling:

- **Graceful degradation** - Continues operation even if some components fail
- **Detailed logging** - All errors are logged with context
- **Exception propagation** - Errors are re-thrown for proper handling
- **Data validation** - Verifies data integrity before and after operations

## Performance Considerations

### **Bulk Operations**

All DML operations are performed in bulk for optimal performance:

```apex
// Bulk insert for products
insert products;

// Bulk update for stock data
update products;
```

### **Efficient Queries**

Queries are optimized to minimize database calls:

```apex
// Single query for all products
List<Product2> products = [
    SELECT Id, Name, ProductCode, Stock_Quantity__c
    FROM Product2 
    WHERE IsActive = true 
    ORDER BY Name
];
```

### **Memory Management**

Large data sets are processed efficiently:

```apex
// Process products in manageable chunks
for (Product2 product : products) {
    product.Stock_Quantity__c = ENOS_ConfigurationUtils.getStockQuantity(product.ProductCode);
}
```

## Testing

The ENOS_DataManager includes comprehensive test coverage:

- **Unit tests** for each operation type
- **Integration tests** with other ENOS components
- **Performance tests** to ensure efficiency
- **Error handling tests** for robustness
- **Edge case tests** for reliability

## Migration Guide

### **From Individual Scripts**

1. **Replace script calls** with ENOS_DataManager methods
2. **Update parameters** to use the new configuration system
3. **Remove old scripts** after migration is complete
4. **Update documentation** to reference the new consolidated script

### **Example Migration**

**Before (Old Script):**
```apex
// Old way - multiple scripts
create_sample_products.apex
add-stock-data.apex
activate_standard_pricebook.apex
```

**After (New Script):**
```apex
// New way - single consolidated script
ENOS_DataManager.createStandardDataSet();
```

## Best Practices

### **1. Use Appropriate Scopes**

- **MINIMAL** - For quick testing and development
- **STANDARD** - For most development work
- **COMPREHENSIVE** - For thorough testing and QA
- **CUSTOM** - For specific requirements

### **2. Configure Logging**

```apex
// Enable verbose logging for debugging
config.verboseLogging = true;

// Disable verbose logging for production
config.verboseLogging = false;
```

### **3. Clean Up After Testing**

```apex
// Always clean up test data
ENOS_DataManager.cleanupData();
```

### **4. Use Configuration-Driven Values**

```apex
// Let configuration drive behavior
config.addStockData = ENOS_ConfigurationUtils.getConfigValueAsBoolean('ADD_STOCK_ON_CREATE');
```

## Troubleshooting

### **Common Issues**

1. **Missing Dependencies** - Ensure ENOS_TestDataFactory, ENOS_LoggingUtils, and ENOS_ConfigurationUtils are deployed
2. **Permission Errors** - Verify user has appropriate permissions for all objects
3. **Data Conflicts** - Use cleanup before creating new data sets
4. **Performance Issues** - Use appropriate scope for your needs

### **Debug Mode**

Enable verbose logging for troubleshooting:

```apex
ENOS_DataManager.ConfigParams config = new ENOS_DataManager.ConfigParams();
config.verboseLogging = true;
ENOS_DataManager.execute(config);
```

## Future Enhancements

### **Planned Features**

1. **Data Export/Import** - Support for data migration
2. **Scheduled Operations** - Automated data management
3. **Data Templates** - Predefined data configurations
4. **Audit Trail** - Track all data operations
5. **Rollback Support** - Undo data operations

### **Extensibility**

The ENOS_DataManager is designed for easy extension:

```apex
// Add new operation types
public enum OperationType {
    CREATE_PRODUCTS,
    ADD_STOCK,
    // ... existing operations ...
    EXPORT_DATA,    // New operation
    IMPORT_DATA     // New operation
}
```

## Support

For questions or issues with the ENOS_DataManager:

1. **Check the logs** - Use verbose logging for detailed information
2. **Review test results** - Ensure all tests are passing
3. **Check dependencies** - Verify all ENOS components are deployed
4. **Review configuration** - Ensure configuration values are correct

## Conclusion

The ENOS_DataManager provides a consolidated, maintainable solution for all data management operations. By replacing multiple individual scripts with a single, configurable interface, it eliminates script maintenance debt and provides a consistent, reliable way to manage ENOS platform data.

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Author**: ENOS Development Team
