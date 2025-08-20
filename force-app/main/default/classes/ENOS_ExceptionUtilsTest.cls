/**
 * @description Test class for ENOS_ExceptionUtils
 * Tests all centralized exception handling methods
 * @author ENOS Development Team
 * @version 1.0.0
 */
@isTest
private class ENOS_ExceptionUtilsTest {
    
    @isTest
    static void testOperationFailureExceptions() {
        Test.startTest();
        
        // Test operation failure with exception
        Exception testException = new DmlException('Test DML error');
        
        try {
            ENOS_ExceptionUtils.throwOperationFailure('generate sales analytics', testException);
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Failed to generate sales analytics'));
            Assert.isTrue(e.getMessage().contains('Test DML error'));
        }
        
        // Test operation failure with details
        try {
            ENOS_ExceptionUtils.throwOperationFailure('process order', 'Invalid order data');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Failed to process order'));
            Assert.isTrue(e.getMessage().contains('Invalid order data'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testSecurityExceptions() {
        Test.startTest();
        
        // Test security violation
        try {
            ENOS_ExceptionUtils.throwSecurityViolation('SQL Injection', 'Dangerous query detected');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Security Error: SQL Injection'));
            Assert.isTrue(e.getMessage().contains('Dangerous query detected'));
        }
        
        // Test injection attempt
        try {
            ENOS_ExceptionUtils.throwInjectionAttempt('XSS');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Security Error: XSS injection detected'));
        }
        
        // Test permission denied
        try {
            ENOS_ExceptionUtils.throwPermissionDenied('delete user records');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('You do not have permission to perform this action'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidationExceptions() {
        Test.startTest();
        
        // Test validation failure
        try {
            ENOS_ExceptionUtils.throwValidationFailure('Email', 'must be valid email format');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Validation failed for Email'));
            Assert.isTrue(e.getMessage().contains('must be valid email format'));
        }
        
        // Test business rule violation
        try {
            ENOS_ExceptionUtils.throwBusinessRuleViolation('Order Total', 'must be greater than zero');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Business rule violation: Order Total'));
            Assert.isTrue(e.getMessage().contains('must be greater than zero'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testSystemExceptions() {
        Test.startTest();
        
        // Test system error
        Exception testException = new CalloutException('API call failed');
        try {
            ENOS_ExceptionUtils.throwSystemError('Payment Gateway', testException);
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('System error in Payment Gateway'));
            Assert.isTrue(e.getMessage().contains('API call failed'));
        }
        
        // Test unexpected error
        try {
            ENOS_ExceptionUtils.throwUnexpectedError('processing payment');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('We hit an unexpected error while processing payment'));
        }
        
        // Test service unavailable
        try {
            ENOS_ExceptionUtils.throwServiceUnavailable('Inventory Service');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('The Inventory Service service is currently unavailable'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testDataExceptions() {
        Test.startTest();
        
        // Test data not found
        try {
            ENOS_ExceptionUtils.throwDataNotFound('Order', 'ORD-001');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Order not found: ORD-001'));
        }
        
        // Test data integrity issue
        try {
            ENOS_ExceptionUtils.throwDataIntegrityIssue('Cart total does not match item totals');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Data integrity issue: Cart total does not match item totals'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testQueryExceptions() {
        Test.startTest();
        
        // Test query failure
        Exception testException = new QueryException('Invalid SOQL syntax');
        try {
            ENOS_ExceptionUtils.throwQueryFailure('Product Search', testException);
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Query failed for Product Search'));
            Assert.isTrue(e.getMessage().contains('Invalid SOQL syntax'));
        }
        
        // Test invalid query pattern
        try {
            ENOS_ExceptionUtils.throwInvalidQueryPattern('FROM ALL is not allowed');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Invalid query: FROM ALL is not allowed is not allowed'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testConfigurationExceptions() {
        Test.startTest();
        
        // Test configuration error
        Exception testException = new DmlException('Failed to update configuration');
        try {
            ENOS_ExceptionUtils.throwConfigurationError('API_ENDPOINT', testException);
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Configuration error for API_ENDPOINT'));
            Assert.isTrue(e.getMessage().contains('Failed to update configuration'));
        }
        
        // Test missing configuration
        try {
            ENOS_ExceptionUtils.throwMissingConfiguration('PAYMENT_GATEWAY_URL');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Missing configuration: PAYMENT_GATEWAY_URL is required'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testRetryExceptions() {
        Test.startTest();
        
        // Test retry exhausted
        Exception testException = new CalloutException('Connection timeout');
        try {
            ENOS_ExceptionUtils.throwRetryExhausted('process payment', 3, testException);
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Operation failed after 3 retries'));
            Assert.isTrue(e.getMessage().contains('Connection timeout'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testUtilityMethods() {
        Test.startTest();
        
        // Test throwSafely with exception
        Exception testException = new DmlException('Test error');
        try {
            ENOS_ExceptionUtils.throwSafely(testException, 'Default message');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Test error'));
        }
        
        // Test throwSafely with null exception
        try {
            ENOS_ExceptionUtils.throwSafely(null, 'Default message');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Default message'));
        }
        
        // Test logAndThrow
        Exception logException = new DmlException('Log test error');
        try {
            ENOS_ExceptionUtils.logAndThrow('test operation', logException, 'User friendly message');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('User friendly message'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testMissingDataExceptions() {
        Test.startTest();
        
        // Test missing data
        try {
            ENOS_ExceptionUtils.throwMissingData('Product ID');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Missing required data: Product ID'));
        }
        
        // Test invalid data
        try {
            ENOS_ExceptionUtils.throwInvalidData('Quantity', 'must be greater than 0');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Invalid data for Quantity'));
            Assert.isTrue(e.getMessage().contains('must be greater than 0'));
        }
        
        // Test access denied
        try {
            ENOS_ExceptionUtils.throwAccessDenied('User Records', 'delete');
            Assert.fail('Expected AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Access denied: Cannot delete User Records'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testBulkExceptionHandling() {
        Test.startTest();
        
        // Test multiple exceptions in sequence
        List<String> operations = new List<String>{
            'generate report',
            'process data',
            'send notification'
        };
        
        List<Exception> exceptions = new List<Exception>{
            new DmlException('DML error'),
            new CalloutException('Callout error'),
            new QueryException('Query error')
        };
        
        for (Integer i = 0; i < operations.size(); i++) {
            try {
                ENOS_ExceptionUtils.throwOperationFailure(operations[i], exceptions[i]);
                Assert.fail('Expected AuraHandledException to be thrown for ' + operations[i]);
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('Failed to ' + operations[i]));
                Assert.isTrue(e.getMessage().contains(exceptions[i].getMessage()));
            }
        }
        
        Test.stopTest();
    }
}



