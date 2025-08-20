/**
 * @description Centralized exception handling utility for ENOS platform
 * Eliminates duplicative exception handling code across all classes
 * @author ENOS Development Team
 * @version 1.0.0
 */
public with sharing class ENOS_ExceptionUtils {
    
    // ============================================================================
    // OPERATION FAILURE EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws CalloutException for operation failures with consistent messaging
     * @param operation The operation that failed (e.g., 'generate sales analytics', 'process order')
     * @param e The exception that occurred
     * @throws CalloutException with user-friendly message
     */
    public static void throwOperationFailure(String operation, Exception e) {
        String message = 'Failed to ' + operation + ': ' + e.getMessage();
        throw new CalloutException(message);
    }
    
    /**
     * @description Throws CalloutException for operation failures without exception details
     * @param operation The operation that failed
     * @param details Additional details about the failure
     * @throws CalloutException with user-friendly message
     */
    public static void throwOperationFailure(String operation, String details) {
        String message = 'Failed to ' + operation + ': ' + details;
        throw new CalloutException(message);
    }
    
    /**
     * @description Throws CalloutException for missing required data
     * @param fieldName The name of the missing field
     * @throws CalloutException with user-friendly message
     */
    public static void throwMissingData(String fieldName) {
        throw new CalloutException('Missing required data: ' + fieldName);
    }
    
    /**
     * @description Throws CalloutException for invalid data
     * @param fieldName The name of the invalid field
     * @param validationRule The validation rule that failed
     * @throws CalloutException with user-friendly message
     */
    public static void throwInvalidData(String fieldName, String validationRule) {
        throw new CalloutException('Invalid data for ' + fieldName + ': ' + validationRule);
    }
    
    /**
     * @description Throws CalloutException for access denied scenarios
     * @param resource The resource access was denied to
     * @param operation The operation that was denied
     * @throws CalloutException with user-friendly message
     */
    public static void throwAccessDenied(String resource, String operation) {
        throw new CalloutException('Access denied: Cannot ' + operation + ' ' + resource);
    }
    
    // ============================================================================
    // SECURITY EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws CalloutException for security violations
     * @param violationType The type of security violation
     * @param details Additional security details
     * @throws CalloutException with security-focused message
     */
    public static void throwSecurityViolation(String violationType, String details) {
        String message = 'Security Error: ' + violationType + ' - ' + details;
        throw new CalloutException(message);
    }
    
    /**
     * @description Throws CalloutException for injection attempts
     * @param injectionType The type of injection attempted
     * @throws CalloutException with security-focused message
     */
    public static void throwInjectionAttempt(String injectionType) {
        throw new CalloutException('Security Error: ' + injectionType + ' injection detected');
    }
    
    /**
     * @description Throws CalloutException for permission issues
     * @param operation The operation that requires permission
     * @throws CalloutException with user-friendly message
     */
    public static void throwPermissionDenied(String operation) {
        throw new CalloutException('You do not have permission to perform this action. Please contact your administrator.');
    }
    
    // ============================================================================
    // VALIDATION EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws CalloutException for validation failures
     * @param fieldName The field that failed validation
     * @param validationRule The validation rule description
     * @throws CalloutException with validation-focused message
     */
    public static void throwValidationFailure(String fieldName, String validationRule) {
        String message = 'Validation failed for ' + fieldName + ': ' + validationRule;
        throw new CalloutException(message);
    }
    
    /**
     * @description Throws CalloutException for business rule violations
     * @param ruleName The business rule that was violated
     * @param details Additional details about the violation
     * @throws CalloutException with business-focused message
     */
    public static void throwBusinessRuleViolation(String ruleName, String details) {
        String message = 'Business rule violation: ' + ruleName + ' - ' + details;
        throw new CalloutException(message);
    }
    
    // ============================================================================
    // SYSTEM EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws CalloutException for system errors
     * @param component The system component that failed
     * @param e The system exception
     * @throws CalloutException with system-focused message
     */
    public static void throwSystemError(String component, Exception e) {
        String message = 'System error in ' + component + ': ' + e.getMessage();
        throw new CalloutException(message);
    }
    
    /**
     * @description Throws CalloutException for unexpected errors
     * @param operation The operation where the error occurred
     * @throws CalloutException with generic error message
     */
    public static void throwUnexpectedError(String operation) {
        throw new CalloutException('We hit an unexpected error while ' + operation + '. Please try again later.');
    }
    
    /**
     * @description Throws CalloutException for service unavailability
     * @param service The service that is unavailable
     * @throws CalloutException with service-focused message
     */
    public static void throwServiceUnavailable(String service) {
        throw new CalloutException('The ' + service + ' service is currently unavailable. Please try again later.');
    }
    
    // ============================================================================
    // DATA EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws CalloutException for data not found scenarios
     * @param dataType The type of data that was not found
     * @param identifier The identifier used to search for the data
     * @throws CalloutException with data-focused message
     */
    public static void throwDataNotFound(String dataType, String identifier) {
        throw new CalloutException(dataType + ' not found: ' + identifier);
    }
    
    /**
     * @description Throws CalloutException for data integrity issues
     * @param issue The data integrity issue description
     * @throws CalloutException with data-focused message
     */
    public static void throwDataIntegrityIssue(String issue) {
        throw new CalloutException('Data integrity issue: ' + issue);
    }
    
    // ============================================================================
    // QUERY EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws CalloutException for query failures
     * @param queryType The type of query that failed
     * @param e The query exception
     * @throws CalloutException with query-focused message
     */
    public static void throwQueryFailure(String queryType, Exception e) {
        String message = 'Query failed for ' + queryType + ': ' + e.getMessage();
        throw new CalloutException(message);
    }
    
    /**
     * @description Throws CalloutException for invalid query patterns
     * @param pattern The invalid pattern detected
     * @throws CalloutException with query-focused message
     */
    public static void throwInvalidQueryPattern(String pattern) {
        throw new CalloutException('Invalid query: ' + pattern + ' is not allowed');
    }
    
    // ============================================================================
    // CONFIGURATION EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws AuraHandledException for configuration errors
     * @param configKey The configuration key that caused the error
     * @param e The configuration exception
     * @throws AuraHandledException with configuration-focused message
     */
    public static void throwConfigurationError(String configKey, Exception e) {
        String message = 'Configuration error for ' + configKey + ': ' + e.getMessage();
        throw new CalloutException(message);
    }
    
    /**
     * @description Throws AuraHandledException for missing configuration
     * @param configKey The missing configuration key
     * @throws AuraHandledException with configuration-focused message
     */
    public static void throwMissingConfiguration(String configKey) {
        throw new CalloutException('Missing configuration: ' + configKey + ' is required');
    }
    
    // ============================================================================
    // RETRY EXCEPTIONS
    // ============================================================================
    
    /**
     * @description Throws AuraHandledException for retry exhaustion
     * @param operation The operation that failed after retries
     * @param maxRetries The maximum number of retries attempted
     * @param lastException The last exception that occurred
     * @throws AuraHandledException with retry-focused message
     */
    public static void throwRetryExhausted(String operation, Integer maxRetries, Exception lastException) {
        String message = 'Operation failed after ' + maxRetries + ' retries: ' + lastException.getMessage();
        throw new CalloutException(message);
    }
    
    // ============================================================================
    // UTILITY METHODS
    // ============================================================================
    
    /**
     * @description Safely throws an exception, handling null cases
     * @param exception The exception to throw, or null for generic message
     * @param defaultMessage The default message if exception is null
     * @throws AuraHandledException with appropriate message
     */
    public static void throwSafely(Exception ex, String defaultMessage) {
        if (ex != null) {
            throw new CalloutException(ex.getMessage());
        } else {
            throw new CalloutException(defaultMessage);
        }
    }
    
    /**
     * @description Logs the exception before throwing (for debugging)
     * @param operation The operation where the exception occurred
     * @param e The exception to log
     * @param userMessage The user-friendly message to throw
     * @throws AuraHandledException with user-friendly message
     */
    public static void logAndThrow(String operation, Exception e, String userMessage) {
        // Log the actual exception for debugging
        System.debug(LoggingLevel.ERROR, 'Exception in ' + operation + ': ' + e.getMessage());
        System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        
        // Throw user-friendly message
        throw new CalloutException(userMessage);
    }
}
