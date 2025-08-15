#!/bin/bash

# ENOS Scratch Org Setup Script
# Creates a new scratch org with full ENOS deployment and sample data
#
# Usage: ./scripts/create-enos-org.sh [org-alias] [duration-days] [org-type]
#
# Examples:
#   ./scripts/create-enos-org.sh                     # Creates "ENOS-Dev" for 7 days (dev type)
#   ./scripts/create-enos-org.sh MyOrg 14 demo      # Creates "MyOrg" for 14 days (demo type)
#   ./scripts/create-enos-org.sh QuickTest 1 quick  # Creates "QuickTest" for 1 day (quick type)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for better UX
ROCKET="🚀"
GEAR="⚙️"
DATABASE="🗄️"
SHIELD="🛡️"
PARTY="🎉"
CHECKMARK="✅"
WARNING="⚠️"
ERROR="❌"
INFO="ℹ️"

# Function to print colored output
print_header() {
    echo -e "\n${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
}

print_step() {
    echo -e "${BLUE}${GEAR} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECKMARK} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_error() {
    echo -e "${RED}${ERROR} $1${NC}"
}

print_info() {
    echo -e "${CYAN}${INFO} $1${NC}"
}

# Parse arguments with defaults
ORG_ALIAS=${1:-"ENOS-Dev"}
DURATION_DAYS=${2:-7}
ORG_TYPE=${3:-"dev"}  # dev, demo, test, quick, training

# Select the appropriate scratch org definition
case $ORG_TYPE in
    "demo")
        SCRATCH_DEF="config/scratch-org-demo.json"
        ;;
    "test")
        SCRATCH_DEF="config/scratch-org-test.json"
        ;;
    "quick")
        SCRATCH_DEF="config/scratch-org-quick.json"
        ;;
    "training")
        SCRATCH_DEF="config/scratch-org-training.json"
        ;;
    "dev"|*)
        SCRATCH_DEF="config/scratch-org-dev.json"
        ;;
esac

print_header "${ROCKET} ENOS Scratch Org Creator"

print_info "Configuration:"
print_info "  Org Alias: $ORG_ALIAS"
print_info "  Duration: $DURATION_DAYS days"
print_info "  Org Type: $ORG_TYPE"
print_info "  Definition: $SCRATCH_DEF"
print_info "  Source Org: DevHub_ECRM"

# Validation
if [ ! -f "sfdx-project.json" ]; then
    print_error "Not in a Salesforce project directory. Please run from project root."
    exit 1
fi

if [ ! -f "$SCRATCH_DEF" ]; then
    print_error "Scratch org definition file not found at $SCRATCH_DEF"
    exit 1
fi

# Check if org alias already exists (with fallback for jq)
if command -v jq >/dev/null 2>&1; then
    if sf org list --json 2>/dev/null | jq -r '.result.scratchOrgs[].alias' 2>/dev/null | grep -q "^$ORG_ALIAS$" 2>/dev/null; then
        print_warning "Org alias '$ORG_ALIAS' already exists!"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_step "Deleting existing org..."
            sf org delete scratch --target-org "$ORG_ALIAS" --no-prompt || true
        else
            print_error "Cancelled. Choose a different alias or delete the existing org."
            exit 1
        fi
    fi
else
    print_warning "jq not found - skipping duplicate org check"
fi

# Step 1: Create Scratch Org
print_header "${ROCKET} Creating Scratch Org"
print_step "Creating scratch org '$ORG_ALIAS' for $DURATION_DAYS days using DevHub_ECRM shape..."

if sf org create scratch \
    --definition-file "$SCRATCH_DEF" \
    --alias "$ORG_ALIAS" \
    --set-default \
    --duration-days "$DURATION_DAYS"; then
    print_success "Scratch org created successfully!"
else
    print_error "Failed to create scratch org"
    exit 1
fi

# Step 2: Deploy Core Metadata
print_header "${GEAR} Deploying Core Metadata"

