# ENOS Platform - Complete Deployment Instructions

## 📋 **Document Information**
- **Last Updated**: December 2024
- **Version**: 1.0
- **Status**: Active
- **Maintainer**: ENOS Development Team

---

## 🎯 **Overview**

This document provides comprehensive deployment instructions for the ENOS e-commerce platform, including all manual steps, automated processes, and configuration requirements. This document is maintained and updated as the platform evolves.

---

## 🚀 **Prerequisites**

### **Required Tools**
- ✅ Salesforce CLI (SFDX/sf) - Latest version
- ✅ Git repository access
- ✅ Access to Salesforce org with Experience Cloud enabled
- ✅ Customer Community Plus Login licenses

### **Required Permissions**
- ✅ System Administrator access
- ✅ Experience Cloud Admin access
- ✅ API access enabled
- ✅ Customize Application permission

---

## 🏗️ **Phase 1: Initial Org Setup**

### **Step 1: Create Scratch Org (Development)**
```bash
# Navigate to project directory
cd NextGenENOS

# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias ENOS-Dev --duration-days 30

# Set as default
sf config set target-org ENOS-Dev
```

### **Step 2: Deploy Foundation Metadata**
```bash
# Deploy all metadata
sf project deploy start --source-dir force-app/main/default

# Verify deployment
sf project deploy report
```

### **Step 3: Run Setup Script**
```bash
# Make script executable
chmod +x scripts/create-enos-org.sh

# Run setup script
./scripts/create-enos-org.sh ENOS-Dev
```

---

## 🔧 **Phase 2: Custom Object Deployment**

### **Step 1: Deploy Custom Objects**
```bash
# Deploy Cart__c object and fields
sf project deploy start --source-dir force-app/main/default/objects/Cart__c

# Deploy Cart_Item__c object and fields
sf project deploy start --source-dir force-app/main/default/objects/Cart_Item__c

# Deploy other custom objects
sf project deploy start --source-dir force-app/main/default/objects
```

### **Step 2: Verify Object Schema**
```bash
# Check Cart__c fields
sf apex run --file scripts/check-schema.apex

# Check Cart_Item__c fields
sf apex run --file scripts/check-cart-item-schema.apex
```

### **Step 3: Create Test Data**
```bash
# Create test data for flow testing
sf apex run --file scripts/final-test-data.apex
```

---

## 🔐 **Phase 3: Permission Sets & Security**

### **Step 1: Deploy Permission Sets**
```bash
# Deploy all permission sets
sf project deploy start --source-dir force-app/main/default/permissionSets
```

### **Step 2: Assign Permission Sets**
```bash
# Assign to current user (for testing)
sf org assign permset --name ENOS_Admin_Access
sf org assign permset --name ENOS_Basic_Access
```

### **Step 3: Verify Security Settings**
- Navigate to Setup → Security → Field-Level Security
- Verify all custom fields have appropriate access
- Check object permissions in permission sets

---

## 🌐 **Phase 4: Experience Cloud Setup**

### **Step 1: Enable Experience Cloud**
- Navigate to Setup → Digital Experiences → Settings
- Enable Digital Experiences
- Configure default settings

### **Step 2: Create Community Site**
```bash
# Create ENOS community
sf community create --name "ENOS" --template-name "Customer Account Portal" --url-path-prefix "enos" --description "NextGen ENOS E-Commerce Platform"
```

### **Step 3: Configure Community Settings**
- Navigate to Digital Experiences → All Sites → ENOS
- Configure member profiles
- Set up navigation and pages
- Configure guest access settings

---

## 🔄 **Phase 5: Flow Implementation**

### **Step 1: Deploy Basic Flows**
```bash
# Deploy working basic flows
sf project deploy start --source-dir force-app/main/default/flows/Checkout.flow-meta.xml
sf project deploy start --source-dir force-app/main/default/flows/Create_Case_simple.flow-meta.xml
```

### **Step 2: Create Enhanced Flows Using Flow Builder**
**IMPORTANT**: Use Salesforce Flow Builder UI instead of metadata files for complex flows.

#### **Enhanced Checkout Flow**
1. Open Setup → Process Automation → Flows
2. Click "New Flow" → Choose "Screen Flow"
3. Follow the detailed instructions in `docs/FLOW_IMPLEMENTATION_GUIDE.md`
4. Test and activate the flow

