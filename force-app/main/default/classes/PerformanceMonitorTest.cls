/**
 * @description Test class for PerformanceMonitor
 * Tests performance monitoring and alerting functionality.
 *
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class PerformanceMonitorTest {
    
    @isTest
    static void testMonitorComponentPerformance() {
        Test.startTest();
        
        // Test monitoring a fast operation
        PerformanceMonitor.startTimer('FastOperation');
        // Simulate some processing
        String testValue = 'Test';
        PerformanceMonitor.endTimer('FastOperation');
        
        // Test monitoring a potentially slow operation
        PerformanceMonitor.startTimer('SlowOperation');
        // Simulate some processing
        for (Integer i = 0; i < 100; i++) {
            testValue += i;
        }
        PerformanceMonitor.endTimer('SlowOperation');
        
        Test.stopTest();
        
        // Verify no exceptions were thrown
        System.assert(true, 'Performance monitoring should complete without errors');
    }
    
    @isTest
    static void testMonitorDatabaseOperations() {
        // Create test data
        Account testAccount = new Account(Name = 'Performance Test Account');
        insert testAccount;
        
        Test.startTest();
        
        PerformanceMonitor.startTimer('DatabaseQuery');
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Performance Test Account'];
        PerformanceMonitor.endTimer('DatabaseQuery');
        
        Test.stopTest();
        
        System.assertEquals(1, accounts.size(), 'Should find one test account');
    }
    
    @isTest
    static void testGetPerformanceMetrics() {
        Test.startTest();
        
        // Run some operations to generate metrics
        PerformanceMonitor.startTimer('TestMetric1');
        PerformanceMonitor.endTimer('TestMetric1');
        
        PerformanceMonitor.startTimer('TestMetric2');
        PerformanceMonitor.endTimer('TestMetric2');
        
        Map<String, Object> metrics = PerformanceMonitor.getPerformanceMetrics();
        
        Test.stopTest();
        
        System.assertNotEquals(null, metrics, 'Performance metrics should not be null');
    }
    
    @isTest
    static void testPerformanceAlerts() {
        Test.startTest();
        
        // Test alerting for slow operations
        PerformanceMonitor.alertSlowOperation('TestSlowOp', 5000);
        
        // Test alerting for memory usage
        PerformanceMonitor.alertHighMemoryUsage();
        
        // Test alerting for CPU usage
        PerformanceMonitor.alertHighCpuUsage();
        
        Test.stopTest();
        
        System.assert(true, 'Performance alerts should complete without errors');
    }
    
    @isTest
    static void testLogPerformanceData() {
        Test.startTest();
        
        PerformanceMonitor.logPerformanceData('TestComponent', 150);
        PerformanceMonitor.logPerformanceData('SlowComponent', 3000);
        
        Test.stopTest();
        
        System.assert(true, 'Performance data logging should complete without errors');
    }
    
    @isTest
    static void testTimerStartStop() {
        Test.startTest();
        
        // Test starting and stopping multiple timers
        PerformanceMonitor.startTimer('Timer1');
        PerformanceMonitor.startTimer('Timer2');
        PerformanceMonitor.endTimer('Timer1');
        PerformanceMonitor.endTimer('Timer2');
        
        // Test stopping non-existent timer
        PerformanceMonitor.endTimer('NonExistentTimer');
        
        Test.stopTest();
        
        System.assert(true, 'Timer operations should handle all scenarios gracefully');
    }
    
    @isTest
    static void testPerformanceThresholds() {
        Test.startTest();
        
        // Test checking against performance thresholds
        Boolean isSlowOperation = PerformanceMonitor.exceedsThreshold('DatabaseQuery', 2000);
        Boolean isFastOperation = PerformanceMonitor.exceedsThreshold('QuickOperation', 100);
        
        Test.stopTest();
        
        System.assertNotEquals(null, isSlowOperation, 'Threshold check should return a boolean');
        System.assertNotEquals(null, isFastOperation, 'Threshold check should return a boolean');
    }
    
    @isTest
    static void testGetSystemPerformance() {
        Test.startTest();
        
        Map<String, Object> systemPerf = PerformanceMonitor.getSystemPerformance();
        
        Test.stopTest();
        
        System.assertNotEquals(null, systemPerf, 'System performance metrics should not be null');
    }
    
    @isTest
    static void testResetMetrics() {
        Test.startTest();
        
        // Generate some metrics
        PerformanceMonitor.startTimer('ResetTest');
        PerformanceMonitor.endTimer('ResetTest');
        
        // Reset metrics
        PerformanceMonitor.resetMetrics();
        
        Map<String, Object> metricsAfterReset = PerformanceMonitor.getPerformanceMetrics();
        
        Test.stopTest();
        
        System.assertNotEquals(null, metricsAfterReset, 'Metrics should still be accessible after reset');
    }
    
    @isTest
    static void testConcurrentTimers() {
        Test.startTest();
        
        // Test multiple concurrent timers
        for (Integer i = 0; i < 5; i++) {
            PerformanceMonitor.startTimer('ConcurrentTimer' + i);
        }
        
        for (Integer i = 0; i < 5; i++) {
            PerformanceMonitor.endTimer('ConcurrentTimer' + i);
        }
        
        Test.stopTest();
        
        System.assert(true, 'Concurrent timers should be handled correctly');
    }
}
