# ENOS Deployment Readiness Checklist

## Pre-Deployment Validation

### ✅ Code Quality & Security

- [x] All Apex classes use `public with sharing` for security
- [x] All SOQL queries include `WITH SECURITY_ENFORCED` clause
- [x] All CRUD/FLS checks implemented using `ENOS_SecurityUtils`
- [x] All LWC components follow SLDS design patterns
- [x] ESLint warnings resolved (no console.log, unused variables)
- [x] All methods include proper error handling with `AuraHandledException`

### ✅ Testing Coverage

- [x] Apex test classes created with `@TestSetup`
- [x] LWC smoke tests implemented for all components
- [x] Test coverage target: 75%+ (minimum requirement)
- [x] Security scenarios tested (permission checks)

### ✅ Data Migration Setup

- [x] SFDMU export/import plans configured
- [x] Category\_\_c CSV with 5 categories created
- [x] Product2 CSV with 20 products and category assignments
- [x] Pricebook2 and PricebookEntry CSVs configured
- [x] Lookup relationships properly mapped

### ✅ Permission Sets

- [x] ENOSCommunity permission set includes all required objects
- [x] CRUD permissions configured for Cart**c, Cart_Item**c
- [x] Read permissions for Product2, Category\_\_c, Pricebook2, PricebookEntry
- [x] Apex class access granted to community users

## Deployment Steps

### 1. Source Code Deployment

```bash
# Deploy all source code
sf project deploy start -o ENOS-Dev
```

### 2. Assign Permission Sets

```bash
# Assign to community user profile
sf org assign permset -n ENOSCommunity -o ENOS-Dev
```

### 3. Import Sample Data

```bash
# Import categories, products, and pricing
sf hardis:org:data:import -o ENOS-Dev -p data/sfdmu
```

### 4. Experience Cloud Configuration

- [ ] Publish Experience Cloud site
- [ ] Configure site header and navigation
- [ ] Set up product catalog pages
- [ ] Test community user access

### 5. Final Validation

- [ ] Run Apex tests: `sf apex run test -o ENOS-Dev`
- [ ] Verify community user can access product catalog
- [ ] Test cart functionality (add/remove items)
- [ ] Validate category filtering works
- [ ] Check mini-cart updates correctly

## Post-Deployment Tasks

### Monitoring & Maintenance

- [ ] Monitor error logs for any issues
- [ ] Verify data integrity (products, categories, pricing)
- [ ] Test user registration and login flows
- [ ] Validate all LWC components render correctly

### Performance Optimization

- [ ] Monitor SOQL query performance
- [ ] Check for any N+1 query issues
- [ ] Validate caching strategies (`@AuraEnabled(cacheable=true)`)
- [ ] Monitor community page load times

## Rollback Plan

### If Issues Arise

1. **Immediate Rollback**: `sf project deploy start --rollback-on-error -o ENOS-Dev`
2. **Data Rollback**: Export current data, then re-import previous version
3. **Permission Rollback**: Remove permission set assignments
4. **Component Rollback**: Deploy previous version of problematic components

### Emergency Contacts

- Development Team Lead
- Salesforce Administrator
- System Integration Specialist

## Success Criteria

### Functional Requirements

- [ ] Community users can browse products by category
- [ ] Search functionality works across product names and descriptions
- [ ] Cart operations (add, update, remove) function correctly
- [ ] Mini-cart displays accurate item counts
- [ ] All LWC components render without errors

### Performance Requirements

- [ ] Page load times < 3 seconds
- [ ] Product search results return in < 1 second
- [ ] Cart operations complete in < 2 seconds
- [ ] No timeout errors during normal operations

### Security Requirements

- [ ] Users can only access their own cart data
- [ ] No unauthorized access to product pricing or inventory
- [ ] All CRUD operations respect field-level security
- [ ] Community users cannot access admin functions

## Notes

- This deployment includes the new Category\_\_c object and enhanced product filtering
- All LWCs have been updated to use real category data instead of hardcoded values
- SFDMU data migration handles all object relationships automatically
- Permission sets ensure community users have minimal required access
- Rollback procedures are documented for emergency situations

**Deployment Date**: TBD
**Deployment Lead**: Development Team
**Approval Required**: Yes
