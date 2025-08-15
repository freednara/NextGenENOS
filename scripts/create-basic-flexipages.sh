#!/bin/bash

# Basic FlexiPage Creator for ENOS
# This script creates basic FlexiPages for the ENOS application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ORG_ALIAS=${1:-"ENOS-Test"}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📄 Creating Basic FlexiPages${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}ℹ️ Target Org: ${ORG_ALIAS}${NC}"

# Create basic product browser app page
echo ""
echo -e "${YELLOW}⚙️ Creating basic Lightning pages via metadata...${NC}"

# Create minimal working flexipage
cat > /tmp/simple_app_page.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<FlexiPage xmlns="http://soap.sforce.com/2006/04/metadata">
    <flexiPageRegions>
        <itemInstances>
            <componentInstance>
                <componentName>flexipage:richText</componentName>
                <identifier>welcomeText</identifier>
                <componentInstanceProperties>
                    <name>richTextValue</name>
                    <value>&lt;h1&gt;🛍️ ENOS Product Browser&lt;/h1&gt;&lt;p&gt;Use this page to browse and manage products&lt;/p&gt;</value>
                </componentInstanceProperties>
            </componentInstance>
        </itemInstances>
        <mode>Append</mode>
        <name>main</name>
        <type>Region</type>
    </flexiPageRegions>
    <masterLabel>ENOS Products</masterLabel>
    <template>
        <name>flexipage:appHomeTemplateDesktop</name>
    </template>
    <type>AppPage</type>
</FlexiPage>
EOF

# Try deploying the basic page
echo -e "${YELLOW}⚙️ Deploying basic app page...${NC}"
if sf project deploy start --metadata-dir /tmp --target-org $ORG_ALIAS --wait 10; then
    echo -e "${GREEN}✅ Basic flexipage deployed successfully${NC}"
else
    echo -e "${RED}❌ Basic flexipage deployment failed${NC}"
    echo -e "${YELLOW}⚠️ Manual setup required - see scripts/setup-flexipages.md${NC}"
fi

# Clean up
rm -f /tmp/simple_app_page.xml

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}📋 FlexiPage Setup Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}📖 Next Steps:${NC}"
echo -e "  1. Open org: ${BLUE}sf org open --target-org $ORG_ALIAS${NC}"
echo -e "  2. Go to Setup → Lightning App Builder"
echo -e "  3. Create new Lightning Pages manually"
echo -e "  4. Add ENOS LWC components:"
echo -e "     • productBrowser"
echo -e "     • productCatalog"
echo -e "     • miniCart"
echo -e "     • shoppingCart"
echo -e "     • recentlyViewed"
echo ""
echo -e "${CYAN}📄 Detailed Instructions:${NC}"
echo -e "  • Follow: ${BLUE}scripts/setup-flexipages.md${NC}"
echo -e "  • All components are deployed and ready to use"
echo -e "  • Templates work best when created via UI"
echo ""
echo -e "${GREEN}Happy page building! ⚡${NC}"
