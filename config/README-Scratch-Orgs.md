# ENOS Scratch Org Configurations

## Overview

This directory contains scratch org definition files for different development and testing scenarios in the ENOS e-commerce platform project.

## 📋 **Available Org Types**

### 1. **Development** (`config/scratch-org-dev.json`)

- **Purpose**: Daily development work
- **Edition**: Developer
- **Features**: Core features + DebugApex + Admin login bypass
- **Default Duration**: 7 days
- **Best For**: Feature development, debugging, coding

### 2. **Demo** (`config/scratch-org-demo.json`)

- **Purpose**: Client presentations and sales demos
- **Edition**: Enterprise
- **Features**: Full feature set including LiveAgent, Knowledge + **ENOS Community**
- **Default Duration**: 30 days
- **Best For**: Client demos, showcasing capabilities
- **Special**: Automatically creates ENOS Experience Cloud community

### 3. **Testing** (`config/scratch-org-test.json`)

- **Purpose**: QA testing and validation
- **Edition**: Developer
- **Features**: Core features with security restrictions
- **Default Duration**: 7 days
- **Best For**: QA testing, UAT, security validation

### 4. **Quick** (`config/scratch-org-quick.json`)

- **Purpose**: Rapid testing and throwaway development
- **Edition**: Developer
- **Features**: Minimal feature set, no sample data
- **Default Duration**: 1 day
- **Best For**: Quick tests, experiments, debugging

### 5. **Training** (`config/scratch-org-training.json`)

- **Purpose**: Workshops and training sessions
- **Edition**: Enterprise
- **Features**: Complete feature set + Flow + Admin access + **ENOS Community**
- **Default Duration**: 14 days
- **Best For**: Workshops, training, educational demos
- **Special**: Automatically creates ENOS Experience Cloud community

### 6. **Default** (`config/project-scratch-def.json`)

- **Purpose**: Standard development (same as dev type)
- **Edition**: Developer
- **Features**: Core ENOS features
- **Used By**: Standard `sf org create scratch` commands

## 🚀 **Usage**

### Main Script (Recommended)

```bash
# Development org
./scripts/create-enos-org.sh MyDev 7 dev

# Demo org
./scripts/create-enos-org.sh ClientDemo 30 demo

# Quick testing org
./scripts/create-enos-org.sh QuickTest 1 quick

# Training org
./scripts/create-enos-org.sh Workshop 14 training

# Testing org
./scripts/create-enos-org.sh QA-Sprint1 7 test
```

### Specialized Scripts

```bash
# Quick shortcuts for common scenarios
./scripts/create-demo-org.sh                    # Creates Demo-MMDD for 30 days
./scripts/create-quick-org.sh                   # Creates Quick-HHMM for 1 day
./scripts/create-training-org.sh               # Creates Training-MMDD for 14 days
./scripts/create-test-org.sh                   # Creates Test-MMDD for 7 days
```

### Direct SF CLI Usage

```bash
# Using specific definition files
sf org create scratch --definition-file config/scratch-org-demo.json --alias MyDemo --duration-days 30
sf org create scratch --definition-file config/scratch-org-quick.json --alias QuickTest --duration-days 1
```

## 🔧 **Configuration Details**

### Common Features (All Orgs)

- **Source Org**: `DevHub_ECRM` (inherits your production configuration)
- **Communities**: Enabled for ENOS experience sites
- **Lightning Experience**: Enabled
- **Experience Bundles**: Enabled for community development

### Feature Comparison

| Feature                | Dev       | Demo       | Test      | Quick     | Training   |
| ---------------------- | --------- | ---------- | --------- | --------- | ---------- |
| **Edition**            | Developer | Enterprise | Developer | Developer | Enterprise |
| **PersonAccounts**     | ✅        | ✅         | ✅        | ❌        | ✅         |
| **SalesCloud**         | ✅        | ✅         | ✅        | ❌        | ✅         |
| **ServiceCloud**       | ✅        | ✅         | ✅        | ❌        | ✅         |
| **LiveAgent**          | ❌        | ✅         | ❌        | ❌        | ✅         |
| **Knowledge**          | ❌        | ✅         | ❌        | ❌        | ✅         |
| **DebugApex**          | ✅        | ❌         | ❌        | ❌        | ❌         |
| **Admin Login Bypass** | ✅        | ❌         | ❌        | ❌        | ✅         |
| **Flow**               | ❌        | ❌         | ❌        | ❌        | ✅         |
| **Email to Case**      | ❌        | ✅         | ❌        | ❌        | ✅         |
| **Sample Data**        | ✅        | ✅         | ✅        | ❌        | ✅         |

