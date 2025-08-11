# Ignore Files Configuration Guide

## **Managing Unnecessary Files in Your StoreConnect Repository**

**Purpose**: This guide explains how to configure and use the various ignore files in your StoreConnect Salesforce DX project to exclude unnecessary files from version control and deployments.

---

## 📁 **Ignore Files Overview**

### **What We've Created**
1. **`.gitignore`** - Excludes files from Git version control
2. **`.forceignore`** - Excludes files from Salesforce DX deployments
3. **`.sfignore`** - Excludes files from Salesforce CLI operations

### **Why Multiple Ignore Files?**
- **`.gitignore`** - Prevents unnecessary files from being committed to Git
- **`.forceignore`** - Prevents files from being deployed to Salesforce orgs
- **`.sfignore`** - Prevents files from being included in CLI operations

---

## 🔧 **File Purposes and Usage**

### **`.gitignore` - Git Version Control**

#### **What It Does**
- Prevents files from being tracked by Git
- Keeps your repository clean and focused
- Excludes development artifacts and sensitive data

#### **When It's Used**
- `git add` operations
- `git commit` operations
- `git status` checks
- Repository cloning and sharing

#### **Key Exclusions**
- **Salesforce CLI files** - `.sfdx/`, `.sf/`, `localdevserver/`
- **Development files** - `.vscode/`, `.idea/`, `node_modules/`
- **System files** - `.DS_Store`, `Thumbs.db`, `*~`
- **Build artifacts** - `dist/`, `build/`, `*.log`
- **Sensitive data** - `.env`, `*secret*`, `*password*`

### **`.forceignore` - Salesforce DX Deployments**

#### **What It Does**
- Prevents files from being deployed to Salesforce orgs
- Keeps deployments focused on essential metadata
- Excludes development and configuration files

#### **When It's Used**
- `sfdx force:source:deploy`
- `sfdx force:source:push`
- `sfdx force:source:pull`
- Package creation and deployment

#### **Key Exclusions**
- **Development files** - Same as `.gitignore`
- **Salesforce metadata** - Custom metadata, named credentials
- **Large assets** - ZIP files, images, static resources
- **Sensitive configurations** - Auth providers, connected apps

### **`.sfignore` - Salesforce CLI Operations**

#### **What It Does**
- Prevents files from being included in CLI operations
- Works with newer `sf` commands
- Similar to `.forceignore` but for modern CLI

#### **When It's Used**
- `sf project deploy start`
- `sf project retrieve start`
- `sf source push`
- `sf source pull`

---

## ⚙️ **Configuration and Customization**

### **Adding New Exclusions**

#### **To Exclude a File Type**
```bash
# Add to .gitignore
*.tmp
*.temp

# Add to .forceignore
*.tmp
*.temp

# Add to .sfignore
*.tmp
*.temp
```

#### **To Exclude a Directory**
```bash
# Add to .gitignore
my-ignored-directory/
build-artifacts/

# Add to .forceignore
my-ignored-directory/
build-artifacts/

# Add to .sfignore
my-ignored-directory/
build-artifacts/
```

#### **To Exclude Specific Files**
```bash
# Add to .gitignore
specific-file.txt
config/local-settings.json

# Add to .forceignore
specific-file.txt
config/local-settings.json

# Add to .sfignore
specific-file.txt
config/local-settings.json
```

### **Including Ignored Files (Overrides)**

#### **Force Include a File**
```bash
# In .gitignore
*.log
!important.log

# In .forceignore
*.log
!important.log

# In .sfignore
*.log
!important.log
```

#### **Force Include a Directory**
```bash
# In .gitignore
docs/generated/
!docs/generated/important-doc.md

# In .forceignore
docs/generated/
!docs/generated/important-doc.md

# In .sfignore
docs/generated/
!docs/generated/important-doc.md
```

---

## 🚫 **What Should Always Be Ignored**

### **Security and Compliance**
- **Environment variables** - `.env`, `.env.local`
- **API keys and secrets** - `*secret*`, `*password*`, `*key*`
- **Credentials** - `credentials.json`, `secrets.json`
- **Authentication data** - Named credentials, connected apps

### **Development Artifacts**
- **Build outputs** - `dist/`, `build/`, `out/`
- **Dependencies** - `node_modules/`, `packages/`
- **Cache files** - `.cache/`, `.eslintcache`, `.pmdCache`
- **Temporary files** - `*.tmp`, `*.temp`, `*.bak`

### **System and IDE Files**
- **Operating system** - `.DS_Store`, `Thumbs.db`, `*~`
- **IDE configurations** - `.vscode/`, `.idea/`
- **Editor files** - `*.swp`, `*.swo`, `*~`

### **Salesforce Specific**
- **CLI configurations** - `.sfdx/`, `.sf/`, `localdevserver/`
- **Scratch org files** - `.scratchorgs/`, `scratch-org-def.json`
- **Large assets** - ZIP files, images, videos
- **Custom metadata** - Environment-specific configurations

---

## ✅ **What Should NOT Be Ignored**

### **Essential Project Files**
- **Source code** - `force-app/main/default/classes/`
- **LWC components** - `force-app/main/default/lwc/`
- **Object definitions** - `force-app/main/default/objects/`
- **Flow definitions** - `force-app/main/default/flows/`
- **Permission sets** - `force-app/main/default/permissionSets/`

