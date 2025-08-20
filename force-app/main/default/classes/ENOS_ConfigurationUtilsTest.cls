/**
 * @description Test class for ENOS_ConfigurationUtils
 * Tests all configuration methods including new performance monitoring and stock quantity configurations
 * @author ENOS Development Team
 * @version 1.0.0
 */
@IsTest
private class ENOS_ConfigurationUtilsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test configuration records
        List<ENOS_Configuration__c> testConfigs = new List<ENOS_Configuration__c>();
        
        // Performance monitoring test configurations
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'CPU_WARNING_THRESHOLD',
            Configuration_Value__c = '75'
        ));
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'CPU_CRITICAL_THRESHOLD',
            Configuration_Value__c = '95'
        ));
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'MEMORY_WARNING_THRESHOLD',
            Configuration_Value__c = '85'
        ));
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'MEMORY_CRITICAL_THRESHOLD',
            Configuration_Value__c = '98'
        ));
        
        // Stock quantity test configurations
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'STOCK_AUDIO_001_QUANTITY',
            Configuration_Value__c = '50'
        ));
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'STOCK_COMP_001_QUANTITY',
            Configuration_Value__c = '25'
        ));
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'STOCK_DEFAULT_QUANTITY',
            Configuration_Value__c = '30'
        ));
        
        // Environment configuration
        testConfigs.add(new ENOS_Configuration__c(
            Configuration_Key__c = 'IS_DEVELOPMENT_ENVIRONMENT',
            Configuration_Value__c = 'true'
        ));
        
        insert testConfigs;
    }
    
    // ============================================================================
    // BASIC CONFIGURATION TESTS
    // ============================================================================
    
    @IsTest
    static void testGetConfigValue() {
        // Test getting existing configuration
        String cpuWarning = ENOS_ConfigurationUtils.getConfigValue('CPU_WARNING_THRESHOLD');
        System.assertEquals('75', cpuWarning, 'Should return configured CPU warning threshold');
        
        // Test getting non-existent configuration (should return default)
        String nonExistent = ENOS_ConfigurationUtils.getConfigValue('NON_EXISTENT_KEY');
        System.assertEquals(null, nonExistent, 'Should return null for non-existent key');
    }
    
    @IsTest
    static void testGetConfigValueAsInteger() {
        // Test getting integer configuration
        Integer stockDefault = ENOS_ConfigurationUtils.getConfigValueAsInteger('STOCK_DEFAULT_QUANTITY');
        System.assertEquals(30, stockDefault, 'Should return configured stock default quantity as integer');
        
        // Test getting non-existent configuration
        Integer nonExistent = ENOS_ConfigurationUtils.getConfigValueAsInteger('NON_EXISTENT_KEY');
        System.assertEquals(null, nonExistent, 'Should return null for non-existent key');
    }
    
    @IsTest
    static void testGetConfigValueAsDecimal() {
        // Test getting decimal configuration
        Decimal cpuWarning = ENOS_ConfigurationUtils.getConfigValueAsDecimal('CPU_WARNING_THRESHOLD');
        System.assertEquals(75.0, cpuWarning, 'Should return configured CPU warning threshold as decimal');
        
        // Test getting non-existent configuration
        Decimal nonExistent = ENOS_ConfigurationUtils.getConfigValueAsDecimal('NON_EXISTENT_KEY');
        System.assertEquals(null, nonExistent, 'Should return null for non-existent key');
    }
    
    @IsTest
    static void testGetConfigValueAsBoolean() {
        // Test getting boolean configuration
        Boolean isDev = ENOS_ConfigurationUtils.getConfigValueAsBoolean('IS_DEVELOPMENT_ENVIRONMENT');
        System.assertEquals(true, isDev, 'Should return configured development environment flag as boolean');
        
        // Test getting non-existent configuration
        Boolean nonExistent = ENOS_ConfigurationUtils.getConfigValueAsBoolean('NON_EXISTENT_KEY');
        System.assertEquals(null, nonExistent, 'Should return null for non-existent key');
    }
    
    // ============================================================================
    // PERFORMANCE MONITORING CONFIGURATION TESTS
    // ============================================================================
    
    @IsTest
    static void testGetCpuWarningThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getCpuWarningThreshold();
        System.assertEquals(75.0, threshold, 'Should return configured CPU warning threshold');
    }
    
    @IsTest
    static void testGetCpuCriticalThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getCpuCriticalThreshold();
        System.assertEquals(95.0, threshold, 'Should return configured CPU critical threshold');
    }
    
    @IsTest
    static void testGetMemoryWarningThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getMemoryWarningThreshold();
        System.assertEquals(85.0, threshold, 'Should return configured memory warning threshold');
    }
    
    @IsTest
    static void testGetMemoryCriticalThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getMemoryCriticalThreshold();
        System.assertEquals(98.0, threshold, 'Should return configured memory critical threshold');
    }
    
    @IsTest
    static void testGetHeapWarningThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getHeapWarningThreshold();
        System.assertEquals(5000000.0, threshold, 'Should return default heap warning threshold');
    }
    
    @IsTest
    static void testGetHeapCriticalThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getHeapCriticalThreshold();
        System.assertEquals(6000000.0, threshold, 'Should return default heap critical threshold');
    }
    
    @IsTest
    static void testGetErrorRateWarningThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getErrorRateWarningThreshold();
        System.assertEquals(5.0, threshold, 'Should return default error rate warning threshold');
    }
    
    @IsTest
    static void testGetErrorRateCriticalThreshold() {
        Decimal threshold = ENOS_ConfigurationUtils.getErrorRateCriticalThreshold();
        System.assertEquals(10.0, threshold, 'Should return default error rate critical threshold');
    }
    
    // ============================================================================
    // STOCK QUANTITY CONFIGURATION TESTS
    // ============================================================================
    
    @IsTest
    static void testGetStockQuantity() {
        // Test getting specific product stock quantity
        Integer audioStock = ENOS_ConfigurationUtils.getStockQuantity('AUD-001');
        System.assertEquals(50, audioStock, 'Should return configured stock quantity for AUD-001');
        
        // Test getting another specific product stock quantity
        Integer compStock = ENOS_ConfigurationUtils.getStockQuantity('COMP-001');
        System.assertEquals(25, compStock, 'Should return configured stock quantity for COMP-001');
        
        // Test getting non-existent product (should return default)
        Integer defaultStock = ENOS_ConfigurationUtils.getStockQuantity('NON_EXISTENT');
        System.assertEquals(30, defaultStock, 'Should return default stock quantity for non-existent product');
        
        // Test getting null product code (should return default)
        Integer nullStock = ENOS_ConfigurationUtils.getStockQuantity(null);
        System.assertEquals(30, nullStock, 'Should return default stock quantity for null product code');
        
        // Test getting blank product code (should return default)
        Integer blankStock = ENOS_ConfigurationUtils.getStockQuantity('');
        System.assertEquals(30, blankStock, 'Should return default stock quantity for blank product code');
    }
    
    @IsTest
    static void testGetDefaultStockQuantity() {
        Integer defaultStock = ENOS_ConfigurationUtils.getDefaultStockQuantity();
        System.assertEquals(30, defaultStock, 'Should return configured default stock quantity');
    }
    
    // ============================================================================
    // ENVIRONMENT CONFIGURATION TESTS
    // ============================================================================
    
    @IsTest
    static void testIsDevelopmentEnvironment() {
        Boolean isDev = ENOS_ConfigurationUtils.isDevelopmentEnvironment();
        System.assertEquals(true, isDev, 'Should return configured development environment flag');
    }
    
    // ============================================================================
    // EXISTING CONFIGURATION TESTS (BACKWARD COMPATIBILITY)
    // ============================================================================
    
    @IsTest
    static void testGetBatchSizeLimit() {
        Integer batchSize = ENOS_ConfigurationUtils.getBatchSizeLimit();
        System.assertEquals(1000, batchSize, 'Should return default batch size limit');
    }
    
    @IsTest
    static void testGetQueryResultLimit() {
        Integer queryLimit = ENOS_ConfigurationUtils.getQueryResultLimit();
        System.assertEquals(2000, queryLimit, 'Should return default query result limit');
    }
    
    @IsTest
    static void testGetPerformanceWarningThreshold() {
        Integer warningThreshold = ENOS_ConfigurationUtils.getPerformanceWarningThreshold();
        System.assertEquals(2000, warningThreshold, 'Should return default performance warning threshold');
    }
    
    @IsTest
    static void testGetPerformanceCriticalThreshold() {
        Integer criticalThreshold = ENOS_ConfigurationUtils.getPerformanceCriticalThreshold();
        System.assertEquals(5000, criticalThreshold, 'Should return default performance critical threshold');
    }
    
    // ============================================================================
    // CONFIGURATION MANAGEMENT TESTS
    // ============================================================================
    
    @IsTest
    static void testSetConfigValue() {
        // Test setting new configuration
        ENOS_ConfigurationUtils.setConfigValue('TEST_KEY', 'TEST_VALUE');
        String value = ENOS_ConfigurationUtils.getConfigValue('TEST_KEY');
        System.assertEquals('TEST_VALUE', value, 'Should return newly set configuration value');
        
        // Test updating existing configuration
        ENOS_ConfigurationUtils.setConfigValue('TEST_KEY', 'UPDATED_VALUE');
        String updatedValue = ENOS_ConfigurationUtils.getConfigValue('TEST_KEY');
        System.assertEquals('UPDATED_VALUE', updatedValue, 'Should return updated configuration value');
    }
    
    @IsTest
    static void testSetConfigValueValidation() {
        // Test setting configuration with blank key
        try {
            ENOS_ConfigurationUtils.setConfigValue('', 'TEST_VALUE');
            System.assert(false, 'Should have thrown exception for blank key');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Configuration key cannot be blank'), 'Should contain appropriate error message');
        }
        
        // Test setting configuration with null key
        try {
            ENOS_ConfigurationUtils.setConfigValue(null, 'TEST_VALUE');
            System.assert(false, 'Should have thrown exception for null key');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('Configuration key cannot be blank'), 'Should contain appropriate error message');
        }
    }
    
    @IsTest
    static void testResetToDefaults() {
        // Set a custom configuration
        ENOS_ConfigurationUtils.setConfigValue('TEST_RESET_KEY', 'CUSTOM_VALUE');
        System.assertEquals('CUSTOM_VALUE', ENOS_ConfigurationUtils.getConfigValue('TEST_RESET_KEY'), 'Custom value should be set');
        
        // Reset to defaults
        ENOS_ConfigurationUtils.resetToDefaults();
        
        // Verify custom configuration is removed
        String value = ENOS_ConfigurationUtils.getConfigValue('TEST_RESET_KEY');
        System.assertEquals(null, value, 'Custom configuration should be removed after reset');
        
        // Verify default configurations are still available
        Integer batchSize = ENOS_ConfigurationUtils.getBatchSizeLimit();
        System.assertEquals(1000, batchSize, 'Default configurations should still be available after reset');
    }
    
    // ============================================================================
    // CACHE FUNCTIONALITY TESTS
    // ============================================================================
    
    @IsTest
    static void testCacheFunctionality() {
        // First call should populate cache
        String firstCall = ENOS_ConfigurationUtils.getConfigValue('CPU_WARNING_THRESHOLD');
        System.assertEquals('75', firstCall, 'First call should return correct value');
        
        // Second call should use cache
        String secondCall = ENOS_ConfigurationUtils.getConfigValue('CPU_WARNING_THRESHOLD');
        System.assertEquals('75', secondCall, 'Second call should return same value from cache');
        
        // Update configuration should update cache
        ENOS_ConfigurationUtils.setConfigValue('CPU_WARNING_THRESHOLD', '80');
        String updatedCall = ENOS_ConfigurationUtils.getConfigValue('CPU_WARNING_THRESHOLD');
        System.assertEquals('80', updatedCall, 'Updated call should return new value from cache');
    }
    
    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================
    
    @IsTest
    static void testPerformanceMonitoringIntegration() {
        // Test that all performance monitoring methods work together
        Decimal cpuWarning = ENOS_ConfigurationUtils.getCpuWarningThreshold();
        Decimal cpuCritical = ENOS_ConfigurationUtils.getCpuCriticalThreshold();
        Decimal memoryWarning = ENOS_ConfigurationUtils.getMemoryWarningThreshold();
        Decimal memoryCritical = ENOS_ConfigurationUtils.getMemoryCriticalThreshold();
        
        // Verify thresholds are in logical order
        System.assert(cpuWarning < cpuCritical, 'CPU warning should be less than critical');
        System.assert(memoryWarning < memoryCritical, 'Memory warning should be less than critical');
        
        // Verify thresholds are within reasonable ranges
        System.assert(cpuWarning >= 50 && cpuWarning <= 90, 'CPU warning should be within reasonable range');
        System.assert(cpuCritical >= 70 && cpuCritical <= 100, 'CPU critical should be within reasonable range');
        System.assert(memoryWarning >= 60 && memoryWarning <= 95, 'Memory warning should be within reasonable range');
        System.assert(memoryCritical >= 80 && memoryCritical <= 100, 'Memory critical should be within reasonable range');
    }
    
    @IsTest
    static void testStockQuantityIntegration() {
        // Test that stock quantity methods work together
        Integer audioStock = ENOS_ConfigurationUtils.getStockQuantity('AUD-001');
        Integer compStock = ENOS_ConfigurationUtils.getStockQuantity('COMP-001');
        Integer defaultStock = ENOS_ConfigurationUtils.getDefaultStockQuantity();
        
        // Verify stock quantities are positive
        System.assert(audioStock > 0, 'Audio stock should be positive');
        System.assert(compStock > 0, 'Computer stock should be positive');
        System.assert(defaultStock > 0, 'Default stock should be positive');
        
        // Verify specific stock quantities are different from default
        System.assertNotEquals(defaultStock, audioStock, 'Audio stock should be different from default');
        System.assertNotEquals(defaultStock, compStock, 'Computer stock should be different from default');
    }
}
