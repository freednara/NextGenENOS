# StoreConnect - Salesforce E-Commerce Rebuild

## Overview

This project rebuilds the StoreConnect e-commerce functionality in Salesforce using Lightning Web Components, Apex classes, and custom objects. The solution provides a complete B2B/B2C e-commerce experience for external customers through Salesforce Experience Cloud.

## 🏗️ Architecture

### Data Model
- **Cart__c**: Shopping cart container with roll-up summaries
- **Cart_Item__c**: Individual cart line items
- **Shipping_Address__c**: Customer shipping address management
- **View_Tracking__c**: Product view tracking for recommendations
- **Notification_Request__c**: Back-in-stock notification requests
- **Enhanced Product2**: Added image URL, stock quantity, and top seller flags
- **Enhanced Account**: Added assigned price book ID for B2B pricing

### Core Components
- **StoreConnectController**: Main business logic for cart operations and product queries
- **StoreConnectOrderProcessor**: Order processing, checkout, and inventory management
- **Product Catalog LWC**: Product browsing with search, filters, and pagination
- **Shopping Cart LWC**: Cart management and checkout process

## 🚀 Deployment Instructions

### Prerequisites
- Salesforce DX CLI installed and authenticated
- Development sandbox with Customer Community Plus Login license
- API version 58.0 or higher

### Step 1: Deploy Custom Objects and Fields
```bash
# Navigate to project directory
cd NextGenENOS

# Deploy all metadata
sfdx force:source:deploy -p force-app/main/default
```

### Step 2: Create Experience Cloud Site
1. **Setup → Digital Experiences → All Sites**
2. **New Site** → Choose "Customer Account Portal" template
3. **Site Name**: StoreConnect
4. **URL Path**: storeconnect
5. **Admin User**: Assign to your admin user

### Step 3: Configure Community Settings
1. **Setup → Digital Experiences → All Sites → StoreConnect**
2. **Administration → Members**
3. **Enable Customer Community Plus Login**
4. **Set up profiles and permission sets**

### Step 4: Create Permission Set
1. **Setup → Permission Sets → New**
2. **Label**: StoreConnect Customer
3. **API Name**: StoreConnect_Customer
4. **Assigned to**: Community users

**Object Permissions:**
- Cart__c: Read, Create, Edit, Delete
- Cart_Item__c: Read, Create, Edit, Delete
- Shipping_Address__c: Read, Create, Edit, Delete
- View_Tracking__c: Read, Create
- Notification_Request__c: Read, Create
- Product2: Read
- Account: Read
- Contact: Read
- Order: Read
- OrderItem: Read

**Field Permissions:**
- All custom fields: Read, Edit (as appropriate)
- Standard fields: Read only

### Step 5: Configure Product Data
1. **Setup → Products → Products**
2. **New Product** → Fill in required fields
3. **Add custom fields:**
   - Image_URL__c: Product image URL
   - Stock_Quantity__c: Available inventory
   - Is_Top_Seller__c: Top seller flag

### Step 6: Set Up Price Books
1. **Setup → Products → Price Books**
2. **New Price Book** for B2B customers
3. **Add products** with appropriate pricing
4. **Assign to accounts** via Assigned_Price_Book_ID__c field

## 🔧 Configuration

### Community Page Setup
1. **Builder → Pages**
2. **Create new page** for Product Catalog
3. **Add Product Catalog LWC** component
4. **Configure recordId** parameter to pass Contact ID

### Navigation Setup
1. **Builder → Navigation Menu**
2. **Add menu items:**
   - Products (Product Catalog page)
   - Cart (Shopping Cart page)
   - Orders (Order History page)
   - Account (Account settings)

### Email Templates
1. **Setup → Email Templates**
2. **Create templates for:**
   - Order confirmation
   - Back-in-stock notifications
   - Cart abandonment reminders

## 📱 User Experience Flow

### Customer Journey
1. **Browse Products**: Search, filter, and view product catalog
2. **Add to Cart**: Add products with quantity selection
3. **Manage Cart**: Update quantities, remove items
4. **Checkout**: Select shipping address, review order
5. **Order Confirmation**: Receive order number and confirmation
6. **Order Tracking**: View order history and status

### Key Features
- **Responsive Design**: Mobile-first approach
- **Real-time Inventory**: Stock level validation
- **Smart Recommendations**: Based on view tracking
- **Address Management**: Multiple shipping addresses
- **Order History**: Complete order tracking

## 🔒 Security Considerations

### Sharing Rules
- **Cart records**: Private to contact owner
- **Shipping addresses**: Private to account
- **View tracking**: Private to contact
- **Products**: Public read access

### Field-Level Security
- **Sensitive fields**: Hidden from community users
- **Editable fields**: Limited to customer data only
- **System fields**: Read-only for customers

## 🧪 Testing

### Test Scenarios
1. **Product Browsing**: Search, filters, pagination
2. **Cart Operations**: Add, update, remove items
3. **Checkout Process**: Address selection, order creation
4. **Inventory Validation**: Stock level checks
5. **User Permissions**: Access control validation

### Test Data
```apex
// Create test products
Product2 testProduct = new Product2(
    Name = 'Test Product',
    ProductCode = 'TEST-001',
    Description = 'Test product description',
    IsActive = true,
    Image_URL__c = 'https://example.com/image.jpg',
    Stock_Quantity__c = 100,
    Is_Top_Seller__c = true
);
insert testProduct;
```

## 📊 Monitoring and Analytics

### Key Metrics
- **Cart conversion rate**: Carts to orders
- **Product view to cart ratio**: Engagement metrics
- **Average order value**: Revenue insights
- **Top performing products**: Sales analytics

### Reports and Dashboards
1. **Cart Analytics**: Abandonment rates, conversion
2. **Product Performance**: Views, sales, inventory
3. **Customer Behavior**: Browsing patterns, preferences
4. **Order Metrics**: Volume, value, trends

## 🚨 Troubleshooting

### Common Issues
1. **Permission Errors**: Check permission set assignments
2. **Component Not Loading**: Verify LWC deployment
3. **Data Not Displaying**: Check sharing rules and field permissions
4. **Performance Issues**: Review SOQL query optimization

### Debug Steps
1. **Check Browser Console**: JavaScript errors
2. **Review Apex Debug Logs**: Server-side issues
3. **Verify Data Access**: Test with system admin
4. **Component Inspection**: Use Lightning Inspector

## 🔄 Future Enhancements

### Planned Features
- **Payment Integration**: Stripe, PayPal, etc.
- **Advanced Search**: Elasticsearch integration
- **Personalization**: AI-powered recommendations
- **Mobile App**: React Native companion app
- **Analytics Dashboard**: Real-time insights

### Integration Points
- **ERP Systems**: SAP, Oracle, NetSuite
- **Shipping Carriers**: FedEx, UPS, DHL APIs
- **Marketing Tools**: HubSpot, Marketo
- **Customer Support**: Zendesk, Service Cloud

## 📞 Support

### Resources
- **Salesforce Documentation**: [developer.salesforce.com](https://developer.salesforce.com)
- **Lightning Web Components**: [lwc.dev](https://lwc.dev)
- **Trailhead**: [trailhead.salesforce.com](https://trailhead.salesforce.com)

### Contact
For technical support or questions about this implementation, contact your Salesforce development team.

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Compatibility**: Salesforce API 58.0+  
**License**: Internal Use Only
