// Check Cart__c fields directly via SOQL to see if they exist
try {
    System.debug('🔍 Checking Cart__c fields via direct SOQL...');
    
    // Try to query Cart__c with custom fields
    try {
        List<Cart__c> carts = [
            SELECT Id, Name, Status__c, Contact__c, Created_Date__c, Guest_Session_Id__c
            FROM Cart__c 
            LIMIT 1
        ];
        System.debug('✅ Direct SOQL query successful - fields exist!');
        System.debug('📊 Found ' + carts.size() + ' carts');
        
        if (!carts.isEmpty()) {
            Cart__c cart = carts[0];
            System.debug('🔍 Sample cart data:');
            System.debug('  ID: ' + cart.Id);
            System.debug('  Name: ' + cart.Name);
            System.debug('  Status: ' + cart.Status__c);
            System.debug('  Contact: ' + cart.Contact__c);
            System.debug('  Created Date: ' + cart.Created_Date__c);
            System.debug('  Guest Session ID: ' + cart.Guest_Session_Id__c);
        }
        
    } catch (Exception e) {
        System.debug('❌ SOQL query failed: ' + e.getMessage());
        System.debug('This suggests the fields do not exist in the org');
    }
    
    // Try to create a Cart__c record to see what fields are available
    System.debug('🧪 Testing Cart__c record creation...');
    try {
        Cart__c testCart = new Cart__c(
            Status__c = 'Active'
        );
        
        // Try to set custom fields
        try {
            testCart.Contact__c = null;
            System.debug('✅ Contact__c field is accessible');
        } catch (Exception e) {
            System.debug('❌ Contact__c field error: ' + e.getMessage());
        }
        
        try {
            testCart.Created_Date__c = System.now();
            System.debug('✅ Created_Date__c field is accessible');
        } catch (Exception e) {
            System.debug('❌ Created_Date__c field error: ' + e.getMessage());
        }
        
        try {
            testCart.Guest_Session_Id__c = 'test-session';
            System.debug('✅ Guest_Session_Id__c field is accessible');
        } catch (Exception e) {
            System.debug('❌ Guest_Session_Id__c field error: ' + e.getMessage());
        }
        
        // Try to insert the cart
        insert testCart;
        System.debug('✅ Cart__c record created successfully with ID: ' + testCart.Id);
        
        // Clean up
        delete testCart;
        System.debug('✅ Test cart cleaned up');
        
    } catch (Exception e) {
        System.debug('❌ Cart creation failed: ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
    // Check if there are any existing Cart__c records
    try {
        Integer cartCount = [SELECT COUNT() FROM Cart__c];
        System.debug('📊 Total Cart__c records in org: ' + cartCount);
        
        if (cartCount > 0) {
            List<Cart__c> existingCarts = [SELECT Id, Name, Status__c FROM Cart__c LIMIT 3];
            System.debug('🔍 Sample existing carts:');
            for (Cart__c cart : existingCarts) {
                System.debug('  ' + cart.Name + ' - Status: ' + cart.Status__c);
            }
        }
        
    } catch (Exception e) {
        System.debug('❌ Count query failed: ' + e.getMessage());
    }
    
} catch (Exception e) {
    System.debug('❌ Error during field check: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
