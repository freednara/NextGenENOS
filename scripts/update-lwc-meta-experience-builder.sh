#!/bin/bash

# ENOS LWC Meta.xml Update Script for Experience Builder
# This script updates all LWC meta.xml files to follow best practices for Experience Builder visibility

set -e

echo "🚀 ENOS LWC Meta.xml Update Script for Experience Builder"
echo "=========================================================="

# List of LWC components to update
LWC_COMPONENTS=(
    "enosProductBrowser"
    "enosProductDetail"
    "enosOrderHistory"
    "enosRecentlyViewed"
    "enosMyQuotes"
    "enosPaymentGateway"
)

echo "📋 Updating LWC meta.xml files for Experience Builder compatibility..."
echo ""

for component in "${LWC_COMPONENTS[@]}"; do
    echo "🔧 Updating $component..."
    
    # Create the updated meta.xml content
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
        
        <!-- Internal Lightning (Optional) -->
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
        
        <!-- Utility Bar and Flow Screen -->
        <target>lightning__UtilityBar</target>
        <target>lightning__FlowScreen</target>
    </targets>
    <targetConfigs>
        <!-- Experience Cloud and Internal Lightning -->
        <targetConfig targets="lightningCommunity__Page,lightningCommunity__Default,lightning__AppPage,lightning__RecordPage,lightning__HomePage">
            <supportedFormFactors>
                <supportedFormFactor type="Large"/>
                <supportedFormFactor type="Small"/>
            </supportedFormFactors>
        </targetConfig>
        
        <!-- Record Page specific configuration -->
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Product2</object>
                <object>Account</object>
                <object>Contact</object>
                <object>Order</object>
                <object>Cart__c</object>
                <object>Cart_Item__c</object>
            </objects>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
EOF
    
    echo "✅ $component updated"
done

echo ""
echo "📋 Core components already updated manually:"
echo "✅ enosProductCatalog"
echo "✅ enosShoppingCart" 
echo "✅ enosMiniCart"
echo ""
echo "📋 All LWC components now have:"
echo "✅ Proper Experience Cloud targets (lightningCommunity__Page, lightningCommunity__Default)"
echo "✅ Internal Lightning targets (lightning__AppPage, lightning__RecordPage, lightning__HomePage)"
echo "✅ Supported form factors (Large, Small)"
echo "✅ Proper targetConfigs for Experience Builder"
echo "✅ No hard-required properties that could hide components"
echo ""
echo "🎯 Next Steps:"
echo "1. Deploy the updated meta.xml files"
echo "2. Close and reopen Experience Builder (refresh isn't enough)"
echo "3. Check if LWC components now appear in the component palette"
echo "4. Try adding components to a page"
echo ""
echo "📚 For troubleshooting, see ERROR_PATTERNS_ANALYSIS.md Pattern #22"
