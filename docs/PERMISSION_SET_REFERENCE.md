# ENOS Permission Set Reference Guide

## 📋 **Document Information**
- **Last Updated**: December 2024
- **Version**: 1.0
- **Status**: Active
- **Maintainer**: ENOS Development Team

---

## 🎯 **Overview**

This document provides a comprehensive reference for all ENOS permission sets, including their purpose, assigned permissions, and usage guidelines. This document is maintained and updated as new features are added to the platform.

---

## 🔐 **Permission Set Overview**

### **Available Permission Sets**

1. **ENOS_Admin_Access** - Full administrative access to all ENOS functionality
2. **ENOS_Basic_Access** - Basic user access for community members
3. **ENOS_Community_Access** - Community-specific access for external users

### **Permission Set Hierarchy**

```
ENOS_Admin_Access (Full Access)
    ↓
ENOS_Basic_Access (Limited Access)
    ↓
ENOS_Community_Access (Community Only)
```

---

## 👑 **ENOS_Admin_Access**

### **Purpose**
Provides full administrative access to all ENOS e-commerce functionality, including development, testing, and production management.

### **Target Users**
- System Administrators
- ENOS Developers
- ENOS Support Engineers
- Business Analysts

### **Custom Permissions**
```
✅ ENOS_User - Basic ENOS functionality access
✅ ENOS_Admin - Administrative ENOS functionality access
```

### **Object Permissions**

#### **Cart__c (Shopping Cart)**
```
✅ Create: Yes
✅ Read: Yes
✅ Edit: Yes
✅ Delete: Yes
✅ View All Records: Yes
✅ Modify All Records: Yes
```

#### **Cart_Item__c (Cart Items)**
```
✅ Create: Yes
✅ Read: Yes
✅ Edit: Yes
✅ Delete: Yes
✅ View All Records: Yes
✅ Modify All Records: Yes
```

#### **Product2 (Products)**
```
✅ Create: Yes
✅ Read: Yes
✅ Edit: Yes
✅ Delete: Yes
✅ View All Records: Yes
✅ Modify All Records: Yes
```

#### **Category__c (Product Categories)**
```
✅ Create: Yes
✅ Read: Yes
✅ Edit: Yes
✅ Delete: Yes
✅ View All Records: Yes
✅ Modify All Records: Yes
```

### **Apex Class Access**
```
✅ ENOS_CartController - Cart management functionality
✅ ENOS_ProductController - Product catalog functionality
✅ ENOSController - Core ENOS functionality
✅ ENOS_SecurityUtils - Security utilities
✅ ENOS_DynamicUtils - Dynamic query utilities
✅ ENOS_AdvancedDynamicUtils - Advanced dynamic features
```

### **Flow Access**
```
✅ ENOS_Enhanced_Checkout - Multi-step checkout process
✅ ENOS_Order_Processing - Automated order creation
✅ ENOS_Cart_Recovery - Cart abandonment recovery
✅ ENOS_Product_Recommendations - Product suggestions
✅ ENOS_Customer_Support - Support request handling
```

### **LWC Component Access**
```
✅ performanceDashboard - Performance monitoring dashboard
✅ dynamicIntegrationTester - Dynamic features testing component
```

### **Field-Level Security**
All custom fields on ENOS objects are accessible with full CRUD permissions.

---

## 👤 **ENOS_Basic_Access**

### **Purpose**
Provides basic access to ENOS functionality for regular users who need to browse products and perform basic operations.

### **Target Users**
- Regular ENOS Users
- Customer Service Representatives
- Sales Representatives
- Marketing Team Members

### **Custom Permissions**
```
✅ ENOS_User - Basic ENOS functionality access
❌ ENOS_Admin - Administrative ENOS functionality access (NOT INCLUDED)
```

### **Object Permissions**

#### **Product2 (Products)**
```
✅ Create: No
✅ Read: Yes
✅ Edit: No
✅ Delete: No
✅ View All Records: No
✅ Modify All Records: No
```

#### **Category__c (Product Categories)**
```
✅ Create: No
✅ Read: Yes
✅ Edit: No
✅ Delete: No
✅ View All Records: No
✅ Modify All Records: No
```

### **Apex Class Access**
```
✅ ENOS_ProductController - Product catalog functionality
✅ ENOS_SecurityUtils - Security utilities (read-only access)
```

### **Flow Access**
```
✅ ENOS_Enhanced_Checkout - Multi-step checkout process
✅ ENOS_Customer_Support - Support request handling
```

### **LWC Component Access**
```
✅ performanceDashboard - Performance monitoring dashboard (read-only)
```

### **Field-Level Security**
Limited to read access on product and category fields only.

---

## 🌐 **ENOS_Community_Access**

### **Purpose**
Provides community-specific access for external users accessing the ENOS platform through Experience Cloud.

### **Target Users**
- Community Members
- External Customers
- Partner Users
- Guest Users (limited access)

### **Custom Permissions**
```
✅ ENOS_User - Basic ENOS functionality access
❌ ENOS_Admin - Administrative ENOS functionality access (NOT INCLUDED)
```

