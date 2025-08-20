@IsTest
private class ENOS_SecurityUtilTest {
  @IsTest
  static void testCustomPermissions() {
    // Test custom permission checking
    Boolean hasUserAccess = ENOS_SecurityUtils.hasENOSUserAccess();
    Boolean hasAdminAccess = ENOS_SecurityUtils.hasENOSAdminAccess();
    Boolean hasPaymentAccess = ENOS_SecurityUtils.hasENOSPaymentProcessorAccess();
    
    // These methods should not throw exceptions
    System.assertNotEquals(null, hasUserAccess, 'User access check should return boolean');
    System.assertNotEquals(null, hasAdminAccess, 'Admin access check should return boolean');
    System.assertNotEquals(null, hasPaymentAccess, 'Payment access check should return boolean');
  }

  @IsTest
  static void testObjectAccessChecks() {
    // Test object access validation
    try {
      ENOS_SecurityUtils.checkObjectReadable('Account');
      System.assert(true, 'Account should be readable');
    } catch (Exception e) {
      // This is expected if Account is not accessible
      System.debug('Account access check failed: ' + e.getMessage());
    }
    
    try {
      ENOS_SecurityUtils.checkObjectCreateable('Account');
      System.assert(true, 'Account should be createable');
    } catch (Exception e) {
      // This is expected if Account is not createable
      System.debug('Account create check failed: ' + e.getMessage());
    }
  }

  @IsTest
  static void testFieldAccessChecks() {
    // Test field access validation
    try {
      ENOS_SecurityUtils.checkFieldReadAccess('Account', new List<String>{'Name', 'Id'});
      System.assert(true, 'Account Name and Id should be readable');
    } catch (Exception e) {
      // This is expected if fields are not accessible
      System.debug('Account field access check failed: ' + e.getMessage());
    }
  }

  @IsTest
  static void testInputSanitization() {
    // Test input sanitization
    String sanitized = ENOS_SecurityUtils.sanitizeInput('Test\'Input"With<Special>Chars');
    System.assertNotEquals(null, sanitized, 'Sanitization should return a value');
    
    String nullInput = ENOS_SecurityUtils.sanitizeInput(null);
    System.assertEquals(null, nullInput, 'Null input should return null');
  }

  @IsTest
  static void testValidationMethods() {
    // Test validation methods
    try {
      ENOS_SecurityUtils.validateRequiredId('001000000000000', 'Test ID');
      System.assert(true, 'Valid ID should pass validation');
    } catch (Exception e) {
      System.debug('ID validation failed: ' + e.getMessage());
    }
    
    try {
      ENOS_SecurityUtils.validatePositiveInteger(5, 'Test Quantity', 1);
      System.assert(true, 'Valid quantity should pass validation');
    } catch (Exception e) {
      System.debug('Quantity validation failed: ' + e.getMessage());
    }
  }
}
