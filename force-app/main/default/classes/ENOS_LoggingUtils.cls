/**
 * @description Logging utility class for ENOS e-commerce platform
 * Provides structured logging with configurable levels and consistent formatting
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_LoggingUtils {
    
    // Configuration for logging levels
    private static final Boolean LOGGING_ENABLED = ENOS_ConfigurationUtils.getConfigValueAsBoolean('SECURITY_LOG_ENABLED');
    private static final Boolean PERFORMANCE_LOGGING_ENABLED = ENOS_ConfigurationUtils.getConfigValueAsBoolean('PERFORMANCE_MONITORING_ENABLED');
    
    /**
     * @description Logs successful operations with consistent formatting
     * @param operation The operation being logged (e.g., 'Cart Item Added', 'Order Created')
     * @param details Additional details about the operation
     */
    public static void logSuccess(String operation, String details) {
        if (LOGGING_ENABLED) {
            System.debug('SUCCESS [' + operation + ']: ' + details);
        }
    }
    
    /**
     * @description Logs successful operations with record ID
     * @param operation The operation being logged
     * @param recordId The ID of the record affected
     * @param details Additional details about the operation
     */
    public static void logSuccess(String operation, Id recordId, String details) {
        if (LOGGING_ENABLED) {
            System.debug('SUCCESS [' + operation + '] Record: ' + recordId + ' - ' + details);
        }
    }
    
    /**
     * @description Logs error conditions with consistent formatting
     * @param operation The operation where the error occurred
     * @param error The error message or exception
     */
    public static void logError(String operation, String error) {
        if (LOGGING_ENABLED) {
            System.debug(LoggingLevel.ERROR, 'ERROR [' + operation + ']: ' + error);
        }
    }
    
    /**
     * @description Logs error conditions with exception details
     * @param operation The operation where the error occurred
     * @param e The exception that occurred
     */
    public static void logError(String operation, Exception e) {
        if (LOGGING_ENABLED) {
            System.debug(LoggingLevel.ERROR, 'ERROR [' + operation + ']: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Logs warning conditions
     * @param operation The operation where the warning occurred
     * @param warning The warning message
     */
    public static void logWarning(String operation, String warning) {
        if (LOGGING_ENABLED) {
            System.debug(LoggingLevel.WARN, 'WARNING [' + operation + ']: ' + warning);
        }
    }
    
    /**
     * @description Logs informational messages
     * @param operation The operation being logged
     * @param info The informational message
     */
    public static void logInfo(String operation, String info) {
        if (LOGGING_ENABLED) {
            System.debug(LoggingLevel.INFO, 'INFO [' + operation + ']: ' + info);
        }
    }
    
    /**
     * @description Logs performance metrics
     * @param operation The operation being measured
     * @param metric The metric name
     * @param value The metric value
     * @param unit The unit of measurement
     */
    public static void logPerformance(String operation, String metric, Decimal value, String unit) {
        if (PERFORMANCE_LOGGING_ENABLED) {
            System.debug(LoggingLevel.INFO, 'PERFORMANCE [' + operation + '] ' + metric + ': ' + value + ' ' + unit);
        }
    }
    
    /**
     * @description Logs security-related events
     * @param operation The operation being logged
     * @param event The security event (e.g., 'Permission Check', 'Access Denied')
     * @param details Additional security details
     */
    public static void logSecurity(String operation, String event, String details) {
        if (LOGGING_ENABLED) {
            System.debug(LoggingLevel.INFO, 'SECURITY [' + operation + '] ' + event + ': ' + details);
        }
    }
    
    /**
     * @description Logs business logic events
     * @param operation The operation being logged
     * @param event The business event (e.g., 'Cart Updated', 'Payment Processed')
     * @param details Additional business details
     */
    public static void logBusiness(String operation, String event, String details) {
        if (LOGGING_ENABLED) {
            System.debug(LoggingLevel.INFO, 'BUSINESS [' + operation + '] ' + event + ': ' + details);
        }
    }
    
    /**
     * @description Checks if logging is enabled for the current context
     * @return Boolean indicating if logging is enabled
     */
    public static Boolean isLoggingEnabled() {
        return LOGGING_ENABLED;
    }
    
    /**
     * @description Checks if performance logging is enabled
     * @return Boolean indicating if performance logging is enabled
     */
    public static Boolean isPerformanceLoggingEnabled() {
        return PERFORMANCE_LOGGING_ENABLED;
    }
}
