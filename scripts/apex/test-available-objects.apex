// Test what fields are actually available
System.debug('Testing available objects and fields...');

// Check what fields are available on Cart__c
try {
    Schema.SObjectType cartType = Schema.getGlobalDescribe().get('Cart__c');
    if(cartType != null) {
        Schema.DescribeSObjectResult cartDescribe = cartType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = cartDescribe.fields.getMap();
        
        System.debug('Cart__c fields available:');
        for(String fieldName : fieldMap.keySet()) {
            if(fieldName.endsWith('__c')) {
                System.debug('- ' + fieldName);
            }
        }
    }
} catch(Exception e) {
    System.debug('Error describing Cart__c: ' + e.getMessage());
}

// Test creating categories first (should work)
try {
    List<Category__c> categories = new List<Category__c>();
    categories.add(new Category__c(Name__c = 'Test Electronics'));
    categories.add(new Category__c(Name__c = 'Test Computers'));
    
    insert categories;
    System.debug('SUCCESS: Created ' + categories.size() + ' categories');
    
    // Query them back
    List<Category__c> queriedCategories = [SELECT Id, Name__c FROM Category__c WHERE Name__c LIKE 'Test%'];
    System.debug('Found ' + queriedCategories.size() + ' test categories:');
    for(Category__c cat : queriedCategories) {
        System.debug('- ' + cat.Name__c + ' (ID: ' + cat.Id + ')');
    }
    
} catch(Exception e) {
    System.debug('Error with categories: ' + e.getMessage());
}

// Test what fields Cart__c actually has
try {
    System.debug('Attempting to query Cart__c with available fields...');
    List<Cart__c> carts = [SELECT Id, Name, Status__c FROM Cart__c LIMIT 1];
    System.debug('Cart__c query successful - found ' + carts.size() + ' records');
} catch(Exception e) {
    System.debug('Error querying Cart__c: ' + e.getMessage());
}

System.debug('Object availability test complete.');
