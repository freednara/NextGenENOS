#!/bin/bash

# Script to update all LWC meta.xml files to be universally available
# This ensures components can be used on all Lightning pages and Community pages

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Updating LWC meta.xml files for universal availability...${NC}"

# Function to update a component's meta.xml
update_component_meta() {
    local component_name=$1
    local meta_file="force-app/main/default/lwc/${component_name}/${component_name}.js-meta.xml"
    
    if [ -f "$meta_file" ]; then
        echo -e "${BLUE}Updating ${component_name}...${NC}"
        
        # Create the updated meta.xml content
        cat > "$meta_file" << EOF
<?xml version="1.0" encoding="UTF-8" ?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>58.0</apiVersion>
    <masterLabel>${component_name}</masterLabel>
    <isExposed>true</isExposed>
    <targets>
        <!-- Lightning App Builder -->
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
        
        <!-- Experience Cloud Sites (Community) -->
        <target>lightningCommunity__Page</target>
        <target>lightningCommunity__Default</target>
        
        <!-- Utility Bar and Flow Screen (optional) -->
        <target>lightning__UtilityBar</target>
        <target>lightning__FlowScreen</target>
    </targets>
    <targetConfigs>
        <!-- Allow use on all record types -->
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>*</object>
            </objects>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
EOF
        
        echo -e "${GREEN}✅ Updated ${component_name}${NC}"
    else
        echo -e "${BLUE}⚠️  Meta file not found for ${component_name}${NC}"
    fi
}

# List of components to update
components=(
    "enosOrderHistory"
    "enosRecentlyViewed"
    "enosMyQuotes"
    "enosPaymentGateway"
)

# Update each component
for component in "${components[@]}"; do
    update_component_meta "$component"
done

echo -e "${GREEN}🎉 All LWC meta.xml files updated for universal availability!${NC}"
echo -e "${BLUE}Components can now be used on:${NC}"
echo -e "  • Lightning App Builder pages"
echo -e "  • Record pages (all objects)"
echo -e "  • Home pages"
echo -e "  • Community pages"
echo -e "  • Utility bars"
echo -e "  • Flow screens"
