# ENOS Platform Deployment Instructions

## 🎯 **Overview**

This document provides step-by-step instructions for deploying the ENOS platform to a Salesforce scratch org. The deployment process is split into **3 phases** to accommodate manual steps and ensure proper verification.

## 📋 **Prerequisites**

- ✅ Salesforce CLI (`sf`) installed and authenticated
- ✅ DevHub org access
- ✅ ENOS project codebase downloaded
- ✅ Bash shell environment (macOS/Linux/WSL)

## 🚀 **Phase 1: Automated Deployment**

### **Step 1: Run the Deployment Script**

```bash
# Navigate to project root
cd /path/to/NextGenENOS

# Run deployment script (creates scratch org with all components)
./scripts/create-enos-org.sh ENOS-Production 7 dev
```

**What This Script Does:**
- ✅ Creates scratch org with proper alias and duration
- ✅ Deploys all custom objects and fields
- ✅ Deploys Apex classes and LWC components
- ✅ Creates ENOS Experience Cloud community
- ✅ Deploys permission sets with field-level security
- ✅ Sets up basic page layouts and flexipages
- ✅ Activates Standard Price Book for cart functionality

**Expected Output:**
- Script completes with success messages
- Custom fields deployed but may not be visible in UI yet
- Permission sets created and assigned
- Community creation started (may take a few minutes)

**Troubleshooting:**
- If script fails, check the error messages
- Common issues: permission set XML syntax, missing dependencies
- Script includes retry logic for most components

---

## 🔧 **Phase 2: Manual Configuration (Required)**

### **Step 2: Open the Scratch Org**

```bash
# Open the org in your browser
sf org open --target-org ENOS-Production
```

### **Step 3: Configure Profile Field Visibility**

**⚠️ CRITICAL: This step cannot be automated and is required for UI functionality**

1. **Navigate to**: Setup → Profiles → [Your Profile Name]
2. **Click**: Field-Level Security
3. **Find**: Product2 object
4. **Set these fields to "Visible"**:
   - `stock_quantity__c`
   - `is_top_seller__c` 
   - `image_url__c`
5. **Click**: Save

**Why This Step is Required:**
- Salesforce requires profile-level field visibility for UI display
- Permission sets grant access but don't control UI visibility
- This affects all users with that profile
- **Pattern #15** in our error analysis documents this requirement

### **Step 4: Verify Community Setup**

1. **Navigate to**: Setup → Digital Experiences → All Sites
2. **Find**: ENOS community
3. **Click**: Edit
4. **Verify**: Status is "Live" or "Under Construction"
5. **If needed**: Click "Publish" to make it live

**Community Status Options:**
- **Under Construction**: Still being built
- **Live**: Available to users
- **Error**: Requires investigation

---

## ✅ **Phase 3: Verification and Testing**

### **Step 5: Run the Verification Script**

```bash
# Run comprehensive verification tests
./scripts/verify-enos-deployment.sh ENOS-Production
```

**What This Script Verifies:**
- ✅ Custom fields are accessible via API
- ✅ Permission sets are properly configured
- ✅ LWC components can access custom fields
- ✅ Community is properly configured
- ✅ All critical components are working

**Verification Phases:**
1. **Core Components**: Fields, permissions, security
2. **Data Operations**: Create/read products with custom fields
3. **LWC Access**: Controller access to custom fields
4. **Community Setup**: Status and configuration
5. **Profile Visibility**: Manual step verification

---

## 📊 **Verification Results**

