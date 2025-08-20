// Script to add stock data to products
// Now that stock_quantity__c field is accessible (using lowercase field name)

try {
    ENOS_LoggingUtils.info('=== ADDING STOCK DATA TO PRODUCTS ===');
    
    // Query products to update
    List<Product2> products = [
        SELECT Id, Name, ProductCode, stock_quantity__c
        FROM Product2 
        WHERE IsActive = true 
        ORDER BY Name
    ];
    
    ENOS_LoggingUtils.info('Found ' + products.size() + ' products to update');
    
    // Add stock data using configuration-based values
    for (Product2 product : products) {
        // Use configuration-based stock quantities
        product.stock_quantity__c = ENOS_ConfigurationUtils.getStockQuantity(product.ProductCode);
        
        ENOS_LoggingUtils.info('Setting stock for ' + product.Name + ' (' + product.ProductCode + ') to: ' + product.stock_quantity__c);
    }
    
    // Update the products
    update products;
    
    ENOS_LoggingUtils.info('✅ Successfully updated stock for ' + products.size() + ' products');
    
    // Verify the update
    List<Product2> updatedProducts = [
        SELECT Id, Name, ProductCode, stock_quantity__c
        FROM Product2 
        WHERE IsActive = true
        ORDER BY Name
    ];
    
    ENOS_LoggingUtils.info('=== VERIFICATION ===');
    for (Product2 product : updatedProducts) {
        ENOS_LoggingUtils.info(product.Name + ' (' + product.ProductCode + '): Stock = ' + product.stock_quantity__c);
    }
    
} catch (Exception e) {
    ENOS_LoggingUtils.error('❌ Error adding stock data', e);
}
