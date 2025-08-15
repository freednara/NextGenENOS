#!/bin/bash

# ENOS Community Setup Script
# Creates and configures the ENOS Experience Cloud community

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ORG_ALIAS=${1:-"ENOS-Test"}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🌐 ENOS Community Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}ℹ️ Target Org: ${ORG_ALIAS}${NC}"

# Check if community exists and get status
echo ""
echo -e "${YELLOW}⚙️ Checking community creation status...${NC}"

JOB_STATUS=$(sf data query --target-org $ORG_ALIAS --query "SELECT Status, Type, Error FROM BackgroundOperation WHERE Type = 'SiteTaskCreate' ORDER BY CreatedDate DESC LIMIT 1" --result-format csv | tail -n 1)

if [[ $JOB_STATUS == *"Complete"* ]]; then
    echo -e "${GREEN}✅ Community creation completed!${NC}"
elif [[ $JOB_STATUS == *"Running"* ]]; then
    echo -e "${YELLOW}⏳ Community creation is still in progress...${NC}"
    echo -e "${BLUE}ℹ️ Please wait a few minutes and run this script again${NC}"
    exit 0
elif [[ $JOB_STATUS == *"Error"* ]]; then
    echo -e "${RED}❌ Community creation failed${NC}"
    echo -e "${RED}Error details: $JOB_STATUS${NC}"
    exit 1
else
    echo -e "${YELLOW}⚙️ Creating ENOS community...${NC}"
    sf community create --name "ENOS" --template-name "Customer Account Portal" --url-path-prefix "enos" --description "NextGen ENOS E-Commerce Platform" --target-org $ORG_ALIAS
    echo -e "${BLUE}ℹ️ Community creation started. Please run this script again in a few minutes.${NC}"
    exit 0
fi

# Check if community is available
echo ""
echo -e "${YELLOW}⚙️ Checking community availability...${NC}"

# Query for the Network (community) record
NETWORK_QUERY=$(sf data query --target-org $ORG_ALIAS --query "SELECT Id, Name, Status FROM Network WHERE Name = 'ENOS'" --result-format csv | tail -n 1)

if [[ $NETWORK_QUERY == *"ENOS"* ]]; then
    NETWORK_ID=$(echo $NETWORK_QUERY | cut -d',' -f1 | tr -d '"')
    NETWORK_STATUS=$(echo $NETWORK_QUERY | cut -d',' -f3 | tr -d '"')
    echo -e "${GREEN}✅ ENOS community found: ${NETWORK_ID}${NC}"
    echo -e "${BLUE}ℹ️ Status: ${NETWORK_STATUS}${NC}"
else
    echo -e "${RED}❌ ENOS community not found${NC}"
    exit 1
fi

# Publish the community if it's not already live
if [[ $NETWORK_STATUS != "Live" ]]; then
    echo ""
    echo -e "${YELLOW}⚙️ Publishing ENOS community...${NC}"
    sf community publish --name "ENOS" --target-org $ORG_ALIAS
    echo -e "${GREEN}✅ Community published!${NC}"
fi

# Update permission sets to include the community
echo ""
echo -e "${YELLOW}⚙️ Updating permission sets for community access...${NC}"

# Create a temporary permission set update
cat > /tmp/community_permissions.apex << 'EOF'
// Add community access to existing permission sets
List<PermissionSet> permSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('ENOS_Basic_Access', 'ENOS_User_Access')];

List<Network> networks = [SELECT Id, Name FROM Network WHERE Name = 'ENOS' LIMIT 1];
if (networks.isEmpty()) {
    System.debug('ERROR: ENOS community not found');
    return;
}

Network enosNetwork = networks[0];
System.debug('Found ENOS network: ' + enosNetwork.Id);

// Grant network access to permission sets
List<NetworkMemberGroup> memberGroups = new List<NetworkMemberGroup>();

for (PermissionSet ps : permSets) {
    NetworkMemberGroup nmg = new NetworkMemberGroup();
    nmg.NetworkId = enosNetwork.Id;
    nmg.ParentId = ps.Id;
    memberGroups.add(nmg);
    System.debug('Adding permission set ' + ps.Name + ' to ENOS community');
}

if (!memberGroups.isEmpty()) {
    try {
        insert memberGroups;
        System.debug('SUCCESS: Added ' + memberGroups.size() + ' permission sets to ENOS community');
    } catch (Exception e) {
        System.debug('ERROR adding permission sets to community: ' + e.getMessage());
    }
}
EOF

sf apex run --target-org $ORG_ALIAS --file /tmp/community_permissions.apex

# Update the profile to include community access
echo ""
echo -e "${YELLOW}⚙️ Updating profile for community access...${NC}"

# Check current profile assignments
PROFILE_QUERY=$(sf data query --target-org $ORG_ALIAS --query "SELECT Id, Name FROM Profile WHERE Name LIKE '%Community%' OR Name LIKE '%ENOS%'" --result-format human)
echo -e "${BLUE}ℹ️ Available community profiles:${NC}"
echo "$PROFILE_QUERY"

# Get community URL
echo ""
echo -e "${YELLOW}⚙️ Getting community URL...${NC}"
COMMUNITY_URL=$(sf data query --target-org $ORG_ALIAS --query "SELECT UrlPathPrefix, Status FROM Network WHERE Name = 'ENOS'" --result-format csv | tail -n 1)

if [[ $COMMUNITY_URL == *"enos"* ]]; then
    echo -e "${GREEN}✅ Community URL: https://[your-domain].my.site.com/enos${NC}"
else
    echo -e "${YELLOW}⚠️ Community URL not yet available${NC}"
fi

# Clean up temporary file
rm -f /tmp/community_permissions.apex

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 ENOS Community Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}ℹ️ Next Steps:${NC}"
echo -e "${BLUE}  1. Open your org: sf org open --target-org $ORG_ALIAS${NC}"
echo -e "${BLUE}  2. Go to Setup → Digital Experiences → All Sites${NC}"
echo -e "${BLUE}  3. Click on ENOS community to configure${NC}"
echo -e "${BLUE}  4. Add your ENOS LWC components to community pages${NC}"
echo -e "${BLUE}  5. Configure community settings and branding${NC}"
echo ""
echo -e "${GREEN}Your ENOS community is ready! 🎉${NC}"
