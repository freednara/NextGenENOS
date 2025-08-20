#!/bin/bash

# ENOS LWC Meta.xml Final Fix Script
# This script creates clean, simple meta.xml files that work in Experience Builder

set -e

echo "🚀 ENOS LWC Meta.xml Final Fix Script"
echo "======================================"

# List of LWC components to fix
LWC_COMPONENTS=(
    "enosProductCatalog"
    "enosShoppingCart"
    "enosMiniCart"
    "enosProductBrowser"
    "enosProductDetail"
    "enosOrderHistory"
    "enosRecentlyViewed"
    "enosMyQuotes"
    "enosPaymentGateway"
)

echo "📋 Creating clean, simple meta.xml files for Experience Builder..."
echo ""

for component in "${LWC_COMPONENTS[@]}"; do
    echo "🔧 Fixing $component..."
    
    # Create the clean, simple meta.xml content
    cat > "force-app/main/default/lwc/$component/$component.js-meta.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>58.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>$component</masterLabel>
    <targets>
        <!-- Experience Cloud (Primary) -->
        <target>lightningCommunity__Page</target>
        <target>lightningCommunity__Default</target>
        
        <!-- Internal Lightning -->
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
        
        <!-- Utility Bar and Flow Screen -->
        <target>lightning__UtilityBar</target>
        <target>lightning__FlowScreen</target>
    </targets>
</LightningComponentBundle>
EOF
    
    echo "✅ $component fixed with clean configuration"
done

echo ""
echo "📋 All LWC components now have:"
echo "✅ Simple, clean meta.xml structure"
echo "✅ Proper Experience Cloud targets (lightningCommunity__Page, lightningCommunity__Default)"
echo "✅ Internal Lightning targets (lightning__AppPage, lightning__RecordPage, lightning__HomePage)"
echo "✅ No complex targetConfigs that could cause conflicts"
echo "✅ No duplicate target specifications"
echo ""
echo "🎯 Next Steps:"
echo "1. Deploy the clean meta.xml files"
echo "2. Close and reopen Experience Builder (refresh isn't enough)"
echo "3. Check if LWC components now appear in the component palette"
echo "4. Try adding components to a page"
echo ""
echo "📚 For troubleshooting, see ERROR_PATTERNS_ANALYSIS.md Pattern #22"
