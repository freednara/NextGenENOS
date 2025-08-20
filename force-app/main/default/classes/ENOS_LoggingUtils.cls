/**
 * @description Centralized logging utility for ENOS platform
 * Provides environment-based conditional logging and consistent logging patterns
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_LoggingUtils {
    
    // Environment flags for conditional logging
    private static final Boolean IS_DEBUG_ENABLED = true; // Default to true for development
    private static final Boolean IS_DEVELOPMENT = false; // Default to false, can be overridden via configuration
    private static final Boolean IS_TEST_CONTEXT = Test.isRunningTest();
    
    // Logging levels for different environments
    private static final Boolean LOG_DEBUG = IS_DEBUG_ENABLED && (IS_DEVELOPMENT || IS_TEST_CONTEXT);
    private static final Boolean LOG_INFO = IS_DEVELOPMENT || IS_TEST_CONTEXT;
    private static final Boolean LOG_WARN = true; // Always log warnings
    private static final Boolean LOG_ERROR = true; // Always log errors
    
    // ============================================================================
    // DEBUG LEVEL LOGGING
    // ============================================================================
    
    /**
     * @description Logs debug messages only in development/test environments with debug enabled
     * @param message The debug message to log
     */
    public static void debug(String message) {
        if (LOG_DEBUG && String.isNotBlank(message)) {
            System.debug(LoggingLevel.DEBUG, formatMessage('DEBUG', message));
        }
    }
    
    /**
     * @description Logs debug messages with additional context
     * @param message The debug message to log
     * @param context Additional context information
     */
    public static void debug(String message, String context) {
        if (LOG_DEBUG && String.isNotBlank(message)) {
            String fullMessage = String.isNotBlank(context) ? 
                formatMessage('DEBUG', message + ' | Context: ' + context) : 
                formatMessage('DEBUG', message);
            System.debug(LoggingLevel.DEBUG, fullMessage);
        }
    }
    
    /**
     * @description Logs debug messages with exception details
     * @param message The debug message to log
     * @param e The exception to log details for
     */
    public static void debug(String message, Exception e) {
        if (LOG_DEBUG && String.isNotBlank(message)) {
            String fullMessage = formatMessage('DEBUG', message + ' | Exception: ' + e.getMessage());
            System.debug(LoggingLevel.DEBUG, fullMessage);
        }
    }
    
    // ============================================================================
    // INFO LEVEL LOGGING
    // ============================================================================
    
    /**
     * @description Logs info messages in development/test environments
     * @param message The info message to log
     */
    public static void info(String message) {
        if (LOG_INFO && String.isNotBlank(message)) {
            System.debug(LoggingLevel.INFO, formatMessage('INFO', message));
        }
    }
    
    /**
     * @description Logs info messages with additional context
     * @param message The info message to log
     * @param context Additional context information
     */
    public static void info(String message, String context) {
        if (LOG_INFO && String.isNotBlank(message)) {
            String fullMessage = String.isNotBlank(context) ? 
                formatMessage('INFO', message + ' | Context: ' + context) : 
                formatMessage('INFO', message);
            System.debug(LoggingLevel.INFO, fullMessage);
        }
    }
    
    /**
     * @description Logs info messages with operation timing
     * @param message The info message to log
     * @param startTime The start time of the operation
     */
    public static void info(String message, Long startTime) {
        if (LOG_INFO && String.isNotBlank(message)) {
            Long duration = System.currentTimeMillis() - startTime;
            String fullMessage = formatMessage('INFO', message + ' | Duration: ' + duration + 'ms');
            System.debug(LoggingLevel.INFO, fullMessage);
        }
    }
    
    // ============================================================================
    // WARNING LEVEL LOGGING
    // ============================================================================
    
    /**
     * @description Logs warning messages (always logged)
     * @param message The warning message to log
     */
    public static void warn(String message) {
        if (String.isNotBlank(message)) {
            System.debug(LoggingLevel.WARN, formatMessage('WARN', message));
        }
    }
    
    /**
     * @description Logs warning messages with additional context
     * @param message The warning message to log
     * @param context Additional context information
     */
    public static void warn(String message, String context) {
        if (String.isNotBlank(message)) {
            String fullMessage = String.isNotBlank(context) ? 
                formatMessage('WARN', message + ' | Context: ' + context) : 
                formatMessage('WARN', message);
            System.debug(LoggingLevel.WARN, fullMessage);
        }
    }
    
    /**
     * @description Logs warning messages with performance threshold information
     * @param message The warning message to log
     * @param value The current value that triggered the warning
     * @param threshold The threshold value
     */
    public static void warn(String message, Decimal value, Decimal threshold) {
        if (String.isNotBlank(message)) {
            String fullMessage = formatMessage('WARN', message + ' | Value: ' + value + ' | Threshold: ' + threshold);
            System.debug(LoggingLevel.WARN, fullMessage);
        }
    }
    
    // ============================================================================
    // ERROR LEVEL LOGGING
    // ============================================================================
    
    /**
     * @description Logs error messages (always logged)
     * @param message The error message to log
     */
    public static void error(String message) {
        if (String.isNotBlank(message)) {
            System.debug(LoggingLevel.ERROR, formatMessage('ERROR', message));
        }
    }
    
    /**
     * @description Logs error messages with additional context
     * @param message The error message to log
     * @param context Additional context information
     */
    public static void error(String message, String context) {
        if (String.isNotBlank(message)) {
            String fullMessage = String.isNotBlank(context) ? 
                formatMessage('ERROR', message + ' | Context: ' + context) : 
                formatMessage('ERROR', message);
            System.debug(LoggingLevel.ERROR, fullMessage);
        }
    }
    
    /**
     * @description Logs error messages with exception details
     * @param message The error message to log
     * @param e The exception to log details for
     */
    public static void error(String message, Exception e) {
        if (String.isNotBlank(message)) {
            String fullMessage = formatMessage('ERROR', message + ' | Exception: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, fullMessage);
            
            // Also log stack trace for debugging
            if (LOG_DEBUG && e.getStackTraceString() != null) {
                System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
            }
        }
    }
    
    /**
     * @description Logs error messages with exception and context
     * @param message The error message to log
     * @param e The exception to log details for
     * @param context Additional context information
     */
    public static void error(String message, Exception e, String context) {
        if (String.isNotBlank(message)) {
            String fullMessage = formatMessage('ERROR', message + ' | Exception: ' + e.getMessage());
            if (String.isNotBlank(context)) {
                fullMessage += ' | Context: ' + context;
            }
            System.debug(LoggingLevel.ERROR, fullMessage);
            
            // Also log stack trace for debugging
            if (LOG_DEBUG && e.getStackTraceString() != null) {
                System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
            }
        }
    }
    
    /**
     * @description Logs error messages with exception details (alias for error method)
     * @param message The error message to log
     * @param e The exception to log details for
     */
    public static void logError(String message, Exception e) {
        error(message, e);
    }
    
    // ============================================================================
    // PERFORMANCE LOGGING
    // ============================================================================
    
    /**
     * @description Logs performance information for operations
     * @param operation The operation being performed
     * @param startTime The start time of the operation
     * @param context Additional context information
     */
    public static void logPerformance(String operation, Long startTime, String context) {
        if (LOG_INFO && String.isNotBlank(operation)) {
            Long duration = System.currentTimeMillis() - startTime;
            String message = 'Performance: ' + operation + ' | Duration: ' + duration + 'ms';
            
            // Log as warning if performance exceeds thresholds
            Integer warningThreshold = ENOS_ConfigurationUtils.getPerformanceWarningThreshold();
            Integer criticalThreshold = ENOS_ConfigurationUtils.getPerformanceCriticalThreshold();
            
            if (duration > criticalThreshold) {
                warn(message + ' | CRITICAL', context);
            } else if (duration > warningThreshold) {
                warn(message + ' | WARNING', context);
            } else {
                info(message, context);
            }
        }
    }
    
    /**
     * @description Logs performance information for operations
     * @param operation The operation being performed
     * @param startTime The start time of the operation
     */
    public static void logPerformance(String operation, Long startTime) {
        if (LOG_INFO && String.isNotBlank(operation)) {
            Long duration = System.currentTimeMillis() - startTime;
            String message = 'Performance: ' + operation + ' | Duration: ' + duration + 'ms';
            info(message);
        }
    }
    
    /**
     * @description Logs performance information with custom thresholds
     * @param operation The operation being performed
     * @param startTime The start time of the operation
     * @param threshold The threshold value for performance warning
     */
    public static void logPerformance(String operation, Long startTime, Integer threshold) {
        if (LOG_INFO && String.isNotBlank(operation)) {
            Long duration = System.currentTimeMillis() - startTime;
            String message = 'Performance: ' + operation + ' | Duration: ' + duration + 'ms';
            
            // Log as warning if performance exceeds custom threshold
            if (threshold != null && duration > threshold) {
                warn(message + ' | WARNING', 'Custom threshold: ' + threshold + 'ms');
            } else {
                info(message);
            }
        }
    }
    
    /**
     * @description Logs performance information with custom thresholds and context
     * @param operation The operation being performed
     * @param startTime The start time of the operation
     * @param threshold The threshold value for performance warning
     * @param context Additional context information
     */
    public static void logPerformance(String operation, Long startTime, Integer threshold, String context) {
        if (LOG_INFO && String.isNotBlank(operation)) {
            Long duration = System.currentTimeMillis() - startTime;
            String message = 'Performance: ' + operation + ' | Duration: ' + duration + 'ms';
            
            // Log as warning if performance exceeds custom threshold
            if (threshold != null && duration > threshold) {
                warn(message + ' | WARNING', context + ' | Custom threshold: ' + threshold + 'ms');
            } else {
                info(message, context);
            }
        }
    }
    
    /**
     * @description Logs performance information with operation and context
     * @param operation The operation being performed
     * @param context The context information
     * @param startTime The start time of the operation
     * @param additionalContext Additional context information
     */
    public static void logPerformance(String operation, String context, Long startTime, String additionalContext) {
        if (LOG_INFO && String.isNotBlank(operation)) {
            Long duration = System.currentTimeMillis() - startTime;
            String message = 'Performance: ' + operation + ' | Duration: ' + duration + 'ms';
            String fullContext = String.isNotBlank(context) ? context : '';
            if (String.isNotBlank(additionalContext)) {
                fullContext += ' | ' + additionalContext;
            }
            info(message, fullContext);
        }
    }
    
    /**
     * @description Logs performance information with operation, context, and threshold
     * @param operation The operation being performed
     * @param context The context information
     * @param threshold The threshold value for performance warning
     * @param additionalContext Additional context information
     */
    public static void logPerformance(String operation, String context, Integer threshold, String additionalContext) {
        if (LOG_INFO && String.isNotBlank(operation)) {
            String message = 'Performance: ' + operation;
            String fullContext = String.isNotBlank(context) ? context : '';
            if (String.isNotBlank(additionalContext)) {
                fullContext += ' | ' + additionalContext;
            }
            if (threshold != null) {
                message += ' | Threshold: ' + threshold;
            }
            info(message, fullContext);
        }
    }
    
    // ============================================================================
    // SECURITY LOGGING
    // ============================================================================
    
    /**
     * @description Logs security-related information
     * @param message The security message to log
     * @param context Additional context information
     */
    public static void logSecurity(String message, String context) {
        // Default to true for security logging
        String fullMessage = 'SECURITY: ' + message;
        if (String.isNotBlank(context)) {
            fullMessage += ' | Context: ' + context;
        }
        System.debug(LoggingLevel.WARN, fullMessage);
    }
    
    /**
     * @description Logs security-related information
     * @param message The security message to log
     */
    public static void logSecurity(String message) {
        logSecurity(message, null);
    }
    
    // ============================================================================
    // BUSINESS LOGIC LOGGING
    // ============================================================================
    
    /**
     * @description Logs business logic events
     * @param event The business event being logged
     * @param details Additional details about the event
     */
    public static void logBusinessEvent(String event, String details) {
        if (LOG_INFO && String.isNotBlank(event)) {
            String message = 'BUSINESS EVENT: ' + event;
            if (String.isNotBlank(details)) {
                message += ' | Details: ' + details;
            }
            System.debug(LoggingLevel.INFO, message);
        }
    }
    
    /**
     * @description Logs business logic events
     * @param event The business event being logged
     */
    public static void logBusinessEvent(String message) {
        logBusinessEvent(message, null);
    }
    
    /**
     * @description Logs info messages (alias for info method)
     * @param message The info message to log
     * @param context Additional context information
     */
    public static void logInfo(String message, String context) {
        info(message, context);
    }
    
    /**
     * @description Logs warning messages (alias for warn method)
     * @param message The warning message to log
     * @param context Additional context information
     */
    public static void logWarning(String message, String context) {
        warn(message, context);
    }
    
    /**
     * @description Checks if logging is enabled for the current environment
     * @return Boolean indicating if logging is enabled
     */
    public static Boolean isLoggingEnabled() {
        return LOG_INFO || LOG_WARN || LOG_ERROR;
    }
    
    // ============================================================================
    // UTILITY METHODS
    // ============================================================================
    
    /**
     * @description Formats log messages with consistent structure
     * @param level The log level
     * @param message The message to format
     * @return String The formatted message
     */
    private static String formatMessage(String level, String message) {
        String timestamp = DateTime.now().format('yyyy-MM-dd HH:mm:ss.SSS');
        String userId = UserInfo.getUserId();
        String orgId = UserInfo.getOrganizationId();
        
        return String.format('[{0}] [{1}] [{2}] [{3}] {4}', 
            new List<String>{timestamp, level, userId, orgId, message});
    }
    
    /**
     * @description Checks if debug logging is enabled
     * @return Boolean True if debug logging is enabled
     */
    public static Boolean isDebugEnabled() {
        return LOG_DEBUG;
    }
    
    /**
     * @description Checks if info logging is enabled
     * @return Boolean True if info logging is enabled
     */
    public static Boolean isInfoEnabled() {
        return LOG_INFO;
    }
    
    /**
     * @description Checks if the current environment is development
     * @return Boolean True if in development environment
     */
    public static Boolean isDevelopmentEnvironment() {
        return IS_DEVELOPMENT;
    }
    
    /**
     * @description Checks if running in test context
     * @return Boolean True if running in test context
     */
    public static Boolean isTestContext() {
        return IS_TEST_CONTEXT;
    }
    
    // ============================================================================
    // LEGACY SUPPORT METHODS
    // ============================================================================
    
    /**
     * @description Legacy method for backward compatibility
     * @param message The message to log
     */
    public static void log(String message) {
        info(message);
    }
    
    /**
     * @description Legacy method for backward compatibility
     * @param message The message to log
     * @param level The log level
     */
    public static void log(String message, LoggingLevel level) {
        switch on level {
            when DEBUG { debug(message); }
            when INFO { info(message); }
            when WARN { warn(message); }
            when ERROR { error(message); }
            when else { info(message); }
        }
    }
}

