/**
 * @description Security utility class for StoreConnect application
 * @author StoreConnect Development Team
 * @version 1.1.0
 * @since 2024-12-16
 *
 * Centralized security enforcement for CRUD/FLS checks and SOQL-injection hardening.
 * Follows AppExchange security review expectations.
 */
public with sharing class StoreConnectSecurityUtil {

    // -----------------------------
    // Caches & Constants
    // -----------------------------
    private static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
    private static final Map<String, Schema.DescribeSObjectResult> DESCRIBE_CACHE = new Map<String, Schema.DescribeSObjectResult>();
    private static final Map<String, Map<String, Schema.SObjectField>> FIELD_MAP_CACHE = new Map<String, Map<String, Schema.SObjectField>>();

    // Basic PII signals for encryption policy
    private static final Set<String> PII_KEYWORDS = new Set<String>{
        'EMAIL','PHONE','MOBILE','SSN','SOCIAL','ACCOUNT','CREDIT','CARD','ADDRESS','DOB','BIRTH','TAX','PASSPORT'
    };

    // Disallowed SQL/SOQL tokens to catch naive concatenation (case-insensitive check)
    private static final Set<String> FORBIDDEN_SOQL_TOKENS = new Set<String>{
        'SELECT','FROM','WHERE','LIMIT','ORDER BY','GROUP BY','HAVING','IN','NOT IN','LIKE','UPDATE','INSERT','DELETE'
    };

    // Private constructor to prevent instantiation
    private StoreConnectSecurityUtil() {}

    // -----------------------------
    // Describe / Field map helpers
    // -----------------------------
    private static Schema.DescribeSObjectResult getDescribe(String objectApiName) {
        String key = String.isBlank(objectApiName) ? null : objectApiName.trim();
        if (String.isBlank(key)) return null;

        if (!DESCRIBE_CACHE.containsKey(key)) {
            Schema.SObjectType sObjType = GLOBAL_DESCRIBE.get(key);
            if (sObjType == null) return null;
            DESCRIBE_CACHE.put(key, sObjType.getDescribe());
        }
        return DESCRIBE_CACHE.get(key);
    }

    private static Map<String, Schema.SObjectField> getFieldMap(String objectApiName) {
        if (!FIELD_MAP_CACHE.containsKey(objectApiName)) {
            Schema.DescribeSObjectResult d = getDescribe(objectApiName);
            if (d == null) return null;
            FIELD_MAP_CACHE.put(objectApiName, d.fields.getMap());
        }
        return FIELD_MAP_CACHE.get(objectApiName);
    }

    // -----------------------------
    // Object-level CRUD helpers
    // -----------------------------
    public static Boolean hasCreatePermission(String objectApiName)  { return requireDescribe(objectApiName).isCreateable(); }
    public static Boolean hasReadPermission(String objectApiName)     { return requireDescribe(objectApiName).isAccessible(); }
    public static Boolean hasUpdatePermission(String objectApiName)   { return requireDescribe(objectApiName).isUpdateable(); }
    public static Boolean hasDeletePermission(String objectApiName)   { return requireDescribe(objectApiName).isDeletable(); }

    private static Schema.DescribeSObjectResult requireDescribe(String objectApiName) {
        Schema.DescribeSObjectResult d = getDescribe(objectApiName);
        if (d == null) throw new SecurityException('Invalid object API name: ' + objectApiName);
        return d;
    }

    // -----------------------------
    // Field-level security helpers
    // -----------------------------
    public static Boolean hasFieldReadPermission(String objectApiName, String fieldApiName) {
        Schema.DescribeFieldResult f = requireField(objectApiName, fieldApiName);
        return f.isAccessible();
    }

    public static Boolean hasFieldEditPermission(String objectApiName, String fieldApiName) {
        Schema.DescribeFieldResult f = requireField(objectApiName, fieldApiName);
        return f.isUpdateable();
    }

    public static Boolean validateFieldAccess(String objectApiName, List<String> fieldApiNames, String operation) {
        if (String.isBlank(objectApiName) || fieldApiNames == null || fieldApiNames.isEmpty()) return true;
        final String op = String.isBlank(operation) ? 'READ' : operation.trim().toUpperCase();
        for (String fName : fieldApiNames) {
            Boolean ok = (op == 'EDIT')
                ? hasFieldEditPermission(objectApiName, fName)
                : hasFieldReadPermission(objectApiName, fName);
            if (!ok) return false;
        }
        return true;
    }

    private static Schema.DescribeFieldResult requireField(String objectApiName, String fieldApiName) {
        Map<String, Schema.SObjectField> fmap = getFieldMap(objectApiName);
        if (fmap == null) throw new SecurityException('Invalid object API name: ' + objectApiName);
        if (!fmap.containsKey(fieldApiName)) {
            throw new SecurityException('Invalid field API name: ' + fieldApiName + ' on object: ' + objectApiName);
        }
        return fmap.get(fieldApiName).getDescribe();
    }

    // -----------------------------
    // Record-level access helper
    // -----------------------------
    public static void validateRecordAccess(List<SObject> records, String operation) {
        if (records == null || records.isEmpty()) return;

        String objectApiName = records[0].getSObjectType().getDescribe().getName();
        String op = String.isBlank(operation) ? '' : operation.trim().toUpperCase();

        switch on op {
            when 'CREATE' { if (!hasCreatePermission(objectApiName)) throw new SecurityException('User lacks Create on ' + objectApiName); }
            when 'READ'   { if (!hasReadPermission(objectApiName))   throw new SecurityException('User lacks Read on ' + objectApiName); }
            when 'UPDATE' { if (!hasUpdatePermission(objectApiName)) throw new SecurityException('User lacks Update on ' + objectApiName); }
            when 'DELETE' { if (!hasDeletePermission(objectApiName)) throw new SecurityException('User lacks Delete on ' + objectApiName); }
            when else     { throw new SecurityException('Invalid operation specified: ' + operation); }
        }
    }

    // -----------------------------
    // SOQL hardening utilities
    // -----------------------------
    /**
     * IMPORTANT: Prefer bind variables in dynamic SOQL/SOSL. This sanitizer is a defense-in-depth fallback.
     */
    public static String sanitizeInput(String input, Integer maxLength) {
        if (String.isBlank(input)) return '';

        if (maxLength != null && maxLength > 0 && input.length() > maxLength) {
            throw new SecurityException('Input exceeds maximum allowed length of ' + maxLength + ' characters');
        }

        // Remove dangerous punctuation often used in injections; keep common safe symbols
        // Allows: letters, digits, whitespace, @ . _ - and basic separators
        String sanitized = input.replaceAll('[^A-Za-z0-9\\s@._\\-,/]', '');

        // Case-insensitive token check
        String upper = sanitized.toUpperCase();
        for (String token : FORBIDDEN_SOQL_TOKENS) {
            if (upper.contains(token)) {
                throw new SecurityException('Input contains forbidden keyword: ' + token);
            }
        }

        // Escape single quotes as an extra guard (still prefer bind vars)
        sanitized = String.escapeSingleQuotes(sanitized);
        return sanitized;
    }

    /** Remove SOQL/SOSL LIKE wildcards to avoid unintended pattern expansion. */
    public static String stripLikeWildcards(String value) {
        if (String.isBlank(value)) return '';
        // % and _ are wildcards in LIKE
        return value.replace('%','').replace('_','');
    }

    // -----------------------------
    // Encryption policy helper
    // -----------------------------
    public static Boolean requiresEncryption(String fieldApiName, String objectApiName) {
        if (String.isBlank(objectApiName) || String.isBlank(fieldApiName)) return false;

        Schema.DescribeFieldResult f = requireField(objectApiName, fieldApiName);

        // If field is already encrypted -> requirement exists
        if (f.isEncrypted()) return true;

        // Use Security Classification when available
        try {
            Schema.SecurityClassification c = f.getSecurityClassification();
            if (c == Schema.SecurityClassification.RESTRICTED || c == Schema.SecurityClassification.CONFIDENTIAL) {
                return true;
            }
        } catch (Exception e) {
            // org may not support classification; ignore
        }

        // Keyword heuristic on API name and label
        String upperName  = fieldApiName.toUpperCase();
        String upperLabel = f.getLabel() != null ? f.getLabel().toUpperCase() : '';
        for (String k : PII_KEYWORDS) {
            if (upperName.contains(k) || upperLabel.contains(k)) return true;
        }
        return false;
    }

    // -----------------------------
    // Minimal audit logging stub
    // -----------------------------
    public static void logSecurityAudit(String operation, String objectApiName, Id recordId, Id userId) {
        try {
            System.debug(LoggingLevel.WARN,
                'SECURITY_AUDIT op=' + operation + ' object=' + objectApiName +
                ' recordId=' + String.valueOf(recordId) + ' userId=' + String.valueOf(userId));
            // If you have a Platform Event (e.g., Security_Audit__e), publish it here:
            // Security_Audit__e evt = new Security_Audit__e(Operation__c=operation, Object__c=objectApiName, RecordId__c=recordId, UserId__c=userId);
            // EventBus.publish(evt);
        } catch (Exception e) {
            // Never fail the business tx due to logging failure
            System.debug(LoggingLevel.ERROR, 'Security audit log failed: ' + e.getMessage());
        }
    }

    // -----------------------------
    // Exception
    // -----------------------------
    public class SecurityException extends Exception {}
}
