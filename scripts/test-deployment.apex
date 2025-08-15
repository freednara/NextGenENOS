// Test script to validate ENOS deployment
System.debug('=== ENOS Deployment Validation ===');

// Test 1: Security Utils
try {
    ENOS_SecurityUtils.checkObjectReadable('Product2');
    System.debug('✅ Security Utils: Product2 read access check passed');
} catch (Exception e) {
    System.debug('❌ Security Utils failed: ' + e.getMessage());
}

// Test 2: Configuration Utils
try {
    Integer batchLimit = ENOS_ConfigurationUtils.getBatchSizeLimit();
    System.debug('✅ Configuration Utils: Batch size limit = ' + batchLimit);
} catch (Exception e) {
    System.debug('❌ Configuration Utils failed: ' + e.getMessage());
}

// Test 3: Dynamic Utils
try {
    List<String> fields = new List<String>{'Id', 'Name'};
    String query = ENOS_DynamicUtils.buildSafeQuery('Product2', fields, 'IsActive = true', null, null);
    System.debug('✅ Dynamic Utils: Safe query builder working - Query: ' + query);
} catch (Exception e) {
    System.debug('❌ Dynamic Utils failed: ' + e.getMessage());
}

// Test 4: Performance Monitor
try {
    Map<String, Object> health = ENOS_PerformanceMonitor.runHealthCheck();
    System.debug('✅ Performance Monitor: Health check completed');
} catch (Exception e) {
    System.debug('❌ Performance Monitor failed: ' + e.getMessage());
}

System.debug('=== Validation Complete ===');