#### **Order Processing Flow**
1. Create new "Record-Triggered Flow"
2. Configure trigger: Cart__c.Status__c changes to "Ready for Order"
3. Add elements for order creation, order items, and cart status update
4. Test and activate

#### **Cart Recovery Flow**
1. Create new "Scheduled-Triggered Flow"
2. Set schedule: Daily at 9:00 AM
3. Add logic for abandoned cart detection and email sending
4. Test and activate

### **Step 3: Flow Testing**
```bash
# Test flow execution
sf apex run --command "// Test flow logic here"
```

---

## 📱 **Phase 6: Lightning Web Components**

### **Step 1: Deploy LWC Components**
```bash
# Deploy all LWC components
sf project deploy start --source-dir force-app/main/default/lwc
```

### **Step 2: Configure Component Access**
- Navigate to Setup → Custom Code → Lightning Components
- Verify component visibility settings
- Configure component properties

### **Step 3: Add Components to Community Pages**
- Open Experience Builder
- Add components to appropriate pages
- Configure component properties and data binding

---

## 🔌 **Phase 7: Integration & APIs**

### **Step 1: Deploy Apex Classes**
```bash
# Deploy all Apex classes
sf project deploy start --source-dir force-app/main/default/classes
```

### **Step 2: Configure Remote Site Settings**
- Navigate to Setup → Security → Remote Site Settings
- Add external domains for integrations
- Configure CORS settings if needed

### **Step 3: Test API Endpoints**
```bash
# Test Apex REST endpoints
sf apex run --command "// Test API calls here"
```

---

## 📊 **Phase 8: Data & Testing**

### **Step 1: Load Sample Data**
```bash
# Load sample products
sf data import --sobjecttype Product2 --csvfile data/sample_products.csv

# Load sample accounts and contacts
sf data import --sobjecttype Account --csvfile data/sample_accounts.csv
sf data import --sobjecttype Contact --csvfile data/sample_contacts.csv
```

### **Step 2: Run Test Classes**
```bash
# Run all tests
sf apex run test --class-names ENOS_SecurityUtilsTest,ENOS_DynamicUtilsTest

# Run specific test class
sf apex run test --class-names ENOS_SecurityUtilsTest
```

### **Step 3: Validate Data Model**
```bash
# Verify data relationships
sf apex run --file scripts/validate-data-model.apex
```

---

## 🔍 **Phase 9: Validation & Quality Assurance**

### **Step 1: Security Review**
- Run Salesforce Security Scanner
- Review field-level security settings
- Verify sharing rules and profiles

### **Step 2: Performance Testing**
- Test flow execution times
- Monitor SOQL query performance
- Validate governor limit compliance

### **Step 3: User Acceptance Testing**
- Test complete user journeys
- Validate business logic
- Test error scenarios and recovery

---

## 🚀 **Phase 10: Production Deployment**

### **Step 1: Production Org Preparation**
```bash
# Authenticate with production org
sf org login web --set-default --alias ENOS-Prod

# Validate deployment
sf project deploy validate --source-dir force-app/main/default
```

### **Step 2: Production Deployment**
```bash
# Deploy to production
sf project deploy start --source-dir force-app/main/default --target-org ENOS-Prod

# Verify deployment
sf project deploy report
```

### **Step 3: Post-Deployment Configuration**
- Configure production-specific settings
- Set up monitoring and alerts
- Configure backup and recovery procedures

---

## 🔧 **Manual Configuration Steps**

### **Experience Cloud Configuration**
1. **Community Builder Setup**
   - Configure navigation menu
   - Set up page layouts
   - Configure component visibility

2. **Member Management**
   - Set up user registration
   - Configure profile assignments
   - Set up approval processes

3. **Email Templates**
   - Create order confirmation templates
   - Set up cart abandonment emails
   - Configure support notification emails

### **Security Configuration**
1. **Field-Level Security**
   - Review all custom fields
   - Set appropriate read/write permissions
   - Configure field encryption if needed

2. **Sharing Rules**
   - Set up record sharing for community users
   - Configure account and contact sharing
   - Set up cart sharing rules

3. **Validation Rules**
   - Review and test validation rules
   - Configure error messages
   - Set up field dependencies

### **Integration Configuration**
1. **External Systems**
   - Configure payment gateway settings
   - Set up shipping provider integration
   - Configure email service providers

2. **API Configuration**
   - Set up API rate limits
   - Configure authentication methods
   - Set up webhook endpoints

---

