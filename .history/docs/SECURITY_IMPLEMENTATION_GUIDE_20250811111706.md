# StoreConnect Security Implementation Guide

## **CRITICAL: Every Apex Controller MUST Use SecurityUtils**

**Purpose**: This guide ensures that **every single Apex method** in StoreConnect follows the security-first pattern. By calling `SecurityUtils` methods at the beginning of every method, we guarantee that Field-Level Security (FLS) and CRUD permissions are respected **100% of the time**.

---

## 🚨 **Security Pattern: Check First, Execute Second**

### **The Rule:**
**NEVER execute business logic without first checking security permissions.**

### **The Pattern:**
```apex
@AuraEnabled
public static ReturnType methodName(Parameters params) {
    // 1. SECURITY CHECK FIRST - Always call SecurityUtils methods here
    SecurityUtils.checkFieldReadAccess('ObjectName__c', fieldsToSecure);
    SecurityUtils.checkObjectCreateable('ObjectName__c');
    
    // 2. BUSINESS LOGIC SECOND - Only execute after security validation
    // Your actual method logic goes here
    return result;
}
```

---

## 📋 **Required Security Checks by Operation Type**

### **For READ Operations (SELECT queries)**
```apex
// ALWAYS check field read access before any SELECT query
List<String> fieldsToSecure = new List<String>{
    'Id', 'Name', 'Quantity__c', 'Unit_Price__c'
};
SecurityUtils.checkFieldReadAccess('Cart_Item__c', fieldsToSecure);

// Then proceed with your query
return [SELECT Id, Name, Quantity__c, Unit_Price__c FROM Cart_Item__c];
```

### **For CREATE Operations (INSERT)**
```apex
// ALWAYS check object create permissions before INSERT
SecurityUtils.checkObjectCreateable('Cart_Item__c');

// ALWAYS check field edit access for fields being set
List<String> fieldsToEdit = new List<String>{
    'Quantity__c', 'Unit_Price__c', 'Product__c'
};
SecurityUtils.checkFieldEditAccess('Cart_Item__c', fieldsToEdit);

// Then proceed with your DML operation
insert newCartItem;
```

### **For UPDATE Operations**
```apex
// ALWAYS check object update permissions before UPDATE
SecurityUtils.checkObjectUpdateable('Cart_Item__c');

// ALWAYS check field edit access for fields being modified
List<String> fieldsToEdit = new List<String>{
    'Quantity__c', 'Unit_Price__c'
};
SecurityUtils.checkFieldEditAccess('Cart_Item__c', fieldsToEdit);

// Then proceed with your DML operation
update cartItemToUpdate;
```

### **For DELETE Operations**
```apex
// ALWAYS check object delete permissions before DELETE
SecurityUtils.checkObjectDeletable('Cart_Item__c');

// Then proceed with your DML operation
delete cartItemToDelete;
```

---

## 🔧 **Real Implementation Examples**

### **Example 1: CartController.getCartItems()**
```apex
@AuraEnabled(cacheable=true)
public static List<Cart_Item__c> getCartItems() {
    // 1. SECURITY CHECK FIRST
    List<String> fieldsToSecure = new List<String>{
        'Id', 'Quantity__c', 'Unit_Price__c', 'Line_Total__c',
        'Product__r.Name', 'Product__r.Image_URL__c'
    };
    SecurityUtils.checkFieldReadAccess('Cart_Item__c', fieldsToSecure);
    
    // 2. BUSINESS LOGIC SECOND
    return [
        SELECT Id, Quantity__c, Unit_Price__c, Line_Total__c,
               Product__r.Name, Product__r.Image_URL__c
        FROM Cart_Item__c
        WHERE Cart__r.Contact__c = :UserInfo.getUserId()
        AND Cart__r.Status__c = 'Active'
        LIMIT 50
    ];
}
```

### **Example 2: CartController.addToCart()**
```apex
@AuraEnabled
public static Cart_Item__c addToCart(Id productId, Integer quantity) {
    // 1. SECURITY CHECK FIRST
    SecurityUtils.checkObjectCreateable('Cart_Item__c');
    
    List<String> fieldsToEdit = new List<String>{
        'Quantity__c', 'Unit_Price__c', 'Product__c'
    };
    SecurityUtils.checkFieldEditAccess('Cart_Item__c', fieldsToEdit);
    
    // 2. BUSINESS LOGIC SECOND
    Cart_Item__c newItem = new Cart_Item__c(
        Product__c = productId,
        Quantity__c = quantity,
        Unit_Price__c = getProductPrice(productId)
    );
    
    insert newItem;
    return newItem;
}
```

