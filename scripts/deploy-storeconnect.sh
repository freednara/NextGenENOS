#!/bin/bash

# StoreConnect Deployment Script
# This script automates the deployment of the StoreConnect e-commerce solution

echo "🚀 Starting StoreConnect Deployment..."
echo "======================================"

# Check if SFDX CLI is installed
if ! command -v sfdx &> /dev/null; then
    echo "❌ SFDX CLI is not installed. Please install it first."
    echo "   Visit: https://developer.salesforce.com/tools/sfdxcli"
    exit 1
fi

# Check if user is authenticated
if ! sfdx force:auth:list --json | grep -q "isActive.*true"; then
    echo "❌ Not authenticated to Salesforce. Please run 'sfdx force:auth:web:login' first."
    exit 1
fi

# Get current directory
PROJECT_DIR=$(pwd)
echo "📁 Project Directory: $PROJECT_DIR"

# Step 1: Deploy Custom Objects and Fields
echo ""
echo "📦 Step 1: Deploying Custom Objects and Fields..."
sfdx force:source:deploy -p force-app/main/default/objects -w 10

if [ $? -eq 0 ]; then
    echo "✅ Custom objects deployed successfully"
else
    echo "❌ Failed to deploy custom objects"
    exit 1
fi

# Step 2: Deploy Apex Classes
echo ""
echo "⚡ Step 2: Deploying Apex Classes..."
sfdx force:source:deploy -p force-app/main/default/classes -w 10

if [ $? -eq 0 ]; then
    echo "✅ Apex classes deployed successfully"
else
    echo "❌ Failed to deploy Apex classes"
    exit 1
fi

# Step 3: Deploy Lightning Web Components
echo ""
echo "⚡ Step 3: Deploying Lightning Web Components..."
sfdx force:source:deploy -p force-app/main/default/lwc -w 10

if [ $? -eq 0 ]; then
    echo "✅ Lightning Web Components deployed successfully"
else
    echo "❌ Failed to deploy Lightning Web Components"
    exit 1
fi

# Step 4: Deploy Permission Sets
echo ""
echo "🛡️ Step 4: Deploying permission sets..."
sfdx force:source:deploy -p force-app/main/default/permissionsets -w 10

if [ $? -eq 0 ]; then
    echo "✅ Permission sets deployed successfully"
else
    echo "❌ Failed to deploy permission sets"
    exit 1
fi

# Step 5: Assign Permission Set to Community Users
echo ""
echo "👥 Step 5: Assigning permission set to community users..."
read -p "Enter comma-separated usernames to assign StoreConnectCommunity: " USER_LIST
IFS=',' read -ra USERS <<< "$USER_LIST"
for USERNAME in "${USERS[@]}"; do
    sfdx force:user:permset:assign -n StoreConnectCommunity -o "$USERNAME"
done

# Step 6: Deploy any remaining metadata
echo ""
echo "📋 Step 6: Deploying remaining metadata..."
sfdx force:source:deploy -p force-app/main/default -w 10

if [ $? -eq 0 ]; then
    echo "✅ All metadata deployed successfully"
else
    echo "❌ Failed to deploy some metadata"
    exit 1
fi

# Step 7: Run tests (optional)
echo ""
echo "🧪 Step 7: Running tests..."
read -p "Do you want to run tests? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sfdx force:apex:test:run --testlevel RunLocalTests --wait 10
    if [ $? -eq 0 ]; then
        echo "✅ Tests passed successfully"
    else
        echo "❌ Some tests failed"
    fi
fi

# Step 8: Validation
echo ""
echo "🔍 Step 8: Validating deployment..."
sfdx force:source:retrieve -m CustomObject:Cart__c,CustomObject:Cart_Item__c,CustomObject:Shipping_Address__c

if [ $? -eq 0 ]; then
    echo "✅ Deployment validation successful"
else
    echo "❌ Deployment validation failed"
    exit 1
fi

echo ""
echo "🎉 StoreConnect Deployment Complete!"
echo "======================================"
echo ""
echo "📋 Next Steps:"
echo "1. Create Experience Cloud site in Salesforce Setup"
echo "2. Configure permission sets for community users"
echo "3. Set up product data and price books"
echo "4. Configure community pages and navigation"
echo "5. Test the solution with community users"
echo ""
echo "📚 For detailed setup instructions, see: STORE_CONNECT_README.md"
echo ""
echo "🔧 Manual Configuration Required:"
echo "- Experience Cloud site setup"
echo "- Permission set configuration"
echo "- Product data population"
echo "- Community page configuration"
echo ""
echo "💡 Need help? Check the README file or contact your Salesforce admin team."
