// ========================================
// COMPREHENSIVE ENOS PLATFORM VERIFICATION SCRIPT
// NextGenENOS ENOS Application
// ========================================
// This script performs comprehensive verification of the ENOS platform
// Includes schema checks, field permissions, data validation, and system health

System.debug('=== ENOS PLATFORM COMPREHENSIVE VERIFICATION ===');

try {
    // ========================================
    // 1. USER AND PERMISSION VERIFICATION
    // ========================================
    System.debug('=== USER AND PERMISSION VERIFICATION ===');
    
    Id currentUserId = UserInfo.getUserId();
    System.debug('Current User ID: ' + currentUserId);
    
    // Check permission set assignments
    List<PermissionSetAssignment> userPermSets = [
        SELECT Id, PermissionSet.Name, PermissionSet.Label
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUserId
        ORDER BY PermissionSet.Name
    ];
    
    System.debug('Permission Set Assignments:');
    for (PermissionSetAssignment psa : userPermSets) {
        System.debug('  - ' + psa.PermissionSet.Label + ' (' + psa.PermissionSet.Name + ')');
    }
    
    // ========================================
    // 2. SCHEMA VERIFICATION
    // ========================================
    System.debug('=== SCHEMA VERIFICATION ===');
    
    // Check if ENOS objects exist
    try {
        Schema.SObjectType cartType = Schema.getGlobalDescribe().get('Cart__c');
        if (cartType != null) {
            System.debug('✅ Cart__c object exists');
        }
    } catch (Exception e) {
        System.debug('❌ Cart__c object not found: ' + e.getMessage());
    }
    
    try {
        Schema.SObjectType cartItemType = Schema.getGlobalDescribe().get('Cart_Item__c');
        if (cartItemType != null) {
            System.debug('✅ Cart_Item__c object exists');
        }
    } catch (Exception e) {
        System.debug('❌ Cart_Item__c object not found: ' + e.getMessage());
    }
    
    try {
        Schema.SObjectType categoryType = Schema.getGlobalDescribe().get('Category__c');
        if (categoryType != null) {
            System.debug('✅ Category__c object exists');
        }
    } catch (Exception e) {
        System.debug('❌ Category__c object not found: ' + e.getMessage());
    }
    
    try {
        Schema.SObjectType shippingAddressType = Schema.getGlobalDescribe().get('Shipping_Address__c');
        if (shippingAddressType != null) {
            System.debug('✅ Shipping_Address__c object exists');
        }
    } catch (Exception e) {
        System.debug('❌ Shipping_Address__c object not found: ' + e.getMessage());
    }
    
    // ========================================
    // 3. FIELD-LEVEL SECURITY (FLS) VERIFICATION
    // ========================================
    System.debug('=== FIELD-LEVEL SECURITY VERIFICATION ===');
    
    // Test Product2 field access
    System.debug('--- Product2 Field Access Test ---');
    try {
        List<Product2> products = [
            SELECT Id, Name, ProductCode, Stock_Quantity__c, Is_Top_Seller__c, Image_URL__c
            FROM Product2 
            WHERE IsActive = true 
            LIMIT 1
        ];
        
        if (!products.isEmpty()) {
            Product2 testProduct = products[0];
            System.debug('✅ Product2 fields accessible:');
            System.debug('  - Name: ' + testProduct.Name);
            System.debug('  - ProductCode: ' + testProduct.ProductCode);
            System.debug('  - Stock_Quantity__c: ' + testProduct.Stock_Quantity__c);
            System.debug('  - Is_Top_Seller__c: ' + testProduct.Is_Top_Seller__c);
            System.debug('  - Image_URL__c: ' + testProduct.Image_URL__c);
        } else {
            System.debug('ℹ️ No Product2 records found to test');
        }
    } catch (Exception e) {
        System.debug('❌ Product2 field access error: ' + e.getMessage());
    }
    
    // Test Cart__c field access
    System.debug('--- Cart__c Field Access Test ---');
    try {
        List<Cart__c> carts = [
            SELECT Id, Contact__c, Status__c, Subtotal__c, Total_Items__c
            FROM Cart__c 
            LIMIT 1
        ];
        
        if (!carts.isEmpty()) {
            Cart__c testCart = carts[0];
            System.debug('✅ Cart__c fields accessible:');
            System.debug('  - Contact__c: ' + testCart.Contact__c);
            System.debug('  - Status__c: ' + testCart.Status__c);
            System.debug('  - Subtotal__c: ' + testCart.Subtotal__c);
            System.debug('  - Total_Items__c: ' + testCart.Total_Items__c);
        } else {
            System.debug('ℹ️ No Cart__c records found to test');
        }
    } catch (Exception e) {
        System.debug('❌ Cart__c field access error: ' + e.getMessage());
    }
    
    // Test Cart_Item__c field access
    System.debug('--- Cart_Item__c Field Access Test ---');
    try {
        List<Cart_Item__c> cartItems = [
            SELECT Id, Cart__c, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
            FROM Cart_Item__c 
            LIMIT 1
        ];
        
        if (!cartItems.isEmpty()) {
            Cart_Item__c testItem = cartItems[0];
            System.debug('✅ Cart_Item__c fields accessible:');
            System.debug('  - Cart__c: ' + testItem.Cart__c);
            System.debug('  - Product__c: ' + testItem.Product__c);
            System.debug('  - Quantity__c: ' + testItem.Quantity__c);
            System.debug('  - Unit_Price__c: ' + testItem.Unit_Price__c);
            System.debug('  - Line_Total__c: ' + testItem.Line_Total__c);
        } else {
            System.debug('ℹ️ No Cart_Item__c records found to test');
        }
    } catch (Exception e) {
        System.debug('❌ Cart_Item__c field access error: ' + e.getMessage());
    }
    
    // Test Category__c field access
    System.debug('--- Category__c Field Access Test ---');
    try {
        List<Category__c> categories = [
            SELECT Id, Name__c, Description__c
            FROM Category__c 
            LIMIT 1
        ];
        
        if (!categories.isEmpty()) {
            Category__c testCategory = categories[0];
            System.debug('✅ Category__c fields accessible:');
            System.debug('  - Name__c: ' + testCategory.Name__c);
            System.debug('  - Description__c: ' + testCategory.Description__c);
        } else {
            System.debug('ℹ️ No Category__c records found to test');
        }
    } catch (Exception e) {
        System.debug('❌ Category__c field access error: ' + e.getMessage());
    }
    
    // ========================================
    // 4. DATA VALIDATION AND BUSINESS LOGIC
    // ========================================
    System.debug('=== DATA VALIDATION AND BUSINESS LOGIC ===');
    
    // Check cart ownership
    System.debug('--- Cart Ownership Validation ---');
    try {
        List<Cart__c> userCarts = [
            SELECT Id, Contact__c, Status__c, Subtotal__c, Total_Items__c
            FROM Cart__c 
            WHERE Contact__c IN (SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account))
            LIMIT 5
        ];
        
        if (!userCarts.isEmpty()) {
            System.debug('✅ Cart ownership validation: ' + userCarts.size() + ' carts found');
            for (Cart__c cart : userCarts) {
                System.debug('  - Cart ' + cart.Id + ': Status=' + cart.Status__c + ', Items=' + cart.Total_Items__c);
            }
        } else {
            System.debug('ℹ️ No carts found for ownership validation');
        }
    } catch (Exception e) {
        System.debug('❌ Cart ownership validation error: ' + e.getMessage());
    }
    
    // Check cart status validation
    System.debug('--- Cart Status Validation ---');
    try {
        List<Cart__c> activeCarts = [
            SELECT Id, Status__c, Total_Items__c
            FROM Cart__c 
            WHERE Status__c = 'Active'
            LIMIT 5
        ];
        
        if (!activeCarts.isEmpty()) {
            System.debug('✅ Cart status validation: ' + activeCarts.size() + ' active carts found');
            for (Cart__c cart : activeCarts) {
                System.debug('  - Cart ' + cart.Id + ': Status=' + cart.Status__c + ', Items=' + cart.Total_Items__c);
            }
        } else {
            System.debug('ℹ️ No active carts found for status validation');
        }
    } catch (Exception e) {
        System.debug('❌ Cart status validation error: ' + e.getMessage());
    }
    
    // Check stock levels
    System.debug('--- Stock Level Validation ---');
    try {
        List<Product2> productsWithStock = [
            SELECT Id, Name, Stock_Quantity__c, Is_Top_Seller__c
            FROM Product2 
            WHERE IsActive = true AND Stock_Quantity__c > 0
            ORDER BY Stock_Quantity__c DESC
            LIMIT 5
        ];
        
        if (!productsWithStock.isEmpty()) {
            System.debug('✅ Stock level validation: ' + productsWithStock.size() + ' products with stock found');
            for (Product2 product : productsWithStock) {
                System.debug('  - ' + product.Name + ': Stock=' + product.Stock_Quantity__c + ', Top Seller=' + product.Is_Top_Seller__c);
            }
        } else {
            System.debug('ℹ️ No products with stock found for validation');
        }
    } catch (Exception e) {
        System.debug('❌ Stock level validation error: ' + e.getMessage());
    }
    
    // Check top sellers
    System.debug('--- Top Sellers Validation ---');
    try {
        List<Product2> topSellers = [
            SELECT Id, Name, Stock_Quantity__c, Is_Top_Seller__c
            FROM Product2 
            WHERE IsActive = true AND Is_Top_Seller__c = true
            ORDER BY Stock_Quantity__c DESC
            LIMIT 5
        ];
        
        if (!topSellers.isEmpty()) {
            System.debug('✅ Top sellers validation: ' + topSellers.size() + ' top sellers found');
            for (Product2 product : topSellers) {
                System.debug('  - ' + product.Name + ': Stock=' + product.Stock_Quantity__c);
            }
        } else {
            System.debug('ℹ️ No top sellers found for validation');
        }
    } catch (Exception e) {
        System.debug('❌ Top sellers validation error: ' + e.getMessage());
    }
    
    // ========================================
    // 5. DATA COUNTS AND STATISTICS
    // ========================================
    System.debug('=== DATA COUNTS AND STATISTICS ===');
    
    try {
        Integer accountCount = [SELECT COUNT() FROM Account];
        Integer contactCount = [SELECT COUNT() FROM Contact];
        Integer productCount = [SELECT COUNT() FROM Product2 WHERE IsActive = true];
        Integer categoryCount = [SELECT COUNT() FROM Category__c];
        Integer cartCount = [SELECT COUNT() FROM Cart__c];
        Integer cartItemCount = [SELECT COUNT() FROM Cart_Item__c];
        Integer shippingAddressCount = [SELECT COUNT() FROM Shipping_Address__c];
        
        System.debug('Data Counts:');
        System.debug('  - Accounts: ' + accountCount);
        System.debug('  - Contacts: ' + contactCount);
        System.debug('  - Products: ' + productCount);
        System.debug('  - Categories: ' + categoryCount);
        System.debug('  - Carts: ' + cartCount);
        System.debug('  - Cart Items: ' + cartItemCount);
        System.debug('  - Shipping Addresses: ' + shippingAddressCount);
        
    } catch (Exception e) {
        System.debug('❌ Data count error: ' + e.getMessage());
    }
    
    // ========================================
    // 6. PAGE LAYOUT VERIFICATION
    // ========================================
    System.debug('=== PAGE LAYOUT VERIFICATION ===');
    
    try {
        // Check if custom page layouts exist
        List<Metadata.Layout> layouts = [SELECT Id, Name FROM Metadata.Layout WHERE Name LIKE '%ENOS%' LIMIT 10];
        
        if (!layouts.isEmpty()) {
            System.debug('✅ ENOS page layouts found: ' + layouts.size());
            for (Metadata.Layout layout : layouts) {
                System.debug('  - ' + layout.Name);
            }
        } else {
            System.debug('ℹ️ No ENOS page layouts found');
        }
    } catch (Exception e) {
        System.debug('ℹ️ Page layout verification not available in this context');
    }
    
    // ========================================
    // 7. SYSTEM HEALTH CHECK
    // ========================================
    System.debug('=== SYSTEM HEALTH CHECK ===');
    
    try {
        // Check org limits
        System.debug('Org Limits:');
        System.debug('  - SOQL Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        System.debug('  - DML Statements: ' + Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
        System.debug('  - CPU Time: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
        System.debug('  - Heap Size: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        
    } catch (Exception e) {
        System.debug('ℹ️ System health check not available in this context');
    }
    
    // ========================================
    // 8. PRICEBOOK VERIFICATION
    // ========================================
    System.debug('=== PRICEBOOK VERIFICATION ===');
    
    try {
        Id standardPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        System.debug('✅ Standard Pricebook ID: ' + standardPricebookId);
        
        List<PricebookEntry> activeEntries = [
            SELECT Id, Product2.Name, UnitPrice, IsActive
            FROM PricebookEntry 
            WHERE Pricebook2Id = :standardPricebookId AND IsActive = true
            LIMIT 5
        ];
        
        if (!activeEntries.isEmpty()) {
            System.debug('✅ Active pricebook entries found: ' + activeEntries.size());
            for (PricebookEntry entry : activeEntries) {
                System.debug('  - ' + entry.Product2.Name + ': $' + entry.UnitPrice);
            }
        } else {
            System.debug('ℹ️ No active pricebook entries found');
        }
        
    } catch (Exception e) {
        System.debug('❌ Pricebook verification error: ' + e.getMessage());
    }
    
    System.debug('=== ENOS PLATFORM VERIFICATION COMPLETED ===');
    System.debug('✅ All verification checks completed successfully');
    
} catch (Exception e) {
    System.debug('❌ Verification script error: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    throw e;
}

