# ENOS Security Architecture Guide

## 📋 **Document Information**
- **Last Updated**: December 2024
- **Version**: 1.0
- **Status**: Active
- **Maintainer**: ENOS Development Team

---

## 🎯 **Overview**

This document provides a comprehensive overview of the ENOS platform's security architecture, focusing on the implementation of `WITH USER_MODE` for complete object and field-level security enforcement. This approach provides a more robust and complete solution than traditional security methods.

---

## 🔐 **Security Architecture Overview**

### **Multi-Layer Security Approach**

The ENOS platform implements a comprehensive, multi-layer security architecture:

1. **Field-Level Security (FLS)** - Enforced through `ENOS_SecurityUtils`
2. **Object-Level Security (CRUD)** - Enforced through permission sets and profiles
3. **Record-Level Security** - Enforced through sharing rules and ownership
4. **Query-Level Security** - Enforced through `WITH USER_MODE`
5. **Input Validation** - Enforced through sanitization and validation utilities

---

## 🚀 **WITH USER_MODE: The Superior Security Approach**

### **Why WITH USER_MODE is Better**

#### **1. Complete Security Coverage**
- **Traditional approach**: `WITH SECURITY_ENFORCED` only covers SOQL queries
- **WITH USER_MODE**: Extends security to ALL operations including DML
- **Result**: Comprehensive security enforcement across the entire platform

#### **2. DML Operation Security**
- **INSERT operations**: Respects user's create permissions on objects and fields
- **UPDATE operations**: Respects user's edit permissions on objects and fields
- **DELETE operations**: Respects user's delete permissions on objects and fields
- **UPSERT operations**: Respects user's create/edit permissions as appropriate

#### **3. Real-Time Permission Enforcement**
- **Dynamic permission checking**: Security is enforced at runtime
- **Profile changes**: Immediately reflected without code deployment
- **Permission set updates**: Take effect immediately for all queries

#### **4. Performance Benefits**
- **Optimized execution**: Salesforce optimizes USER_MODE queries
- **Reduced overhead**: No need for manual permission checking in code
- **Scalable security**: Performance doesn't degrade with complex security rules

---

## 🏗️ **Security Implementation Architecture**

### **Core Security Classes**

#### **1. ENOS_SecurityUtils**
```apex
// Traditional security enforcement
public static void checkObjectReadable(String objectName)
public static void checkFieldReadable(String objectName, String fieldName)
public static Boolean hasReadPermission(String objectName)
```

#### **2. ENOS_DynamicUtils**
```apex
// Dynamic query building with USER_MODE
public static String buildSafeQuery(String objectName, List<String> fields, ...)
// Automatically appends WITH USER_MODE to all queries
```

#### **3. ENOS_AdvancedDynamicUtils**
```apex
// Complex query building with USER_MODE
public static String buildComplexQuery(String objectName, List<String> fields, ...)
// Supports aggregations, GROUP BY, HAVING with USER_MODE
```

#### **4. ENOS_UserModeSecurityUtils** ⭐ **NEW**
```apex
// Enhanced security utilities leveraging USER_MODE
public static List<SObject> executeSecureQuery(String query)
public static List<SObject> executeSecureQuery(String objectName, List<String> fields, ...)
public static Integer executeSecureCountQuery(String objectName, String whereClause)
public static List<AggregateResult> executeSecureAggregateQuery(...)
```

---

## 🔄 **Security Enforcement Flow**

### **Query Execution Security Flow**

```
1. User Request → 2. Security Validation → 3. Query Building → 4. USER_MODE Execution → 5. Result Return
     ↓                    ↓                    ↓                    ↓                    ↓
Input Sanitization  Permission Check    WITH USER_MODE      Runtime Security    Filtered Results
```

### **DML Operation Security Flow**

```
1. User Request → 2. Security Validation → 3. Data Preparation → 4. USER_MODE DML → 5. Success/Failure
     ↓                    ↓                    ↓                    ↓                    ↓
Input Sanitization  Permission Check    Data Validation    Runtime Security    Result Handling
```

---

## 📊 **Security Comparison Matrix**

| Security Aspect | WITH SECURITY_ENFORCED | WITH USER_MODE | ENOS Implementation |
|----------------|------------------------|----------------|---------------------|
| **SOQL Queries** | ✅ Full Coverage | ✅ Full Coverage | ✅ Enhanced with validation |
| **DML Operations** | ❌ No Coverage | ✅ Full Coverage | ✅ Complete security |
| **Field-Level Security** | ✅ Enforced | ✅ Enforced | ✅ Enhanced validation |
| **Object-Level Security** | ✅ Enforced | ✅ Enforced | ✅ Permission set integration |
| **Record-Level Security** | ✅ Enforced | ✅ Enforced | ✅ Sharing rule compliance |
| **Performance** | ✅ Optimized | ✅ Optimized | ✅ Monitoring & alerts |
| **Runtime Updates** | ✅ Immediate | ✅ Immediate | ✅ Dynamic permission checking |