### **Example 3: CartController.updateCartItem()**
```apex
@AuraEnabled
public static void updateCartItem(Id cartItemId, Integer newQuantity) {
    // 1. SECURITY CHECK FIRST
    SecurityUtils.checkObjectUpdateable('Cart_Item__c');
    
    List<String> fieldsToEdit = new List<String>{
        'Quantity__c'
    };
    SecurityUtils.checkFieldEditAccess('Cart_Item__c', fieldsToEdit);
    
    // 2. BUSINESS LOGIC SECOND
    Cart_Item__c itemToUpdate = [SELECT Id, Quantity__c FROM Cart_Item__c WHERE Id = :cartItemId];
    itemToUpdate.Quantity__c = newQuantity;
    update itemToUpdate;
}
```

---

## 🚫 **Common Security Mistakes - NEVER DO THESE**

### **❌ WRONG: No Security Check**
```apex
@AuraEnabled
public static List<Cart_Item__c> getCartItems() {
    // DANGEROUS: No security check before query
    return [SELECT Id, Quantity__c, Unit_Price__c FROM Cart_Item__c];
}
```

### **❌ WRONG: Security Check After Logic**
```apex
@AuraEnabled
public static void updateCartItem(Id cartItemId, Integer newQuantity) {
    // DANGEROUS: Security check comes after business logic
    Cart_Item__c itemToUpdate = [SELECT Id, Quantity__c FROM Cart_Item__c WHERE Id = :cartItemId];
    itemToUpdate.Quantity__c = newQuantity;
    update itemToUpdate;
    
    // Too late! Security check should be first
    SecurityUtils.checkObjectUpdateable('Cart_Item__c');
}
```

### **❌ WRONG: Incomplete Security Check**
```apex
@AuraEnabled
public static void addToCart(Id productId, Integer quantity) {
    // DANGEROUS: Only checking object permissions, not field permissions
    SecurityUtils.checkObjectCreateable('Cart_Item__c');
    
    // Missing: SecurityUtils.checkFieldEditAccess() for fields being set
    
    Cart_Item__c newItem = new Cart_Item__c(
        Product__c = productId,        // Field not checked for edit access
        Quantity__c = quantity,        // Field not checked for edit access
        Unit_Price__c = 10.00         // Field not checked for edit access
    );
    
    insert newItem;
}
```

---

## ✅ **Security Checklist for Every Method**

**Before writing any business logic, verify:**

- [ ] **Security check is the FIRST line** of the method (after parameter validation)
- [ ] **Field-level security** is checked for ALL fields being accessed
- [ ] **Object-level permissions** are checked for the operation type
- [ ] **Security check covers** the specific operation (READ, CREATE, UPDATE, DELETE)
- [ ] **No business logic executes** before security validation
- [ ] **AuraHandledException** is thrown for security violations

---

## 🔍 **Security Validation Testing**

### **Test Scenarios to Verify**
1. **User without object permissions** - Should get security error
2. **User without field permissions** - Should get security error  
3. **User with full permissions** - Should execute successfully
4. **Invalid parameters** - Should get validation error
5. **Cross-object field access** - Should be properly secured

### **Sample Test Method**
```apex
@IsTest
static void testSecurityEnforcement() {
    // Test that security checks prevent unauthorized access
    try {
        // This should fail if user doesn't have permissions
        SecurityUtils.checkFieldReadAccess('Cart_Item__c', new List<String>{'Id', 'Quantity__c'});
        System.assert(false, 'Security check should have failed');
    } catch (AuraHandledException e) {
        System.assert(e.getMessage().contains('Security Error'), 'Should throw security error');
    }
}
```

---

## 🎯 **Why This Matters**

1. **AppExchange Compliance**: Security review requires 100% FLS/CRUD enforcement
2. **Data Protection**: Prevents unauthorized access to sensitive information
3. **Audit Trail**: Security violations are logged and tracked
4. **User Experience**: Clear error messages when permissions are insufficient
5. **Maintainability**: Centralized security logic is easier to update and audit

---

## 📞 **Support & Questions**

**If you have questions about implementing security:**

1. **Review this guide** thoroughly
2. **Check existing implementations** for examples
3. **Ask the lead developer** for clarification
4. **Never deploy** insecure code

**Remember: Security is not optional. Every method must follow this pattern.**

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Next Review**: After Sprint 1 completion  
**Owner**: StoreConnect Development Team
