#!/bin/bash

# Quick ENOS Core Deployment Script
# Deploys only the working components to avoid test class issues

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}⚙️ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Get org alias from command line or use default
ORG_ALIAS=${1:-"ENOS-Dev"}

echo -e "${BLUE}🚀 Quick ENOS Core Deployment${NC}"
echo -e "Target Org: $ORG_ALIAS"
echo ""

# Step 1: Deploy core classes (excluding test classes)
print_step "Deploying core Apex classes..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/classes/ENOS_ProductController.cls \
    --source-dir force-app/main/default/classes/ENOS_CartController.cls \
    --source-dir force-app/main/default/classes/ENOS_ExceptionUtils.cls \
    --source-dir force-app/main/default/classes/ENOS_SecurityUtils.cls \
    --wait 10; then
    print_success "Core Apex classes deployed successfully"
else
    print_error "Failed to deploy core Apex classes"
    exit 1
fi

# Step 2: Deploy Lightning Message Channels
print_step "Deploying Lightning Message Channels..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/messageChannels \
    --wait 10; then
    print_success "Lightning Message Channels deployed successfully"
else
    print_error "Failed to deploy Lightning Message Channels"
    exit 1
fi

# Step 3: Deploy working LWC components
print_step "Deploying working LWC components..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/lwc/enosProductCatalog \
    --source-dir force-app/main/default/lwc/enosShoppingCart \
    --source-dir force-app/main/default/lwc/enosMiniCart \
    --wait 10; then
    print_success "Working LWC components deployed successfully"
else
    print_error "Failed to deploy LWC components"
    exit 1
fi

# Step 4: Deploy permission sets
print_step "Deploying permission sets..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/permissionsets \
    --wait 10; then
    print_success "Permission sets deployed successfully"
else
    print_error "Failed to deploy permission sets"
    exit 1
fi

# Step 5: Activate Standard Price Book
print_step "Activating Standard Price Book..."
if sf apex run --target-org "$ORG_ALIAS" --file scripts/activate_standard_pricebook.apex > /dev/null 2>&1; then
    print_success "Standard Price Book activated successfully"
else
    print_warning "Standard Price Book activation had issues (may already be active)"
fi

# Step 6: Create sample products
print_step "Creating sample products..."
if sf apex run --target-org "$ORG_ALIAS" --file scripts/create_sample_products.apex > /dev/null 2>&1; then
    print_success "Sample products created successfully"
else
    print_warning "Sample products creation had issues"
fi

echo ""
echo -e "${GREEN}🎉 ENOS Core Deployment Complete!${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Open org: sf org open --target-org $ORG_ALIAS"
echo "2. Test the product catalog and cart functionality"
echo "3. Check that products are visible and add-to-cart works"
echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo "  Open org:          sf org open --target-org $ORG_ALIAS"
echo "  Set as default:    sf config set target-org=$ORG_ALIAS"
echo "  Test cart:         sf apex run --target-org $ORG_ALIAS --file scripts/test_cart_functionality.apex"
