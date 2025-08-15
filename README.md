# NextGen ENOS E-Commerce Platform

## 🚀 **Platform Overview**

NextGen ENOS is a comprehensive e-commerce platform built on Salesforce, featuring Dynamic Apex capabilities, modern Lightning Web Components, and automated deployment processes. The platform provides a secure, scalable foundation for e-commerce operations with advanced features for cart management, order processing, and customer engagement.

---

## ✨ **Key Features**

### **🔐 Security-First Architecture**
- **Field-Level Security (FLS)** enforcement through `ENOS_SecurityUtils`
- **WITH USER_MODE** for complete object and field-level security including DML operations
- **Role-based access control** with comprehensive permission sets
- **Data validation rules** for integrity and compliance
- **Secure dynamic queries** with injection prevention and runtime security enforcement

### **🔄 Dynamic Apex Capabilities**
- **ENOS_DynamicUtils** - Safe and secure dynamic SOQL queries
- **ENOS_AdvancedDynamicUtils** - Advanced features with performance monitoring
- **Metadata-driven development** for flexible and maintainable code
- **Retry mechanisms** with exponential backoff for resilient operations

### **⚡ Modern UI Components**
- **Performance Dashboard** - Real-time monitoring and alerts
- **Dynamic Integration Tester** - End-to-end feature validation
- **Responsive design** optimized for all devices
- **Configurable properties** for easy customization

### **🌐 Experience Cloud Integration**
- **Community site** with JIT user provisioning
- **Guest and member access** with appropriate permissions
- **Custom profiles** for different user types
- **SSO integration** ready for external identity providers

---

## 🏗️ **Architecture Components**

### **Core Objects**
- **Cart__c** - Shopping cart management with status tracking
- **Cart_Item__c** - Individual cart items with quantity and pricing
- **Product2** - Product catalog with category organization
- **Category__c** - Product categorization and hierarchy

### **Apex Classes**
- **ENOS_SecurityUtils** - Security enforcement and validation
- **ENOS_DynamicUtils** - Dynamic query building and execution with USER_MODE
- **ENOS_AdvancedDynamicUtils** - Advanced features and performance monitoring with USER_MODE
- **ENOS_UserModeSecurityUtils** - Enhanced security utilities leveraging WITH USER_MODE for complete coverage
- **ENOS_Controller** - Core platform functionality
- **ENOS_CartController** - Cart management operations
- **ENOS_ProductController** - Product catalog operations

### **Lightning Web Components**
- **performanceDashboard** - Performance metrics and alerts
- **dynamicIntegrationTester** - Feature testing and validation

### **Permission Sets**
- **ENOS_Admin_Access** - Full administrative access
- **ENOS_Basic_Access** - Basic user functionality
- **ENOS_Community_Access** - Community member access

---

## 🚀 **Quick Start**

### **Prerequisites**
- Salesforce CLI (SFDX/sf) - Latest version
- Git repository access
- Access to Salesforce org with Experience Cloud enabled

### **1. Clone Repository**
```bash
git clone [repository-url]
cd NextGenENOS
```

### **2. Create Scratch Org**
```bash
# Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias ENOS-Dev --duration-days 30

# Set as default
sf config set target-org ENOS-Dev
```

### **3. Run Setup Script**
```bash
# Make script executable
chmod +x scripts/create-enos-org.sh

# Run setup script
./scripts/create-enos-org.sh ENOS-Dev
```

### **4. Deploy Metadata**
```bash
# Deploy all metadata
sf project deploy start --source-dir force-app/main/default
```

---

## 📚 **Documentation**

### **Complete Setup Guide**
- **[ENOS_DEPLOYMENT_INSTRUCTIONS.md](docs/ENOS_DEPLOYMENT_INSTRUCTIONS.md)** - Complete deployment instructions with all manual steps
- **[FLOW_IMPLEMENTATION_GUIDE.md](docs/FLOW_IMPLEMENTATION_GUIDE.md)** - Detailed flow creation using Flow Builder
- **[PERMISSION_SET_REFERENCE.md](docs/PERMISSION_SET_REFERENCE.md)** - Comprehensive permission set documentation
- **[SECURITY_ARCHITECTURE_GUIDE.md](docs/SECURITY_ARCHITECTURE_GUIDE.md)** - Complete security architecture with WITH USER_MODE implementation
- **[ENOS_COMPLETE_SETUP_SUMMARY.md](docs/ENOS_COMPLETE_SETUP_SUMMARY.md)** - Complete platform overview and status

### **Scripts**
- **[create-enos-org.sh](scripts/create-enos-org.sh)** - Automated org setup and configuration
- **[final-test-data.apex](scripts/final-test-data.apex)** - Test data creation for development
- **[check-schema.apex](scripts/check-schema.apex)** - Schema validation and debugging

---

## 🔄 **Current Status**

### **✅ Completed**
- **Infrastructure Setup** - Scratch org, custom objects, permission sets
- **Dynamic Apex Implementation** - Security utilities, dynamic queries, performance monitoring
- **Lightning Web Components** - Performance dashboard, integration tester
- **Automated Deployment** - Complete setup automation
- **Documentation Suite** - Comprehensive guides and references