### **Configuration Files**
- **Project configuration** - `sfdx-project.json`, `package.xml`
- **Documentation** - `docs/` (except generated content)
- **README files** - Project documentation and guides
- **License files** - Legal and compliance documents

### **Version Control**
- **Git configuration** - `.gitattributes`, `.gitignore`
- **CI/CD configuration** - GitHub Actions, deployment scripts
- **Code quality** - ESLint, Prettier, PMD configurations

---

## 🔍 **Testing Your Ignore Files**

### **Testing .gitignore**

#### **Check What's Being Ignored**
```bash
# Check git status
git status

# Check what would be added
git add .
git status

# Reset if needed
git reset
```

#### **Force Add a File (if needed)**
```bash
# Force add a specific file
git add -f force-app/main/default/important-file.cls
```

### **Testing .forceignore**

#### **Check Deployment Scope**
```bash
# Check what would be deployed
sfdx force:source:deploy --dryrun --sourcepath force-app/main/default

# Check source status
sfdx force:source:status
```

#### **Test Specific Deployments**
```bash
# Deploy specific metadata
sfdx force:source:deploy --sourcepath force-app/main/default/classes
```

### **Testing .sfignore**

#### **Check CLI Operations**
```bash
# Check what would be deployed
sf project deploy start --dry-run --source-dir force-app/main/default

# Check source status
sf source status
```

---

## 🚨 **Common Issues and Solutions**

### **File Still Being Tracked**

#### **Problem**: File is already tracked by Git
```bash
# Remove from Git tracking (keeps file locally)
git rm --cached filename

# Commit the removal
git commit -m "Remove filename from tracking"
```

#### **Problem**: File is in multiple ignore files
**Solution**: Ensure the file is ignored in all relevant ignore files

### **File Not Being Ignored**

#### **Problem**: Pattern doesn't match
```bash
# Check if pattern is correct
# Use * for wildcards
# Use / for directory separators
# Use ! for exceptions
```

#### **Problem**: File is in wrong location
**Solution**: Ensure ignore file is in the correct directory (project root)

### **Deployment Issues**

#### **Problem**: File being deployed despite .forceignore
**Solution**: Check file path and ensure it matches the ignore pattern

#### **Problem**: Metadata not being deployed
**Solution**: Check if file is accidentally ignored when it shouldn't be

---

## 📋 **Maintenance and Updates**

### **Regular Review Schedule**
- **Monthly** - Review and update ignore patterns
- **After major changes** - Update when adding new file types
- **Before deployments** - Verify critical files aren't ignored

### **Team Communication**
- **Document changes** - Update this guide when patterns change
- **Team review** - Have team members review ignore file changes
- **Testing** - Test ignore patterns before committing

### **Version Control**
- **Commit ignore files** - Always commit `.gitignore`, `.forceignore`, `.sfignore`
- **Track changes** - Document why patterns were added or removed
- **Review history** - Check ignore file change history when troubleshooting

---

## 🎯 **Best Practices**

### **Security First**
- **Always ignore** sensitive data and credentials
- **Review patterns** for potential security implications
- **Test thoroughly** before committing ignore file changes

### **Performance Optimization**
- **Ignore large files** that don't need version control
- **Exclude build artifacts** that can be regenerated
- **Limit cache files** to improve repository performance

### **Team Collaboration**
- **Document patterns** clearly with comments
- **Use consistent naming** across all ignore files
- **Review regularly** to ensure patterns remain relevant

---

## ✅ **Implementation Checklist**

**Before Committing**:
- [ ] **Review .gitignore** for security and performance
- [ ] **Test .forceignore** with deployment operations
- [ ] **Verify .sfignore** with CLI operations
- [ ] **Document changes** in this guide
- [ ] **Test with team** to ensure no critical files are ignored

**After Committing**:
- [ ] **Monitor deployments** for any issues
- [ ] **Check Git status** to ensure proper exclusions
- [ ] **Update documentation** if patterns change
- [ ] **Team communication** about any new exclusions

---

## 🔄 **Integration with CI/CD**

### **GitHub Actions**
- **Ignore files** are automatically respected by Git operations
- **Deployment scripts** should use appropriate ignore files
- **Build processes** should exclude ignored files

### **Salesforce DX**
- **Deployments** automatically respect `.forceignore`
- **Retrievals** automatically respect `.forceignore`
- **Package creation** respects ignore patterns

### **Salesforce CLI**
- **Modern CLI** respects `.sfignore`
- **Legacy CLI** respects `.forceignore`
- **Both CLIs** respect `.gitignore` for source operations

---

## 🎯 **Strategic Value**

**Clean Repository Management:**
- **Security compliance** through proper credential exclusion
- **Performance optimization** by excluding unnecessary files
- **Team collaboration** through consistent file management
- **Deployment efficiency** by focusing on essential metadata

**Professional Development:**
- **Industry best practices** for Salesforce DX projects
- **Security-first approach** to file management
- **Scalable architecture** for growing projects
- **Maintainable codebase** through proper organization

**Your StoreConnect project now has comprehensive ignore file configuration that ensures security, performance, and maintainability while following Salesforce DX best practices.**

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Next Review**: Monthly  
**Owner**: StoreConnect Development Team
