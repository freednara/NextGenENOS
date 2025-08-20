// ========================================
// CHECK PRODUCT2 FIELDS SCRIPT
// NextGenENOS ENOS Application
// ========================================
// This script checks what fields are available on the Product2 object

System.debug('=== CHECKING PRODUCT2 FIELDS ===');

try {
    // Get the Product2 object describe
    Schema.DescribeSObjectResult productDesc = Schema.SObjectType.Product2;
    System.debug('✅ Product2 object exists');
    
    // Get all fields
    Map<String, Schema.SObjectField> fieldMap = productDesc.fields.getMap();
    System.debug('📊 Total fields on Product2: ' + fieldMap.size());
    
    // List all custom fields
    System.debug('🔍 Custom fields on Product2:');
    for (String fieldName : fieldMap.keySet()) {
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDesc = field.getDescribe();
        
        if (fieldDesc.isCustom()) {
            System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ') - Required: ' + fieldDesc.isNillable());
        }
    }
    
    // List standard fields we care about
    System.debug('🔍 Standard fields on Product2:');
    String[] standardFields = new String[]{'Id', 'Name', 'ProductCode', 'Description', 'IsActive', 'Family'};
    for (String fieldName : standardFields) {
        if (fieldMap.containsKey(fieldName)) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            System.debug('  - ' + fieldName + ' (' + fieldDesc.getType() + ') - Accessible: ' + fieldDesc.isAccessible());
        } else {
            System.debug('  - ' + fieldName + ' (NOT FOUND)');
        }
    }
    
    // Try to query some products to see what's available
    System.debug('🔍 Testing Product2 query...');
    try {
        List<Product2> products = [SELECT Id, Name, ProductCode, Description, IsActive, Family FROM Product2 LIMIT 5];
        System.debug('✅ Product2 query successful: ' + products.size() + ' products found');
        
        if (!products.isEmpty()) {
            for (Product2 product : products) {
                System.debug('  - ' + product.Name + ' (Code: ' + product.ProductCode + ')');
            }
        }
    } catch (Exception e) {
        System.debug('❌ Product2 query failed: ' + e.getMessage());
    }
    
} catch (Exception e) {
    System.debug('❌ Error checking Product2 fields: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

System.debug('=== PRODUCT2 FIELDS CHECK COMPLETE ===');




