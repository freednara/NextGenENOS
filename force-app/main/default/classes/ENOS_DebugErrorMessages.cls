@IsTest
public class ENOS_DebugErrorMessages {
    
    @IsTest
    static void debugSecurityErrorMessages() {
        System.debug('=== DEBUGGING SECURITY ERROR MESSAGES ===');
        
        // Test 1: Invalid object in AdvancedDynamicUtils
        String error1 = '';
        try {
            ENOS_AdvancedDynamicUtils.executeComplexQuery(
                'InvalidObject', 
                new List<String>{'Id'}, 
                null, null, null, null, null, null
            );
        } catch (Exception e) {
            error1 = e.getMessage();
            System.debug('ERROR 1 - InvalidObject in executeComplexQuery: ' + error1);
        }
        
        // Test 2: Invalid field in AdvancedDynamicUtils
        String error2 = '';
        try {
            ENOS_AdvancedDynamicUtils.executeComplexQuery(
                'Product2', 
                new List<String>{'InvalidField'}, 
                null, null, null, null, null, null
            );
        } catch (Exception e) {
            error2 = e.getMessage();
            System.debug('ERROR 2 - InvalidField in executeComplexQuery: ' + error2);
        }
        
        // Test 3: Invalid object in DynamicUtils
        String error3 = '';
        try {
            ENOS_DynamicUtils.buildSafeQuery('InvalidObject__c', new List<String>{'Id'}, null, null, null);
        } catch (Exception e) {
            error3 = e.getMessage();
            System.debug('ERROR 3 - InvalidObject in buildSafeQuery: ' + error3);
        }
        
        // Test 4: Invalid field in DynamicUtils
        String error4 = '';
        try {
            ENOS_DynamicUtils.buildSafeQuery('Product2', new List<String>{'InvalidField__c'}, null, null, null);
        } catch (Exception e) {
            error4 = e.getMessage();
            System.debug('ERROR 4 - InvalidField in buildSafeQuery: ' + error4);
        }
        
        // Test 5: Null object name in DynamicUtils
        String error5 = '';
        try {
            ENOS_DynamicUtils.buildSafeQuery(null, new List<String>{'Id'}, null, null, null);
        } catch (Exception e) {
            error5 = e.getMessage();
            System.debug('ERROR 5 - Null object name in buildSafeQuery: ' + error5);
        }
        
        // Use assertions to display the error messages
        System.debug('=== ALL ERROR MESSAGES ===');
        System.debug('ERROR 1: ' + error1);
        System.debug('ERROR 2: ' + error2);
        System.debug('ERROR 3: ' + error3);
        System.debug('ERROR 4: ' + error4);
        System.debug('ERROR 5: ' + error5);
        
        // Force a failure with the error messages so we can see them
        System.assert(false, 'ERROR 1: ' + error1 + ' | ERROR 2: ' + error2 + ' | ERROR 3: ' + error3 + ' | ERROR 4: ' + error4 + ' | ERROR 5: ' + error5);
    }
}
