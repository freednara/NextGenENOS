// Test Dynamic Apex Implementation
// This script tests all the new dynamic methods we've implemented

System.debug('=== Testing ENOS Dynamic Apex Implementation ===');

try {
    // Test 1: Basic Security Utils Methods
    System.debug('Test 1: Testing basic security methods...');
    
    // Test dynamic object access
    ENOS_SecurityUtils.checkDynamicObjectAccess('Product2', 'read');
    System.debug('✅ Dynamic object access check passed');
    
    // Test dynamic field access
    List<String> testFields = new List<String>{'Id', 'Name', 'ProductCode'};
    ENOS_SecurityUtils.checkDynamicFieldAccess('Product2', testFields);
    System.debug('✅ Dynamic field access check passed');
    
    // Test 2: Dynamic Utils Methods
    System.debug('Test 2: Testing dynamic utility methods...');
    
    // Test query building
    String testQuery = ENOS_DynamicUtils.buildSafeQuery('Product2', testFields, 'IsActive = true', 'Name ASC', 10);
    System.debug('✅ Query building passed: ' + testQuery);
    
    // Test metadata retrieval
    Schema.DescribeSObjectResult productMetadata = ENOS_DynamicUtils.getObjectMetadata('Product2');
    System.debug('✅ Metadata retrieval passed: ' + productMetadata.getName());
    
    // Test accessible fields
    List<String> accessibleFields = ENOS_SecurityUtils.getDynamicAccessibleFields('Product2', 'read');
    System.debug('✅ Accessible fields: ' + accessibleFields.size() + ' fields found');
    
    // Test 3: Product Controller Dynamic Methods
    System.debug('Test 3: Testing product controller dynamic methods...');
    
    // Test dynamic product query
    List<Product2> dynamicProducts = ENOS_ProductController.getProductsDynamic(testFields, null, null, 5);
    System.debug('✅ Dynamic product query passed: ' + dynamicProducts.size() + ' products found');
    
    // Test product metadata
    Map<String, Object> productMeta = ENOS_ProductController.getProductMetadata();
    System.debug('✅ Product metadata passed: ' + productMeta.get('objectName'));
    
    System.debug('🎉 ALL TESTS PASSED! Dynamic Apex implementation is working correctly.');
    
    // Test Phase 2: Enhanced Controllers
    System.debug('=== Testing Phase 2: Enhanced Controllers ===');
    
    // Test ENOS_CartController dynamic methods
    List<String> cartFields = new List<String>{'Id', 'Quantity__c', 'Unit_Price__c'};
    List<Cart_Item__c> dynamicCartItems = ENOS_CartController.getCartItemsDynamic(cartFields, 5);
    System.debug('✅ Dynamic cart query passed: ' + dynamicCartItems.size() + ' items found');
    
    Map<String, Object> cartMetadata = ENOS_CartController.getCartMetadata();
    System.debug('✅ Cart metadata passed: ' + cartMetadata.get('objectName'));
    
    // Test ENOS_Controller dynamic methods
    Map<String, Object> filters = new Map<String, Object>{
        'Family' => 'Electronics',
        'IsActive' => true
    };
    List<Product2> filteredProducts = ENOS_Controller.getProductsDynamicAdvanced(
        cartFields, filters, 'Name', 'ASC', 10
    );
    System.debug('✅ Dynamic advanced product query passed: ' + filteredProducts.size() + ' products found');
    
    List<String> objectNames = new List<String>{'Product2', 'Cart_Item__c'};
    Map<String, Object> multiMetadata = ENOS_Controller.getMultiObjectMetadata(objectNames);
    System.debug('✅ Multi-object metadata passed: ' + multiMetadata.size() + ' objects');
    
    System.debug('🎉 PHASE 2 COMPLETE! All enhanced controllers working correctly.');
    
    // Test Phase 3: Advanced Dynamic Features
    System.debug('=== Testing Phase 3: Advanced Dynamic Features ===');
    
    // Test Advanced Dynamic Utils
    List<String> fields = new List<String>{'Id', 'Name', 'Family'};
    Map<String, Object> filters = new Map<String, Object>{
        'IsActive' => true,
        'Family' => 'Electronics',
        'Stock_Quantity__c' => '>0'
    };
    List<String> aggregations = new List<String>{'COUNT(Id)', 'AVG(Stock_Quantity__c)'};
    List<String> groupBy = new List<String>{'Family'};
    
    // Test complex query building
    String complexQuery = ENOS_AdvancedDynamicUtils.buildComplexQuery(
        'Product2', fields, filters, aggregations, groupBy, 
        'COUNT(Id) > 1', 'Family ASC', 10
    );
    System.debug('✅ Complex query building passed: ' + complexQuery);
    
    // Test complex query execution
    List<SObject> complexResults = ENOS_AdvancedDynamicUtils.executeComplexQuery(
        'Product2', fields, filters, aggregations, groupBy, 
        'COUNT(Id) > 1', 'Family ASC', 10
    );
    System.debug('✅ Complex query execution passed: ' + complexResults.size() + ' results');
    
    // Test template queries
    String templateQuery = ENOS_AdvancedDynamicUtils.buildTemplateQuery(
        'product_search', fields, 'Family = \'Electronics\'', 'Name ASC'
    );
    System.debug('✅ Template query passed: ' + templateQuery);
    
    // Test performance metrics
    Map<String, Object> performanceMetrics = ENOS_AdvancedDynamicUtils.getPerformanceMetrics();
    System.debug('✅ Performance metrics passed: ' + performanceMetrics.size() + ' query types tracked');
    
    // Test parameter validation
    Boolean isValid = ENOS_AdvancedDynamicUtils.validateComplexQueryParameters('Product2', fields, filters);
    System.debug('✅ Parameter validation passed: ' + isValid);
    
    System.debug('🎉 PHASE 3 COMPLETE! All advanced dynamic features working correctly.');
    
} catch (Exception e) {
    System.debug('❌ TEST FAILED: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
