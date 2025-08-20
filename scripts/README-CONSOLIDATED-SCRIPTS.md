# ENOS Platform Consolidated Scripts

## Overview
This directory contains consolidated and optimized scripts for the ENOS platform, replacing the previous scattered and duplicated scripts with a clean, maintainable structure.

## Script Structure

### 🚀 **Org Creation & Deployment**
- **`create-enos-org.sh`** - Comprehensive scratch org creator with all ENOS features
- **`deploy-enos.sh`** - Full ENOS deployment script
- **`create-basic-flexipages.sh`** - Flexipage creation for ENOS objects
- **`update-permissions.sh`** - Permission set management and updates
- **`setup-enos-user.sh`** - User setup and configuration
- **`setup-enos-community.sh`** - Community setup and configuration

### 📊 **Test Data Management**
- **`apex/insert-test-data-basic.apex`** - Essential test data (5 accounts, 10 contacts, 15 products)
- **`apex/insert-test-data-comprehensive.apex`** - Full production-like dataset (25+ accounts, 50+ contacts, 100+ products)
- **`apex/insert-test-data-minimal.apex`** - Minimal test data for quick testing
- **`apex/add-stock-data.apex`** - Stock data utility for products

### 🔍 **Verification & Testing**
- **`apex/verify-enos-platform.apex`** - Comprehensive platform verification (FLS, schema, data validation)
- **`apex/test-enos-controllers.apex`** - Controller testing (product, cart, LWC integration)
- **`apex/assign-enos-permissions.apex`** - Permission assignment and validation

### 📁 **Supporting Directories**
- **`soql/`** - SOQL query templates and examples
- **`apex/`** - All Apex scripts and utilities

## Usage Examples

### Create a New ENOS Org
```bash
# Basic development org (7 days)
./scripts/create-enos-org.sh

# Custom org with specific parameters
./scripts/create-enos-org.sh MyOrg 14 demo

# Quick testing org (1 day)
./scripts/create-enos-org.sh QuickTest 1 quick
```

### Load Test Data
```bash
# Basic test data (recommended for development)
sf apex run --target-org YourOrg --file scripts/apex/insert-test-data-basic.apex

# Comprehensive test data (recommended for testing)
sf apex run --target-org YourOrg --file scripts/apex/insert-test-data-comprehensive.apex

# Minimal test data (for quick validation)
sf apex run --target-org YourOrg --file scripts/apex/insert-test-data-minimal.apex
```

### Verify Platform Health
```bash
# Comprehensive platform verification
sf apex run --target-org YourOrg --file scripts/apex/verify-enos-platform.apex

# Test controller functionality
sf apex run --target-org YourOrg --file scripts/apex/test-enos-controllers.apex
```

### Deploy ENOS
```bash
# Full deployment
./scripts/deploy-enos.sh

# Update permissions
./scripts/update-permissions.sh
```

## Benefits of Consolidation

### ✅ **Before (Previous State)**
- 60+ scattered scripts with significant duplication
- Multiple versions of the same functionality
- Inconsistent naming and structure
- Difficult maintenance and updates
- Confusing for new developers

### ✅ **After (Current State)**
- 15 consolidated scripts with clear purpose
- Single source of truth for each function
- Consistent naming and documentation
- Easy maintenance and updates
- Clear structure for new developers

## Script Categories

### **Tier 1: Basic Test Data**
- Essential accounts, contacts, products
- Suitable for development and basic testing
- Fast execution (< 30 seconds)

### **Tier 2: Comprehensive Test Data**
- Full production-like dataset
- Suitable for comprehensive testing and demos
- Moderate execution time (1-2 minutes)

### **Tier 3: Minimal Test Data**
- Minimal dataset for quick validation
- Suitable for smoke tests and validation
- Fast execution (< 15 seconds)

## Maintenance Notes

### **Adding New Scripts**
1. Follow the naming convention: `verb-noun-description.apex`
2. Place in appropriate directory (`scripts/` or `scripts/apex/`)
3. Update this README with description and usage
4. Ensure no duplication with existing scripts

### **Updating Existing Scripts**
1. Test changes in sandbox first
2. Update documentation if functionality changes
3. Maintain backward compatibility where possible
4. Follow the established error handling patterns

### **Script Dependencies**
- Test data scripts depend on ENOS objects being deployed
- Verification scripts require proper permission sets
- Controller tests require test data to be loaded first

## Troubleshooting

### **Common Issues**
- **Permission Errors**: Ensure ENOS permission sets are assigned
- **Object Not Found**: Verify ENOS objects are deployed
- **Field Access Errors**: Check FLS settings and permission sets
- **Test Data Conflicts**: Use `verify-enos-platform.apex` to check data state

### **Debug Mode**
Most scripts include comprehensive debug logging. Check debug logs for:
- Data creation progress
- Error details and stack traces
- Performance metrics and limits
- Validation results

## Performance Considerations

### **Test Data Scripts**
- Basic: ~30 seconds, minimal governor limit usage
- Comprehensive: ~2 minutes, moderate governor limit usage
- Minimal: ~15 seconds, minimal governor limit usage

### **Verification Scripts**
- Platform verification: ~1 minute, moderate query usage
- Controller testing: ~30 seconds, minimal resource usage

### **Best Practices**
- Run comprehensive scripts during off-peak hours
- Use basic/minimal scripts for frequent testing
- Monitor governor limits in large orgs
- Clean up test data when no longer needed

## Support

For issues or questions about these scripts:
1. Check the debug logs for detailed error information
2. Verify the org has all required ENOS components
3. Ensure proper permission set assignments
4. Review the ERROR_PATTERNS_ANALYSIS.md for common issues

---

**Last Updated**: Script consolidation completed
**Total Scripts**: 15 (down from 60+)
**Maintenance**: Significantly improved
**Documentation**: Comprehensive coverage

