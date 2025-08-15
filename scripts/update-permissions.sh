#!/bin/bash

# ENOS Permission Update Script
# This script updates and deploys all permission sets and profiles

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_step() {
    echo -e "${YELLOW}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if org alias is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <org-alias>"
    echo "Example: $0 ENOS-Test"
    exit 1
fi

ORG_ALIAS="$1"

print_header "ENOS Permission Update Script"
echo "Target Org: $ORG_ALIAS"
echo ""

# Step 1: Deploy updated permission sets and profiles
print_step "Deploying updated permission sets and profiles..."
if sf project deploy start --target-org "$ORG_ALIAS" --source-dir force-app/main/default; then
    print_success "Permission sets and profiles deployed successfully"
else
    print_error "Failed to deploy permission sets and profiles"
    exit 1
fi

echo ""

# Step 2: Get current user info
print_step "Getting current user information..."
CURRENT_USER=$(sf org display --target-org "$ORG_ALIAS" --json | jq -r '.result.username')
if [ "$CURRENT_USER" != "null" ] && [ -n "$CURRENT_USER" ]; then
    print_success "Current user: $CURRENT_USER"
else
    print_error "Could not determine current user"
    exit 1
fi

echo ""

# Step 3: Assign ENOS_Admin_Access to current user
print_step "Assigning ENOS_Admin_Access permission set to current user..."
if sf data record create --target-org "$ORG_ALIAS" --sobjecttype PermissionSetAssignment --values "AssigneeId=$CURRENT_USER,PermissionSetId=ENOS_Admin_Access"; then
    print_success "Admin permission set assigned successfully"
else
    print_info "Admin permission set may already be assigned or doesn't exist yet"
fi

echo ""

# Step 4: List all permission sets for reference
print_step "Available permission sets in org:"
sf data query --target-org "$ORG_ALIAS" --query "SELECT Name, Label, Description FROM PermissionSet WHERE Name LIKE '%ENOS%'" --result-format human || print_info "No ENOS permission sets found"

echo ""

# Step 5: List all profiles for reference
print_step "Available profiles in org:"
sf data query --target-org "$ORG_ALIAS" --query "SELECT Name, UserType, UserLicense FROM Profile WHERE Name LIKE '%ENOS%' OR Name LIKE '%ENOS%'" --result-format human || print_info "No ENOS profiles found"

echo ""

# Step 6: Show permission assignment status
print_step "Current user permission assignments:"
sf data query --target-org "$ORG_ALIAS" --query "SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId = '$CURRENT_USER'" --result-format human || print_info "Could not retrieve permission assignments"

echo ""

print_header "Permission Update Complete!"
echo ""
echo "Next Steps:"
echo "1. Verify permission sets are properly assigned in Setup > Permission Sets"
echo "2. Test ENOS functionality with different user types"
echo "3. Adjust permissions as needed for your specific use case"
echo ""
echo "Useful Commands:"
echo "  sf data query --target-org $ORG_ALIAS --query \"SELECT Name, Label FROM PermissionSet WHERE Name LIKE '%ENOS%'\""
echo "  sf data query --target-org $ORG_ALIAS --query \"SELECT PermissionSet.Name, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name LIKE '%ENOS%'\""
echo "  sf org open --target-org $ORG_ALIAS"
echo ""
echo -e "${GREEN}Happy permission managing! 🔐${NC}"
