// Fix product image URLs to use CSP-compliant placeholder images
// This resolves Content Security Policy violations with shorter URLs

try {
    System.debug('🔧 Fixing product image URLs for CSP compliance...');
    
    // Get all products with problematic image URLs
    List<Product2> productsToUpdate = [
        SELECT Id, Name, image_url__c 
        FROM Product2 
        WHERE image_url__c LIKE '%example.com%'
        LIMIT 200
    ];
    
    System.debug('📊 Found ' + productsToUpdate.size() + ' products with example.com URLs');
    
    if (productsToUpdate.isEmpty()) {
        System.debug('✅ No products found with problematic URLs');
        return;
    }
    
    // Update image URLs to use CSP-compliant placeholder images
    for (Product2 product : productsToUpdate) {
        // Use shorter, CSP-compliant placeholder URLs
        if (product.Name.contains('Laptop')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Laptop';
        } else if (product.Name.contains('Smartphone')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Smartphone';
        } else if (product.Name.contains('Air Fryer')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Air+Fryer';
        } else if (product.Name.contains('Coffee')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Coffee';
        } else if (product.Name.contains('Chair') || product.Name.contains('Desk')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Office';
        } else if (product.Name.contains('Thermostat') || product.Name.contains('Camera')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Home';
        } else if (product.Name.contains('Tracker') || product.Name.contains('Yoga')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Fitness';
        } else if (product.Name.contains('Blender') || product.Name.contains('Pot')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Kitchen';
        } else if (product.Name.contains('Electronics')) {
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Electronics';
        } else {
            // Generic placeholder for other products
            product.image_url__c = 'https://via.placeholder.com/200x200/cccccc/999999?text=Product';
        }
    }
    
    // Update the products
    update productsToUpdate;
    
    System.debug('✅ Updated ' + productsToUpdate.size() + ' product image URLs');
    System.debug('🎉 All image URLs are now CSP-compliant!');
    
    // Verify the update
    List<Product2> updatedProducts = [
        SELECT Id, Name, image_url__c 
        FROM Product2 
        WHERE image_url__c LIKE 'https://via.placeholder.com%'
        LIMIT 5
    ];
    
    System.debug('🔍 Sample updated products:');
    for (Product2 product : updatedProducts) {
        System.debug('  ' + product.Name + ': ' + product.image_url__c);
    }
    
} catch (Exception e) {
    System.debug('❌ Error fixing image URLs: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
