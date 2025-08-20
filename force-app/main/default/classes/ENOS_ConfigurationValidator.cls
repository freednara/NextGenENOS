/**
 * @description Configuration validation utility for ENOS platform
 * Ensures all configuration values are valid and within acceptable ranges
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_ConfigurationValidator {
    
    // Validation rules for configuration values
    private static final Map<String, Map<String, Object>> VALIDATION_RULES = new Map<String, Map<String, Object>>{
        'BATCH_SIZE_LIMIT' => new Map<String, Object>{
            'min' => 100,
            'max' => 10000,
            'type' => 'Integer',
            'description' => 'Batch size for bulk operations'
        },
        'QUERY_RESULT_LIMIT' => new Map<String, Object>{
            'min' => 1000,
            'max' => 50000,
            'type' => 'Integer',
            'description' => 'Maximum query results'
        },
        'PERFORMANCE_WARNING_THRESHOLD_MS' => new Map<String, Object>{
            'min' => 100,
            'max' => 10000,
            'type' => 'Integer',
            'description' => 'Performance warning threshold'
        },
        'PERFORMANCE_CRITICAL_THRESHOLD_MS' => new Map<String, Object>{
            'min' => 1000,
            'max' => 30000,
            'type' => 'Integer',
            'description' => 'Performance critical threshold'
        },
        'MAX_RETRY_ATTEMPTS' => new Map<String, Object>{
            'min' => 1,
            'max' => 10,
            'type' => 'Integer',
            'description' => 'Maximum retry attempts'
        },
        'RETRY_DELAY_MS' => new Map<String, Object>{
            'min' => 100,
            'max' => 10000,
            'type' => 'Integer',
            'description' => 'Retry delay in milliseconds'
        },
        'CART_ITEM_MAX_QUANTITY' => new Map<String, Object>{
            'min' => 100,
            'max' => 9999,
            'type' => 'Integer',
            'description' => 'Maximum cart item quantity'
        },
        'CART_ITEM_MIN_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 100,
            'type' => 'Integer',
            'description' => 'Minimum cart item quantity'
        },
        'MAX_PAYMENT_AMOUNT' => new Map<String, Object>{
            'min' => 1000.00,
            'max' => 999999.99,
            'type' => 'Decimal',
            'description' => 'Maximum payment amount'
        },
        'SESSION_TIMEOUT_MINUTES' => new Map<String, Object>{
            'min' => 5,
            'max' => 480,
            'type' => 'Integer',
            'description' => 'Session timeout in minutes'
        },
        'MAX_SEARCH_RESULTS' => new Map<String, Object>{
            'min' => 10,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Maximum search results'
        },
        'CACHE_DURATION_MINUTES' => new Map<String, Object>{
            'min' => 1,
            'max' => 1440,
            'type' => 'Integer',
            'description' => 'Cache duration in minutes'
        },
        'PERFORMANCE_ALERT_ENABLED' => new Map<String, Object>{
            'min' => null,
            'max' => null,
            'type' => 'Boolean',
            'description' => 'Enable performance alerts'
        },
        'PERFORMANCE_METRICS_RETENTION_DAYS' => new Map<String, Object>{
            'min' => 1,
            'max' => 365,
            'type' => 'Integer',
            'description' => 'Performance metrics retention period'
        },
        'SYSTEM_HEALTH_CHECK_INTERVAL_MINUTES' => new Map<String, Object>{
            'min' => 1,
            'max' => 60,
            'type' => 'Integer',
            'description' => 'System health check interval'
        },
        'MAX_PERFORMANCE_METRICS_PER_QUERY' => new Map<String, Object>{
            'min' => 100,
            'max' => 10000,
            'type' => 'Integer',
            'description' => 'Maximum performance metrics per query'
        },
        'PERFORMANCE_ALERT_EMAIL_ENABLED' => new Map<String, Object>{
            'min' => null,
            'max' => null,
            'type' => 'Boolean',
            'description' => 'Enable performance alert emails'
        },
        'PERFORMANCE_ALERT_SLACK_ENABLED' => new Map<String, Object>{
            'min' => null,
            'max' => null,
            'type' => 'Boolean',
            'description' => 'Enable performance alert Slack notifications'
        },
        // Performance monitoring thresholds
        'CPU_WARNING_THRESHOLD' => new Map<String, Object>{
            'min' => 50,
            'max' => 90,
            'type' => 'Decimal',
            'description' => 'CPU usage warning threshold'
        },
        'CPU_CRITICAL_THRESHOLD' => new Map<String, Object>{
            'min' => 70,
            'max' => 100,
            'type' => 'Decimal',
            'description' => 'CPU usage critical threshold'
        },
        'MEMORY_WARNING_THRESHOLD' => new Map<String, Object>{
            'min' => 60,
            'max' => 95,
            'type' => 'Decimal',
            'description' => 'Memory usage warning threshold'
        },
        'MEMORY_CRITICAL_THRESHOLD' => new Map<String, Object>{
            'min' => 80,
            'max' => 100,
            'type' => 'Decimal',
            'description' => 'Memory usage critical threshold'
        },
        'HEAP_WARNING_THRESHOLD' => new Map<String, Object>{
            'min' => 3000000,
            'max' => 8000000,
            'type' => 'Decimal',
            'description' => 'Heap size warning threshold'
        },
        'HEAP_CRITICAL_THRESHOLD' => new Map<String, Object>{
            'min' => 5000000,
            'max' => 10000000,
            'type' => 'Decimal',
            'description' => 'Heap size critical threshold'
        },
        'ERROR_RATE_WARNING_THRESHOLD' => new Map<String, Object>{
            'min' => 1,
            'max' => 20,
            'type' => 'Decimal',
            'description' => 'Error rate warning threshold'
        },
        'ERROR_RATE_CRITICAL_THRESHOLD' => new Map<String, Object>{
            'min' => 5,
            'max' => 50,
            'type' => 'Decimal',
            'description' => 'Error rate critical threshold'
        },
        // Stock quantity configuration
        'STOCK_DEFAULT_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Default stock quantity for products'
        },
        'STOCK_AUDIO_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for AUD-001 product'
        },
        'STOCK_AUDIO_002_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for AUD-002 product'
        },
        'STOCK_COMP_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for COMP-001 product'
        },
        'STOCK_COMP_002_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for COMP-002 product'
        },
        'STOCK_MOB_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for MOB-001 product'
        },
        'STOCK_MOB_002_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for MOB-002 product'
        },
        'STOCK_GAM_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for GAM-001 product'
        },
        'STOCK_GAM_002_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for GAM-002 product'
        },
        'STOCK_NET_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for NET-001 product'
        },
        'STOCK_NET_002_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for NET-002 product'
        },
        'STOCK_PWR_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for PWR-001 product'
        },
        'STOCK_PWR_002_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for PWR-002 product'
        },
        'STOCK_STO_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for STO-001 product'
        },
        'STOCK_IOT_001_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for IOT-001 product'
        },
        'STOCK_IOT_002_QUANTITY' => new Map<String, Object>{
            'min' => 1,
            'max' => 1000,
            'type' => 'Integer',
            'description' => 'Stock quantity for IOT-002 product'
        },
        // Environment configuration
        'IS_DEVELOPMENT_ENVIRONMENT' => new Map<String, Object>{
            'min' => null,
            'max' => null,
            'type' => 'Boolean',
            'description' => 'Development environment flag'
        },
        'SECURITY_LOG_ENABLED' => new Map<String, Object>{
            'min' => null,
            'max' => null,
            'type' => 'Boolean',
            'description' => 'Enable security logging'
        }
    };

    /**
     * @description Validates all configuration values
     * @return Map<String, Object> Validation results with status and issues
     */
    public static Map<String, Object> validateAllConfigurations() {
        Map<String, Object> results = new Map<String, Object>();
        List<String> issues = new List<String>();
        List<String> warnings = new List<String>();
        Integer validCount = 0;
        Integer totalCount = 0;

        for (String configKey : VALIDATION_RULES.keySet()) {
            totalCount++;
            Map<String, Object> rule = VALIDATION_RULES.get(configKey);
            String validationResult = validateConfiguration(configKey, rule);
            
            if (validationResult == 'VALID') {
                validCount++;
            } else if (validationResult == 'WARNING') {
                warnings.add(configKey + ': ' + rule.get('description'));
            } else {
                issues.add(configKey + ': ' + rule.get('description'));
            }
        }

        results.put('status', issues.isEmpty() ? 'VALID' : 'INVALID');
        results.put('validCount', validCount);
        results.put('totalCount', totalCount);
        results.put('issues', issues);
        results.put('warnings', warnings);
        results.put('timestamp', DateTime.now());

        return results;
    }

    /**
     * @description Validates a specific configuration value
     * @param configKey The configuration key to validate
     * @param rule The validation rule for this configuration
     * @return String Validation result: 'VALID', 'WARNING', or 'INVALID'
     */
    private static String validateConfiguration(String configKey, Map<String, Object> rule) {
        try {
            String type = (String) rule.get('type');
            Object value = getConfigurationValue(configKey, type);
            
            if (value == null) {
                return 'WARNING'; // Missing configuration, use default
            }

            // Type validation
            if (!isValidType(value, type)) {
                return 'INVALID';
            }

            // Range validation
            if (type == 'Integer') {
                Integer intValue = (Integer) value;
                Integer min = (Integer) rule.get('min');
                Integer max = (Integer) rule.get('max');
                
                if (intValue < min || intValue > max) {
                    return 'INVALID';
                }
            } else if (rule.get('type') == 'Decimal') {
                Decimal decValue = (Decimal) value;
                Decimal min = (Decimal) rule.get('min');
                Decimal max = (Decimal) rule.get('max');
                
                if (decValue < min || decValue > max) {
                    return 'INVALID';
                }
            }

            return 'VALID';

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error validating configuration ' + configKey + ': ' + e.getMessage());
            return 'INVALID';
        }
    }

    /**
     * @description Gets the configuration value with proper type casting
     * @param configKey The configuration key
     * @param type The expected type
     * @return Object The configuration value
     */
    private static Object getConfigurationValue(String configKey, String type) {
        if (type == 'Integer') {
            return ENOS_ConfigurationUtils.getConfigValueAsInteger(configKey);
        } else if (type == 'Decimal') {
            return ENOS_ConfigurationUtils.getConfigValueAsDecimal(configKey);
        } else if (type == 'Boolean') {
            return ENOS_ConfigurationUtils.getConfigValueAsBoolean(configKey);
        } else {
            return ENOS_ConfigurationUtils.getConfigValue(configKey);
        }
    }

    /**
     * @description Checks if a value is of the expected type
     * @param value The value to check
     * @param expectedType The expected type
     * @return Boolean True if the type matches
     */
    private static Boolean isValidType(Object value, String expectedType) {
        if (value == null) return false;
        
        if (expectedType == 'Integer') {
            return value instanceof Integer;
        } else if (expectedType == 'Decimal') {
            return value instanceof Decimal;
        } else if (expectedType == 'Boolean') {
            return value instanceof Boolean;
        } else if (expectedType == 'String') {
            return value instanceof String;
        }
        
        return false;
    }

    /**
     * @description Gets configuration recommendations based on validation results
     * @param validationResults The validation results
     * @return List<String> List of recommendations
     */
    public static List<String> getConfigurationRecommendations(Map<String, Object> validationResults) {
        List<String> recommendations = new List<String>();
        
        if (validationResults.get('status') == 'VALID') {
            recommendations.add('All configurations are valid. No changes needed.');
            return recommendations;
        }

        List<String> issues = (List<String>) validationResults.get('issues');
        List<String> warnings = (List<String>) validationResults.get('warnings');

        if (!issues.isEmpty()) {
            recommendations.add('Critical issues found. Please review and fix:');
            for (String issue : issues) {
                recommendations.add('- ' + issue);
            }
        }

        if (!warnings.isEmpty()) {
            recommendations.add('Warnings found. Consider reviewing:');
            for (String warning : warnings) {
                recommendations.add('- ' + warning);
            }
        }

        recommendations.add('Use ENOS_ConfigurationUtils.setConfigValue() to update configurations.');
        recommendations.add('Consider using ENOS_Configuration__c custom object for persistent storage.');

        return recommendations;
    }

    /**
     * @description Logs configuration validation results
     * @param validationResults The validation results to log
     */
    public static void logValidationResults(Map<String, Object> validationResults) {
        if (ENOS_LoggingUtils.isLoggingEnabled()) {
            String status = (String) validationResults.get('status');
            Integer validCount = (Integer) validationResults.get('validCount');
            Integer totalCount = (Integer) validationResults.get('totalCount');
            
            ENOS_LoggingUtils.logInfo('Configuration Validation', 
                'Status: ' + status + ', Valid: ' + validCount + '/' + totalCount);
            
            List<String> issues = (List<String>) validationResults.get('issues');
            if (!issues.isEmpty()) {
                for (String issue : issues) {
                    ENOS_LoggingUtils.logWarning('Configuration Validation', issue);
                }
            }
        }
    }
}
