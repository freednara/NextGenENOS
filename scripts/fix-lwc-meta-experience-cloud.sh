#!/bin/bash

# ENOS LWC Meta.xml Fix Script for Experience Cloud
# This script fixes the meta.xml files by removing unsupported supportedFormFactors for lightningCommunity__Page

set -e

echo "🚀 ENOS LWC Meta.xml Fix Script for Experience Cloud"
echo "====================================================="

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

echo "📋 Fixing LWC meta.xml files for Experience Cloud compatibility..."
echo ""

for component in "${LWC_COMPONENTS[@]}"; do
    echo "🔧 Fixing $component..."
    
    # Create the corrected meta.xml content
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
        <!-- Internal Lightning with form factors -->
        <targetConfig targets="lightning__AppPage,lightning__RecordPage,lightning__HomePage">
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
    
    echo "✅ $component fixed"
done

echo ""
echo "📋 All LWC components now have:"
echo "✅ Proper Experience Cloud targets (lightningCommunity__Page, lightningCommunity__Default)"
echo "✅ Internal Lightning targets (lightning__AppPage, lightning__RecordPage, lightning__HomePage)"
echo "✅ Supported form factors ONLY for internal Lightning targets (not Experience Cloud)"
echo "✅ Proper targetConfigs for Experience Builder"
echo "✅ No unsupported tags for lightningCommunity__Page"
echo ""
echo "🎯 Next Steps:"
echo "1. Deploy the corrected meta.xml files"
echo "2. Close and reopen Experience Builder (refresh isn't enough)"
echo "3. Check if LWC components now appear in the component palette"
echo "4. Try adding components to a page"
echo ""
echo "📚 For troubleshooting, see ERROR_PATTERNS_ANALYSIS.md Pattern #22"
