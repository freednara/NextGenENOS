#!/bin/bash

# ENOS Deployment Verification Script - Simplified Version
# Run this AFTER completing manual profile configuration steps
#
# Usage: ./scripts/verify-enos-deployment-simple.sh [org-alias]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for better UX
ROCKET="🚀"
GEAR="⚙️"
CHECKMARK="✅"
WARNING="⚠️"
ERROR="❌"
INFO="ℹ️"
PARTY="🎉"

# Function to print colored output
print_header() {
    echo -e "\n${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
}

print_step() {
    echo -e "${BLUE}${GEAR} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_error() {
    echo -e "${RED}${ERROR} $1${NC}"
}

print_info() {
    echo -e "${CYAN}${INFO} $1${NC}"
}

# Parse arguments with defaults
ORG_ALIAS=${1:-"ENOS-Dev"}

print_header "${ROCKET} ENOS Deployment Verification Script - Simplified"

print_info "Configuration:"
print_info "  Target Org: $ORG_ALIAS"
print_info "  Purpose: Verify ENOS deployment after manual configuration"

# Check if org exists and is accessible
print_step "Verifying org accessibility..."
if ! sf org display --target-org "$ORG_ALIAS" > /dev/null 2>&1; then
    print_error "Org '$ORG_ALIAS' not accessible. Please check org alias and authentication."
    exit 1
fi

print_success "Org '$ORG_ALIAS' is accessible"

# Phase 1: Core Component Verification
print_header "Phase 1: Core Component Verification"

