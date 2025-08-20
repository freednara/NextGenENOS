/**
 * @description Test class for ENOS_ConfigurationValidator
 * Provides comprehensive test coverage for configuration validation functionality
 * @author ENOS Development Team
 * @version 1.0.0
 */
@isTest
private class ENOS_ConfigurationValidatorTest {
    
    @TestSetup
    static void setupTestData() {
        // No test data needed for this utility class
    }
    
    @isTest
    static void testValidateAllConfigurations() {
        // Test validation of all configurations
        Test.startTest();
        
        Map<String, Object> validationResults = ENOS_ConfigurationValidator.validateAllConfigurations();
        
        Test.stopTest();
        
        // Verify validation results structure
        System.assertNotEquals(null, validationResults, 'Validation results should not be null');
        System.assert(validationResults.containsKey('status'), 'Results should contain status');
        System.assert(validationResults.containsKey('validCount'), 'Results should contain valid count');
        System.assert(validationResults.containsKey('totalCount'), 'Results should contain total count');
        System.assert(validationResults.containsKey('issues'), 'Results should contain issues');
        System.assert(validationResults.containsKey('warnings'), 'Results should contain warnings');
        System.assert(validationResults.containsKey('timestamp'), 'Results should contain timestamp');
        
        // Verify validation results
        String status = (String) validationResults.get('status');
        Integer validCount = (Integer) validationResults.get('validCount');
        Integer totalCount = (Integer) validationResults.get('totalCount');
        
        System.assertNotEquals(null, status, 'Status should not be null');
        System.assertNotEquals(null, validCount, 'Valid count should not be null');
        System.assertNotEquals(null, totalCount, 'Total count should not be null');
        System.assert(validCount > 0, 'Should have some valid configurations');
        System.assert(totalCount > 0, 'Should have total configurations to validate');
    }
    

    

    
    @isTest
    static void testGetConfigurationRecommendations() {
        // Test getting configuration recommendations
        Test.startTest();
        
        List<String> recommendations = ENOS_ConfigurationValidator.getConfigurationRecommendations(
            new Map<String, Object>{
                'status' => 'INVALID',
                'issues' => new List<String>{'QUERY_RESULT_LIMIT: Value exceeds maximum limit'},
                'warnings' => new List<String>{'BATCH_SIZE_LIMIT: Batch size for bulk operations'}
            }
        );
        
        Test.stopTest();
        
        // Verify recommendations are generated
        System.assertNotEquals(null, recommendations, 'Recommendations should not be null');
        System.assert(recommendations.size() > 0, 'Should have some recommendations');
        
        // Verify recommendation content
        Boolean hasRecommendation = false;
        for (String rec : recommendations) {
            if (rec.contains('QUERY_RESULT_LIMIT') || rec.contains('exceeds maximum limit')) {
                hasRecommendation = true;
                break;
            }
        }
        System.assert(hasRecommendation, 'Should have recommendation for invalid configuration');
    }
    
    @isTest
    static void testLogValidationResults() {
        // Test logging validation results
        Test.startTest();
        
        Map<String, Object> validationResults = new Map<String, Object>{
            'status' => 'VALID',
            'validCount' => 5,
            'totalCount' => 6,
            'issues' => new List<String>(),
            'warnings' => new List<String>()
        };
        
        // This method logs to debug, so we just verify it doesn't throw an exception
        ENOS_ConfigurationValidator.logValidationResults(validationResults);
        
        Test.stopTest();
        
        // If no exception is thrown, the test passes
        System.assert(true, 'Logging validation results should complete without errors');
    }
    

}
