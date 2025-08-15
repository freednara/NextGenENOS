@IsTest
private class ENOS_SecurityUtilTest {
  @IsTest
  static void requiresEncryption_detectsPii() {
    // Test that Email field requires encryption (contains PII keyword)
    Boolean emailRequiresEncryption = ENOSSecurityUtil.requiresEncryption(
      'Email',
      'Contact'
    );
    System.assert(
      emailRequiresEncryption,
      'Email field should require encryption'
    );

    Boolean idRequiresEncryption = ENOSSecurityUtil.requiresEncryption(
      'Id',
      'Account'
    );
    System.assert(
      !idRequiresEncryption,
      'Id field should not require encryption'
    );

    // Test with empty field name
    Boolean emptyFieldRequiresEncryption = ENOSSecurityUtil.requiresEncryption(
      '',
      'Account'
    );
    System.assert(
      !emptyFieldRequiresEncryption,
      'Empty field should not require encryption'
    );

    // Test with invalid object
    Boolean invalidObjectRequiresEncryption = ENOSSecurityUtil.requiresEncryption(
      'Name',
      'InvalidObject'
    );
    System.assert(
      !invalidObjectRequiresEncryption,
      'Invalid object should not require encryption'
    );

    // Test with nonexistent field
    Boolean nonexistentFieldRequiresEncryption = ENOSSecurityUtil.requiresEncryption(
      'NonexistentField__c',
      'Contact'
    );
    System.assert(
      !nonexistentFieldRequiresEncryption,
      'Nonexistent field should not require encryption'
    );

    // Test with null parameters
    Boolean nullFieldRequiresEncryption = ENOSSecurityUtil.requiresEncryption(
      null,
      'Account'
    );
    System.assert(
      !nullFieldRequiresEncryption,
      'Null field should not require encryption'
    );

    Boolean nullObjectRequiresEncryption = ENOSSecurityUtil.requiresEncryption(
      'Name',
      null
    );
    System.assert(
      !nullObjectRequiresEncryption,
      'Null object should not require encryption'
    );
  }

  @IsTest
  static void testValidateRecordAccess() {
    // Create test data
    Account a1 = new Account(Name = 'Test Account 1');
    Account a2 = new Account(Name = 'Test Account 2');
    insert new List<Account>{ a1, a2 };

    // Test READ access validation
    ENOSSecurityUtil.validateRecordAccess(new List<SObject>{ a1 }, 'READ');

    // Test with empty list
    ENOSSecurityUtil.validateRecordAccess(new List<SObject>(), 'READ');

    // Test with null list
    ENOSSecurityUtil.validateRecordAccess(null, 'READ');

    // Test with invalid operation
    try {
      ENOSSecurityUtil.validateRecordAccess(
        new List<SObject>{ a1, a2 },
        'INVALID_OPERATION'
      );
      System.assert(
        false,
        'Should have thrown exception for invalid operation'
      );
    } catch (ENOSSecurityUtil.SecurityException e) {
      System.assert(
        e.getMessage().contains('Invalid operation'),
        'Should contain error message'
      );
    }
  }
}
