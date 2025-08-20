#!/bin/bash

# Update LWC Component Names to Match New Directory Structure
# This script updates class names, file names, and references

echo "Updating LWC component names..."

# Function to update component files
update_component() {
    local old_name=$1
    local new_name=$2
    
    echo "Updating $old_name to $new_name..."
    
    cd force-app/main/default/lwc/$new_name
    
    # Rename files to match new component name
    mv "${old_name}.js" "${new_name}.js" 2>/dev/null || echo "File already renamed"
    mv "${old_name}.html" "${new_name}.html" 2>/dev/null || echo "File already renamed"
    mv "${old_name}.css" "${new_name}.css" 2>/dev/null || echo "File already renamed"
    mv "${old_name}.js-meta.xml" "${new_name}.js-meta.xml" 2>/dev/null || echo "File already renamed"
    
    # Update class names in JavaScript files
    if [ -f "${new_name}.js" ]; then
        sed -i '' "s/class ${old_name}/class ${new_name}/g" "${new_name}.js"
        sed -i '' "s/export default class ${old_name}/export default class ${new_name}/g" "${new_name}.js"
    fi
    
    # Update meta.xml files
    if [ -f "${new_name}.js-meta.xml" ]; then
        sed -i '' "s/<masterLabel>${old_name}<\/masterLabel>/<masterLabel>${new_name}<\/masterLabel>/g" "${new_name}.js-meta.xml"
    fi
    
    cd ../../../..
}

# Update all components
update_component "ENOS_miniCart" "enosMiniCart"
update_component "ENOS_myQuotes" "enosMyQuotes"
update_component "ENOS_orderHistory" "enosOrderHistory"
update_component "ENOS_paymentGateway" "enosPaymentGateway"
update_component "ENOS_productBrowser" "enosProductBrowser"
update_component "ENOS_productCatalog" "enosProductCatalog"
update_component "ENOS_productDetail" "enosProductDetail"
update_component "ENOS_recentlyViewed" "enosRecentlyViewed"
update_component "ENOS_shoppingCart" "enosShoppingCart"

echo "LWC component names updated!"
echo "Now you can deploy the components to see them in Experience Builder."

