# CommunityRegistrationHandler Setup Guide

## **Configuring Automatic Cart Creation for New Community Users**

**Purpose**: This guide walks the admin through configuring the `CommunityRegistrationHandler` class to automatically create shopping carts for new community users upon registration.

---

## 🎯 **What This Handler Does**

### **Automatic Cart Creation**
- **Triggers**: When a new user registers on the Experience Cloud site
- **Action**: Automatically creates an empty `Cart__c` record linked to the new user
- **Benefit**: Users can immediately start shopping without waiting for cart setup

### **Registration Process Flow**
1. **User registers** on the community site
2. **Salesforce creates** User and Contact records
3. **CommunityRegistrationHandler** is called automatically
4. **Cart__c record** is created in the background
5. **User can immediately** start adding products to cart

---

## ⚙️ **Prerequisites**

### **Before Configuration**
- [ ] **CommunityRegistrationHandler.cls** deployed to your org
- [ ] **Experience Cloud site** created and configured
- **Custom objects** deployed (`Cart__c`, `Cart_Item__c`, etc.)
- **Permission sets** configured for community users

### **Required Permissions**
- **System Administrator** profile or equivalent
- **Customize Application** permission
- **Manage Communities** permission

---

## 🔧 **Step-by-Step Configuration**

### **Step 1: Navigate to Experience Cloud Settings**
1. **Go to Setup** → **Experience Cloud** → **All Sites**
2. **Click on your site** (e.g., "StoreConnect Community")
3. **Click "Administration"** → **Login & Registration**

### **Step 2: Configure Registration Handler**
1. **Scroll down** to "Registration Handler" section
2. **Click "Edit"** button
3. **Select "Apex Class"** from the dropdown
4. **Enter**: `CommunityRegistrationHandler`
5. **Click "Save"**

### **Step 3: Verify Configuration**
1. **Refresh the page**
2. **Confirm** "Registration Handler" shows `CommunityRegistrationHandler`
3. **Note the timestamp** of when it was last updated

---

## 📋 **Configuration Screenshots & Details**

### **Login & Registration Settings Location**
```
Setup → Experience Cloud → All Sites → [Your Site] → Administration → Login & Registration
```

### **Registration Handler Field**
- **Field Name**: Registration Handler
- **Type**: Apex Class
- **Value**: CommunityRegistrationHandler
- **Status**: Active

### **Expected Result**
After configuration, new user registrations will automatically trigger cart creation without any additional setup.

---

## 🧪 **Testing the Configuration**

### **Test Registration Process**
1. **Create a test user** through community registration
2. **Verify Contact record** is created
3. **Check for Cart__c record** linked to the Contact
4. **Confirm cart status** is "Active"

### **Verification Queries**
Run these queries in Developer Console to verify:

**Check for new Contact:**
```sql
SELECT Id, FirstName, LastName, Email, UserId__c 
FROM Contact 
WHERE Email = '[test-email@example.com]'
```

**Check for new Cart:**
```sql
SELECT Id, Name, Contact__c, Status__c, CreatedDate 
FROM Cart__c 
WHERE Contact__c IN (
    SELECT Id FROM Contact WHERE Email = '[test-email@example.com]'
)
```

### **Expected Results**
- **Contact record**: Should exist with UserId__c populated
- **Cart record**: Should exist with Status__c = 'Active'
- **Timing**: Cart should be created within 1-2 minutes of registration

---

## 🔍 **Troubleshooting Common Issues**

### **Issue 1: Handler Not Being Called**
**Symptoms**: No Cart__c records created for new users
**Possible Causes**:
- Handler class not deployed
- Handler class not properly configured
- Apex class compilation errors

**Solutions**:
1. **Verify class deployment** in Setup → Apex Classes
2. **Check for compilation errors** in Setup → Apex Classes
3. **Re-enter handler class name** in site settings
4. **Clear browser cache** and refresh

### **Issue 2: Cart Creation Fails**
**Symptoms**: Cart__c records not created despite handler being called
**Possible Causes**:
- Missing custom object permissions
- Validation rule failures
- Field-level security restrictions

**Solutions**:
1. **Check debug logs** for error messages
2. **Verify permission set** includes Cart__c access
3. **Review validation rules** on Cart__c object
4. **Check field-level security** on Cart__c fields

### **Issue 3: Duplicate Carts Created**
**Symptoms**: Multiple Cart__c records for same user
**Possible Causes**:
- Handler called multiple times
- Race conditions in @future method

**Solutions**:
1. **Check debug logs** for multiple executions
2. **Verify duplicate prevention logic** in handler
3. **Review registration process** for multiple triggers

---

## 📊 **Monitoring & Maintenance**

### **Debug Logs to Monitor**
- **CommunityRegistrationHandler** execution logs
- **Cart creation success/failure** messages
- **Error stack traces** for troubleshooting

### **Regular Health Checks**
- **Weekly**: Verify new registrations create carts
- **Monthly**: Review error logs and patterns
- **Quarterly**: Test registration process end-to-end

### **Performance Considerations**
- **@future method** runs asynchronously (1-2 minute delay)
- **Cart creation** doesn't block user registration
- **Error handling** prevents registration failures

---

## 🚨 **Security Considerations**

### **Permission Requirements**
- **Community users** need Create permission on Cart__c
- **Handler class** runs in system context
- **Field-level security** is enforced on cart creation

### **Data Validation**
- **Duplicate prevention** logic prevents multiple carts
- **Error handling** logs issues without exposing data
- **Transaction safety** ensures data integrity

---

## 🔄 **Future Enhancements**

### **Potential Improvements**
- **Email notifications** when cart is created
- **Welcome message** with cart information
- **Default product suggestions** in new cart
- **Integration** with marketing automation tools

### **Configuration Options**
- **Cart template** customization
- **Default cart items** for new users
- **Welcome flow** integration
- **Analytics tracking** for registration success

---

## 📞 **Support & Escalation**

### **If Configuration Fails**
1. **Review this guide** step-by-step
2. **Check debug logs** for error messages
3. **Verify prerequisites** are met
4. **Contact development team** with specific error details

### **Escalation Path**
1. **Admin**: Basic configuration and testing
2. **Developer**: Handler class issues and debugging
3. **System Admin**: Permission and security issues

---

## ✅ **Configuration Checklist**

**Before Going Live**:
- [ ] **CommunityRegistrationHandler.cls** deployed and active
- [ ] **Registration handler** configured in site settings
- [ ] **Test registration** completed successfully
- [ ] **Cart creation** verified for test user
- [ ] **Error handling** tested with invalid scenarios
- [ ] **Permission sets** configured for community users
- [ ] **Custom objects** deployed and accessible

---

**This configuration ensures that every new StoreConnect community user automatically gets a shopping cart, providing an immediate and seamless shopping experience.**

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Next Review**: After Sprint 1 completion  
**Owner**: StoreConnect Development Team
