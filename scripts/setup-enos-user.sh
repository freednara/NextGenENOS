#!/bin/bash

# ENOS Community User Setup Script
# This script configures a community user with proper permissions for the ENOS e-commerce platform
# 
# Usage: ./scripts/setup-enos-user.sh [target-org-alias]
# 
# If no org alias is provided, uses the default org

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse arguments
TARGET_ORG=${1:-""}
ORG_FLAG=""

if [ -n "$TARGET_ORG" ]; then
    ORG_FLAG="--target-org $TARGET_ORG"
    print_status "Using target org: $TARGET_ORG"
else
    print_status "Using default org"
fi

print_status "🚀 Starting ENOS User Setup..."

# Check if we're in the right directory
if [ ! -f "sfdx-project.json" ]; then
    print_error "Not in a Salesforce project directory. Please run from project root."
    exit 1
fi

# Check if permission script exists
if [ ! -f "scripts/apex/assign-enos-permissions.apex" ]; then
    print_error "Permission assignment script not found!"
    exit 1
fi

# Deploy permission sets first (in case they're not deployed)
print_status "📦 Deploying permission sets..."
if sf project deploy start $ORG_FLAG --source-dir force-app/main/default/permissionsets --ignore-errors > /dev/null 2>&1; then
    print_success "Permission sets deployed"
else
    print_warning "Permission sets deployment had issues (may already be deployed)"
fi

# Wait a moment for deployment to complete
sleep 2

# Run the permission assignment script
print_status "🔧 Assigning ENOS permissions..."
if sf apex run $ORG_FLAG --file scripts/apex/assign-enos-permissions.apex; then
    print_success "✅ ENOS permissions assigned successfully!"
else
    print_error "❌ Failed to assign permissions"
    exit 1
fi

# Get current user info
print_status "👤 Getting user information..."
CURRENT_USER=$(sf data query $ORG_FLAG --query "SELECT Name, Username FROM User WHERE Id = '$(sf org display $ORG_FLAG --json | jq -r '.result.id')'" --result-format csv | tail -n +2)
print_success "User setup complete for: $CURRENT_USER"

echo
print_success "🎉 ENOS user setup completed!"
echo -e "${BLUE}📱 You can now:${NC}"
echo "   • Access ENOS apps and components"
echo "   • Create and manage shopping carts"
echo "   • Process orders and payments"
echo "   • Use all ENOS features"
echo
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "   • Open your org: sf org open $ORG_FLAG"
echo "   • Navigate to App Launcher → ENOS"
echo "   • Add ProductBrowser/ProductCatalog to Lightning pages"
echo