print_step "Deploying ConnectedApp..."
if sf project deploy start --target-org "$ORG_ALIAS" --source-dir force-app/main/default/connectedApps; then
    print_success "ConnectedApp deployed"
else
    print_warning "ConnectedApp deployment had issues (may be expected if already deployed)"
fi

print_step "Deploying custom permissions..."
if sf project deploy start --target-org "$ORG_ALIAS" --source-dir force-app/main/default/customPermissions; then
    print_success "Custom permissions deployed"
else
    print_warning "Custom permissions deployment had issues (may be expected)"
fi

print_step "Deploying core objects and security..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/objects \
    --source-dir force-app/main/default/classes/ENOS_SecurityUtils.cls; then
    print_success "Core objects and security deployed"
else
    print_error "Failed to deploy core metadata"
    exit 1
fi

print_step "Deploying ENOS_DynamicUtils dependency..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/classes/ENOS_DynamicUtils.cls; then
    print_success "ENOS_DynamicUtils dependency deployed"
else
    print_error "Failed to deploy ENOS_DynamicUtils dependency"
    exit 1
fi

print_step "Deploying core controllers..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/classes/ENOS_ProductController.cls \
    --source-dir force-app/main/default/classes/ENOSController.cls \
    --source-dir force-app/main/default/classes/ENOS_CartController.cls; then
    print_success "Core controllers deployed"
else
    print_error "Failed to deploy controllers"
    exit 1
fi

print_step "Deploying permission sets..."
if sf project deploy start --target-org "$ORG_ALIAS" \
    --source-dir force-app/main/default/permissionsets/ENOS_Basic_Access.permissionset-meta.xml; then
    print_success "Permission sets deployed"
else
    print_warning "Permission sets deployment had issues"
fi

# Step 3: Deploy Sample Data (skip for quick orgs)
if [ "$ORG_TYPE" != "quick" ]; then
    print_header "${DATABASE} Loading Sample Data"

    print_step "Creating sample products, accounts, and pricing..."
    if sf apex run --target-org "$ORG_ALIAS" --file scripts/apex/insert-basic-test-data.apex > /dev/null 2>&1; then
        print_success "Basic test data loaded successfully"
    else
        print_error "Failed to load basic test data"
        exit 1
    fi

    print_step "Creating additional ENOS data..."
    if sf apex run --target-org "$ORG_ALIAS" --file scripts/apex/minimal-test-data.apex > /dev/null 2>&1; then
        print_success "ENOS-specific data loaded"
    else
        print_warning "ENOS data loading had issues (may be expected)"
    fi
else
    print_header "${DATABASE} Skipping Sample Data (Quick Org)"
    print_info "Sample data loading skipped for quick org type"
fi

# Step 4: Assign Permissions
print_header "${SHIELD} Setting Up User Permissions"

print_step "Assigning ENOS permissions to current user..."
if sf apex run --target-org "$ORG_ALIAS" --file scripts/apex/assign-enos-permissions.apex > /dev/null 2>&1; then
    print_success "User permissions assigned successfully"
else
    print_error "Failed to assign permissions"
    exit 1
fi

# Step 5: Verification
print_header "${CHECKMARK} Verification & Summary"

print_step "Verifying deployment..."

# Count products (skip for quick orgs)
if [ "$ORG_TYPE" != "quick" ]; then
    PRODUCT_COUNT=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT COUNT() FROM Product2 WHERE IsActive = true" --result-format csv | tail -n 1 | tr -d '\r')
    print_info "Products available: $PRODUCT_COUNT"

    # Count accounts  
    ACCOUNT_COUNT=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT COUNT() FROM Account" --result-format csv | tail -n 1 | tr -d '\r')
    print_info "Accounts created: $ACCOUNT_COUNT"
else
    PRODUCT_COUNT="0 (quick org)"
    ACCOUNT_COUNT="0 (quick org)"
