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
}
