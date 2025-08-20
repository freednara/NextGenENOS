#!/bin/bash

# ENOS Platform Package Deployment Script
# Deploys the complete ENOS platform using comprehensive package.xml
#
# Usage: ./scripts/deploy-package.sh [org-alias] [package-type]
#
# Examples:
#   ./scripts/deploy-package.sh ENOS-Dev full        # Deploy full platform
#   ./scripts/deploy-package.sh ENOS-Dev core        # Deploy core components only
#   ./scripts/deploy-package.sh ENOS-Dev lwc         # Deploy LWC components only

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
PACKAGE="📦"

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
PACKAGE_TYPE=${2:-"full"}

print_header "${PACKAGE} ENOS Platform Package Deployment"

print_info "Configuration:"
print_info "  Target Org: $ORG_ALIAS"
print_info "  Package Type: $PACKAGE_TYPE"
print_info "  Source Directory: force-app/main/default"

# Check if org exists and is accessible
print_step "Verifying org accessibility..."
if ! sf org display --target-org "$ORG_ALIAS" > /dev/null 2>&1; then
    print_error "Org '$ORG_ALIAS' not accessible. Please check org alias and authentication."
    exit 1
fi

print_success "Org '$ORG_ALIAS' is accessible"

# Deploy based on package type
case $PACKAGE_TYPE in
    "full")
        print_step "Deploying full ENOS platform..."
        if sf project deploy start --target-org "$ORG_ALIAS" --source-dir force-app/main/default --wait 10; then
            print_success "Full platform deployment completed successfully"
        else
            print_error "Full platform deployment failed"
            exit 1
        fi
        ;;
    "core")
        print_step "Deploying core ENOS components..."
        # Deploy core components (Apex classes, custom objects, permission sets)
        if sf project deploy start --target-org "$ORG_ALIAS" \
            --source-dir force-app/main/default/classes \
            --source-dir force-app/main/default/objects \
            --source-dir force-app/main/default/permissionsets \
            --source-dir force-app/main/default/messageChannels \
            --wait 10; then
            print_success "Core components deployment completed successfully"
        else
            print_error "Core components deployment failed"
            exit 1
        fi
        ;;
    "lwc")
        print_step "Deploying LWC components..."
        if sf project deploy start --target-org "$ORG_ALIAS" \
            --source-dir force-app/main/default/lwc \
            --wait 10; then
            print_success "LWC components deployment completed successfully"
        else
            print_error "LWC components deployment failed"
            exit 1
        fi
        ;;
    "fields")
        print_step "Deploying custom fields..."
        if sf project deploy start --target-org "$ORG_ALIAS" \
            --source-dir force-app/main/default/objects \
            --wait 10; then
            print_success "Custom fields deployment completed successfully"
        else
            print_error "Custom fields deployment failed"
            exit 1
        fi
        ;;
    *)
        print_error "Invalid package type: $PACKAGE_TYPE"
        print_info "Valid options: full, core, lwc, fields"
        exit 1
        ;;
esac

# Verify deployment
print_step "Verifying deployment..."
if sf project deploy report --use-most-recent --target-org "$ORG_ALIAS" --json | grep -q '"status":"Succeeded"'; then
    print_success "Deployment verification successful"
else
    print_warning "Deployment verification incomplete - check deployment status manually"
fi

print_header "${CHECKMARK} Package Deployment Complete"

print_info "Next Steps:"
print_info "1. Run verification script: ./scripts/verify-enos-deployment-simple.sh $ORG_ALIAS"
print_info "2. Configure profile field visibility (manual step required)"
print_info "3. Test LWC components in Experience Builder"
print_info "4. Verify permission set assignments"

print_success "ENOS platform package deployment completed successfully!"