### **🔄 In Progress**
- **Flow Implementation** - Enhanced checkout, order processing, cart recovery
- **Community Configuration** - Navigation, page layouts, component placement
- **Integration Testing** - End-to-end validation and performance testing

### **📋 Next Steps**
1. **Implement flows** using Flow Builder UI
2. **Configure community** pages and navigation
3. **Complete testing** and validation
4. **Deploy to production** when ready

---

## 🛠️ **Development Workflow**

### **1. Development Phase**
- Use scratch orgs for development
- Follow Dynamic Apex best practices
- Implement security-first approach
- Test with provided test data

### **2. Testing Phase**
- Unit testing with comprehensive coverage
- Integration testing with real data
- Performance testing and optimization
- User acceptance testing

### **3. Deployment Phase**
- Automated deployment scripts
- Permission set assignment
- Community configuration
- Production validation

---

## 🔧 **Configuration**

### **Environment Variables**
```bash
# Set your org alias
export ENOS_ORG_ALIAS="ENOS-Dev"

# Set your org type (scratch, sandbox, production)
export ENOS_ORG_TYPE="scratch"
```

### **Custom Settings**
- **Security settings** - Field-level security and sharing rules
- **Community settings** - Guest access and member permissions
- **Flow settings** - Automation triggers and schedules
- **Integration settings** - External system connections

---

## 🚨 **Troubleshooting**

### **Common Issues**
1. **Permission Set Deployment Failures**
   - Verify user has System Administrator profile
   - Check API access is enabled
   - Ensure "Customize Application" permission

2. **Custom Object Deployment Issues**
   - Deploy entire object directory, not just fields
   - Check for validation rule conflicts
   - Verify field metadata syntax

3. **Flow Deployment Issues**
   - Use Flow Builder UI instead of metadata files
   - Check flow variable definitions
   - Verify object and field references

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

## 📊 **Performance & Monitoring**

### **Built-in Monitoring**
- **Performance Dashboard** - Real-time metrics and alerts
- **Query Performance** - Execution time and frequency tracking
- **Resource Usage** - Governor limit monitoring
- **Error Tracking** - Comprehensive error logging

### **Optimization Features**
- **Dynamic query caching** for frequently accessed data
- **Retry mechanisms** for resilient operations
- **Performance alerts** for slow queries
- **Resource optimization** recommendations

---

## 🔒 **Security Features**

### **Data Protection**
- **Field-level security** enforcement with `WITH USER_MODE`
- **Record-level sharing** rules and ownership controls
- **Input validation** and sanitization with enhanced security
- **SOQL injection prevention** and runtime security validation
- **Complete DML operation security** through USER_MODE enforcement

### **Access Control**
- **Role-based permissions** with custom permission sets
- **Community user isolation** from internal data
- **API access controls** and rate limiting
- **Audit logging** for all operations

---

## 🌟 **Best Practices**

### **Development**
1. **Always use ENOS_SecurityUtils** for data access
2. **Implement proper error handling** with try-catch blocks
3. **Use dynamic queries** only when necessary
4. **Test thoroughly** with provided test data

### **Security**
1. **Follow principle of least privilege** for permissions
2. **Validate all user inputs** before processing
3. **Use secure defaults** for all configurations
4. **Regular security reviews** and updates

### **Performance**
1. **Monitor query performance** using built-in dashboard
2. **Implement caching** for frequently accessed data
3. **Use bulk operations** for large datasets
4. **Optimize governor limit usage**

---

## 🤝 **Contributing**

### **Development Guidelines**
1. **Follow existing code patterns** and naming conventions
2. **Update documentation** for all changes
3. **Test thoroughly** before submitting changes
4. **Maintain security standards** in all implementations

### **Code Review Process**
1. **Submit pull request** with detailed description
2. **Include tests** for new functionality
3. **Update relevant documentation**
4. **Address review feedback** promptly

---

## 📞 **Support & Contact**

### **Internal Support**
- **Development Team**: [Team Contact Information]
- **System Administrator**: [Admin Contact Information]
- **Project Manager**: [PM Contact Information]

### **External Resources**
- **Salesforce Support**: [Support Case Number]
- **Community Forums**: [Forum Links]
- **Documentation**: [Salesforce Documentation]

---

## 📝 **License**

This project is licensed under the [License Type] - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **Salesforce Platform** for the robust foundation
- **Lightning Web Components** for modern UI development
- **Dynamic Apex** for flexible and secure development
- **Experience Cloud** for external user access

---

## 📈 **Roadmap**

### **Phase 1: Foundation** ✅ **COMPLETE**
- Core infrastructure and security
- Dynamic Apex implementation
- Basic UI components

### **Phase 2: Automation** 🔄 **IN PROGRESS**
- Flow implementation
- Community configuration
- Integration testing

### **Phase 3: Enhancement** 📋 **PLANNED**
- Advanced analytics
- Mobile optimization
- Third-party integrations

### **Phase 4: Scale** 📋 **FUTURE**
- Multi-org support
- Advanced AI features
- Global deployment

---

**Note**: This platform is designed for production use with enterprise-grade security and performance. Follow all documentation and best practices for successful implementation and operation.