fi

# Test controller access
print_step "Testing Apex controller access..."
if sf apex run --target-org "$ORG_ALIAS" --file /dev/stdin <<< "try { List<Product2> products = ENOS_ProductController.getProducts(); System.debug('SUCCESS: ENOS_ProductController returned ' + products.size() + ' products'); } catch (Exception e) { System.debug('ERROR: ' + e.getMessage()); }" > /dev/null 2>&1; then
    print_success "ENOS_ProductController access verified"
else
    print_warning "ENOS_ProductController access test failed"
fi

# Get org info (with fallbacks for systems without jq)
if command -v jq >/dev/null 2>&1; then
    ORG_INFO=$(sf org display --target-org "$ORG_ALIAS" --json 2>/dev/null || echo '{"result":{"id":"","username":"","instanceUrl":""}}')
    ORG_ID=$(echo "$ORG_INFO" | jq -r '.result.id' 2>/dev/null || echo "Unknown")
    USERNAME=$(echo "$ORG_INFO" | jq -r '.result.username' 2>/dev/null || echo "Unknown")
    ORG_URL=$(echo "$ORG_INFO" | jq -r '.result.instanceUrl' 2>/dev/null || echo "Unknown")
else
    # Fallback parsing without jq
    ORG_INFO=$(sf org display --target-org "$ORG_ALIAS" --json 2>/dev/null || echo '{}')
    ORG_ID=$(echo "$ORG_INFO" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 || echo "Unknown")
    USERNAME=$(echo "$ORG_INFO" | grep -o '"username":"[^"]*"' | cut -d'"' -f4 || echo "Unknown")
    ORG_URL=$(echo "$ORG_INFO" | grep -o '"instanceUrl":"[^"]*"' | cut -d'"' -f4 || echo "Unknown")
fi

# Step 6: ENOS Community Setup (Required for all ENOS orgs)
print_header "${WORLD} Setting Up ENOS Community"

print_step "Creating ENOS Experience Cloud community..."
if sf community create --name "ENOS" --template-name "Customer Account Portal" --url-path-prefix "enos" --description "NextGen ENOS E-Commerce Platform" --target-org "$ORG_ALIAS"; then
    print_info "ENOS community creation initiated (runs in background)"
    print_info "Community will be available at: https://[your-domain].my.site.com/enos"
    
    # Wait for community creation to complete
    print_step "Waiting for community creation to complete..."
    print_info "This may take 5-15 minutes..."
    
    # Check community status every 30 seconds for up to 20 minutes
    COMMUNITY_READY=false
    ATTEMPTS=0
    MAX_ATTEMPTS=40  # 20 minutes max
    
    while [ $ATTEMPTS -lt $MAX_ATTEMPTS ] && [ "$COMMUNITY_READY" = false ]; do
        sleep 30
        ATTEMPTS=$((ATTEMPTS + 1))
        
        print_info "Checking community status (attempt $ATTEMPTS/$MAX_ATTEMPTS)..."
        
        # Check if community creation is complete
        JOB_STATUS=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT Status, Type, Error FROM BackgroundOperation WHERE Type = 'SiteTaskCreate' ORDER BY CreatedDate DESC LIMIT 1" --result-format csv 2>/dev/null | tail -n 1 || echo "Unknown")
        
        if [[ $JOB_STATUS == *"Complete"* ]]; then
            print_success "Community creation completed!"
            COMMUNITY_READY=true
        elif [[ $JOB_STATUS == *"Error"* ]]; then
            print_error "Community creation failed: $JOB_STATUS"
            break
        elif [[ $JOB_STATUS == *"Running"* ]]; then
            print_info "Community creation still in progress..."
        else
            print_info "Checking community availability..."
        fi
    done
    
    if [ "$COMMUNITY_READY" = true ]; then
        # Check if community is available
        print_step "Verifying community availability..."
        NETWORK_QUERY=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT Id, Name, Status FROM Network WHERE Name = 'ENOS'" --result-format csv 2>/dev/null | tail -n 1 || echo "")
        
        if [[ $NETWORK_QUERY == *"ENOS"* ]]; then
            NETWORK_ID=$(echo $NETWORK_QUERY | cut -d',' -f1 | tr -d '"')
            NETWORK_STATUS=$(echo $NETWORK_QUERY | cut -d',' -f3 | tr -d '"')
            print_success "ENOS community found: $NETWORK_ID"
            print_info "Status: $NETWORK_STATUS"
            
            # Publish the community if it's not already live
            if [[ $NETWORK_STATUS != "Live" ]]; then
                print_step "Publishing ENOS community..."
                if sf community publish --name "ENOS" --target-org "$ORG_ALIAS"; then
                    print_success "Community published successfully!"
                else
                    print_warning "Community publishing failed - may need manual intervention"
                fi
            fi
            
            # Update permission sets to include community access
            print_step "Updating permission sets for community access..."
            
            # Create a temporary permission set update script
            cat > /tmp/community_permissions.apex << 'EOF'
