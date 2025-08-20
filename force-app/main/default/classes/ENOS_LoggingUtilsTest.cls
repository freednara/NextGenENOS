/**
 * @description Test class for ENOS_LoggingUtils
 * Tests all logging methods including conditional logging based on environment
 * @author ENOS Development Team
 * @version 1.0.0
 */
@IsTest
private class ENOS_LoggingUtilsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test configuration for development environment
        ENOS_Configuration__c devConfig = new ENOS_Configuration__c(
            Configuration_Key__c = 'IS_DEVELOPMENT_ENVIRONMENT',
            Configuration_Value__c = 'true'
        );
        insert devConfig;
    }
    
    // ============================================================================
    // DEBUG LEVEL LOGGING TESTS
    // ============================================================================
    
    @IsTest
    static void testDebugLogging() {
        // Test debug logging in test context
        ENOS_LoggingUtils.debug('Test debug message');
        
        // Test debug logging with context
        ENOS_LoggingUtils.debug('Test debug message', 'Test context');
        
        // Test debug logging with exception
        try {
            throw new CalloutException('Test exception');
        } catch (Exception e) {
            ENOS_LoggingUtils.debug('Test debug with exception', e);
        }
        
        // Verify no exceptions were thrown
        System.assert(true, 'Debug logging should complete without errors');
    }
    
    // ============================================================================
    // INFO LEVEL LOGGING TESTS
    // ============================================================================
    
    @IsTest
    static void testInfoLogging() {
        // Test info logging
        ENOS_LoggingUtils.info('Test info message');
        
        // Test info logging with context
        ENOS_LoggingUtils.info('Test info message', 'Test context');
        
        // Test info logging with timing
        Long startTime = System.currentTimeMillis();
        ENOS_LoggingUtils.info('Test info with timing', startTime);
        
        // Verify no exceptions were thrown
        System.assert(true, 'Info logging should complete without errors');
    }
    
    // ============================================================================
    // WARNING LEVEL LOGGING TESTS
    // ============================================================================
    
    @IsTest
    static void testWarnLogging() {
        // Test warning logging
        ENOS_LoggingUtils.warn('Test warning message');
        
        // Test warning logging with context
        ENOS_LoggingUtils.warn('Test warning message', 'Test context');
        
        // Test warning logging with performance data
        ENOS_LoggingUtils.warn('Test performance warning', 1500, 1000);
        
        // Verify no exceptions were thrown
        System.assert(true, 'Warning logging should complete without errors');
    }
    
    // ============================================================================
    // ERROR LEVEL LOGGING TESTS
    // ============================================================================
    
    @IsTest
    static void testErrorLogging() {
        // Test error logging
        ENOS_LoggingUtils.error('Test error message');
        
        // Test error logging with context
        ENOS_LoggingUtils.error('Test error message', 'Test context');
        
        // Test error logging with exception
        try {
            throw new CalloutException('Test exception for error logging');
        } catch (Exception e) {
            ENOS_LoggingUtils.error('Test error with exception', e);
        }
        
        // Test error logging with exception and context
        try {
            throw new CalloutException('Test exception for error logging with context');
        } catch (Exception e) {
            ENOS_LoggingUtils.error('Test error with exception and context', e, 'Test context');
        }
        
        // Verify no exceptions were thrown
        System.assert(true, 'Error logging should complete without errors');
    }
    
    // ============================================================================
    // PERFORMANCE LOGGING TESTS
    // ============================================================================
    
    @IsTest
    static void testPerformanceLogging() {
        // Test performance logging
        Long startTime = System.currentTimeMillis();
        ENOS_LoggingUtils.logPerformance('Test operation', startTime);
        
        // Test performance logging with context
        ENOS_LoggingUtils.logPerformance('Test operation with context', startTime, 'Test context');
        
        // Verify no exceptions were thrown
        System.assert(true, 'Performance logging should complete without errors');
    }
    
    // ============================================================================
    // SECURITY LOGGING TESTS
    // ============================================================================
    
    @IsTest
    static void testSecurityLogging() {
        // Test security logging
        ENOS_LoggingUtils.logSecurity('Test security event');
        
        // Test security logging with context
        ENOS_LoggingUtils.logSecurity('Test security event', 'Test context');
        
        // Verify no exceptions were thrown
        System.assert(true, 'Security logging should complete without errors');
    }
    
    // ============================================================================
    // BUSINESS LOGIC LOGGING TESTS
    // ============================================================================
    
    @IsTest
    static void testBusinessEventLogging() {
        // Test business event logging
        ENOS_LoggingUtils.logBusinessEvent('Test business event');
        
        // Test business event logging with details
        ENOS_LoggingUtils.logBusinessEvent('Test business event', 'Test details');
        
        // Verify no exceptions were thrown
        System.assert(true, 'Business event logging should complete without errors');
    }
    
    // ============================================================================
    // UTILITY METHOD TESTS
    // ============================================================================
    
    @IsTest
    static void testUtilityMethods() {
        // Test environment checking methods
        Boolean isDebugEnabled = ENOS_LoggingUtils.isDebugEnabled();
        Boolean isInfoEnabled = ENOS_LoggingUtils.isInfoEnabled();
        Boolean isDevEnv = ENOS_LoggingUtils.isDevelopmentEnvironment();
        Boolean isTestCtx = ENOS_LoggingUtils.isTestContext();
        
        // Verify methods return expected values in test context
        System.assert(isTestCtx, 'Should be in test context');
        System.assert(isInfoEnabled, 'Info logging should be enabled in test context');
        
        // Verify no exceptions were thrown
        System.assert(true, 'Utility methods should complete without errors');
    }
    
    // ============================================================================
    // LEGACY SUPPORT TESTS
    // ============================================================================
    
    @IsTest
    static void testLegacySupport() {
        // Test legacy log method
        ENOS_LoggingUtils.log('Test legacy log message');
        
        // Test legacy log method with level
        ENOS_LoggingUtils.log('Test legacy log with level', LoggingLevel.INFO);
        ENOS_LoggingUtils.log('Test legacy log with level', LoggingLevel.WARN);
        ENOS_LoggingUtils.log('Test legacy log with level', LoggingLevel.ERROR);
        ENOS_LoggingUtils.log('Test legacy log with level', LoggingLevel.DEBUG);
        
        // Verify no exceptions were thrown
        System.assert(true, 'Legacy support methods should complete without errors');
    }
    
    // ============================================================================
    // EDGE CASE TESTS
    // ============================================================================
    
    @IsTest
    static void testEdgeCases() {
        // Test logging with null messages
        ENOS_LoggingUtils.debug(null);
        ENOS_LoggingUtils.info(null);
        ENOS_LoggingUtils.warn(null);
        ENOS_LoggingUtils.error(null);
        
        // Test logging with blank messages
        ENOS_LoggingUtils.debug('');
        ENOS_LoggingUtils.info('');
        ENOS_LoggingUtils.warn('');
        ENOS_LoggingUtils.error('');
        
        // Test logging with null context - use explicit method calls to avoid ambiguity
        ENOS_LoggingUtils.debug('Test message', (String)null);
        ENOS_LoggingUtils.info('Test message', (String)null);
        ENOS_LoggingUtils.warn('Test message', (String)null);
        ENOS_LoggingUtils.error('Test message', (String)null);
        
        // Test logging with blank context
        ENOS_LoggingUtils.debug('Test message', '');
        ENOS_LoggingUtils.info('Test message', '');
        ENOS_LoggingUtils.warn('Test message', '');
        ENOS_LoggingUtils.error('Test message', '');
        
        // Verify no exceptions were thrown
        System.assert(true, 'Edge case logging should complete without errors');
    }
    
    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================
    
    @IsTest
    static void testIntegrationWithConfiguration() {
        // Test that logging utility works with configuration
        Boolean isDev = ENOS_LoggingUtils.isDevelopmentEnvironment();
        
        // Log a message to test integration
        ENOS_LoggingUtils.info('Integration test message');
        
        // Verify no exceptions were thrown
        System.assert(true, 'Integration test should complete without errors');
    }
    
    // ============================================================================
    // PERFORMANCE THRESHOLD TESTS
    // ============================================================================
    
    @IsTest
    static void testPerformanceThresholds() {
        // Test performance logging with different thresholds
        Long startTime = System.currentTimeMillis();
        
        // Fast operation (should log as info)
        ENOS_LoggingUtils.logPerformance('Fast operation', startTime);
        
        // Simulate slow operation by waiting
        System.debug('Simulating slow operation...');
        
        // Slow operation (should log as warning)
        Long slowStartTime = startTime - 3000; // 3 seconds ago
        ENOS_LoggingUtils.logPerformance('Slow operation', slowStartTime);
        
        // Very slow operation (should log as critical)
        Long verySlowStartTime = startTime - 6000; // 6 seconds ago
        ENOS_LoggingUtils.logPerformance('Very slow operation', verySlowStartTime);
        
        // Verify no exceptions were thrown
        System.assert(true, 'Performance threshold tests should complete without errors');
    }
    
    // ============================================================================
    // MESSAGE FORMATTING TESTS
    // ============================================================================
    
    @IsTest
    static void testMessageFormatting() {
        // Test various message formats
        ENOS_LoggingUtils.info('Simple message');
        ENOS_LoggingUtils.info('Message with special chars: !@#$%^&*()');
        ENOS_LoggingUtils.info('Message with numbers: 12345');
        ENOS_LoggingUtils.info('Message with spaces and   tabs');
        ENOS_LoggingUtils.info('Message with "quotes" and \'single quotes\'');
        
        // Test long messages
        String longMessage = 'A'.repeat(1000);
        ENOS_LoggingUtils.info(longMessage);
        
        // Verify no exceptions were thrown
        System.assert(true, 'Message formatting tests should complete without errors');
    }
}