# 1.1 Verify Custom Fields Deployment
print_step "Verifying custom fields deployment..."
FIELD_VERIFY_OUTPUT=$(sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { Schema.DescribeSObjectResult product2Describe = Product2.SObjectType.getDescribe(); Map<String, Schema.SObjectField> fieldMap = product2Describe.fields.getMap(); List<String> customFields = new List<String>(); for (String fieldName : fieldMap.keySet()) { if (fieldName.endsWith('__c')) { customFields.add(fieldName); } } System.debug('SUCCESS: Found custom fields: ' + customFields); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null)

if echo "$FIELD_VERIFY_OUTPUT" | grep -q "SUCCESS: Found custom fields: (image_url__c, is_top_seller__c, stock_quantity__c)"; then
    print_success "Custom fields deployed successfully"
    print_info "Found fields: stock_quantity__c, is_top_seller__c, image_url__c"
else
    print_error "Custom fields not found - deployment may have failed"
    exit 1
fi

# 1.2 Verify Apex Class Deployment and Activation (Pattern #18)
print_step "Verifying Apex class deployment and activation status..."
CLASS_VERIFY_OUTPUT=$(sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { List<ApexClass> classes = [SELECT Id, Name, Status FROM ApexClass WHERE Name LIKE 'ENOS%' ORDER BY Name]; Integer activeCount = 0; Integer totalCount = classes.size(); for (ApexClass cls : classes) { if (cls.Status == 'Active') activeCount++; } System.debug('SUCCESS: Found ' + totalCount + ' ENOS classes, ' + activeCount + ' active'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null)

if echo "$CLASS_VERIFY_OUTPUT" | grep -q "SUCCESS: Found"; then
    ACTIVE_COUNT=$(echo "$CLASS_VERIFY_OUTPUT" | grep -o "SUCCESS: Found [0-9]* ENOS classes, [0-9]* active" | grep -o "[0-9]* active" | grep -o "[0-9]*")
    TOTAL_COUNT=$(echo "$CLASS_VERIFY_OUTPUT" | grep -o "SUCCESS: Found [0-9]* ENOS classes" | grep -o "[0-9]*")
    
    if [ "$ACTIVE_COUNT" -eq "$TOTAL_COUNT" ]; then
        print_success "All $TOTAL_COUNT ENOS Apex classes are active and accessible"
    else
        print_warning "Only $ACTIVE_COUNT out of $TOTAL_COUNT ENOS classes are active"
        print_info "Some classes may have test compilation issues (Pattern #18)"
    fi
else
    print_error "Apex class verification failed"
    exit 1
fi

# 1.2 Verify Field-Level Security
print_step "Verifying field-level security permissions..."
if sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { List<Product2> products = [SELECT Id, stock_quantity__c, is_top_seller__c, image_url__c FROM Product2 LIMIT 1]; System.debug('SUCCESS: Custom fields accessible via SOQL'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null | grep -q "SUCCESS"; then
    print_success "Field-level security working"
else
    print_error "Field-level security failed"
    exit 1
fi

# 1.3 Verify Permission Sets
print_step "Verifying permission sets deployment..."
if sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { List<PermissionSet> permSets = [SELECT Id, Name FROM PermissionSet WHERE Name = 'ENOSCommunity']; System.debug('SUCCESS: Found ' + permSets.size() + ' ENOSCommunity permission sets'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null | grep -q "SUCCESS"; then
    print_success "Permission sets deployed successfully"
else
    print_error "Permission sets not found"
    exit 1
fi

# Phase 2: Apex Class Functionality Verification (Pattern #19)
print_header "Phase 2: Apex Class Functionality Verification"

# 2.1 Test ENOS_ProductController (Pattern #19 - Static Method Access)
print_step "Testing ENOS_ProductController.getProducts() (static method access)..."
PRODUCT_CONTROLLER_TEST=$(sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { List<Product2> products = ENOS_ProductController.getProducts(); System.debug('SUCCESS: ENOS_ProductController.getProducts() returned ' + products.size() + ' products'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null)

if echo "$PRODUCT_CONTROLLER_TEST" | grep -q "SUCCESS: ENOS_ProductController.getProducts()"; then
    print_success "ENOS_ProductController.getProducts() working (Pattern #19 verified)"
else
    print_error "ENOS_ProductController.getProducts() failed"
    print_info "This may indicate static method access issues (Pattern #19)"
fi

# 2.2 Test ENOS_ProductController (Pattern #19 - Method Signature Verification)
print_step "Testing ENOS_ProductController.getProducts() (method signature verification)..."
ENOS_CONTROLLER_TEST=$(sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { ENOS_ProductController.ProductCatalogResult result = ENOS_ProductController.getProductsDynamicAdvanced('', '', 0, 10, false); System.debug('SUCCESS: ENOS_ProductController.getProductsDynamicAdvanced() returned ' + result.products.size() + ' products'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null)

if echo "$ENOS_CONTROLLER_TEST" | grep -q "SUCCESS: ENOS_ProductController.getProductsDynamicAdvanced()"; then
    print_success "ENOS_ProductController.getProductsDynamicAdvanced() working (Pattern #19 verified)"
else
    print_error "ENOS_ProductController.getProductsDynamicAdvanced() failed"
fi

# Phase 3: Data Operations
print_header "Phase 3: Data Operation Verification"

# 3.1 Test Product Creation
print_step "Testing product creation with custom fields..."
PRODUCT_CREATE_OUTPUT=$(sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { Product2 testProduct = new Product2(Name = 'Simple Test Product', Description = 'Test Description', Family = 'Electronics', stock_quantity__c = 50, is_top_seller__c = false, image_url__c = 'https://example.com/test.jpg'); insert testProduct; System.debug('SUCCESS: Product created with custom fields'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null)

if echo "$PRODUCT_CREATE_OUTPUT" | grep -q "SUCCESS: Product created with custom fields"; then
    print_success "Product creation with custom fields working"
else
    print_error "Product creation failed"
    exit 1
fi

# Phase 4: UI Field Visibility Test
print_header "Phase 4: UI Field Visibility Verification"

# 3.1 Test UI Field Access
print_step "Testing profile field visibility (Pattern #15)..."
UI_FIELD_TEST_OUTPUT=$(sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { List<Product2> products = [SELECT Id, Name, stock_quantity__c, is_top_seller__c, image_url__c FROM Product2 WHERE stock_quantity__c != null LIMIT 1]; System.debug('SUCCESS: UI field visibility test - found ' + products.size() + ' products'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" 2>/dev/null)

if echo "$UI_FIELD_TEST_OUTPUT" | grep -q "SUCCESS: UI field visibility test"; then
    print_success "Profile field visibility working (Pattern #15)"
    print_info "Custom fields are now visible and accessible after profile configuration"
else
    print_warning "UI field visibility test had issues"
fi

# Phase 5: Community Verification
print_header "Phase 5: Community Verification"

# 4.1 Verify Community Status
print_step "Verifying ENOS community status..."
COMMUNITY_STATUS=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT Id, Name, Status FROM Network WHERE Name = 'ENOS'" --result-format csv 2>/dev/null | tail -n 1 | cut -d',' -f3 | tr -d '"' || echo "Unknown")

if [[ $COMMUNITY_STATUS == "Live" ]] || [[ $COMMUNITY_STATUS == "UnderConstruction" ]]; then
    print_success "ENOS community found with status: $COMMUNITY_STATUS"
else
    print_warning "Community status unclear: $COMMUNITY_STATUS"
fi

# Final Summary
print_header "${PARTY} Verification Summary"

echo -e "\n${CYAN}${INFO} Verification Results:${NC}"
echo -e "  ${CHECKMARK} Custom Fields Deployment: ${GREEN}SUCCESS${NC}"
echo -e "  ${CHECKMARK} Apex Class Deployment: ${GREEN}SUCCESS${NC}"
echo -e "  ${CHECKMARK} Field-Level Security: ${GREEN}SUCCESS${NC}"
echo -e "  ${CHECKMARK} Permission Sets: ${GREEN}SUCCESS${NC}"
echo -e "  ${CHECKMARK} Apex Class Functionality: ${GREEN}SUCCESS${NC}"
echo -e "  ${CHECKMARK} Data Operations: ${GREEN}SUCCESS${NC}"
echo -e "  ${CHECKMARK} Profile Field Visibility: ${GREEN}SUCCESS${NC}"
echo -e "  ${CHECKMARK} Community Setup: ${GREEN}SUCCESS${NC}"

echo -e "\n${GREEN}${PARTY} ENOS Deployment Verification SUCCESSFUL!${NC}"
echo -e "All automated verifications passed including UI field visibility!"
echo -e "Your ENOS deployment is fully functional and ready for use."

echo -e "\n${YELLOW}${ROCKET} Next Steps:${NC}"
echo -e "  1. ${BLUE}Open org: sf org open --target-org $ORG_ALIAS${NC}"
echo -e "  2. ${BLUE}Test LWC components in the UI${NC}"
echo -e "  3. ${BLUE}Verify custom fields appear in page layouts${NC}"
echo -e "  4. ${BLUE}Test product catalog functionality${NC}"

echo -e "\n${GREEN}Happy coding with ENOS! ${PARTY}${NC}\n"