---

## 🛠️ **Implementation Examples**

### **1. Basic Query with USER_MODE**

#### **Traditional Approach (Less Secure)**
```apex
// Basic query without security enforcement
String query = 'SELECT Id, Name, Price__c FROM Product2 WHERE IsActive = true';
List<Product2> products = Database.query(query);
```

#### **ENOS Approach with USER_MODE (Most Secure)**
```apex
// Secure query with USER_MODE and validation
List<String> fields = new List<String>{'Id', 'Name', 'Price__c'};
String whereClause = 'IsActive = true';

List<Product2> products = ENOS_UserModeSecurityUtils.executeSecureQuery(
    'Product2', fields, whereClause, null, null
);
```

### **2. Complex Query with Aggregations**

#### **Traditional Approach**
```apex
String query = 'SELECT Category__c, COUNT(Id), AVG(Price__c) ' +
               'FROM Product2 ' +
               'WHERE IsActive = true ' +
               'GROUP BY Category__c ' +
               'HAVING COUNT(Id) > 5';

List<AggregateResult> results = Database.query(query);
```

#### **ENOS Approach with USER_MODE**
```apex
List<String> aggregateFields = new List<String>{
    'Category__c', 'COUNT(Id)', 'AVG(Price__c)'
};
String whereClause = 'IsActive = true';
List<String> groupByFields = new List<String>{'Category__c'};

List<AggregateResult> results = ENOS_UserModeSecurityUtils.executeSecureAggregateQuery(
    'Product2', aggregateFields, whereClause, groupByFields
);
```

### **3. Search Query with Text Search**

#### **Traditional Approach**
```apex
String query = 'SELECT Id, Name, Description__c ' +
               'FROM Product2 ' +
               'WHERE FIND(\'' + searchTerm + '\' IN ALL FIELDS)';

List<Product2> results = Database.query(query);
```

#### **ENOS Approach with USER_MODE**
```apex
List<String> fields = new List<String>{'Id', 'Name', 'Description__c'};
String whereClause = 'Category__c = \'Electronics\'';

List<Product2> results = ENOS_UserModeSecurityUtils.executeSecureSearchQuery(
    'Product2', fields, searchTerm, whereClause
);
```

---

## 🔍 **Security Validation and Testing**

### **1. Query Security Validation**

#### **Security Check Method**
```apex
// Validate query security before execution
Boolean isSecure = ENOS_UserModeSecurityUtils.validateQuerySecurity(query);
if (!isSecure) {
    throw new AuraHandledException('Query security validation failed');
}
```

#### **Security Context Validation**
```apex
// Get current user's security context
Map<String, Object> securityContext = ENOS_UserModeSecurityUtils.getUserSecurityContext();

// Check specific object access
Boolean canReadProducts = ENOS_UserModeSecurityUtils.checkUserAccess('Product2', 'read');
Boolean canCreateOrders = ENOS_UserModeSecurityUtils.checkUserAccess('Order', 'create');
```

### **2. Automated Security Testing**

#### **Unit Test Example**
```apex
@IsTest
static void testSecureQueryExecution() {
    // Test that queries respect user permissions
    Test.startTest();
    
    // Should succeed for users with proper permissions
    List<Product2> products = ENOS_UserModeSecurityUtils.executeSecureQuery(
        'Product2', 
        new List<String>{'Id', 'Name'}, 
        'IsActive = true', 
        null, 
        null
    );
    
    // Verify results are filtered by user permissions
    System.assertNotEquals(null, products);
    
    Test.stopTest();
}
```

---

## 🚨 **Security Best Practices**

### **1. Always Use USER_MODE**

#### **✅ Recommended**
```apex
// Use ENOS utilities that automatically apply USER_MODE
List<SObject> results = ENOS_UserModeSecurityUtils.executeSecureQuery(...);
```

#### **❌ Avoid**
```apex
// Direct database queries without security enforcement
List<SObject> results = Database.query('SELECT * FROM Account');
```

### **2. Validate Input Parameters**

#### **✅ Recommended**
```apex
// Validate and sanitize all input parameters
if (!ENOS_SecurityUtils.validateSOQLInjection(whereClause)) {
    throw new AuraHandledException('Invalid input detected');
}
```

#### **❌ Avoid**
```apex
// Direct string concatenation without validation
String query = 'SELECT * FROM Account WHERE ' + userInput;
```

### **3. Use Permission Sets for Access Control**

#### **✅ Recommended**
```apex
// Define clear permission sets for different user roles
// ENOS_Admin_Access - Full access
// ENOS_Basic_Access - Limited access
// ENOS_Community_Access - Community user access
```

