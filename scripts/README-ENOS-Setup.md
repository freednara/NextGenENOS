# ENOS User Setup Scripts

This directory contains automated scripts to quickly set up ENOS permissions and access for users in any Salesforce org.

## Quick Start

### 1. Setup User Permissions

```bash
./scripts/setup-enos-user.sh
```

### 2. Setup User Permissions (Custom Org)

```bash
./scripts/setup-enos-user.sh my-org-alias
```

### 3. Assign Permissions via Apex

```bash
sf apex run --file scripts/apex/assign-enos-permissions.apex
```

## Script Details

### Permission Set: `ENOS_Basic_Access`

- **Purpose**: Basic e-commerce functionality
- **Access**: Product browsing, search, basic cart operations
- **Users**: Community users, basic customers

**Includes Access To:**

- Product2 (Read)
- Category\_\_c (Read)
- ENOSController
- ENOS_ProductController
- ENOS_SecurityUtils

**Custom Permissions:**

- ENOS_User

### `setup-enos-user.sh`

**Purpose**: Automated user setup with permission assignment

**Features:**

- Creates community user profile
- Assigns ENOS permission sets
- Configures Experience Cloud access
- Sets up user authentication

**Usage Examples:**

```bash
# Use default org
./scripts/setup-enos-user.sh

# Specify org alias
./scripts/setup-enos-user.sh ENOS-Fresh

# Production org
./scripts/setup-enos-user.sh production-org

# Development sandbox
./scripts/setup-enos-user.sh dev-sandbox

# Custom org
./scripts/setup-enos-user.sh my-custom-org
```

### `assign-enos-permissions.apex`

**Purpose**: Apex-based permission assignment

**Features:**

- Assigns ENOS permission sets to current user
- Checks existing assignments
- Provides detailed logging
- Error handling and validation

**Customization:**
Edit `scripts/apex/assign-enos-permissions.apex`:

```apex
List<String> permissionSetNames = new List<String>{
    'ENOS_Basic_Access',
    'ENOS_User_Access',
    'ENOS_Admin_Access'
};
```

## Troubleshooting

### Common Issues

#### Permission Set Not Found

```
⚠️ Permission Set not found: ENOS_Basic_Access
```

**Solution**: Create the permission set first using the setup script

#### Already Assigned

```
✅ Already assigned: ENOS_Basic_Access
```

**Solution**: No action needed - user already has permissions

#### Permission Assignment Failed

```
❌ Error assigning permission sets: [Error Details]
```

**Solution**: Check user profile and org permissions

### Verification Commands

#### Check Current Permissions

```bash
sf org list users --target-org ENOS-Dev
```

#### Verify Permission Set Assignment

```bash
sf data query --query "SELECT Id, PermissionSet.Name, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name LIKE 'ENOS%'"
```

#### Check User Access

```bash
sf org display user --target-org ENOS-Dev
```

## Success Indicators

- 🎉 "ENOS user setup completed!"
- ✅ Permission sets assigned successfully
- 🔐 User can access ENOS functionality
- Access ENOS apps in App Launcher