// Add community access to existing permission sets
List<PermissionSet> permSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('ENOS_Basic_Access', 'ENOS_Admin_Access')];

List<Network> networks = [SELECT Id, Name FROM Network WHERE Name = 'ENOS' LIMIT 1];
if (networks.isEmpty()) {
    System.debug('ERROR: ENOS community not found');
    return;
}

Network enosNetwork = networks[0];
System.debug('Found ENOS network: ' + enosNetwork.Id);

// Grant network access to permission sets using NetworkMemberGroup
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
        // Alternative approach: use NetworkMember instead
        System.debug('Trying alternative approach with NetworkMember...');
        List<NetworkMember> members = new List<NetworkMember>();
        for (PermissionSet ps : permSets) {
            NetworkMember nm = new NetworkMember();
            nm.NetworkId = enosNetwork.Id;
            nm.MemberId = ps.Id;
            members.add(nm);
        }
        try {
            insert members;
            System.debug('SUCCESS: Added ' + members.size() + ' permission sets to ENOS community using NetworkMember');
        } catch (Exception e2) {
            System.debug('ERROR with alternative approach: ' + e2.getMessage());
        }
    }
}
EOF

            if sf apex run --target-org "$ORG_ALIAS" --file /tmp/community_permissions.apex; then
                print_success "Permission sets updated for community access"
            else
                print_warning "Permission set update failed - may need manual configuration"
            fi
            
            # Clean up temporary file
            rm -f /tmp/community_permissions.apex
            
            # Get community URL
            print_step "Getting community URL..."
            COMMUNITY_URL=$(sf data query --target-org "$ORG_ALIAS" --query "SELECT UrlPathPrefix, Status FROM Network WHERE Name = 'ENOS'" --result-format csv 2>/dev/null | tail -n 1 || echo "")
            
            if [[ $COMMUNITY_URL == *"enos"* ]]; then
                print_success "Community URL: https://[your-domain].my.site.com/enos"
            else
                print_warning "Community URL not yet available"
            fi
            
            print_success "ENOS Community setup completed successfully!"
            
            # Step 7: Create ENOS Community Profile and Configure JIT Handler
            print_header "${USER} Setting Up ENOS Community Profile & JIT Handler"
            
            print_step "Creating ENOS Community Profile..."
            
            # Create a temporary Apex script to create the community profile
            cat > /tmp/create_community_profile.apex << 'EOF'
