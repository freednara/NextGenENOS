#!/bin/bash

# ENOS Experience Cloud Site Activation Script
# This script helps activate the Experience Cloud site and verify LWC component availability

set -e

echo "🚀 ENOS Experience Cloud Site Activation Script"
echo "================================================"

# Check if org is specified
if [ -z "$1" ]; then
    echo "❌ Error: Please specify the target org alias"
    echo "Usage: ./activate-experience-cloud-site.sh <org-alias>"
    echo "Example: ./activate-experience-cloud-site.sh ENOS-Pattern-Test"
    exit 1
fi

ORG_ALIAS="$1"
echo "🎯 Target Org: $ORG_ALIAS"

echo ""
echo "📋 Step 1: Checking Experience Cloud Site Status"
echo "------------------------------------------------"

# Check current site status
echo "🔍 Querying Experience Cloud site status..."
sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "
try {
    System.debug('=== EXPERIENCE CLOUD SITE STATUS ===');
    List<Network> networks = [SELECT Id, Name, Status, UrlPathPrefix FROM Network];
    System.debug('Found ' + networks.size() + ' networks');
    for (Network net : networks) {
        System.debug('Site: ' + net.Name + ' - Status: ' + net.Status + ' - URL: ' + net.UrlPathPrefix);
    }
    System.debug('=== STATUS CHECK COMPLETE ===');
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
"

echo ""
echo "📋 Step 2: Checking LWC Component Deployment Status"
echo "---------------------------------------------------"

# Check LWC component status
echo "🔍 Querying LWC component deployment status..."
sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "
try {
    System.debug('=== LWC COMPONENT STATUS ===');
    List<ApexClass> lwcClasses = [SELECT Id, Name, Status FROM ApexClass WHERE Name LIKE 'enos%' ORDER BY Name];
    System.debug('Found ' + lwcClasses.size() + ' ENOS classes');
    for (ApexClass cls : lwcClasses) {
        System.debug('Class: ' + cls.Name + ' - Status: ' + cls.Status);
    }
    System.debug('=== LWC STATUS CHECK COMPLETE ===');
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
"

echo ""
echo "📋 Step 3: Manual Steps Required"
echo "--------------------------------"

echo "⚠️  IMPORTANT: The following steps must be completed manually in the Salesforce UI:"
echo ""
echo "1. 🏗️  Go to Setup → Digital Experiences → All Sites"
echo "2. 🔍 Find the 'ENOS' site in the list"
echo "3. ⚙️  Click the gear icon (⚙️) next to the ENOS site"
echo "4. 📝 Select 'Edit' from the dropdown"
echo "5. 🚀 Change the 'Status' from 'UnderConstruction' to 'Live'"
echo "6. 💾 Click 'Save'"
echo "7. ⏳ Wait a few minutes for the site to fully activate"
echo ""
echo "📋 Step 4: Verification Commands (Run after manual activation)"
echo "--------------------------------------------------------------"

echo "After manually activating the site, run these commands to verify:"
echo ""
echo "# Check if site is now live:"
echo "sf apex run --target-org $ORG_ALIAS --file /dev/stdin <<< \""
echo "try {"
echo "    List<Network> networks = [SELECT Id, Name, Status, UrlPathPrefix FROM Network];"
echo "    for (Network net : networks) {"
echo "        System.debug('Site: ' + net.Name + ' - Status: ' + net.Status);"
echo "    }"
echo "} catch (Exception e) {"
echo "    System.debug('ERROR: ' + e.getMessage());"
echo "}"
echo "\""
echo ""
echo "# Check LWC component accessibility:"
echo "sf apex run --target-org $ORG_ALIAS --file /dev/stdin <<< \""
echo "try {"
echo "    Type componentType = Type.forName('enosProductCatalog');"
echo "    System.debug('Component accessible: ' + componentType);"
echo "} catch (Exception e) {"
echo "    System.debug('Component not accessible: ' + e.getMessage());"
echo "}"
echo "\""
echo ""
echo "📋 Step 5: Expected Results After Activation"
echo "--------------------------------------------"

echo "✅ Experience Cloud site status should change to 'Live'"
echo "✅ LWC components should appear in Experience Cloud page builder"
echo "✅ Components should be available in Lightning App Builder"
echo "✅ Components should work correctly on live Experience Cloud pages"
echo ""
echo "🔍 If components still don't appear after activation:"
echo "1. Check if additional Experience Cloud targets are needed in meta.xml files"
echo "2. Verify component deployment status in Setup → Lightning Components"
echo "3. Check for any deployment errors in Setup → Deployment Status"
echo "4. Consider refreshing the Experience Cloud page builder"

echo ""
echo "🎯 Script completed. Please complete the manual steps above."
echo "📚 For more information, see ERROR_PATTERNS_ANALYSIS.md Pattern #22"
