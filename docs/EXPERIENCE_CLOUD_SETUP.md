# 🌐 Experience Cloud Configuration Guide

## Overview
This guide provides comprehensive instructions for setting up and configuring Salesforce Experience Cloud for the NextGenENOS StoreConnect e-commerce platform.

## Prerequisites

### 1. Salesforce Org Requirements
- [ ] Salesforce org with Experience Cloud licenses
- [ ] Customer Community Plus or Partner Community licenses for users
- [ ] Domain management permissions
- [ ] System Administrator access

### 2. Technical Requirements
- [ ] Custom domain configured (optional but recommended)
- [ ] SSL certificate for custom domain
- [ ] DNS configuration access
- [ ] Email deliverability configured

## Step 1: Enable Experience Cloud

### 1.1 Enable Digital Experiences
1. Go to **Setup** → **Digital Experiences** → **Settings**
2. Click **Enable Digital Experiences**
3. Select domain name (e.g., `storeconnect` for `storeconnect.force.com`)
4. Agree to Terms of Service
5. Click **Enable**

### 1.2 Configure Experience Cloud Settings
```
Setup → Digital Experiences → Settings

Settings to Configure:
- Self-Registration: Enabled
- Password Policies: Enhanced security
- Login & Logout URLs: Custom pages
- Email Templates: Branded templates
- External Users: Allow standard external profiles
```

## Step 2: Create Experience Cloud Site

### 2.1 Create New Experience
1. Go to **Setup** → **Digital Experiences** → **All Sites**
2. Click **New**
3. Select **Customer Service (Napili)** template
4. Configure basic settings:
   ```
   Name: StoreConnect Community
   URL: storeconnect-community
   Description: NextGenENOS E-commerce Platform
   ```

### 2.2 Site Configuration
```yaml
General Settings:
  - Site Name: StoreConnect Community
  - Site URL: /storeconnect
  - Active: True
  - Allow Guest Users: True
  - Guest User Profile: ENOS Community Login

Branding:
  - Logo: Company logo (190x40px recommended)
  - Favicon: Custom favicon
  - Brand Colors: Match company branding
  - Custom CSS: Enhanced styling

Navigation:
  - Home
  - Products
  - Cart
  - Orders
  - Profile
  - Support
```

## Step 3: Configure User Management

### 3.1 Profile Configuration
```
Profile: ENOS Community Login
License Type: Customer Community Login
User Type: Customer Portal User

Permissions:
- Read: Product2, PricebookEntry, Category__c
- Create/Read/Update: Cart__c, Cart_Item__c, Order, OrderItem
- Read: Account, Contact (own records only)
- Read/Update: Shipping_Address__c (own records only)
```

### 3.2 Permission Set Assignment
```
Permission Set: StoreConnectCommunity

Apex Classes Access:
- CartController
- ProductController
- StoreConnectController
- PerformanceMonitor (read-only)

Object Permissions:
- All required custom objects with appropriate CRUD
- Field-level security for sensitive data
```

### 3.3 Sharing Rules
```
Sharing Rule Name: StoreConnect Community Sharing

Objects to Share:
- Product2: Public Read Only
- Category__c: Public Read Only
- Cart__c: Private (owner-based)
- Order: Private (owner-based)
- Shipping_Address__c: Private (owner-based)

External Sharing:
- Account: Account owner and users in Account hierarchy
- Contact: Contact owner
```

## Step 4: Page Configuration

### 4.1 Lightning Pages Setup

#### Home Page
```
Page Name: StoreConnect Home
Template: Header, Two Columns, Footer
Components:
- Header: Navigation and search
- Hero Banner: Featured products/promotions
- Product Browser: Latest products
- Categories: Product category navigation
- Footer: Links and contact info
```

#### Product Catalog Page
```
Page Name: Product Catalog
Template: Header, Full Width, Footer
Components:
- Product Catalog: Main component with search and filters
- Mini Cart: Shopping cart summary
- Recently Viewed: Recently viewed products
```

#### Shopping Cart Page
```
Page Name: Shopping Cart
Template: Header, Two Columns, Footer
Components:
- Shopping Cart: Main cart component
- Order Summary: Price breakdown
- Payment Gateway: Checkout integration
```

#### Order History Page
```
Page Name: Order History
Template: Header, Full Width, Footer
Components:
- Order History: List of past orders
- Order Details: Expandable order information
```

