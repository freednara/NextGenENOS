/**
 * @description Configuration utility class for ENOS platform
 * Provides configurable limits, thresholds, and operational parameters
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_ConfigurationUtils {
    
    // Cache for configuration values to improve performance
    private static final Map<String, String> CONFIG_CACHE = new Map<String, String>();
    private static final DateTime CACHE_TIMESTAMP = DateTime.now();
    private static final Integer CACHE_DURATION_MINUTES = 15;
    
    // Default configuration values
    private static final Map<String, String> DEFAULT_CONFIG = new Map<String, String>{
        'BATCH_SIZE_LIMIT' => '1000',
        'QUERY_RESULT_LIMIT' => '2000',
        'PERFORMANCE_WARNING_THRESHOLD_MS' => '2000',
        'PERFORMANCE_CRITICAL_THRESHOLD_MS' => '5000',
        'MAX_RETRY_ATTEMPTS' => '3',
        'RETRY_DELAY_MS' => '1000',
        'SECURITY_LOG_ENABLED' => 'true',
        'PERFORMANCE_MONITORING_ENABLED' => 'true',
        'CART_ITEM_MAX_QUANTITY' => '999',
        'CART_ITEM_MIN_QUANTITY' => '1',
        'MAX_PAYMENT_AMOUNT' => '999999.99',
        'DEFAULT_PRICEBOOK_ID' => '01sSL00000ACZHE',
        'SESSION_TIMEOUT_MINUTES' => '30',
        'MAX_SEARCH_RESULTS' => '50',
        'CACHE_DURATION_MINUTES' => '15',
        'PERFORMANCE_ALERT_ENABLED' => 'true',
        'PERFORMANCE_METRICS_RETENTION_DAYS' => '30',
        'SYSTEM_HEALTH_CHECK_INTERVAL_MINUTES' => '5',
        'MAX_PERFORMANCE_METRICS_PER_QUERY' => '1000',
        'PERFORMANCE_ALERT_EMAIL_ENABLED' => 'false',
        'PERFORMANCE_ALERT_SLACK_ENABLED' => 'false',
        // Performance monitoring thresholds
        'CPU_WARNING_THRESHOLD' => '70',
        'CPU_CRITICAL_THRESHOLD' => '90',
        'MEMORY_WARNING_THRESHOLD' => '80',
        'MEMORY_CRITICAL_THRESHOLD' => '95',
        'HEAP_WARNING_THRESHOLD' => '5000000',
        'HEAP_CRITICAL_THRESHOLD' => '6000000',
        'ERROR_RATE_WARNING_THRESHOLD' => '5',
        'ERROR_RATE_CRITICAL_THRESHOLD' => '10',
        // Stock quantity configuration
        'STOCK_DEFAULT_QUANTITY' => '20',
        'STOCK_AUDIO_001_QUANTITY' => '25',
        'STOCK_AUDIO_002_QUANTITY' => '30',
        'STOCK_COMP_001_QUANTITY' => '15',
        'STOCK_COMP_002_QUANTITY' => '12',
        'STOCK_MOB_001_QUANTITY' => '40',
        'STOCK_MOB_002_QUANTITY' => '35',
        'STOCK_GAM_001_QUANTITY' => '20',
        'STOCK_GAM_002_QUANTITY' => '28',
        'STOCK_NET_001_QUANTITY' => '18',
        'STOCK_NET_002_QUANTITY' => '22',
        'STOCK_PWR_001_QUANTITY' => '45',
        'STOCK_PWR_002_QUANTITY' => '38',
        'STOCK_STO_001_QUANTITY' => '32',
        'STOCK_IOT_001_QUANTITY' => '26',
        'STOCK_IOT_002_QUANTITY' => '50',
        // Environment configuration
        'IS_DEVELOPMENT_ENVIRONMENT' => 'false',
        'SECURITY_LOG_ENABLED' => 'true'
    };
    
    /**
     * @description Gets a configuration value by key
     * @param configKey The configuration key
     * @return String The configuration value
     */
    public static String getConfigValue(String configKey) {
        if (String.isBlank(configKey)) {
            return null;
        }
        
        // Check cache first
        if (CONFIG_CACHE.containsKey(configKey)) {
            return CONFIG_CACHE.get(configKey);
        }
        
        // Check if cache is expired
        if (DateTime.now().addMinutes(-CACHE_DURATION_MINUTES) > CACHE_TIMESTAMP) {
            refreshCache();
        }
        
        // Return from cache or default
        return CONFIG_CACHE.containsKey(configKey) ? CONFIG_CACHE.get(configKey) : DEFAULT_CONFIG.get(configKey);
    }
    
    /**
     * @description Gets a configuration value as integer
     * @param configKey The configuration key
     * @return Integer The configuration value as integer
     */
    public static Integer getConfigValueAsInteger(String configKey) {
        String value = getConfigValue(configKey);
        return value != null ? Integer.valueOf(value) : null;
    }
    
    /**
     * @description Gets a configuration value as boolean
     * @param configKey The configuration key
     * @return Boolean The configuration value as boolean
     */
    public static Boolean getConfigValueAsBoolean(String configKey) {
        String value = getConfigValue(configKey);
        return value != null ? Boolean.valueOf(value) : null;
    }
    
    /**
     * @description Gets a configuration value as decimal
     * @param configKey The configuration key
     * @return Decimal The configuration value as decimal
     */
    public static Decimal getConfigValueAsDecimal(String configKey) {
        String value = getConfigValue(configKey);
        return value != null ? Decimal.valueOf(value) : null;
    }
    
    /**
     * @description Gets the batch size limit for bulk operations
     * @return Integer The batch size limit
     */
    public static Integer getBatchSizeLimit() {
        return getConfigValueAsInteger('BATCH_SIZE_LIMIT');
    }
    
    /**
     * @description Gets the query result limit
     * @return Integer The query result limit
     */
    public static Integer getQueryResultLimit() {
        return getConfigValueAsInteger('QUERY_RESULT_LIMIT');
    }
    
    /**
     * @description Gets the performance warning threshold in milliseconds
     * @return Integer The warning threshold
     */
    public static Integer getPerformanceWarningThreshold() {
        return getConfigValueAsInteger('PERFORMANCE_WARNING_THRESHOLD_MS');
    }
    
    /**
     * @description Gets the performance critical threshold in milliseconds
     * @return Integer The critical threshold
     */
    public static Integer getPerformanceCriticalThreshold() {
        return getConfigValueAsInteger('PERFORMANCE_CRITICAL_THRESHOLD_MS');
    }
    
    /**
     * @description Gets the maximum retry attempts for operations
     * @return Integer The maximum retry attempts
     */
    public static Integer getMaxRetryAttempts() {
        return getConfigValueAsInteger('MAX_RETRY_ATTEMPTS');
    }
    
    /**
     * @description Gets the retry delay in milliseconds
     * @return Integer The retry delay
     */
    public static Integer getRetryDelay() {
        return getConfigValueAsInteger('RETRY_DELAY_MS');
    }
    
    /**
     * @description Checks if security logging is enabled
     * @return Boolean True if security logging is enabled
     */
    public static Boolean isSecurityLoggingEnabled() {
        return getConfigValueAsBoolean('SECURITY_LOG_ENABLED');
    }
    
    /**
     * @description Checks if performance monitoring is enabled
     * @return Boolean True if performance monitoring is enabled
     */
    public static Boolean isPerformanceMonitoringEnabled() {
        return getConfigValueAsBoolean('PERFORMANCE_MONITORING_ENABLED');
    }
    
    /**
     * @description Gets the maximum quantity allowed for cart items
     * @return Integer The maximum cart item quantity
     */
    public static Integer getCartItemMaxQuantity() {
        return getConfigValueAsInteger('CART_ITEM_MAX_QUANTITY');
    }
    
    /**
     * @description Gets the minimum quantity allowed for cart items
     * @return Integer The minimum cart item quantity
     */
    public static Integer getCartItemMinQuantity() {
        return getConfigValueAsInteger('CART_ITEM_MIN_QUANTITY');
    }
    
    /**
     * @description Gets the maximum payment amount allowed
     * @return Decimal The maximum payment amount
     */
    public static Decimal getMaxPaymentAmount() {
        String value = getConfigValue('MAX_PAYMENT_AMOUNT');
        return value != null ? Decimal.valueOf(value) : null;
    }
    
    /**
     * @description Gets the default pricebook ID
     * @return String The default pricebook ID
     */
    public static String getDefaultPricebookId() {
        return getConfigValue('DEFAULT_PRICEBOOK_ID');
    }
    
    /**
     * @description Gets the session timeout in minutes
     * @return Integer The session timeout in minutes
     */
    public static Integer getSessionTimeoutMinutes() {
        return getConfigValueAsInteger('SESSION_TIMEOUT_MINUTES');
    }
    
    /**
     * @description Gets the maximum number of search results
     * @return Integer The maximum search results
     */
    public static Integer getMaxSearchResults() {
        return getConfigValueAsInteger('MAX_SEARCH_RESULTS');
    }
    
    /**
     * @description Gets the cache duration in minutes
     * @return Integer The cache duration in minutes
     */
    public static Integer getCacheDurationMinutes() {
        return getConfigValueAsInteger('CACHE_DURATION_MINUTES');
    }

    /**
     * @description Checks if performance alerts are enabled
     * @return Boolean True if performance alerts are enabled
     */
    public static Boolean isPerformanceAlertEnabled() {
        return getConfigValueAsBoolean('PERFORMANCE_ALERT_ENABLED');
    }

    /**
     * @description Gets the performance metrics retention period in days
     * @return Integer The retention period in days
     */
    public static Integer getPerformanceMetricsRetentionDays() {
        return getConfigValueAsInteger('PERFORMANCE_METRICS_RETENTION_DAYS');
    }

    /**
     * @description Gets the system health check interval in minutes
     * @return Integer The health check interval in minutes
     */
    public static Integer getSystemHealthCheckIntervalMinutes() {
        return getConfigValueAsInteger('SYSTEM_HEALTH_CHECK_INTERVAL_MINUTES');
    }

    /**
     * @description Gets the maximum performance metrics per query
     * @return Integer The maximum metrics per query
     */
    public static Integer getMaxPerformanceMetricsPerQuery() {
        return getConfigValueAsInteger('MAX_PERFORMANCE_METRICS_PER_QUERY');
    }

    /**
     * @description Checks if performance alert emails are enabled
     * @return Boolean True if performance alert emails are enabled
     */
    public static Boolean isPerformanceAlertEmailEnabled() {
        return getConfigValueAsBoolean('PERFORMANCE_ALERT_EMAIL_ENABLED');
    }

    /**
     * @description Checks if performance alert Slack notifications are enabled
     * @return Boolean True if Slack notifications are enabled
     */
    public static Boolean isPerformanceAlertSlackEnabled() {
        return getConfigValueAsBoolean('PERFORMANCE_ALERT_SLACK_ENABLED');
    }
    
    /**
     * @description Refreshes the configuration cache from the database
     */
    private static void refreshCache() {
        try {
            // Clear existing cache
            CONFIG_CACHE.clear();
            
            // Load configurations from database
            List<ENOS_Configuration__c> configs = [
                SELECT Configuration_Key__c, Configuration_Value__c
                FROM ENOS_Configuration__c
                WITH USER_MODE
            ];
            
            // Populate cache
            for (ENOS_Configuration__c config : configs) {
                if (String.isNotBlank(config.Configuration_Key__c) && String.isNotBlank(config.Configuration_Value__c)) {
                    CONFIG_CACHE.put(config.Configuration_Key__c, config.Configuration_Value__c);
                }
            }
            
            // Add default values for missing configurations
            for (String key : DEFAULT_CONFIG.keySet()) {
                if (!CONFIG_CACHE.containsKey(key)) {
                    CONFIG_CACHE.put(key, DEFAULT_CONFIG.get(key));
                }
            }
            
        } catch (Exception e) {
            // If database access fails, use default values
            CONFIG_CACHE.putAll(DEFAULT_CONFIG);
            ENOS_LoggingUtils.error('Error refreshing configuration cache', e);
        }
    }
    
    /**
     * @description Sets a configuration value
     * @param configKey The configuration key
     * @param configValue The configuration value
     */
    public static void setConfigValue(String configKey, String configValue) {
        if (String.isBlank(configKey)) {
            throw new IllegalArgumentException('Configuration key cannot be blank');
        }
        
        try {
            // Check if configuration exists
            List<ENOS_Configuration__c> existingConfigs = [
                SELECT Id, Configuration_Value__c
                FROM ENOS_Configuration__c
                WHERE Configuration_Key__c = :configKey
                WITH USER_MODE
                LIMIT 1
            ];
            
            if (!existingConfigs.isEmpty()) {
                // Update existing configuration
                existingConfigs[0].Configuration_Value__c = configValue;
                update existingConfigs[0];
            } else {
                // Create new configuration
                ENOS_Configuration__c newConfig = new ENOS_Configuration__c(
                    Configuration_Key__c = configKey,
                    Configuration_Value__c = configValue
                );
                insert newConfig;
            }
            
            // Update cache
            CONFIG_CACHE.put(configKey, configValue);
            
        } catch (Exception e) {
            throw new CalloutException('Error setting configuration value: ' + e.getMessage());
        }
    }
    
    /**
     * @description Resets configuration to default values
     */
    public static void resetToDefaults() {
        try {
            // Clear all custom configurations
            List<ENOS_Configuration__c> customConfigs = [
                SELECT Id
                FROM ENOS_Configuration__c
                WITH USER_MODE
            ];
            
            if (!customConfigs.isEmpty()) {
                delete customConfigs;
            }
            
            // Reset cache to defaults
            CONFIG_CACHE.clear();
            CONFIG_CACHE.putAll(DEFAULT_CONFIG);
            
        } catch (Exception e) {
            throw new CalloutException('Error resetting configurations: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // PERFORMANCE MONITORING CONFIGURATION METHODS
    // ============================================================================
    
    /**
     * @description Gets the CPU warning threshold
     * @return Decimal The CPU warning threshold
     */
    public static Decimal getCpuWarningThreshold() {
        return getConfigValueAsDecimal('CPU_WARNING_THRESHOLD');
    }
    
    /**
     * @description Gets the CPU critical threshold
     * @return Decimal The CPU critical threshold
     */
    public static Decimal getCpuCriticalThreshold() {
        return getConfigValueAsDecimal('CPU_CRITICAL_THRESHOLD');
    }
    
    /**
     * @description Gets the memory warning threshold
     * @return Decimal The memory warning threshold
     */
    public static Decimal getMemoryWarningThreshold() {
        return getConfigValueAsDecimal('MEMORY_WARNING_THRESHOLD');
    }
    
    /**
     * @description Gets the memory critical threshold
     * @return Decimal The memory critical threshold
     */
    public static Decimal getMemoryCriticalThreshold() {
        return getConfigValueAsDecimal('MEMORY_CRITICAL_THRESHOLD');
    }
    
    /**
     * @description Gets the heap warning threshold
     * @return Decimal The heap warning threshold
     */
    public static Decimal getHeapWarningThreshold() {
        return getConfigValueAsDecimal('HEAP_WARNING_THRESHOLD');
    }
    
    /**
     * @description Gets the heap critical threshold
     * @return Decimal The heap critical threshold
     */
    public static Decimal getHeapCriticalThreshold() {
        return getConfigValueAsDecimal('HEAP_CRITICAL_THRESHOLD');
    }
    
    /**
     * @description Gets the error rate warning threshold
     * @return Decimal The error rate warning threshold
     */
    public static Decimal getErrorRateWarningThreshold() {
        return getConfigValueAsDecimal('ERROR_RATE_WARNING_THRESHOLD');
    }
    
    /**
     * @description Gets the error rate critical threshold
     * @return Decimal The error rate critical threshold
     */
    public static Decimal getErrorRateCriticalThreshold() {
        return getConfigValueAsDecimal('ERROR_RATE_CRITICAL_THRESHOLD');
    }
    
    // ============================================================================
    // STOCK QUANTITY CONFIGURATION METHODS
    // ============================================================================
    
    /**
     * @description Gets the stock quantity for a specific product code
     * @param productCode The product code
     * @return Integer The stock quantity for the product
     */
    public static Integer getStockQuantity(String productCode) {
        if (String.isBlank(productCode)) {
            return getConfigValueAsInteger('STOCK_DEFAULT_QUANTITY');
        }
        
        String configKey = 'STOCK_' + productCode.replace('-', '_') + '_QUANTITY';
        String value = getConfigValue(configKey);
        return value != null ? Integer.valueOf(value) : getConfigValueAsInteger('STOCK_DEFAULT_QUANTITY');
    }
    
    /**
     * @description Gets the default stock quantity
     * @return Integer The default stock quantity
     */
    public static Integer getDefaultStockQuantity() {
        return getConfigValueAsInteger('STOCK_DEFAULT_QUANTITY');
    }
    
    // ============================================================================
    // ENVIRONMENT CONFIGURATION METHODS
    // ============================================================================
    
    /**
     * @description Checks if the current environment is development
     * @return Boolean True if in development environment
     */
    public static Boolean isDevelopmentEnvironment() {
        return getConfigValueAsBoolean('IS_DEVELOPMENT_ENVIRONMENT');
    }
}