### **Automated Verifications (Script)**
- ✅ Custom Fields Deployment (Pattern #12)
- ✅ Field-Level Security (Pattern #13)
- ✅ Permission Sets (Pattern #14)
- ✅ Data Operations
- ✅ LWC Component Access
- ✅ Community Setup

### **Manual Verifications (Required)**
- ⚠️ Profile Field Visibility (Pattern #15)
- ⚠️ LWC Components in UI
- ⚠️ Page Layouts Displaying Custom Fields

---

## 🔍 **Manual Testing Checklist**

After completing all phases, manually verify:

### **UI Field Visibility**
- [ ] Open Product2 records in the UI
- [ ] Verify custom fields appear in page layouts
- [ ] Check that fields are editable (if permissions allow)

### **LWC Component Testing**
- [ ] Navigate to ENOS app in App Launcher
- [ ] Test product catalog component
- [ ] Verify custom field data displays correctly
- [ ] Test filtering and pagination

### **Community Testing**
- [ ] Access community URL
- [ ] Test user registration/login
- [ ] Verify product catalog functionality
- [ ] Test shopping cart features

---

## 🚨 **Common Issues and Solutions**

### **Issue: Custom Fields Not Visible in UI**
**Solution**: Complete Step 3 (Profile Field Visibility)
- Fields exist and are accessible via API
- UI visibility requires profile-level configuration
- This is a Salesforce platform limitation

### **Issue: Permission Set Deployment Failed**
**Solution**: Check XML syntax
- Look for duplicate elements
- Verify field references exist
- Check for invalid metadata

### **Issue: LWC Components Not Loading**
**Solution**: Verify dependencies
- Check Lightning Message Channels deployed
- Verify Apex controllers accessible
- Check component metadata

### **Issue: Community Not Accessible**
**Solution**: Check community status
- Verify community is published
- Check user permissions
- Verify community settings

---

## 📝 **Post-Deployment Tasks**

### **Data Population**
```bash
# Create sample products with custom fields
sf apex run --target-org ENOS-Production --file scripts/create_sample_products.apex
```

### **User Management**
- Assign appropriate permission sets to users
- Configure community user profiles
- Set up sharing rules if needed

### **Customization**
- Modify page layouts as needed
- Customize community branding
- Configure additional fields or objects

---

## 🔄 **Updating Existing Deployments**

### **Code Updates**
```bash
# Deploy specific components
sf project deploy start --target-org ENOS-Production --source-dir force-app/main/default/classes

# Deploy all changes
sf project deploy start --target-org ENOS-Production
```

### **Permission Updates**
```bash
# Deploy updated permission sets
sf project deploy start --target-org ENOS-Production --source-dir force-app/main/default/permissionsets
```

---

## 📚 **Reference Materials**

### **Scripts**
- `scripts/create-enos-org.sh` - Main deployment script
- `scripts/verify-enos-deployment.sh` - Verification script
- `scripts/create_sample_products.apex` - Sample data creation

### **Documentation**
- `ERROR_PATTERNS_ANALYSIS.md` - Error patterns and solutions
- `README.md` - Project overview and setup

### **Salesforce Resources**
- [Field-Level Security](https://help.salesforce.com/s/articleView?id=sf.security_fls.htm)
- [Permission Sets](https://help.salesforce.com/s/articleView?id=sf.users_permissions.htm)
- [Experience Cloud](https://help.salesforce.com/s/articleView?id=sf.exp_cloud_setup.htm)

---

## 🎉 **Success Criteria**

Your ENOS deployment is successful when:

1. ✅ **All automated verifications pass**
2. ✅ **Custom fields visible in UI**
3. ✅ **LWC components display custom field data**
4. ✅ **Community accessible and functional**
5. ✅ **Permission sets properly configured**
6. ✅ **Sample data working correctly**

---

## 🆘 **Getting Help**

### **Check Error Patterns**
- Review `ERROR_PATTERNS_ANALYSIS.md`
- Look for similar issues and solutions
- Check pattern numbers referenced in scripts

### **Debug Steps**
1. Run verification script to identify issues
2. Check Salesforce debug logs
3. Verify metadata deployment status
4. Test individual components in isolation

### **Common Debug Commands**
```bash
# Check org status
sf org display --target-org ENOS-Production

# View debug logs
sf apex run --target-org ENOS-Production --file /dev/stdin

# Check deployment status
sf project deploy report --job-id [DEPLOYMENT_ID]
```

---

**Happy Deploying! 🚀**

*Remember: The manual profile configuration step is critical and cannot be skipped.*
