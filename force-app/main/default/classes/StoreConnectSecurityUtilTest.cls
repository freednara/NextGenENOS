@IsTest
private class StoreConnectSecurityUtilTest {

    @IsTest
    static void requiresEncryption_detectsPii() {
        // Test that Email field requires encryption (contains PII keyword)
        System.assert(
            StoreConnectSecurityUtil.requiresEncryption('Email', 'Contact'),
            'Email should require encryption'
        );
        
        // Test that a simple field encryption status can be determined
        Boolean idRequiresEncryption = StoreConnectSecurityUtil.requiresEncryption('Id', 'Account');
        System.assertNotEquals(
            null,
            idRequiresEncryption,
            'Encryption requirement should return a boolean value'
        );
        
        // Test that blank field doesn't require encryption
        System.assertEquals(
            false,
            StoreConnectSecurityUtil.requiresEncryption('', 'Account'),
            'Blank field should not require encryption'
        );
    }

    @IsTest
    static void requiresEncryption_invalidField() {
        Boolean threwException = false;
        try {
            StoreConnectSecurityUtil.requiresEncryption('NonexistentField__c', 'Contact');
        } catch (StoreConnectSecurityUtil.SecurityException e) {
            threwException = true;
        }
        System.assert(threwException, 'Method should throw exception when field does not exist');
    }

    @IsTest
    static void validateRecordAccess_allAccessible() {
        Account a1 = new Account(Name = 'Accessible');
        insert a1;

        Test.startTest();
        StoreConnectSecurityUtil.validateRecordAccess(new List<SObject>{ a1 }, 'READ');
        Test.stopTest();

        System.assert(true, 'Should not throw when all records are accessible');
    }

    @IsTest
    static void validateRecordAccess_inaccessible() {
        Account a1 = new Account(Name = 'A1');
        Account a2 = new Account(Name = 'A2');
        insert new List<Account>{ a1, a2 };
        delete a2;

        Boolean threw = false;
        Test.startTest();
        try {
            StoreConnectSecurityUtil.validateRecordAccess(
                new List<SObject>{ a1, new Account(Id = a2.Id) },
                'READ'
            );
        } catch (StoreConnectSecurityUtil.SecurityException e) {
            threw = true;
        }
        Test.stopTest();

        System.assert(threw, 'Should throw when a record is not accessible');
    }
}
