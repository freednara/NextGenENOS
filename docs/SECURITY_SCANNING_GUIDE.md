# 🛡️ Security Scanning Guide

## Overview

NextGenENOS implements comprehensive security scanning through multiple layers of automated analysis to ensure code quality, security compliance, and vulnerability detection.

## Security Scanning Pipeline

### 1. **PMD Static Analysis**

- **Purpose**: Apex code security and quality analysis
- **Engine**: PMD 7.0.0
- **Focus Areas**:
  - SOQL injection prevention
  - CRUD/FLS violation detection
  - XSS vulnerability identification
  - Insecure endpoint detection
  - Performance optimization
  - Code quality standards

**Configuration**: `config/pmd-ruleset.xml`

### 2. **CodeQL Analysis**

- **Purpose**: Advanced security vulnerability detection
- **Languages**: JavaScript, TypeScript (LWC components)
- **Features**:
  - Security-focused queries
  - Extended vulnerability detection
  - SARIF output for GitHub Security tab

**Configuration**: `.github/codeql/codeql-config.yml`

### 3. **Secrets Detection**

- **Tool**: TruffleHog
- **Purpose**: Detect hardcoded secrets, keys, and credentials
- **Scope**: Entire repository
- **Features**:
  - Real-time scanning
  - Verified secrets only
  - JSON output for analysis

### 4. **Dependency Security**

- **Tools**:
  - npm audit (dependency vulnerabilities)
  - GitHub Dependency Review
  - License compliance checking
- **Scope**: All Node.js dependencies
- **Thresholds**: Moderate and above

### 5. **SFDX Scanner** (Optional)

- **Purpose**: Salesforce-specific security analysis
- **Engine**: PMD with Salesforce rules
- **Format**: SARIF for integration

## Security Scan Execution

### GitHub Actions Integration

The security scanning runs automatically on:

- **Push to main/develop branches**
- **Pull requests**
- **Manual workflow dispatch**

### Scan Jobs

```yaml
# Basic Security Scan
security-scan:
  - PMD Security Analysis
  - Secrets Detection
  - SFDX Scanner (optional)

# Advanced Security Analysis
advanced-security:
  - CodeQL Analysis
  - Dependency Security Review
  - NPM Audit
  - License Compliance
```

### Reports and Artifacts

All security scan results are:

1. **Uploaded to GitHub Security tab** (SARIF format)
2. **Stored as workflow artifacts** (30-day retention)
3. **Summarized in workflow summaries**
4. **Available for download**

## Security Scan Results

### Viewing Results

#### GitHub Security Tab

1. Navigate to repository **Security** tab
2. Select **Code scanning alerts**
3. Filter by tool (PMD, CodeQL, etc.)
4. Review findings and remediation advice

#### Workflow Artifacts

1. Go to **Actions** → Recent workflow run
2. Scroll to **Artifacts** section
3. Download security reports
4. Review detailed findings

#### Workflow Summary

- Real-time scan status
- High-level metrics
- Quick issue identification
- Direct links to detailed reports

### Understanding Results

#### PMD Security Findings

- **Priority 1**: Critical security issues (SOQL injection, CRUD violations)
- **Priority 2**: Performance and best practices
- **Priority 3**: Design improvements
- **Priority 4**: Code style and documentation

#### CodeQL Findings

- **Critical**: Remote code execution, SQL injection
- **High**: XSS, authentication bypass
- **Medium**: Information disclosure, CSRF
- **Low**: Minor security improvements

#### Dependency Findings

- **Critical**: Immediate update required
- **High**: Update recommended
- **Moderate**: Monitor and plan update
- **Low**: Optional improvement

## Security Configuration

### PMD Ruleset Customization

```xml
<!-- High-priority security rules -->
<rule ref="category/apex/security.xml">
    <priority>1</priority>
</rule>

<!-- Custom exclusions for utility classes -->
<exclude-pattern>.*Test\.cls</exclude-pattern>
<exclude-pattern>ENOS_PerformanceMonitor\.cls</exclude-pattern>
```

### CodeQL Configuration

```yaml
queries:
  - uses: security-and-quality
  - uses: security-extended

paths:
  - force-app/main/default/lwc/**/*.js
  - force-app/main/default/aura/**/*.js
```

## Best Practices

### For Developers

1. **Run Local Scans**

   ```bash
   # PMD analysis
   npm run lint:apex

   # JavaScript analysis
   npm run lint

   # Security audit
   npm audit
   ```

2. **Address Security Findings**
   - Fix Priority 1 (security) issues immediately
   - Plan remediation for Priority 2-3 issues
   - Document exceptions for false positives

3. **Code Review Integration**
   - Review security scan results in PR reviews
   - Require security approval for sensitive changes
   - Use scan results to guide code improvements

### For Security Team

1. **Monitor Security Alerts**
   - Set up notifications for new security findings
   - Review critical vulnerabilities within 24 hours
   - Track remediation progress

2. **Update Security Rules**
   - Regularly review and update PMD rules
   - Add new CodeQL queries as needed
   - Tune thresholds based on findings

3. **Security Metrics**
   - Track vulnerability trends
   - Monitor fix times
   - Report on security posture

## Troubleshooting

### Common Issues

#### PMD Parsing Errors

- **Cause**: New Salesforce syntax not recognized
- **Solution**: Add exclusion pattern or update PMD version

#### CodeQL Build Failures

- **Cause**: JavaScript build issues
- **Solution**: Verify package.json and dependencies

#### Secrets False Positives

- **Cause**: Test data or examples detected as secrets
- **Solution**: Use .trufflehogignore file

### Getting Help

- **GitHub Issues**: Report bugs or feature requests
- **Security Team**: security@yourorganization.com
- **Documentation**: Review this guide and linked resources

## Compliance and Reporting

### Regulatory Requirements

- **SOC 2**: Automated security testing
- **GDPR**: Data protection validation
- **PCI DSS**: Secure coding practices
- **Salesforce Security Review**: AppExchange compliance

### Audit Trail

- All scan results stored and versioned
- Historical trend analysis available
- Compliance reporting automated
- Change tracking integrated

## Security Scan Metrics

### Key Performance Indicators

- **Critical vulnerabilities**: Target 0
- **High vulnerabilities**: Target < 5
- **Mean time to remediation**: Target < 48 hours
- **Scan coverage**: Target 100% of code
- **False positive rate**: Target < 10%

### Monthly Security Report

Generated automatically including:

- Vulnerability trend analysis
- Top security issues
- Remediation progress
- Compliance status
- Recommendations for improvement

---

## Quick Reference

| Scan Type      | Tool       | Output       | Priority |
| -------------- | ---------- | ------------ | -------- |
| Apex Security  | PMD        | SARIF + Text | High     |
| JS/TS Security | CodeQL     | SARIF        | High     |
| Secrets        | TruffleHog | JSON         | Critical |
| Dependencies   | npm audit  | JSON         | Medium   |
| SFDX           | Scanner    | SARIF        | Medium   |

**Need Help?** Check the [Security Policy](../.github/SECURITY.md) or contact the security team.