### **Object Permissions**

#### **Product2 (Products)**
```
✅ Create: No
✅ Read: Yes
✅ Edit: No
✅ Delete: No
✅ View All Records: No
✅ Modify All Records: No
```

#### **Category__c (Product Categories)**
```
✅ Create: No
✅ Read: Yes
✅ Edit: No
✅ Delete: No
✅ View All Records: No
✅ Modify All Records: No
```

#### **Cart__c (Shopping Cart)**
```
✅ Create: Yes (own records only)
✅ Read: Yes (own records only)
✅ Edit: Yes (own records only)
✅ Delete: Yes (own records only)
✅ View All Records: No
✅ Modify All Records: No
```

#### **Cart_Item__c (Cart Items)**
```
✅ Create: Yes (own records only)
✅ Read: Yes (own records only)
✅ Edit: Yes (own records only)
✅ Delete: Yes (own records only)
✅ View All Records: No
✅ Modify All Records: No
```

### **Apex Class Access**
```
✅ ENOS_ProductController - Product catalog functionality
✅ ENOS_SecurityUtils - Security utilities (read-only access)
```

### **Flow Access**
```
✅ ENOS_Enhanced_Checkout - Multi-step checkout process
✅ ENOS_Customer_Support - Support request handling
```

### **LWC Component Access**
```
✅ performanceDashboard - Performance monitoring dashboard (read-only)
```

### **Field-Level Security**
Limited to read access on product and category fields, and CRUD access on own cart records.

---

## 🔧 **Permission Set Management**

### **Assignment Guidelines**

#### **ENOS_Admin_Access**
- **Assign to**: System administrators, developers, support engineers
- **When to assign**: During initial setup, development, and testing phases
- **Duration**: Permanent or until role changes

#### **ENOS_Basic_Access**
- **Assign to**: Regular users, customer service, sales, marketing
- **When to assign**: When users need basic ENOS functionality
- **Duration**: Permanent or until role changes

#### **ENOS_Community_Access**
- **Assign to**: Community members, external users
- **When to assign**: When users register for community access
- **Duration**: Permanent or until community membership expires

### **Assignment Commands**

#### **Assign Permission Set to User**
```bash
# Assign ENOS Admin Access
sf org assign permset --name ENOS_Admin_Access --target-org ENOS-Dev

# Assign ENOS Basic Access
sf org assign permset --name ENOS_Basic_Access --target-org ENOS-Dev

# Assign ENOS Community Access
sf org assign permset --name ENOS_Community_Access --target-org ENOS-Dev
```

#### **Assign Permission Set to Multiple Users**
```bash
# Assign to specific users
sf org assign permset --name ENOS_Admin_Access --target-org ENOS-Dev --users user1@example.com,user2@example.com

# Assign to all users with specific profile
sf org assign permset --name ENOS_Basic_Access --target-org ENOS-Dev --profiles "System Administrator"
```

#### **Remove Permission Set Assignment**
```bash
# Remove permission set assignment
sf org unassign permset --name ENOS_Admin_Access --target-org ENOS-Dev --users user@example.com
```

### **Permission Set Deployment**

#### **Deploy All Permission Sets**
```bash
# Deploy all permission sets
sf project deploy start --source-dir force-app/main/default/permissionSets --target-org ENOS-Dev
```

#### **Deploy Specific Permission Set**
```bash
# Deploy specific permission set
sf project deploy start --source-dir force-app/main/default/permissionSets/ENOS_Admin_Access.permissionset-meta.xml --target-org ENOS-Dev
```

---

## 🔍 **Permission Set Validation**

### **Validation Commands**

#### **Check Permission Set Status**
```bash
# List all permission sets
sf data query --query "SELECT Id, Name, Label, Description FROM PermissionSet WHERE Name LIKE 'ENOS%'" --target-org ENOS-Dev

# Check permission set assignments
sf data query --query "SELECT Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name LIKE 'ENOS%'" --target-org ENOS-Dev
```

#### **Validate Object Access**
```bash
# Check object permissions
sf data query --query "SELECT Id, Parent.Label, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete FROM ObjectPermissions WHERE Parent.Name LIKE 'ENOS%'" --target-org ENOS-Dev
```

#### **Validate Field Access**
```bash
# Check field permissions
sf data query --query "SELECT Id, Parent.Label, SobjectType, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE Parent.Name LIKE 'ENOS%'" --target-org ENOS-Dev
```

### **Validation Checklist**

#### **Pre-Deployment Validation**
- [ ] Permission sets compile without errors
- [ ] All referenced Apex classes exist
- [ ] All referenced flows exist
- [ ] All referenced LWC components exist
- [ ] Object and field references are valid

#### **Post-Deployment Validation**
- [ ] Permission sets deploy successfully
- [ ] Users can access assigned functionality
- [ ] Security restrictions work as expected
- [ ] No unintended access granted
- [ ] Community users have appropriate access

---

## 🚨 **Troubleshooting Permission Issues**

### **Common Issues**

