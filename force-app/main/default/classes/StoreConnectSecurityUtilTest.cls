@IsTest
private class StoreConnectSecurityUtilTest {

    @IsTest
    static void requiresEncryption_detectsPii() {
        System.assert(
            StoreConnectSecurityUtil.requiresEncryption('Email', 'Contact'),
            'Email should require encryption'
        );
        System.assertEquals(
            false,
            StoreConnectSecurityUtil.requiresEncryption('Name', 'Account'),
            'Name should not require encryption'
        );
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