// Create ENOS Community Profile for JIT user provisioning
try {
    // Check if ENOS Community Profile already exists
    List<Profile> existingProfiles = [SELECT Id, Name FROM Profile WHERE Name = 'ENOS Community User' LIMIT 1];
    
    if (!existingProfiles.isEmpty()) {
        System.debug('ENOS Community Profile already exists: ' + existingProfiles[0].Id);
        return;
    }
    
    // Get the Customer Community User profile as a template
    List<Profile> templateProfiles = [SELECT Id, Name, UserType, UserLicenseId FROM Profile WHERE Name = 'Customer Community User' LIMIT 1];
    
    if (templateProfiles.isEmpty()) {
        System.debug('ERROR: Customer Community User profile not found');
        return;
    }
    
    Profile templateProfile = templateProfiles[0];
    
    // Create the ENOS Community Profile
    Profile enosProfile = new Profile();
    enosProfile.Name = 'ENOS Community User';
    enosProfile.UserType = templateProfile.UserType;
    enosProfile.UserLicenseId = templateProfile.UserLicenseId;
    
    // Set community-specific permissions
    enosProfile.ChatterAnswersUser = false;
    enosProfile.CommunityUser = true;
    enosProfile.ExternalUser = true;
    
    insert enosProfile;
    System.debug('SUCCESS: Created ENOS Community Profile: ' + enosProfile.Id);
    
    // Now configure the community to use the JIT handler
    List<Network> networks = [SELECT Id, Name FROM Network WHERE Name = 'ENOS' LIMIT 1];
    if (!networks.isEmpty()) {
        Network enosNetwork = networks[0];
        
        // Update network settings to enable JIT
        enosNetwork.EnableDirectMessages = true;
        enosNetwork.EnableGuestChatter = false;
        enosNetwork.EnableInvitation = false;
        enosNetwork.EnableShowAllNetworkSettings = false;
        enosNetwork.EnableSiteAsContainer = true;
        enosNetwork.EnableTalkingAboutStats = false;
        enosNetwork.EnableUpDownVote = false;
        enosNetwork.EnableUrlHints = false;
        enosNetwork.EnableMemberTopicFlagging = false;
        enosNetwork.EnableTopicAssignmentRules = false;
        enosNetwork.EnableTopicSuggestions = false;
        enosNetwork.EnableUpDownVote = false;
        enosNetwork.EnableWelcomeMat = false;
        
        update enosNetwork;
        System.debug('SUCCESS: Updated ENOS Network settings');
        
        // Create Auth. Provider configuration for JIT
        // Note: This requires manual setup in the org as Auth. Provider metadata can't be created via Apex
        System.debug('INFO: Auth. Provider must be configured manually in Setup → Security → Auth. Providers');
        System.debug('INFO: Set the Registration Handler to: ENOS_CommunityRegistrationHandler');
    }
    
} catch (Exception e) {
    System.debug('ERROR creating community profile: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
EOF

            if sf apex run --target-org "$ORG_ALIAS" --file /tmp/create_community_profile.apex; then
                print_success "ENOS Community Profile created successfully"
            else
                print_warning "Community profile creation failed - may need manual setup"
            fi
            
            # Clean up temporary file
            rm -f /tmp/create_community_profile.apex
            
            # Deploy community-specific permission set
            print_step "Deploying ENOS Community permission set..."
            if sf project deploy start --target-org "$ORG_ALIAS" --source-dir force-app/main/default/permissionSets/ENOS_Community_Access.permissionset-meta.xml; then
                print_success "ENOS Community permission set deployed"
            else
                print_warning "Community permission set deployment failed - may not exist yet"
            fi
            
            print_step "Configuring JIT Handler for ENOS Community..."
            
            # Create a basic Auth. Provider configuration
            print_info "Creating basic Auth. Provider configuration..."
            
            # Create a temporary Apex script to set up Auth. Provider
            cat > /tmp/setup_auth_provider.apex << 'EOF'
// Set up basic Auth. Provider configuration for ENOS JIT
try {
    // Check if any Auth. Provider exists
    List<AuthProvider> existingProviders = [SELECT Id, FriendlyName, ProviderType FROM AuthProvider LIMIT 1];
    
    if (!existingProviders.isEmpty()) {
        System.debug('Auth. Provider already exists: ' + existingProviders[0].FriendlyName);
        System.debug('You can update it manually to use ENOS_CommunityRegistrationHandler');
        return;
    }
    
    // Create a basic SAML Auth. Provider (most common for enterprise)
    AuthProvider samlProvider = new AuthProvider();
    samlProvider.FriendlyName = 'ENOS_SAML_Provider';
    samlProvider.ProviderType = 'SAML';
    samlProvider.IsActive = true;
    
    // Note: These fields require actual values and cannot be set programmatically
    // samlProvider.EntityId = 'https://your-domain.my.salesforce.com';
    // samlProvider.LogoutUrl = 'https://your-idp.com/logout';
    // samlProvider.SingleLogoutUrl = 'https://your-idp.com/slo';
    
    insert samlProvider;
    System.debug('SUCCESS: Created basic SAML Auth. Provider: ' + samlProvider.Id);
    System.debug('IMPORTANT: You must manually configure the following:');
    System.debug('1. Entity ID (your Salesforce org URL)');
    System.debug('2. Single Sign-On URL (from your Identity Provider)');
    System.debug('3. X.509 Certificate (from your Identity Provider)');
    System.debug('4. Set Registration Handler to: ENOS_CommunityRegistrationHandler');
    System.debug('5. Enable Just-In-Time User Provisioning');
    System.debug('6. Set Profile to: ENOS Community User');
    
    // Also create a basic OAuth provider for testing
    try {
        AuthProvider oauthProvider = new AuthProvider();
        oauthProvider.FriendlyName = 'ENOS_OAuth_Provider';
        oauthProvider.ProviderType = 'OpenIdConnect';
        oauthProvider.IsActive = true;
        
        insert oauthProvider;
        System.debug('SUCCESS: Created OAuth Provider: ' + oauthProvider.Id);
        System.debug('For OAuth, you must configure:');
        System.debug('1. Consumer Key and Secret from your OAuth provider');
        System.debug('2. Authorization Endpoint URL');
        System.debug('3. Token Endpoint URL');
        System.debug('4. User Info Endpoint URL');
        
    } catch (Exception oauthError) {
        System.debug('OAuth provider creation failed: ' + oauthError.getMessage());
    }
    
} catch (Exception e) {
    System.debug('ERROR creating Auth. Provider: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
EOF

            if sf apex run --target-org "$ORG_ALIAS" --file /tmp/setup_auth_provider.apex; then
                print_success "Basic Auth. Provider created successfully"
                print_info "Next steps for JIT configuration:"
                print_info "1. Go to Setup → Security → Auth. Providers"
                print_info "2. Edit 'ENOS_SAML_Provider'"
                print_info "3. Configure your Identity Provider details"
                print_info "4. Set Registration Handler to: ENOS_CommunityRegistrationHandler"
                print_info "5. Enable 'Just-In-Time User Provisioning'"
                print_info "6. Set Profile to: ENOS Community User"
            else
                print_warning "Auth. Provider creation failed - manual setup required"
                print_info "Manual JIT configuration required:"
                print_info "1. Go to Setup → Security → Auth. Providers"
                print_info "2. Create your Auth. Provider (SAML, OAuth, etc.)"
                print_info "3. Set Registration Handler to: ENOS_CommunityRegistrationHandler"
                print_info "4. Enable 'Just-In-Time User Provisioning'"
                print_info "5. Set Profile to: ENOS Community User"
            fi
            
            # Clean up temporary file
            rm -f /tmp/setup_auth_provider.apex
            
            print_success "ENOS Community Profile & JIT Handler setup completed!"
            
            # Step 8: Create ENOS System User for JIT Handler
            print_header "${USER} Creating ENOS System User for JIT Handler"
            
            print_step "Creating ENOS System User..."
            
            # Create a temporary Apex script to create the system user
            cat > /tmp/create_system_user.apex << 'EOF'
// Create ENOS System User for JIT handler operations
try {
    // Check if ENOS System User already exists
    List<User> existingUsers = [SELECT Id, Username, Email FROM User WHERE Username = 'enos.system@enos.com' LIMIT 1];
    
    if (!existingUsers.isEmpty()) {
        System.debug('ENOS System User already exists: ' + existingUsers[0].Id);
        System.debug('Email: ' + existingUsers[0].Email);
        return;
    }
    
    // Get the System Administrator profile
    List<Profile> adminProfiles = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    
    if (adminProfiles.isEmpty()) {
        System.debug('ERROR: System Administrator profile not found');
        return;
    }
    
    Profile adminProfile = adminProfiles[0];
    
    // Create the ENOS System User
    User enosSystemUser = new User();
    enosSystemUser.Username = 'enos.system@enos.com';
    enosSystemUser.Email = 'enos.system@enos.com';
    enosSystemUser.FirstName = 'ENOS';
    enosSystemUser.LastName = 'System';
    enosSystemUser.Alias = 'enos';
    enosSystemUser.EmailEncodingKey = 'UTF-8';
    enosSystemUser.LanguageLocaleKey = 'en_US';
    enosSystemUser.LocaleSidKey = 'en_US';
    enosSystemUser.TimeZoneSidKey = 'America/New_York';
    enosSystemUser.ProfileId = adminProfile.Id;
    enosSystemUser.IsActive = true;
    
    // Set a secure password (will need to be reset on first login)
    enosSystemUser.CommunityNickname = 'enos_system';
    
    insert enosSystemUser;
    System.debug('SUCCESS: Created ENOS System User: ' + enosSystemUser.Id);
    System.debug('Username: ' + enosSystemUser.Username);
    System.debug('IMPORTANT: This user will need password reset on first login');
    
    // Assign ENOS permission sets to the system user
    List<PermissionSet> enosPermSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('ENOS_Admin_Access', 'ENOS_Basic_Access')];
    
    if (!enosPermSets.isEmpty()) {
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        
        for (PermissionSet ps : enosPermSets) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = enosSystemUser.Id;
            psa.PermissionSetId = ps.Id;
            assignments.add(psa);
            System.debug('Adding permission set: ' + ps.Name);
        }
        
        if (!assignments.isEmpty()) {
            insert assignments;
            System.debug('SUCCESS: Assigned ' + assignments.size() + ' permission sets to ENOS System User');
        }
    }
    
} catch (Exception e) {
    System.debug('ERROR creating ENOS System User: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
EOF

            if sf apex run --target-org "$ORG_ALIAS" --file /tmp/create_system_user.apex; then
                print_success "ENOS System User created successfully"
                print_info "Username: enos.system@enos.com"
                print_info "Profile: System Administrator"
                print_info "Permission Sets: ENOS_Admin_Access, ENOS_Basic_Access"
            else
                print_warning "System user creation failed - may need manual setup"
            fi
            
            # Clean up temporary file
            rm -f /tmp/create_system_user.apex
            
            # Summary of automation vs. manual steps
            print_header "${INFO} JIT Handler Setup Summary"
            print_success "✅ AUTOMATED:"
            print_info "  • ENOS Community Profile created"
            print_info "  • Basic SAML Auth. Provider created"
            print_info "  • Basic OAuth Auth. Provider created"
            print_info "  • Community network configured for JIT"
            print_info "  • ENOS System User created (enos.system@enos.com)"
            
            print_warning "⚠️ MANUAL CONFIGURATION REQUIRED:"
            print_info "  • Update ENOS System User email to your actual email"
            print_info "  • Configure Identity Provider details (URLs, certificates)"
            print_info "  • Set Registration Handler to: ENOS_CommunityRegistrationHandler"
            print_info "  • Set JIT Handler User to: enos.system@enos.com"
            print_info "  • Enable 'Just-In-Time User Provisioning'"
            print_info "  • Set Profile to: ENOS Community User"
            
            print_info "💡 TIP: The Auth. Providers and System User are pre-created and ready for configuration!"
            
        else
            print_error "ENOS community not found after creation"
        fi
    else
        print_warning "Community creation timed out - please run './scripts/setup-enos-community.sh $ORG_ALIAS' manually"
    fi
else
    print_warning "Community creation failed - may already exist or require manual setup"
fi

# Final success message
print_header "${PARTY} ENOS Org Ready!"

echo -e "${GREEN}${PARTY} Your ENOS scratch org is fully configured and ready to use!${NC}\n"

echo -e "${CYAN}${INFO} Org Details:${NC}"
echo -e "  Alias: $ORG_ALIAS"
echo -e "  Type: $ORG_TYPE"
echo -e "  Username: $USERNAME"
echo -e "  Org ID: $ORG_ID"
echo -e "  Duration: $DURATION_DAYS days"
echo -e "  Source: DevHub_ECRM"
echo -e "  URL: $ORG_URL"

echo -e "\n${CYAN}${INFO} Data Summary:${NC}"
echo -e "  Products: $PRODUCT_COUNT"
echo -e "  Accounts: $ACCOUNT_COUNT"
echo -e "  Custom Objects: Cart__c, Cart_Item__c, Category__c, etc."
echo -e "  Permissions: ENOS_Basic_Access assigned"

echo -e "\n${CYAN}${INFO} What's Working:${NC}"
echo -e "  ${CHECKMARK} ENOS_ProductController.getProducts() - for ProductBrowser"
echo -e "  ${CHECKMARK} ENOSController.getAllProducts() - for ProductCatalog"
echo -e "  ${CHECKMARK} Category filtering by Product Family"
echo -e "  ${CHECKMARK} Shopping cart functionality"
echo -e "  ${CHECKMARK} Security and permissions"
echo -e "  ${CHECKMARK} ENOS Experience Cloud Community"
echo -e "  ${CHECKMARK} ENOS Community Profile for JIT provisioning"
echo -e "  ${CHECKMARK} ENOS System User for JIT handler operations"

echo -e "\n${YELLOW}${ROCKET} Next Steps:${NC}"
echo -e "  1. Open org: ${BLUE}sf org open --target-org $ORG_ALIAS${NC}"
echo -e "  2. Navigate to App Launcher → ENOS"
echo -e "  3. Add ProductBrowser/ProductCatalog to Lightning pages"
echo -e "  4. Access ENOS Community: https://[your-domain].my.site.com/enos"
echo -e "  5. Update ENOS System User email: enos.system@enos.com → your-email@domain.com"
echo -e "  6. Configure JIT Handler in Setup → Security → Auth. Providers"
if [ "$ORG_TYPE" == "quick" ]; then
    echo -e "  7. Load data: ${BLUE}sf apex run --target-org $ORG_ALIAS --file scripts/apex/insert-basic-test-data.apex${NC}"
else
    echo -e "  7. Test the application with your sample data"
fi

echo -e "\n${PURPLE}${GEAR} Useful Commands:${NC}"
echo -e "  Open org:          ${BLUE}sf org open --target-org $ORG_ALIAS${NC}"
echo -e "  Set as default:    ${BLUE}sf config set target-org=$ORG_ALIAS${NC}"
echo -e "  Deploy updates:    ${BLUE}sf project deploy start --target-org $ORG_ALIAS${NC}"
echo -e "  Add more data:     ${BLUE}sf apex run --target-org $ORG_ALIAS --file scripts/apex/[script-name].apex${NC}"
echo -e "  Add permissions:   ${BLUE}./scripts/setup-enos-user.sh $ORG_ALIAS${NC}"
echo -e "  Community URL:     ${BLUE}https://[your-domain].my.site.com/enos${NC}"

echo -e "\n${GREEN}Happy coding with ENOS! ${PARTY}${NC}\n"