### 4.2 Page Assignments
```
Profile: ENOS Community Login
Pages:
- Home: StoreConnect Home (default)
- Record Pages: Product Detail Page
- App Pages: Product Catalog, Shopping Cart, Order History

URL Mappings:
- /products → Product Catalog Page
- /cart → Shopping Cart Page
- /orders → Order History Page
- /profile → Profile Page
```

## Step 5: Navigation Configuration

### 5.1 Primary Navigation
```yaml
Navigation Menu: StoreConnect Main Menu
Items:
  - Home:
      Type: Salesforce Object
      Target: Home
      Label: Home
      
  - Products:
      Type: App Page
      Target: Product Catalog
      Label: Products
      
  - Cart:
      Type: App Page  
      Target: Shopping Cart
      Label: Cart
      
  - Orders:
      Type: App Page
      Target: Order History
      Label: My Orders
      
  - Profile:
      Type: Salesforce Object
      Target: Contact
      Label: My Profile
```

### 5.2 Footer Navigation
```yaml
Footer Menu: StoreConnect Footer
Items:
  - About Us
  - Terms of Service
  - Privacy Policy
  - Contact Support
  - Help Center
```

## Step 6: Branding and Styling

### 6.1 Theme Configuration
```css
/* Custom CSS for StoreConnect branding */
:root {
  --primary-color: #0176d3;
  --secondary-color: #16325c;
  --accent-color: #ff6b35;
  --text-color: #181818;
  --background-color: #f4f6f9;
}

.site-header {
  background-color: var(--primary-color);
  border-bottom: 2px solid var(--secondary-color);
}

.product-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.2s ease;
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.btn-primary {
  background-color: var(--accent-color);
  border-color: var(--accent-color);
}
```

### 6.2 Logo and Assets
```
Logo Requirements:
- Main Logo: 190x40px (PNG with transparent background)
- Favicon: 32x32px (ICO format)
- Hero Banner: 1200x400px (high quality)

Asset Locations:
- Upload to Static Resources
- Reference in Experience Builder
- Use in custom components
```

## Step 7: Self-Registration Setup

### 7.1 Registration Page Configuration
```
Self-Registration Settings:
- Enable Self-Registration: True
- Registration Page: Custom LWC component
- Default Profile: ENOS Community Login
- Default Account: Partner/Customer Account
- Email Verification: Required
- CAPTCHA: Enabled for security

Registration Fields:
- First Name (required)
- Last Name (required)  
- Email (required)
- Phone
- Company
- Terms Agreement (required)
```

### 7.2 Email Templates
```
Templates to Configure:
- Welcome Email: Branded welcome message
- Email Verification: Account activation
- Password Reset: Secure reset process
- Order Confirmation: Purchase confirmations
- Account Locked: Security notifications

Template Branding:
- Company logo and colors
- Consistent messaging
- Clear call-to-action buttons
- Contact information
```

## Step 8: Security Configuration

### 8.1 Login & Security Settings
```
Login Policies:
- Session Timeout: 8 hours
- Password Requirements: Strong passwords
- Two-Factor Authentication: Optional
- IP Restrictions: None (public site)
- Login Hours: 24/7 availability

Security Policies:
- HTTPS Redirect: Enabled
- Clickjack Protection: Enabled
- Content Security Policy: Configured
- CORS Settings: Appropriate origins only
```

### 8.2 Guest User Security
```
Guest User Profile: StoreConnect Guest
Permissions:
- Read Product2, Category__c: Public catalog browsing
- No access to user data
- Limited to public pages only
- Cannot access cart or orders

Guest User Restrictions:
- No DML operations
- Read-only access to public data
- Session limitations
- Rate limiting applied
```

## Step 9: Integration Configuration

### 9.1 Payment Gateway Integration
```yaml
PayGov Integration:
  Endpoint: Configured in Named Credentials
  Authentication: JWT/OAuth as appropriate
  Test Mode: Enabled for development
  Production Mode: For live deployment
  
Payment Methods:
  - Credit Cards (Visa, MasterCard, Amex)
  - Debit Cards
  - ACH (if supported)
  - Alternative payment methods
```

### 9.2 External Service Configuration
```
External Services:
- Email Service: Marketing automation
- Analytics: Google Analytics integration
- Customer Support: Chat widget
- Shipping: Carrier API integration

API Configurations:
- Named Credentials for secure connections
- Remote Site Settings for external calls
- CORS configuration for web services
- Rate limiting and timeout settings
```

## Step 10: Performance Optimization