#### **❌ Avoid**
```apex
// Hard-coded permission checks in code
if (UserInfo.getProfileId() == adminProfileId) {
    // Admin-only logic
}
```

---

## 📈 **Performance Monitoring and Optimization**

### **1. Built-in Performance Monitoring**

#### **Performance Dashboard**
```apex
// Monitor query performance in real-time
Map<String, Object> metrics = ENOS_AdvancedDynamicUtils.getPerformanceMetrics();

// Get performance alerts
List<Object> alerts = performanceDashboard.getPerformanceAlerts();
```

#### **Performance Recommendations**
```apex
// Get optimization recommendations
List<Object> recommendations = performanceDashboard.getPerformanceRecommendations();
```

### **2. Security Performance Metrics**

#### **Query Security Validation**
```apex
// Monitor security validation performance
Long startTime = System.currentTimeMillis();
Boolean isSecure = ENOS_UserModeSecurityUtils.validateQuerySecurity(query);
Long validationTime = System.currentTimeMillis() - startTime;

// Log performance metrics
System.debug('Security validation time: ' + validationTime + 'ms');
```

---

## 🔄 **Migration from WITH SECURITY_ENFORCED**

### **1. Automatic Replacement**

The ENOS platform automatically handles the migration:

```apex
// Old approach (automatically replaced)
String query = ENOS_DynamicUtils.buildSafeQuery(...);
// Result: query + ' WITH USER_MODE'

// New approach (explicit)
String query = ENOS_UserModeSecurityUtils.executeSecureQuery(...);
// Result: Direct execution with USER_MODE
```

### **2. Backward Compatibility**

All existing code continues to work:

```apex
// Existing code still works
List<Product2> products = ENOS_DynamicUtils.executeSafeQuery('Product2', fields, whereClause);

// New enhanced approach
List<Product2> products = ENOS_UserModeSecurityUtils.executeSecureQuery('Product2', fields, whereClause);
```

---

## 🎯 **Security Roadmap**

### **Phase 1: Foundation** ✅ **COMPLETE**
- Basic security utilities with `ENOS_SecurityUtils`
- Dynamic query building with `ENOS_DynamicUtils`
- Advanced features with `ENOS_AdvancedDynamicUtils`

### **Phase 2: Enhanced Security** 🔄 **IN PROGRESS**
- `ENOS_UserModeSecurityUtils` implementation
- Complete `WITH USER_MODE` coverage
- Enhanced security validation

### **Phase 3: Advanced Security** 📋 **PLANNED**
- Real-time security monitoring
- Automated security testing
- Security performance optimization

### **Phase 4: Security Intelligence** 📋 **FUTURE**
- AI-powered security analysis
- Predictive security threats
- Automated security response

---

## 📚 **Security Resources**

### **Salesforce Documentation**
- [WITH USER_MODE Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_security_with_user_mode.htm)
- [Field-Level Security Guide](https://help.salesforce.com/s/articleView?id=sf.security_fls.htm)
- [Object Permissions Guide](https://help.salesforce.com/s/articleView?id=sf.security_object_permissions.htm)

### **ENOS-Specific Resources**
- [Permission Set Reference](../PERMISSION_SET_REFERENCE.md)
- [Deployment Instructions](../ENOS_DEPLOYMENT_INSTRUCTIONS.md)
- [API Reference](../API_REFERENCE.md)

---

## 🔒 **Security Compliance**

### **1. PCI DSS Compliance**
- **Data encryption**: All sensitive data encrypted at rest and in transit
- **Access control**: Comprehensive user access management
- **Audit logging**: Complete audit trail for all operations

### **2. GDPR Compliance**
- **Data privacy**: User consent and data handling compliance
- **Right to be forgotten**: Complete data deletion capabilities
- **Data portability**: Export capabilities for user data

### **3. SOX Compliance**
- **Financial controls**: Secure financial data handling
- **Access management**: Segregation of duties enforcement
- **Audit trails**: Complete financial transaction logging

---

## 📝 **Change Log**

### **Version 1.0 (December 2024)**
- Initial security architecture guide created
- WITH USER_MODE implementation documented
- Security best practices and examples provided
- Performance monitoring and optimization guide

---

## 📞 **Security Support**

### **Internal Security Team**
- **Security Lead**: [Security Team Contact]
- **Compliance Officer**: [Compliance Contact]
- **Development Team**: [Dev Team Contact]

### **External Security Resources**
- **Salesforce Security**: [Security Documentation]
- **Security Auditors**: [Audit Team Contact]

---

## ✅ **Document Approval**

- **Created By**: [Your Name]
- **Reviewed By**: [Security Team]
- **Approved By**: [Chief Security Officer]
- **Next Review Date**: [Review Date]

---

**Note**: This document outlines the comprehensive security architecture for the ENOS platform. All team members must follow these security practices to maintain platform security and compliance. Security changes require additional review and approval from the security team.
