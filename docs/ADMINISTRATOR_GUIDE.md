# StoreConnect Administrator Guide

## Overview

This guide provides step-by-step instructions for configuring and managing the StoreConnect e-commerce application in Salesforce. StoreConnect enables external customers to browse products, manage shopping carts, and place orders through a secure Experience Cloud community.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Permission Set Configuration](#permission-set-configuration)
4. [Experience Cloud Site Setup](#experience-cloud-site-setup)
5. [Community Configuration](#community-configuration)
6. [Product Data Setup](#product-data-setup)
7. [Batch Job Configuration](#batch-job-configuration)
8. [User Management](#user-management)
9. [Monitoring and Maintenance](#monitoring-and-maintenance)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

Before configuring StoreConnect, ensure you have:

- **Salesforce Edition**: Enterprise, Performance, or Unlimited
- **Experience Cloud License**: Customer Community Plus Login
- **User Permissions**: System Administrator or equivalent
- **API Access**: Enabled for your org
- **Custom Objects**: All StoreConnect custom objects deployed

## Initial Setup

### Step 1: Verify Custom Objects

Navigate to **Setup → Object Manager** and confirm these objects are available:

- ✅ **Cart\_\_c** - Shopping cart container
- ✅ **Cart_Item\_\_c** - Cart line items
- ✅ **Shipping_Address\_\_c** - Customer address book
- ✅ **View_Tracking\_\_c** - Product view tracking
- ✅ **Notification_Request\_\_c** - Back-in-stock notifications

### Step 2: Verify Custom Fields

Check that these custom fields exist on standard objects:

**Product2 Object:**

- ✅ **Image_URL\_\_c** - Product image URL
- ✅ **Stock_Quantity\_\_c** - Available inventory
- ✅ **Is_Top_Seller\_\_c** - Top seller flag

**Account Object:**

- ✅ **Assigned_Price_Book_ID\_\_c** - B2B pricing support

## Permission Set Configuration

### Step 1: Assign StoreConnect Community User Permission Set

1. Navigate to **Setup → Permission Sets**
2. Find **"StoreConnect Community User"**
3. Click **Manage Assignments**
4. Click **Add Assignments**
5. Select the users who will access the community
6. Click **Assign**

### Step 2: Verify Permission Set Contents

The permission set includes:

**Object Permissions:**

- **Product2**: Read access
- **Cart\_\_c**: Read, Create, Edit, Delete
- **Cart_Item\_\_c**: Read, Create, Edit, Delete
- **Shipping_Address\_\_c**: Read, Create, Edit, Delete
- **View_Tracking\_\_c**: Read, Create
- **Notification_Request\_\_c**: Read, Create
- **Order**: Read access
- **OrderItem**: Read access

**Field Permissions:**

- All custom fields properly configured
- Standard fields set to appropriate access levels

## Experience Cloud Site Setup

### Step 1: Create the Community Site

1. Navigate to **Setup → Digital Experiences → All Sites**
2. Click **New Site**
3. Choose **"Customer Account Portal"** template
4. Configure site settings:
   - **Site Name**: StoreConnect
   - **URL Path**: storeconnect
   - **Admin User**: Your admin user
   - **Default Language**: English
5. Click **Create**

### Step 2: Configure Site Settings

1. **General Settings:**
   - **Site Label**: StoreConnect
   - **Site Description**: E-commerce community for customers
   - **Site Type**: Customer Community

2. **Login & Registration:**
   - **Self-Registration**: Enabled
   - **Login Page**: Default
   - **Registration Page**: Default

3. **Security Settings:**
   - **Session Timeout**: 8 hours
   - **Force HTTPS**: Enabled
   - **IP Restrictions**: Configure as needed

## Community Configuration

### Step 1: Configure Navigation Menu

1. Navigate to **Builder → Navigation Menu**
2. Create menu items:
   - **Products** → Product Catalog page
   - **Cart** → Shopping Cart page
   - **Orders** → Order History page
   - **Account** → Account settings page

### Step 2: Set Up Community Pages

1. **Product Catalog Page:**
   - Add **Product Catalog** LWC component
   - Configure **recordId** parameter to pass Contact ID
   - Set page layout and styling

2. **Shopping Cart Page:**
   - Add **Shopping Cart** LWC component
   - Configure **recordId** parameter
   - Set up responsive design

3. **Order History Page:**
   - Create custom page for order display
   - Add order list component
   - Configure filtering and sorting

### Step 3: Configure Member Access

1. Navigate to **Administration → Members**
2. **Profiles:**
   - Assign **StoreConnect Community User** profile
   - Configure member visibility settings
   - Set up member approval process

3. **Sharing Rules:**
   - **Cart records**: Private to contact owner
   - **Shipping addresses**: Private to account
   - **Products**: Public read access

## Product Data Setup

### Step 1: Configure Products

1. Navigate to **Setup → Products → Products**
2. **Create New Product:**
   - **Product Name**: Enter product name
   - **Product Code**: Enter SKU
   - **Description**: Product description
   - **Is Active**: Checked
   - **Image_URL\_\_c**: Product image URL
   - **Stock_Quantity\_\_c**: Available inventory
   - **Is_Top_Seller\_\_c**: Set as needed

### Step 2: Set Up Price Books

1. **Standard Price Book:**
   - Add products with base pricing
   - Set currency and pricing model

2. **B2B Price Book:**
   - Create custom price book for business customers
   - Add products with contract pricing
   - Assign to accounts via **Assigned_Price_Book_ID\_\_c**

### Step 3: Configure Product Categories

1. **Product Code Structure:**
   - Use consistent SKU format
   - Include category prefixes
   - Example: ELEC-001, CLOTH-002

2. **Product Organization:**
   - Group by category
   - Set appropriate stock levels
   - Configure top seller flags

## Batch Job Configuration

### Step 1: Schedule Top Seller Calculation

1. Navigate to **Setup → Apex Classes**
2. Find **StoreConnectTopSellerBatch**
3. Click **Schedule Apex**
4. Configure schedule:
   - **Job Name**: Top Seller Calculation
   - **Frequency**: Daily
   - **Time**: 2:00 AM
   - **Days**: Monday through Sunday

### Step 2: Configure Data Cleanup Jobs

1. **View Tracking Cleanup:**
   - Schedule **StoreConnectViewTrackingCleanup**
   - Run weekly to remove old tracking data
   - Keep last 90 days of data

2. **Cart Abandonment Cleanup:**
   - Schedule **StoreConnectCartCleanup**
   - Run daily to clean abandoned carts
   - Set 30-day abandonment threshold

## User Management

### Step 1: Community User Creation

1. **Manual Creation:**
   - Navigate to **Setup → Users**
   - Click **New User**
   - Select **Customer Community User** profile
   - Fill in required information
   - Assign **StoreConnect Community User** permission set

2. **Self-Registration:**
   - Users register through community
   - Admin approves new registrations
   - Automatic permission set assignment

### Step 2: User Access Management

1. **Profile Management:**
   - Monitor user activity
   - Manage user permissions
   - Handle user deactivation

2. **Access Control:**
   - Review sharing rules
   - Monitor data access
   - Audit user permissions

## Monitoring and Maintenance

### Step 1: Regular Monitoring

1. **Daily Checks:**
   - Monitor community login activity
   - Check for failed transactions
   - Review error logs

2. **Weekly Reviews:**
   - Analyze user engagement metrics
   - Review product performance
   - Check system performance

3. **Monthly Audits:**
   - Review user permissions
   - Audit data access
   - Performance optimization

### Step 2: Performance Monitoring

1. **Apex Execution:**
   - Monitor governor limit usage
   - Track query performance
   - Review bulk operation efficiency

2. **Community Performance:**
   - Page load times
   - User session duration
   - Error rates

### Step 3: Data Maintenance

1. **Regular Cleanup:**
   - Remove old view tracking data
   - Clean abandoned carts
   - Archive completed orders

2. **Data Quality:**
   - Validate product information
   - Check inventory accuracy
   - Monitor data integrity

## Troubleshooting

### Common Issues and Solutions

1. **Permission Errors:**
   - Verify permission set assignment
   - Check field-level security
   - Review sharing rules

2. **Component Not Loading:**
   - Check LWC deployment
   - Verify component configuration
   - Review browser console errors

3. **Data Not Displaying:**
   - Check user permissions
   - Verify data sharing rules
   - Review SOQL query results

4. **Performance Issues:**
   - Monitor governor limits
   - Review query optimization
   - Check bulk operation efficiency

### Support Resources

- **Salesforce Documentation**: [developer.salesforce.com](https://developer.salesforce.com)
- **StoreConnect Technical Guide**: See `TECHNICAL_DOCUMENTATION.md`
- **Salesforce Support**: Contact your Salesforce representative

## Security Best Practices

### Data Protection

1. **User Data Isolation:**
   - Users can only see their own data
   - Implement proper sharing rules
   - Regular security audits

2. **Input Validation:**
   - All user input is sanitized
   - SOQL injection prevention
   - XSS protection

3. **Access Control:**
   - Principle of least privilege
   - Regular permission reviews
   - Secure authentication

### Compliance

1. **GDPR Compliance:**
   - Data retention policies
   - User consent management
   - Data export capabilities

2. **Security Standards:**
   - AppExchange security review compliance
   - Regular security assessments
   - Vulnerability management

## Conclusion

StoreConnect provides a secure, scalable e-commerce solution for Salesforce customers. By following this guide, administrators can ensure proper configuration, maintenance, and security of the application.

For technical questions or advanced configuration, refer to the Technical Documentation or contact the development team.

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Compatibility**: Salesforce API 58.0+  
**Support**: Contact StoreConnect Development Team