### 10.1 Caching Strategy
```
Caching Configuration:
- Static Resources: 1 year cache
- Public Pages: 1 hour cache
- Dynamic Content: No cache
- API Responses: 15-minute cache

CDN Configuration:
- Salesforce CDN for static assets
- Image optimization enabled
- Compression enabled
- Geographic distribution
```

### 10.2 Performance Monitoring
```yaml
Monitoring Setup:
  Page Load Times: Track critical pages
  API Response Times: Monitor backend calls
  User Experience: Track user journeys
  Error Rates: Monitor and alert on issues
  
Performance Targets:
  Page Load: < 3 seconds
  API Response: < 1 second
  Uptime: 99.9%
  Error Rate: < 1%
```

## Step 11: Testing & Validation

### 11.1 Functional Testing
```
Test Scenarios:
✓ User registration and email verification
✓ Login and logout functionality
✓ Product browsing and search
✓ Shopping cart operations
✓ Order placement and confirmation
✓ Profile management
✓ Password reset functionality
✓ Mobile responsiveness
✓ Cross-browser compatibility
```

### 11.2 Security Testing
```
Security Tests:
✓ SQL injection prevention
✓ XSS protection
✓ CSRF protection
✓ Data access controls
✓ Permission enforcement
✓ Session management
✓ Input validation
✓ Error handling
```

### 11.3 Performance Testing
```
Performance Tests:
✓ Load testing (100+ concurrent users)
✓ Stress testing (peak load scenarios)
✓ Page load speed testing
✓ API response time testing
✓ Database query optimization
✓ Memory usage monitoring
✓ Network bandwidth testing
```

## Step 12: Go-Live Checklist

### 12.1 Pre-Launch Validation
- [ ] All components deployed and tested
- [ ] User profiles and permissions configured
- [ ] Branding and styling complete
- [ ] Integration testing completed
- [ ] Performance testing passed
- [ ] Security review completed
- [ ] Content review and approval
- [ ] User acceptance testing signed off

### 12.2 Launch Tasks
- [ ] DNS configuration (if custom domain)
- [ ] SSL certificate installation
- [ ] Production data migration
- [ ] User communication sent
- [ ] Support team briefed
- [ ] Monitoring systems active
- [ ] Backup procedures verified

### 12.3 Post-Launch Monitoring
- [ ] User registration rates
- [ ] Site performance metrics
- [ ] Error rates and issues
- [ ] User feedback collection
- [ ] Support ticket volume
- [ ] Business KPI tracking

## Step 13: Maintenance & Support

### 13.1 Regular Maintenance
```
Weekly Tasks:
- Performance monitoring review
- Error log analysis  
- User feedback review
- Content updates as needed

Monthly Tasks:
- Security review and updates
- Performance optimization
- User training needs assessment
- Feature usage analytics

Quarterly Tasks:
- Platform updates and patches
- Security audit
- Performance benchmarking
- User satisfaction survey
```

### 13.2 Support Procedures
```
Support Channels:
- Help Center: Self-service articles
- Contact Form: General inquiries
- Chat Support: Real-time assistance
- Phone Support: Critical issues

Escalation Matrix:
- Level 1: General questions (2-hour response)
- Level 2: Technical issues (1-hour response)
- Level 3: Critical issues (15-minute response)
- Emergency: System down (immediate response)
```

## Documentation and Resources

### 13.3 User Documentation
- [ ] User Guide: How to navigate and use the platform
- [ ] FAQ: Common questions and answers
- [ ] Video Tutorials: Step-by-step guidance
- [ ] Feature Announcements: New functionality
- [ ] Troubleshooting Guide: Common issues and solutions

### 13.4 Administrator Documentation
- [ ] Configuration Guide: System setup and maintenance
- [ ] Security Guidelines: Best practices and policies
- [ ] Performance Tuning: Optimization strategies
- [ ] Backup and Recovery: Data protection procedures
- [ ] Integration Documentation: API and service connections

---

## Success Metrics

### Key Performance Indicators (KPIs)
- **User Adoption**: Registration and active user rates
- **Performance**: Page load times and system responsiveness
- **Business Impact**: Order volume and revenue metrics
- **User Satisfaction**: Feedback scores and support tickets
- **System Health**: Uptime and error rates

### Monitoring Dashboard
Track these metrics in real-time using:
- Salesforce Analytics
- Google Analytics
- Custom performance monitoring
- User feedback systems
- Business intelligence tools

*This configuration ensures a robust, secure, and user-friendly e-commerce experience built on Salesforce Experience Cloud.*
