/**
 * @description Performance configuration utility for ENOS platform
 * Centralizes performance monitoring configuration and provides advanced monitoring capabilities
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_PerformanceConfig {
    
    // Performance monitoring configuration
    private static final Map<String, String> PERFORMANCE_CONFIG = new Map<String, String>{
        'ENABLE_REAL_TIME_MONITORING' => 'true',
        'ENABLE_HISTORICAL_TRACKING' => 'true',
        'ENABLE_ALERT_ESCALATION' => 'false',
        'ENABLE_PERFORMANCE_BASELINING' => 'true',
        'ENABLE_AUTO_OPTIMIZATION' => 'false',
        'ENABLE_RESOURCE_THROTTLING' => 'true',
        'ENABLE_QUERY_ANALYSIS' => 'true',
        'ENABLE_TRANSACTION_TRACING' => 'false'
    };
    
    /**
     * @description Gets all performance configuration values
     * @return Map<String, String> All performance configuration values
     */
    public static Map<String, String> getAllPerformanceConfig() {
        Map<String, String> config = new Map<String, String>();
        
        // Add configuration utility values
        config.put('PERFORMANCE_WARNING_THRESHOLD_MS', String.valueOf(ENOS_ConfigurationUtils.getPerformanceWarningThreshold()));
        config.put('PERFORMANCE_CRITICAL_THRESHOLD_MS', String.valueOf(ENOS_ConfigurationUtils.getPerformanceCriticalThreshold()));
        config.put('PERFORMANCE_ALERT_ENABLED', String.valueOf(ENOS_ConfigurationUtils.isPerformanceAlertEnabled()));
        config.put('PERFORMANCE_METRICS_RETENTION_DAYS', String.valueOf(ENOS_ConfigurationUtils.getPerformanceMetricsRetentionDays()));
        config.put('SYSTEM_HEALTH_CHECK_INTERVAL_MINUTES', String.valueOf(ENOS_ConfigurationUtils.getSystemHealthCheckIntervalMinutes()));
        config.put('MAX_PERFORMANCE_METRICS_PER_QUERY', String.valueOf(ENOS_ConfigurationUtils.getMaxPerformanceMetricsPerQuery()));
        config.put('PERFORMANCE_ALERT_EMAIL_ENABLED', String.valueOf(ENOS_ConfigurationUtils.isPerformanceAlertEmailEnabled()));
        config.put('PERFORMANCE_ALERT_SLACK_ENABLED', String.valueOf(ENOS_ConfigurationUtils.isPerformanceAlertSlackEnabled()));
        
        // Add performance-specific configuration
        config.putAll(PERFORMANCE_CONFIG);
        
        return config;
    }
    
    /**
     * @description Checks if real-time performance monitoring is enabled
     * @return Boolean True if real-time monitoring is enabled
     */
    public static Boolean isRealTimeMonitoringEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_REAL_TIME_MONITORING'));
    }
    
    /**
     * @description Checks if historical performance tracking is enabled
     * @return Boolean True if historical tracking is enabled
     */
    public static Boolean isHistoricalTrackingEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_HISTORICAL_TRACKING'));
    }
    
    /**
     * @description Checks if alert escalation is enabled
     * @return Boolean True if alert escalation is enabled
     */
    public static Boolean isAlertEscalationEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_ALERT_ESCALATION'));
    }
    
    /**
     * @description Checks if performance baselining is enabled
     * @return Boolean True if performance baselining is enabled
     */
    public static Boolean isPerformanceBaseliningEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_PERFORMANCE_BASELINING'));
    }
    
    /**
     * @description Checks if automatic optimization is enabled
     * @return Boolean True if automatic optimization is enabled
     */
    public static Boolean isAutoOptimizationEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_AUTO_OPTIMIZATION'));
    }
    
    /**
     * @description Checks if resource throttling is enabled
     * @return Boolean True if resource throttling is enabled
     */
    public static Boolean isResourceThrottlingEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_RESOURCE_THROTTLING'));
    }
    
    /**
     * @description Checks if query analysis is enabled
     * @return Boolean True if query analysis is enabled
     */
    public static Boolean isQueryAnalysisEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_QUERY_ANALYSIS'));
    }
    
    /**
     * @description Checks if transaction tracing is enabled
     * @return Boolean True if transaction tracing is enabled
     */
    public static Boolean isTransactionTracingEnabled() {
        return Boolean.valueOf(PERFORMANCE_CONFIG.get('ENABLE_TRANSACTION_TRACING'));
    }
    
    /**
     * @description Gets performance monitoring recommendations based on current configuration
     * @return List<String> List of performance monitoring recommendations
     */
    public static List<String> getPerformanceRecommendations() {
        List<String> recommendations = new List<String>();
        
        // Check if performance monitoring is enabled
        if (!ENOS_ConfigurationUtils.isPerformanceMonitoringEnabled()) {
            recommendations.add('Enable performance monitoring for better system visibility');
        }
        
        // Check if alerts are enabled
        if (!ENOS_ConfigurationUtils.isPerformanceAlertEnabled()) {
            recommendations.add('Enable performance alerts to catch issues early');
        }
        
        // Check if historical tracking is enabled
        if (!isHistoricalTrackingEnabled()) {
            recommendations.add('Enable historical tracking for trend analysis and capacity planning');
        }
        
        // Check if query analysis is enabled
        if (!isQueryAnalysisEnabled()) {
            recommendations.add('Enable query analysis to identify performance bottlenecks');
        }
        
        // Check performance thresholds
        Integer warningThreshold = ENOS_ConfigurationUtils.getPerformanceWarningThreshold();
        Integer criticalThreshold = ENOS_ConfigurationUtils.getPerformanceCriticalThreshold();
        
        if (warningThreshold >= criticalThreshold) {
            recommendations.add('Warning threshold should be lower than critical threshold for effective alerting');
        }
        
        if (warningThreshold < 1000) {
            recommendations.add('Warning threshold is very low - consider increasing to reduce alert noise');
        }
        
        if (criticalThreshold > 10000) {
            recommendations.add('Critical threshold is very high - consider lowering for better responsiveness');
        }
        
        // Check retention settings
        Integer retentionDays = ENOS_ConfigurationUtils.getPerformanceMetricsRetentionDays();
        if (retentionDays < 7) {
            recommendations.add('Performance metrics retention is very short - consider increasing for better trend analysis');
        }
        
        if (retentionDays > 90) {
            recommendations.add('Performance metrics retention is very long - consider reducing to manage storage costs');
        }
        
        return recommendations;
    }
    
    /**
     * @description Gets performance monitoring status summary
     * @return Map<String, Object> Performance monitoring status
     */
    public static Map<String, Object> getPerformanceStatus() {
        Map<String, Object> status = new Map<String, Object>();
        
        status.put('monitoringEnabled', ENOS_ConfigurationUtils.isPerformanceMonitoringEnabled());
        status.put('alertsEnabled', ENOS_ConfigurationUtils.isPerformanceAlertEnabled());
        status.put('realTimeEnabled', isRealTimeMonitoringEnabled());
        status.put('historicalEnabled', isHistoricalTrackingEnabled());
        status.put('queryAnalysisEnabled', isQueryAnalysisEnabled());
        status.put('warningThreshold', ENOS_ConfigurationUtils.getPerformanceWarningThreshold());
        status.put('criticalThreshold', ENOS_ConfigurationUtils.getPerformanceCriticalThreshold());
        status.put('retentionDays', ENOS_ConfigurationUtils.getPerformanceMetricsRetentionDays());
        status.put('healthCheckInterval', ENOS_ConfigurationUtils.getSystemHealthCheckIntervalMinutes());
        status.put('recommendations', getPerformanceRecommendations());
        status.put('lastUpdated', DateTime.now());
        
        return status;
    }
    
    /**
     * @description Validates performance configuration for consistency
     * @return Map<String, Object> Validation results
     */
    public static Map<String, Object> validatePerformanceConfig() {
        Map<String, Object> results = new Map<String, Object>();
        List<String> issues = new List<String>();
        List<String> warnings = new List<String>();
        
        // Validate thresholds
        Integer warningThreshold = ENOS_ConfigurationUtils.getPerformanceWarningThreshold();
        Integer criticalThreshold = ENOS_ConfigurationUtils.getPerformanceCriticalThreshold();
        
        if (warningThreshold >= criticalThreshold) {
            issues.add('Warning threshold must be lower than critical threshold');
        }
        
        if (warningThreshold < 100) {
            warnings.add('Warning threshold is very low and may generate excessive alerts');
        }
        
        if (criticalThreshold > 30000) {
            warnings.add('Critical threshold is very high and may delay issue detection');
        }
        
        // Validate intervals
        Integer healthCheckInterval = ENOS_ConfigurationUtils.getSystemHealthCheckIntervalMinutes();
        if (healthCheckInterval < 1) {
            issues.add('Health check interval must be at least 1 minute');
        }
        
        if (healthCheckInterval > 60) {
            warnings.add('Health check interval is very long and may delay issue detection');
        }
        
        // Validate retention
        Integer retentionDays = ENOS_ConfigurationUtils.getPerformanceMetricsRetentionDays();
        if (retentionDays < 1) {
            issues.add('Performance metrics retention must be at least 1 day');
        }
        
        if (retentionDays > 365) {
            warnings.add('Performance metrics retention is very long and may impact storage costs');
        }
        
        // Set status
        results.put('status', issues.isEmpty() ? 'VALID' : 'INVALID');
        results.put('issues', issues);
        results.put('warnings', warnings);
        results.put('timestamp', DateTime.now());
        
        return results;
    }
}