## 📋 **Configuration Checklist**

### **Pre-Deployment**
- [ ] Scratch org created and configured
- [ ] All metadata deployed successfully
- [ ] Custom objects and fields created
- [ ] Permission sets configured
- [ ] Test data loaded

### **Post-Deployment**
- [ ] Experience Cloud site configured
- [ ] Flows tested and activated
- [ ] LWC components deployed and configured
- [ ] Security settings verified
- [ ] Integration endpoints tested
- [ ] User acceptance testing completed

### **Production Readiness**
- [ ] Security review completed
- [ ] Performance testing passed
- [ ] Backup procedures configured
- [ ] Monitoring and alerting set up
- [ ] Documentation updated
- [ ] Training completed

---

## 🚨 **Troubleshooting Guide**

### **Common Deployment Issues**

#### **1. Permission Set Deployment Failures**
**Symptoms**: "Insufficient access rights" errors
**Solution**: 
- Verify user has System Administrator profile
- Check API access is enabled
- Ensure user has "Customize Application" permission

#### **2. Custom Object Deployment Issues**
**Symptoms**: Fields not appearing after deployment
**Solution**:
- Deploy entire object directory, not just fields
- Check for validation rule conflicts
- Verify field metadata syntax

#### **3. Flow Deployment Failures**
**Symptoms**: "Error parsing file" messages
**Solution**:
- Use Flow Builder UI instead of metadata files
- Check flow variable definitions
- Verify object and field references

#### **4. LWC Component Issues**
**Symptoms**: Components not appearing in community
**Solution**:
- Check component visibility settings
- Verify component metadata configuration
- Check for JavaScript errors in browser console

### **Debugging Commands**
```bash
# Check org status
sf org display

# View deployment errors
sf project deploy report

# Check object schema
sf apex run --file scripts/check-schema.apex

# Test specific functionality
sf apex run --command "// Debug code here"
```

---

## 📚 **Documentation & Resources**

### **Required Documentation**
- [ ] `docs/FLOW_IMPLEMENTATION_GUIDE.md` - Detailed flow creation instructions
- [ ] `docs/PERMISSION_SET_REFERENCE.md` - Permission set configurations
- [ ] `docs/API_REFERENCE.md` - API endpoint documentation
- [ ] `docs/TROUBLESHOOTING.md` - Common issues and solutions

### **External Resources**
- [Salesforce Flow Builder Documentation](https://help.salesforce.com/s/articleView?id=flow_builder.htm)
- [Experience Cloud Setup Guide](https://help.salesforce.com/s/articleView?id=networks_overview.htm)
- [Lightning Web Components Guide](https://developer.salesforce.com/docs/component-library/documentation/lwc)

---

## 🔄 **Maintenance & Updates**

### **Regular Maintenance Tasks**
1. **Weekly**
   - Monitor flow execution logs
   - Check for failed deployments
   - Review error logs

2. **Monthly**
   - Update permission sets as needed
   - Review security settings
   - Performance monitoring

3. **Quarterly**
   - Full security review
   - Performance optimization
   - Documentation updates

### **Update Procedures**
1. **Code Updates**
   - Pull latest changes from Git
   - Deploy updated metadata
   - Test functionality
   - Update documentation

2. **Configuration Changes**
   - Document all changes
   - Test in sandbox first
   - Update this document
   - Notify team members

---

## 📞 **Support & Contact**

### **Internal Support**
- **Development Team**: [Team Contact Information]
- **System Administrator**: [Admin Contact Information]
- **Project Manager**: [PM Contact Information]

### **External Support**
- **Salesforce Support**: [Support Case Number]
- **Community Forums**: [Forum Links]
- **Documentation**: [Documentation Links]

---

## 📝 **Change Log**

### **Version 1.0 (December 2024)**
- Initial deployment instructions created
- Complete flow implementation guide added
- Security configuration procedures documented
- Troubleshooting guide included

### **Future Updates**
- This document will be updated as the platform evolves
- New features and configurations will be added
- Manual steps will be automated where possible
- Security and performance improvements will be documented

---

## ✅ **Document Approval**

- **Created By**: [Your Name]
- **Reviewed By**: [Reviewer Name]
- **Approved By**: [Approver Name]
- **Next Review Date**: [Review Date]

---

**Note**: This document is a living document and should be updated whenever changes are made to the ENOS platform. All team members are responsible for keeping this documentation current and accurate.
