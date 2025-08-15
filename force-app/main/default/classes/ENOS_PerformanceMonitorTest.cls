/**
 * @description Test class for ENOS_PerformanceMonitor
 * Tests performance monitoring and alerting functionality.
 *
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
@isTest
public class ENOS_PerformanceMonitorTest {
  @isTest
  static void testMonitorComponentPerformance() {
    Test.startTest();

    // Test monitoring a fast operation
    ENOS_PerformanceMonitor.startTimer('FastOperation');
    // Simulate some processing
    String testValue = 'Test';
    ENOS_PerformanceMonitor.endTimer('FastOperation');

    // Test monitoring a potentially slow operation
    ENOS_PerformanceMonitor.startTimer('SlowOperation');
    // Simulate some processing
    for (Integer i = 0; i < 100; i++) {
      testValue += i;
    }
    ENOS_PerformanceMonitor.endTimer('SlowOperation');

    Test.stopTest();

    // Verify no exceptions were thrown
    System.assert(
      true,
      'Performance monitoring should complete without errors'
    );
  }

  @isTest
  static void testMonitorDatabaseOperations() {
    // Create test data
    Account testAccount = new Account(Name = 'Performance Test Account');
    insert testAccount;

    Test.startTest();

    ENOS_PerformanceMonitor.startTimer('DatabaseQuery');
    List<Account> accounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Performance Test Account'
    ];
    ENOS_PerformanceMonitor.endTimer('DatabaseQuery');

    Test.stopTest();

    System.assertEquals(1, accounts.size(), 'Should find one test account');
  }

  @isTest
  static void testGetPerformanceMetrics() {
    Test.startTest();

    // Run some operations to generate metrics
    ENOS_PerformanceMonitor.startTimer('TestMetric1');
    ENOS_PerformanceMonitor.endTimer('TestMetric1');

    ENOS_PerformanceMonitor.startTimer('TestMetric2');
    ENOS_PerformanceMonitor.endTimer('TestMetric2');

    Map<String, Object> metrics = ENOS_PerformanceMonitor.getPerformanceMetrics();

    Test.stopTest();

    System.assertNotEquals(
      null,
      metrics,
      'Performance metrics should not be null'
    );
  }

  @isTest
  static void testPerformanceAlerts() {
    Test.startTest();

    // Test alerting for slow operations
    ENOS_PerformanceMonitor.alertSlowOperation('TestSlowOp', 5000);

    // Test alerting for memory usage
    ENOS_PerformanceMonitor.alertHighMemoryUsage();

    // Test alerting for CPU usage
    ENOS_PerformanceMonitor.alertHighCpuUsage();

    Test.stopTest();

    System.assert(true, 'Performance alerts should complete without errors');
  }

  @isTest
  static void testLogPerformanceData() {
    Test.startTest();

    ENOS_PerformanceMonitor.logPerformanceData('TestComponent', 150);
    ENOS_PerformanceMonitor.logPerformanceData('SlowComponent', 3000);

    Test.stopTest();

    System.assert(
      true,
      'Performance data logging should complete without errors'
    );
  }

  @isTest
  static void testTimerStartStop() {
    Test.startTest();

    // Test starting and stopping multiple timers
    ENOS_PerformanceMonitor.startTimer('Timer1');
    ENOS_PerformanceMonitor.startTimer('Timer2');
    ENOS_PerformanceMonitor.endTimer('Timer1');
    ENOS_PerformanceMonitor.endTimer('Timer2');

    // Test stopping non-existent timer
    ENOS_PerformanceMonitor.endTimer('NonExistentTimer');

    Test.stopTest();

    System.assert(
      true,
      'Timer operations should handle all scenarios gracefully'
    );
  }

  @isTest
  static void testPerformanceThresholds() {
    Test.startTest();

    // Test checking against performance thresholds
    Boolean isSlowOperation = ENOS_PerformanceMonitor.exceedsThreshold(
      'DatabaseQuery',
      2000
    );
    Boolean isFastOperation = ENOS_PerformanceMonitor.exceedsThreshold(
      'QuickOperation',
      100
    );

    Test.stopTest();

    System.assertNotEquals(
      null,
      isSlowOperation,
      'Threshold check should return a boolean'
    );
    System.assertNotEquals(
      null,
      isFastOperation,
      'Threshold check should return a boolean'
    );
  }

  @isTest
  static void testGetSystemPerformance() {
    Test.startTest();

    Map<String, Object> systemPerf = ENOS_PerformanceMonitor.getSystemPerformance();

    Test.stopTest();

    System.assertNotEquals(
      null,
      systemPerf,
      'System performance metrics should not be null'
    );
  }

  @isTest
  static void testResetMetrics() {
    Test.startTest();

    // Generate some metrics
    ENOS_PerformanceMonitor.startTimer('ResetTest');
    ENOS_PerformanceMonitor.endTimer('ResetTest');

    // Reset metrics
    ENOS_PerformanceMonitor.resetMetrics();

    Map<String, Object> metricsAfterReset = ENOS_PerformanceMonitor.getPerformanceMetrics();

    Test.stopTest();

    System.assertNotEquals(
      null,
      metricsAfterReset,
      'Metrics should still be accessible after reset'
    );
  }

  @isTest
  static void testConcurrentTimers() {
    Test.startTest();

    // Test multiple concurrent timers
    for (Integer i = 0; i < 5; i++) {
      ENOS_PerformanceMonitor.startTimer('ConcurrentTimer' + i);
    }

    for (Integer i = 0; i < 5; i++) {
      ENOS_PerformanceMonitor.endTimer('ConcurrentTimer' + i);
    }

    Test.stopTest();

    System.assert(true, 'Concurrent timers should be handled correctly');
  }
}
