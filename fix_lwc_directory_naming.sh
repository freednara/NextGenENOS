#!/bin/bash

# Fix LWC Component Directory Naming
# Salesforce LWC requires lowercase-first camelCase naming

echo "Fixing ENOS LWC component directory naming..."

# Create backup directory
mkdir -p force-app/main/default/lwc/backup_$(date +%Y%m%d_%H%M%S)

# Function to rename component directory
rename_component() {
    local old_name=$1
    local new_name=$2
    
    echo "Renaming $old_name to $new_name..."
    
    # Move to parent directory
    cd force-app/main/default/lwc
    
    # Rename the directory
    mv "$old_name" "$new_name"
    
    # Go back to project root
    cd ../../../..
}

# Rename all ENOS components to follow LWC naming conventions
rename_component "ENOS_miniCart" "enosMiniCart"
rename_component "ENOS_myQuotes" "enosMyQuotes"
rename_component "ENOS_orderHistory" "enosOrderHistory"
rename_component "ENOS_paymentGateway" "enosPaymentGateway"
rename_component "ENOS_productBrowser" "enosProductBrowser"
rename_component "ENOS_productCatalog" "enosProductCatalog"
rename_component "ENOS_productDetail" "enosProductDetail"
rename_component "ENOS_recentlyViewed" "enosRecentlyViewed"
rename_component "ENOS_shoppingCart" "enosShoppingCart"

echo "LWC component directory naming fixed!"
echo "Components now follow proper Salesforce LWC naming conventions:"
echo "- enosMiniCart"
echo "- enosMyQuotes"
echo "- enosOrderHistory"
echo "- enosPaymentGateway"
echo "- enosProductBrowser"
echo "- enosProductCatalog"
echo "- enosProductDetail"
echo "- enosRecentlyViewed"
echo "- enosShoppingCart"
echo ""
echo "Now you need to update the component class names and references."

