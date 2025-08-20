# ENOS Deployment Quick Reference

## 🚀 **3-Phase Deployment Process**

### **Phase 1: Deploy (Automated)**
```bash
./scripts/create-enos-org.sh ENOS-Production 7 dev
```

### **Phase 2: Configure (Manual)**
1. `sf org open --target-org ENOS-Production`
2. **Setup → Profiles → [Profile] → Field-Level Security**
3. **Set Product2 fields to "Visible":**
   - `stock_quantity__c`
   - `is_top_seller__c`
   - `image_url__c`

### **Phase 3: Verify (Automated)**
```bash
./scripts/verify-enos-deployment.sh ENOS-Production
```

---

## ⚠️ **Critical Manual Step**

**Profile Field Visibility** cannot be automated and is required for UI functionality.

**Why**: Salesforce requires profile-level field visibility for UI display, separate from permission set FLS.

---

## 🔍 **What Gets Verified**

- ✅ Custom fields accessible via API
- ✅ Permission sets deployed
- ✅ LWC components working
- ✅ Community configured
- ⚠️ UI field visibility (manual check)

---

## 🚨 **Common Issues**

| Issue | Solution |
|-------|----------|
| Fields not visible in UI | Complete Phase 2 manual step |
| Permission set fails | Check XML syntax, remove duplicates |
| LWC not loading | Verify dependencies deployed |
| Community inaccessible | Check status, publish if needed |

---

## 📚 **Full Documentation**

- `DEPLOYMENT_INSTRUCTIONS.md` - Complete step-by-step guide
- `ERROR_PATTERNS_ANALYSIS.md` - Error patterns and solutions
- `scripts/create-enos-org.sh` - Deployment script
- `scripts/verify-enos-deployment.sh` - Verification script

---

**Remember: Manual profile configuration is required! 🎯**
