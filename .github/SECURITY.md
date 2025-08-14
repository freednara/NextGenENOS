# Security Policy

## Supported Versions

We actively support security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

### How to Report

If you discover a security vulnerability in NextGenENOS, please report it to us via:

1. **GitHub Security Advisories** (Preferred)
   - Go to the [Security tab](../../security/advisories) in this repository
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email** (For sensitive issues)
   - Send an email to: security@yourorganization.com
   - Include "NextGenENOS Security" in the subject line

### What to Include

Please include the following information in your report:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact and severity
- Suggested remediation (if any)
- Your contact information

### Response Timeline

- **Initial Response**: Within 24 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Critical issues within 30 days, others within 90 days

### Security Best Practices

When contributing to NextGenENOS, please follow these security guidelines:

#### Salesforce Security
- Always use `with sharing` classes for data access
- Implement proper CRUD/FLS checks using SecurityUtils
- Use bind variables in SOQL queries
- Validate all user inputs
- Never hardcode credentials or sensitive data

#### JavaScript/LWC Security
- Use CSP-compliant code
- Sanitize user inputs
- Avoid eval() and similar dynamic code execution
- Use secure communication patterns

#### Dependencies
- Keep all dependencies up to date
- Use `npm audit` to check for vulnerabilities
- Review third-party packages before adding them

### Security Scanning

This project uses multiple security scanning tools:

- **PMD**: Static analysis for Apex code security
- **CodeQL**: Advanced security analysis for JavaScript/TypeScript
- **npm audit**: Dependency vulnerability scanning
- **TruffleHog**: Secrets detection
- **SFDX Scanner**: Salesforce-specific security scanning

### Disclosure Policy

We follow responsible disclosure practices:

1. Security issues are fixed before public disclosure
2. Credit is given to security researchers who responsibly report issues
3. Security advisories are published for significant vulnerabilities
4. Users are notified of security updates through release notes

### Contact

For questions about this security policy, contact:
- Security Team: security@yourorganization.com
- Project Maintainers: maintainers@yourorganization.com