#### **1. "Insufficient Access Rights" Errors**
**Symptoms**: Users cannot access ENOS functionality
**Causes**:
- Permission set not assigned
- Permission set not deployed
- Object/field access not configured
- Profile restrictions

**Solutions**:
1. Verify permission set assignment
2. Check permission set deployment status
3. Validate object and field permissions
4. Review profile restrictions

#### **2. "Object Not Found" Errors**
**Symptoms**: Permission set references non-existent objects
**Causes**:
- Objects not deployed
- Object names misspelled
- API version compatibility issues

**Solutions**:
1. Deploy missing objects
2. Correct object names
3. Update API versions

#### **3. "Field Not Found" Errors**
**Symptoms**: Permission set references non-existent fields
**Causes**:
- Fields not deployed
- Field names misspelled
- Field-level security conflicts

**Solutions**:
1. Deploy missing fields
2. Correct field names
3. Check field-level security settings

### **Debugging Commands**

#### **Check User Permissions**
```bash
# Check user's permission sets
sf data query --query "SELECT Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Username = 'user@example.com'" --target-org ENOS-Dev

# Check user's profile
sf data query --query "SELECT Id, Name, Profile.Name FROM User WHERE Username = 'user@example.com'" --target-org ENOS-Dev
```

#### **Check Object Access**
```bash
# Check if user can access specific object
sf apex run --command "System.debug('Cart__c accessible: ' + Schema.SObjectType.Cart__c.isAccessible());" --target-org ENOS-Dev
```

#### **Check Field Access**
```bash
# Check if user can access specific field
sf apex run --command "System.debug('Status__c accessible: ' + Schema.SObjectType.Cart__c.fields.Status__c.isAccessible());" --target-org ENOS-Dev
```

---

## 📚 **Permission Set Best Practices**

### **Security Principles**

#### **1. Principle of Least Privilege**
- Grant only necessary permissions
- Start with minimal access
- Add permissions incrementally
- Regular permission reviews

#### **2. Separation of Concerns**
- Different permission sets for different roles
- Clear permission boundaries
- Avoid permission set overlap
- Document permission purposes

#### **3. Regular Auditing**
- Monthly permission reviews
- Quarterly security assessments
- Annual permission cleanup
- Document all changes

### **Naming Conventions**

#### **Permission Set Names**
```
Format: ENOS_[Role]_[Access_Level]
Examples:
- ENOS_Admin_Access
- ENOS_Basic_Access
- ENOS_Community_Access
```

#### **Custom Permission Names**
```
Format: ENOS_[Functionality]
Examples:
- ENOS_User
- ENOS_Admin
- ENOS_Checkout
- ENOS_Reporting
```

### **Documentation Standards**

#### **Required Documentation**
- Permission set purpose and scope
- Target user roles and responsibilities
- Assigned permissions and restrictions
- Assignment guidelines and procedures
- Change management procedures

#### **Update Procedures**
- Document all permission changes
- Update this reference guide
- Notify affected users
- Test permission changes
- Maintain change logs

---

## 🔄 **Permission Set Updates**

### **Update Procedures**

#### **1. Planning Phase**
- Identify required changes
- Assess security impact
- Plan testing strategy
- Prepare rollback plan

#### **2. Development Phase**
- Update permission set metadata
- Test in sandbox environment
- Validate all permissions
- Document changes

#### **3. Deployment Phase**
- Deploy to target org
- Assign to test users
- Validate functionality
- Monitor for issues

#### **4. Post-Deployment**
- Assign to production users
- Monitor system performance
- Collect user feedback
- Document lessons learned

### **Change Management**

#### **Change Request Process**
1. **Submit change request** with justification
2. **Review security impact** with security team
3. **Test changes** in sandbox environment
4. **Obtain approval** from stakeholders
5. **Deploy changes** to production
6. **Monitor and validate** changes

#### **Emergency Changes**
- **Immediate security fixes** can bypass normal process
- **Document emergency** in change log
- **Review and approve** post-implementation
- **Update procedures** to prevent recurrence

---

## 📝 **Change Log**

### **Version 1.0 (December 2024)**
- Initial permission set reference created
- Complete permission set documentation
- Assignment guidelines and procedures
- Troubleshooting and best practices

### **Future Updates**
- This document will be updated as new permission sets are added
- Permission changes will be documented
- Best practices will be updated based on experience
- Security improvements will be incorporated

---

## 📞 **Support & Contact**

### **Internal Support**
- **Security Team**: [Security Team Contact]
- **System Administrator**: [Admin Contact]
- **Development Team**: [Dev Team Contact]

### **External Support**
- **Salesforce Support**: [Support Case Number]
- **Security Documentation**: [Security Docs Link]

---

## ✅ **Document Approval**

- **Created By**: [Your Name]
- **Reviewed By**: [Security Team]
- **Approved By**: [System Administrator]
- **Next Review Date**: [Review Date]

---

**Note**: This document is a living document and should be updated whenever permission sets are modified. All team members are responsible for keeping this documentation current and accurate. Security changes require additional review and approval.
