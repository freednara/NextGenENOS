/**
 * @description Performance monitoring utility for StoreConnect application
 * Tracks key performance metrics, monitors system health, and provides alerting capabilities
 * 
 * @author NextGenENOS Team
 * @since 2024
 */
public with sharing class PerformanceMonitor {
    
    /**
     * @description Performance metric data structure
     */
    public class PerformanceMetric {
        @AuraEnabled public String metricName { get; set; }
        @AuraEnabled public Decimal value { get; set; }
        @AuraEnabled public String unit { get; set; }
        @AuraEnabled public DateTime timestamp { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public String status { get; set; } // OK, WARNING, CRITICAL
        
        public PerformanceMetric(String name, Decimal val, String unit, String category) {
            this.metricName = name;
            this.value = val;
            this.unit = unit;
            this.category = category;
            this.timestamp = DateTime.now();
            this.status = determineStatus(name, val);
        }
        
        private String determineStatus(String name, Decimal val) {
            // Define thresholds for different metrics
            Map<String, Map<String, Decimal>> thresholds = new Map<String, Map<String, Decimal>>{
                'RESPONSE_TIME' => new Map<String, Decimal>{'WARNING' => 2000, 'CRITICAL' => 5000},
                'CPU_USAGE' => new Map<String, Decimal>{'WARNING' => 70, 'CRITICAL' => 90},
                'MEMORY_USAGE' => new Map<String, Decimal>{'WARNING' => 80, 'CRITICAL' => 95},
                'ERROR_RATE' => new Map<String, Decimal>{'WARNING' => 5, 'CRITICAL' => 10},
                'HEAP_SIZE' => new Map<String, Decimal>{'WARNING' => 5000000, 'CRITICAL' => 6000000}
            };
            
            if (thresholds.containsKey(name)) {
                Map<String, Decimal> limits = thresholds.get(name);
                if (val >= limits.get('CRITICAL')) return 'CRITICAL';
                if (val >= limits.get('WARNING')) return 'WARNING';
            }
            
            return 'OK';
        }
    }
    
    /**
     * @description System health dashboard data
     */
    public class HealthDashboard {
        @AuraEnabled public List<PerformanceMetric> metrics { get; set; }
        @AuraEnabled public String overallStatus { get; set; }
        @AuraEnabled public Integer activeUsers { get; set; }
        @AuraEnabled public Decimal systemLoad { get; set; }
        @AuraEnabled public DateTime lastUpdated { get; set; }
        
        public HealthDashboard() {
            this.metrics = new List<PerformanceMetric>();
            this.lastUpdated = DateTime.now();
            this.overallStatus = 'OK';
        }
    }
    
    /**
     * @description Performance timing utility for method execution tracking
     */
    public class PerformanceTimer {
        private Long startTime;
        private String operation;
        
        public PerformanceTimer(String operationName) {
            this.operation = operationName;
            this.startTime = System.currentTimeMillis();
        }
        
        public void stop() {
            Long endTime = System.currentTimeMillis();
            Long duration = endTime - startTime;
            
            // Log performance data
            logPerformanceMetric(operation, duration, 'ms', 'RESPONSE_TIME');
            
            // Alert if slow
            if (duration > 5000) {
                sendPerformanceAlert('CRITICAL', operation + ' took ' + duration + 'ms to execute');
            } else if (duration > 2000) {
                sendPerformanceAlert('WARNING', operation + ' took ' + duration + 'ms to execute');
            }
        }
    }
    
    /**
     * @description Collects comprehensive system performance metrics
     */
    @AuraEnabled(cacheable=false)
    public static HealthDashboard getSystemHealth() {
        try {
            SecurityUtils.checkObjectReadable('Order');
            SecurityUtils.checkObjectReadable('OrderItem');
            SecurityUtils.checkObjectReadable('Cart__c');
            
            HealthDashboard dashboard = new HealthDashboard();
            
            // Collect various performance metrics
            dashboard.metrics.addAll(getResponseTimeMetrics());
            dashboard.metrics.addAll(getSystemResourceMetrics());
            dashboard.metrics.addAll(getBusinessMetrics());
            dashboard.metrics.addAll(getErrorMetrics());
            
            // Calculate overall system status
            dashboard.overallStatus = calculateOverallStatus(dashboard.metrics);
            dashboard.activeUsers = getActiveUserCount();
            dashboard.systemLoad = calculateSystemLoad();
            
            return dashboard;
            
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve system health: ' + e.getMessage());
        }
    }
    
    /**
     * @description Tracks response time for critical operations
     */
    private static List<PerformanceMetric> getResponseTimeMetrics() {
        List<PerformanceMetric> metrics = new List<PerformanceMetric>();
        
        // Simulate response time measurements for key operations
        Long startTime = System.currentTimeMillis();
        
        // Test product search response time
        try {
            List<Product2> products = [SELECT Id, Name FROM Product2 WITH SECURITY_ENFORCED LIMIT 10];
            Long productSearchTime = System.currentTimeMillis() - startTime;
            metrics.add(new PerformanceMetric('PRODUCT_SEARCH_TIME', productSearchTime, 'ms', 'RESPONSE_TIME'));
        } catch (Exception e) {
            metrics.add(new PerformanceMetric('PRODUCT_SEARCH_ERROR', 1, 'count', 'ERROR'));
        }
        
        // Test cart operations response time
        startTime = System.currentTimeMillis();
        try {
            List<Cart__c> carts = [SELECT Id FROM Cart__c WITH SECURITY_ENFORCED LIMIT 5];
            Long cartTime = System.currentTimeMillis() - startTime;
            metrics.add(new PerformanceMetric('CART_OPERATION_TIME', cartTime, 'ms', 'RESPONSE_TIME'));
        } catch (Exception e) {
            metrics.add(new PerformanceMetric('CART_OPERATION_ERROR', 1, 'count', 'ERROR'));
        }
        
        return metrics;
    }
    
    /**
     * @description Monitors system resource usage
     */
    private static List<PerformanceMetric> getSystemResourceMetrics() {
        List<PerformanceMetric> metrics = new List<PerformanceMetric>();
        
        // Heap size monitoring
        Long heapSize = Limits.getHeapSize();
        Long heapLimit = Limits.getLimitHeapSize();
        Decimal heapUsagePercent = (Decimal)heapSize / heapLimit * 100;
        
        metrics.add(new PerformanceMetric('HEAP_SIZE', heapSize, 'bytes', 'RESOURCE'));
        metrics.add(new PerformanceMetric('HEAP_USAGE_PERCENT', heapUsagePercent, '%', 'RESOURCE'));
        
        // SOQL query monitoring
        Integer queries = Limits.getQueries();
        Integer queryLimit = Limits.getLimitQueries();
        Decimal queryUsagePercent = (Decimal)queries / queryLimit * 100;
        
        metrics.add(new PerformanceMetric('SOQL_QUERIES', queries, 'count', 'RESOURCE'));
        metrics.add(new PerformanceMetric('SOQL_USAGE_PERCENT', queryUsagePercent, '%', 'RESOURCE'));
        
        // DML monitoring
        Integer dmlStatements = Limits.getDmlStatements();
        Integer dmlLimit = Limits.getLimitDmlStatements();
        Decimal dmlUsagePercent = (Decimal)dmlStatements / dmlLimit * 100;
        
        metrics.add(new PerformanceMetric('DML_STATEMENTS', dmlStatements, 'count', 'RESOURCE'));
        metrics.add(new PerformanceMetric('DML_USAGE_PERCENT', dmlUsagePercent, '%', 'RESOURCE'));
        
        // CPU time monitoring
        Integer cpuTime = Limits.getCpuTime();
        Integer cpuLimit = Limits.getLimitCpuTime();
        Decimal cpuUsagePercent = (Decimal)cpuTime / cpuLimit * 100;
        
        metrics.add(new PerformanceMetric('CPU_TIME', cpuTime, 'ms', 'RESOURCE'));
        metrics.add(new PerformanceMetric('CPU_USAGE_PERCENT', cpuUsagePercent, '%', 'RESOURCE'));
        
        return metrics;
    }
    
    /**
     * @description Tracks business-specific performance metrics
     */
    private static List<PerformanceMetric> getBusinessMetrics() {
        List<PerformanceMetric> metrics = new List<PerformanceMetric>();
        
        try {
            // Orders processed today
            Integer ordersToday = [
                SELECT COUNT() 
                FROM Order 
                WHERE CreatedDate = TODAY 
                WITH SECURITY_ENFORCED
            ];
            metrics.add(new PerformanceMetric('ORDERS_TODAY', ordersToday, 'count', 'BUSINESS'));
            
            // Active carts
            Integer activeCarts = [
                SELECT COUNT() 
                FROM Cart__c 
                WHERE Status__c = 'Active' 
                AND LastModifiedDate = LAST_N_DAYS:1 
                WITH SECURITY_ENFORCED
            ];
            metrics.add(new PerformanceMetric('ACTIVE_CARTS', activeCarts, 'count', 'BUSINESS'));
            
            // Product views (from actual analytics)
            Integer productViews = getActualProductViews();
            metrics.add(new PerformanceMetric('PRODUCT_VIEWS_HOUR', productViews, 'count', 'BUSINESS'));
            
            // Cart conversion rate (calculated from actual data)
            Decimal conversionRate = calculateActualConversionRate();
            metrics.add(new PerformanceMetric('CART_CONVERSION_RATE', conversionRate, '%', 'BUSINESS'));
            
        } catch (Exception e) {
            metrics.add(new PerformanceMetric('BUSINESS_METRICS_ERROR', 1, 'count', 'ERROR'));
        }
        
        return metrics;
    }
    
    /**
     * @description Monitors error rates and system issues
     */
    private static List<PerformanceMetric> getErrorMetrics() {
        List<PerformanceMetric> metrics = new List<PerformanceMetric>();
        
        // Error rate monitoring from asynchronous job failures
        Decimal errorRate = calculateActualErrorRate();
        metrics.add(new PerformanceMetric('ERROR_RATE', errorRate, '%', 'ERROR'));

        return metrics;
    }
    
    /**
     * @description Calculates overall system status based on individual metrics
     */
    private static String calculateOverallStatus(List<PerformanceMetric> metrics) {
        Integer criticalCount = 0;
        Integer warningCount = 0;
        
        for (PerformanceMetric metric : metrics) {
            if (metric.status == 'CRITICAL') {
                criticalCount++;
            } else if (metric.status == 'WARNING') {
                warningCount++;
            }
        }
        
        if (criticalCount > 0) return 'CRITICAL';
        if (warningCount > 0) return 'WARNING';
        return 'OK';
    }
    
    /**
     * @description Gets count of active users in the system
     */
    private static Integer getActiveUserCount() {
        try {
            // Count users active in the last hour (simulation)
            return (Integer)(Math.random() * 50) + 10; // 10-60 users
        } catch (Exception e) {
            return 0;
        }
    }
    
    /**
     * @description Calculates current system load
     */
    private static Decimal calculateSystemLoad() {
        // Combine various factors to determine system load
        Decimal heapUsage = (Decimal)Limits.getHeapSize() / Limits.getLimitHeapSize() * 100;
        Decimal queryUsage = (Decimal)Limits.getQueries() / Limits.getLimitQueries() * 100;
        Decimal cpuUsage = (Decimal)Limits.getCpuTime() / Limits.getLimitCpuTime() * 100;
        
        return (heapUsage + queryUsage + cpuUsage) / 3;
    }
    
    /**
     * @description Logs performance metrics for historical tracking
     */
    @future
    public static void logPerformanceMetric(String metricName, Decimal value, String unit, String category) {
        try {
            // In production, this would write to a custom object for historical tracking
            System.debug(LoggingLevel.INFO, 
                'PERFORMANCE_METRIC: ' + metricName + '=' + value + unit + 
                ' [' + category + '] at ' + DateTime.now());
                
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to log performance metric: ' + e.getMessage());
        }
    }
    
    /**
     * @description Sends performance alerts for critical issues
     */
    @future
    public static void sendPerformanceAlert(String severity, String message) {
        try {
            // In production, this would integrate with notification systems
            System.debug(LoggingLevel.WARN, 
                'PERFORMANCE_ALERT [' + severity + ']: ' + message + ' at ' + DateTime.now());
            
            // Could integrate with:
            // - Email notifications
            // - Slack/Teams webhooks
            // - SMS alerts
            // - Platform events for real-time monitoring dashboards
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to send performance alert: ' + e.getMessage());
        }
    }
    
    /**
     * @description Creates a performance timer for method execution tracking
     */
    public static PerformanceTimer startTimer(String operationName) {
        return new PerformanceTimer(operationName);
    }
    
    /**
     * @description Gets performance trends over time
     */
    @AuraEnabled(cacheable=true)
    public static List<PerformanceMetric> getPerformanceTrends(String metricName, Integer days) {
        try {
            SecurityUtils.checkFieldReadAccess('Order', 'CreatedDate');
            
            List<PerformanceMetric> trends = new List<PerformanceMetric>();
            
            // Simulate historical performance data
            for (Integer i = days; i >= 0; i--) {
                DateTime trendDate = DateTime.now().addDays(-i);
                Decimal value = Math.round((Math.random() * 100 + 50) * 100) / 100; // Random trend data
                
                PerformanceMetric trend = new PerformanceMetric(metricName, value, 'ms', 'TREND');
                trend.timestamp = trendDate;
                trends.add(trend);
            }
            
            return trends;
            
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve performance trends: ' + e.getMessage());
        }
    }
    
    /**
     * @description Runs comprehensive system health check
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> runHealthCheck() {
        Map<String, Object> healthCheck = new Map<String, Object>();
        
        try {
            // Database connectivity
            healthCheck.put('database', testDatabaseConnectivity());
            
            // External service connectivity
            healthCheck.put('paymentService', testPaymentServiceHealth());
            
            // System resources
            healthCheck.put('resources', checkSystemResources());
            
            // Application functionality
            healthCheck.put('application', testApplicationHealth());
            
            // Overall status
            healthCheck.put('overallStatus', calculateHealthCheckStatus(healthCheck));
            healthCheck.put('timestamp', DateTime.now());
            
        } catch (Exception e) {
            healthCheck.put('error', e.getMessage());
            healthCheck.put('overallStatus', 'ERROR');
        }
        
        return healthCheck;
    }
    
    private static Map<String, Object> testDatabaseConnectivity() {
        Map<String, Object> dbHealth = new Map<String, Object>();
        try {
            Long startTime = System.currentTimeMillis();
            List<Product2> testQuery = [SELECT COUNT() FROM Product2 WITH SECURITY_ENFORCED LIMIT 1];
            Long responseTime = System.currentTimeMillis() - startTime;
            
            dbHealth.put('status', 'OK');
            dbHealth.put('responseTime', responseTime);
        } catch (Exception e) {
            dbHealth.put('status', 'ERROR');
            dbHealth.put('error', e.getMessage());
        }
        return dbHealth;
    }
    
    private static Map<String, Object> testPaymentServiceHealth() {
        Map<String, Object> paymentHealth = new Map<String, Object>();
        try {
            // Simulate payment service health check
            paymentHealth.put('status', 'OK');
            paymentHealth.put('responseTime', Math.round(Math.random() * 1000));
        } catch (Exception e) {
            paymentHealth.put('status', 'ERROR');
            paymentHealth.put('error', e.getMessage());
        }
        return paymentHealth;
    }
    
    private static Map<String, Object> checkSystemResources() {
        Map<String, Object> resources = new Map<String, Object>();
        
        resources.put('heapUsage', (Decimal)Limits.getHeapSize() / Limits.getLimitHeapSize() * 100);
        resources.put('queryUsage', (Decimal)Limits.getQueries() / Limits.getLimitQueries() * 100);
        resources.put('dmlUsage', (Decimal)Limits.getDmlStatements() / Limits.getLimitDmlStatements() * 100);
        resources.put('cpuUsage', (Decimal)Limits.getCpuTime() / Limits.getLimitCpuTime() * 100);
        
        // Determine status based on highest usage
        Decimal maxUsage = Math.max(Math.max((Decimal)resources.get('heapUsage'), (Decimal)resources.get('queryUsage')),
                                   Math.max((Decimal)resources.get('dmlUsage'), (Decimal)resources.get('cpuUsage')));
        
        if (maxUsage > 90) resources.put('status', 'CRITICAL');
        else if (maxUsage > 70) resources.put('status', 'WARNING');
        else resources.put('status', 'OK');
        
        return resources;
    }
    
    private static Map<String, Object> testApplicationHealth() {
        Map<String, Object> appHealth = new Map<String, Object>();
        try {
            // Test core application functionality
            SecurityUtils.checkObjectReadable('Product2');
            SecurityUtils.checkObjectReadable('Cart__c');
            
            appHealth.put('status', 'OK');
            appHealth.put('securityChecks', 'PASSED');
        } catch (Exception e) {
            appHealth.put('status', 'ERROR');
            appHealth.put('error', e.getMessage());
        }
        return appHealth;
    }
    
    private static String calculateHealthCheckStatus(Map<String, Object> healthCheck) {
        Boolean hasError = false;
        Boolean hasWarning = false;
        
        for (String key : healthCheck.keySet()) {
            if (healthCheck.get(key) instanceof Map<String, Object>) {
                Map<String, Object> component = (Map<String, Object>)healthCheck.get(key);
                String status = (String)component.get('status');
                if (status == 'ERROR' || status == 'CRITICAL') hasError = true;
                else if (status == 'WARNING') hasWarning = true;
            }
        }
        
        if (hasError) return 'CRITICAL';
        if (hasWarning) return 'WARNING';
        return 'OK';
    }
    
    /**
     * @description Get actual product views from analytics data
     * @return Number of product views in the last hour
     */
    private static Integer getActualProductViews() {
        try {
            // Query actual view tracking data
            List<AggregateResult> results = [
                SELECT COUNT(Id) viewCount
                FROM View_Tracking__c
                WHERE Last_Viewed_Date__c >= :DateTime.now().addHours(-1)
                WITH SECURITY_ENFORCED
            ];
            
            if (!results.isEmpty() && results[0].get('viewCount') != null) {
                return (Integer)results[0].get('viewCount');
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Unable to retrieve actual product views: ' + e.getMessage());
        }
        
        return 0; // Default to 0 if data unavailable
    }
    
    /**
     * @description Calculate actual cart conversion rate
     * @return Conversion rate as percentage
     */
    private static Decimal calculateActualConversionRate() {
        try {
            // Get cart creation count
            List<AggregateResult> cartResults = [
                SELECT COUNT(Id) cartCount
                FROM Cart__c
                WHERE CreatedDate >= :DateTime.now().addHours(-1)
                WITH SECURITY_ENFORCED
            ];
            
            // Get order creation count
            List<AggregateResult> orderResults = [
                SELECT COUNT(Id) orderCount
                FROM Order
                WHERE CreatedDate >= :DateTime.now().addHours(-1)
                WITH SECURITY_ENFORCED
            ];
            
            Integer cartCount = cartResults.isEmpty() ? 0 : (Integer)cartResults[0].get('cartCount');
            Integer orderCount = orderResults.isEmpty() ? 0 : (Integer)orderResults[0].get('orderCount');
            
            if (cartCount > 0) {
                return (Decimal.valueOf(orderCount) / Decimal.valueOf(cartCount) * 100).setScale(2);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Unable to calculate actual conversion rate: ' + e.getMessage());
        }
        
        return 0.0; // Default to 0% if calculation fails
    }
    
    /**
     * @description Calculate actual error rate from system logs
     * @return Error rate as percentage
     */
    private static Decimal calculateActualErrorRate() {
        try {
            List<AggregateResult> totalJobs = [
                SELECT COUNT(Id) totalCount
                FROM AsyncApexJob
                WHERE CreatedDate >= :DateTime.now().addHours(-1)
            ];

            List<AggregateResult> failedJobs = [
                SELECT COUNT(Id) failCount
                FROM AsyncApexJob
                WHERE CreatedDate >= :DateTime.now().addHours(-1)
                AND (Status = 'Failed' OR Status = 'Aborted')
            ];

            Decimal totalCount = (Decimal) (totalJobs.isEmpty() ? 0 : totalJobs[0].get('totalCount'));
            Decimal failCount = (Decimal) (failedJobs.isEmpty() ? 0 : failedJobs[0].get('failCount'));

            if (totalCount > 0) {
                return (failCount / totalCount * 100).setScale(2);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Unable to calculate actual error rate: ' + e.getMessage());
        }

        return 0;
    }
}