## 📊 **Deployment Pipeline**

### Development Workflow

1. **Development**: Use `dev` type for feature work
2. **Testing**: Deploy to `test` type for QA validation
3. **Demo**: Use `demo` type for client presentations
4. **Training**: Use `training` type for workshops

### Quick Scenarios

- **Debugging**: Use `quick` type for minimal setup
- **Experiments**: Use `quick` type for throwaway testing
- **Client Calls**: Use `demo` type for impromptu demos

## 🛠️ **Customization**

### Adding New Org Types

1. Create new JSON file: `config/scratch-org-[type].json`
2. Update `scripts/create-enos-org.sh` case statement
3. Add new specialized script if needed

### Modifying Existing Types

Edit the appropriate JSON file and update:

- `features`: Add/remove Salesforce features
- `settings`: Modify org-specific settings
- `edition`: Change org edition (Developer/Enterprise)

### Example Custom Type

```json
{
  "orgName": "ENOS Custom",
  "sourceOrg": "DevHub_ECRM",
  "edition": "Enterprise",
  "features": ["EnableSetPasswordInApi", "Communities", "YourCustomFeature"],
  "settings": {
    "lightningExperienceSettings": {
      "enableS1DesktopEnabled": true
    },
    "yourCustomSettings": {
      "enableYourFeature": true
    }
  }
}
```

## 🔗 **Related Scripts**

- **`scripts/setup-enos-user.sh`**: Assign permissions to users
- **`scripts/apex/assign-enos-permissions.apex`**: Permission assignment logic
- **`scripts/apex/insert-basic-test-data.apex`**: Sample data creation
- **`scripts/apex/minimal-test-data.apex`**: ENOS-specific data

## 💡 **Best Practices**

1. **Use appropriate org types** for different purposes
2. **Keep demo orgs longer** (30 days) for client presentations
3. **Use quick orgs** for experiments and debugging
4. **Training orgs** should have admin bypass for workshops
5. **Test orgs** should mirror production security settings
6. **Always specify meaningful aliases** for easier identification

## 🎯 **Quick Reference**

```bash
# Most common commands
./scripts/create-enos-org.sh                    # Default dev org
./scripts/create-demo-org.sh                           # Quick demo setup
./scripts/create-quick-org.sh                          # Minimal test org
./scripts/create-training-org.sh                       # Workshop org

# Custom configurations
./scripts/create-enos-org.sh MyFeature 14 dev  # Custom dev org
./scripts/create-enos-org.sh BigDemo 30 demo   # Extended demo org
```

## 🌐 **ENOS Community Features**

Demo and Training orgs automatically include the **ENOS Experience Cloud community**:

### Community Details

- **Name**: ENOS
- **Template**: Customer Account Portal
- **URL**: `https://[your-domain].my.site.com/enos`
- **Profile**: ENOS Community Login (pre-configured)
- **Permission Set**: ENOS_Community_Access

### Community Setup Process

1. **Automatic**: Community creation starts during org setup
2. **Manual Completion**: Run `./scripts/setup-enos-community.sh [ORG-ALIAS]` after creation
3. **Configuration**: Add ENOS LWC components to community pages
4. **Testing**: Test ProductBrowser, ProductCatalog, and Cart functionality

### Manual Community Setup

For orgs that don't automatically create communities:

```bash
# Create community manually
sf community create --name "ENOS" --template-name "Customer Account Portal" --url-path-prefix "enos"

# Complete setup
./scripts/setup-enos-community.sh [ORG-ALIAS]

# Deploy community permission set
sf project deploy start --source-dir force-app/main/default/permissionsets/ENOS_Community_Access.permissionset-meta.xml
```

---

_All scratch orgs inherit from DevHub_ECRM for consistency with your production environment._
