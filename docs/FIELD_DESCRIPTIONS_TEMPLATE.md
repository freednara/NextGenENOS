# ENOS Field Descriptions Template

## **ADMIN TASK: Populate Description Fields for All Custom Objects and Fields**

**Deadline**: Wednesday, August 13th

**Purpose**: This is the first layer of our documentation foundation. Every custom object and field MUST have a completed Description field before Sprint 1 is considered complete.

---

## 📋 **Custom Objects - Description Field Requirements**

### **Cart\_\_c Object**

**Object Description**:

```
Shopping cart container for ENOS e-commerce functionality. Each logged-in community user has one active cart that persists across sessions. Carts are automatically created when users add their first product and are converted to orders upon checkout completion.
```

### **Cart_Item\_\_c Object**

**Object Description**:

```
Individual product line items within a user's shopping cart. Each cart item represents a single product with quantity, pricing, and calculated totals. Cart items are automatically removed when the parent cart is converted to an order.
```

### **Shipping_Address\_\_c Object**

**Object Description**:

```
Customer shipping address book for ENOS orders. Users can save multiple addresses (e.g., "Home Office", "Main Warehouse") and mark one as default. Addresses are linked to customer accounts and used during checkout for order fulfillment.
```

### **View_Tracking\_\_c Object**

**Object Description**:

```
Product view tracking system for ENOS recommendation engine. Records are created every time a user views a product detail page. This data powers the "Recently Viewed" component and personalized product recommendations. Records are automatically cleaned up after 90 days.
```

### **Notification_Request\_\_c Object**

**Object Description**:

```
Back-in-stock notification system for ENOS customers. Users can request email notifications when out-of-stock products become available. Records track the status of notification requests and prevent duplicate requests from the same user for the same product.
```

---

## 📝 **Custom Fields - Description Field Requirements**

### **Cart\_\_c Fields**

#### **Contact\_\_c**

**Description**:

```
Master-detail relationship to the Contact record representing the community user who owns this cart. This field controls sharing and access - users can only see carts linked to their own Contact record.
```

#### **Status\_\_c**

**Description**:

```
Cart lifecycle status indicating the current state of the shopping session. Values: Active (user is shopping), Abandoned (inactive for 30+ days), Converted (checkout completed, order created).
```

#### **Subtotal\_\_c**

**Description**:

```
Roll-up summary field that automatically calculates the total value of all items in the cart. Sums the Line_Total__c field from all child Cart_Item__c records. This field is read-only and updated automatically by Salesforce.
```

#### **Total_Items\_\_c**

**Description**:

```
Roll-up summary field that automatically counts the total quantity of all items in the cart. Sums the Quantity__c field from all child Cart_Item__c records. This field is read-only and updated automatically by Salesforce.
```

### **Cart_Item\_\_c Fields**

#### **Cart\_\_c**

**Description**:

```
Master-detail relationship to the parent Cart__c record. This field establishes the parent-child relationship and ensures cart items are automatically deleted when the parent cart is deleted.
```

#### **Product\_\_c**

**Description**:

```
Lookup relationship to the Product2 record representing the specific product added to the cart. This field is required and protected from deletion to prevent broken cart data if products are removed from the catalog.
```

#### **Quantity\_\_c**

**Description**:

```
Number of units of the product added to the cart. Default value is 1. This field is required and must be greater than 0. Quantity is validated against available stock before allowing cart updates.
```

#### **Unit_Price\_\_c**

**Description**:

```
The price of the product at the moment it was added to the cart. This field captures the price snapshot to handle price changes during the shopping session. Populated automatically by Apex logic.
```

#### **Line_Total\_\_c**

**Description**:

```
Formula field that automatically calculates the total value for this line item. Formula: Quantity__c * Unit_Price__c. This field is read-only and provides real-time pricing calculations.
```

### **Shipping_Address\_\_c Fields**

#### **Account\_\_c**

**Description**:

```
Master-detail relationship to the Account record representing the customer entity. This field controls sharing and access - users can only see addresses linked to their own Account record.
```

#### **Address_Label\_\_c**

**Description**:

```
User-friendly name for the shipping address (e.g., "Main Warehouse", "Home Office", "Branch Location"). This field serves as the record name and helps users identify different addresses in their address book.
```

#### **Street\_\_c**

**Description**:

```
Street address including building number, street name, and any additional address information. This field is required and supports multi-line text for complex addresses.
```

#### **City\_\_c**

**Description**:

```
City or municipality where the shipping address is located. This field is required and used for shipping calculations and address validation.
```

#### **State\_\_c**

**Description**:

```
State, province, or region where the shipping address is located. This field is required and used for shipping calculations, tax calculations, and address validation.
```

#### **Postal_Code\_\_c**

**Description**:

```
ZIP code, postal code, or equivalent postal identifier for the shipping address. This field is required and used for shipping calculations and address validation.
```

#### **Country\_\_c**

**Description**:

```
Country where the shipping address is located. This field is required and used for international shipping calculations, customs documentation, and address validation.
```

#### **Is_Default\_\_c**

**Description**:

```
Checkbox indicating whether this address is the user's default shipping address. Only one address per Account can be marked as default. This field is used to pre-select shipping addresses during checkout.
```

### **View_Tracking\_\_c Fields**

#### **User_Contact\_\_c**

**Description**:

```
Lookup relationship to the Contact record representing the community user who viewed the product. This field tracks user behavior for personalized recommendations and analytics.
```

#### **Product\_\_c**

**Description**:

```
Lookup relationship to the Product2 record representing the product that was viewed. This field tracks product popularity and user interest for recommendation engine optimization.
```

#### **Last_Viewed_Date\_\_c**

**Description**:

```
Date and time when the user last viewed this product. This field is used for sorting recently viewed products and determining which tracking records to clean up during maintenance jobs.
```

### **Notification_Request\_\_c Fields**

#### **User_Contact\_\_c**

**Description**:

```
Lookup relationship to the Contact record representing the community user requesting the back-in-stock notification. This field prevents duplicate requests and enables targeted email notifications.
```

#### **Product\_\_c**

**Description**:

```
Lookup relationship to the Product2 record representing the out-of-stock product the user wants to be notified about. This field links the notification request to the specific product for inventory monitoring.
```

#### **Status\_\_c**

**Description**:

```
Current status of the notification request. Values: Active (waiting for product to come back in stock), Notified (email notification sent, request fulfilled). This field tracks the lifecycle of notification requests.
```

### **Enhanced Standard Object Fields**

#### **Product2.Image_URL\_\_c**

**Description**:

```
URL link to the primary product image hosted on an external CDN or image hosting service. This field is used by the ENOS product catalog to display product images. Supports HTTPS URLs for secure image loading.
```

#### **Product2.Stock_Quantity\_\_c**

**Description**:

```
Current available inventory quantity for this product. This field is used for stock validation during cart operations, out-of-stock notifications, and inventory management. Must be 0 or greater.
```

#### **Product2.Is_Top_Seller\_\_c**

**Description**:

```
Flag indicating whether this product is classified as a top seller based on sales performance. This field is automatically updated by nightly batch jobs and used by the recommendation engine to highlight popular products.
```

#### **Account.Assigned_Price_Book_ID\_\_c**

**Description**:

```
18-digit Salesforce ID of the custom Price Book assigned to this Account for B2B contract pricing. This field enables different pricing tiers for business customers and is used during checkout to determine applicable pricing.
```

---

## ✅ **Admin Completion Checklist**

**Before marking Sprint 1 as complete, verify:**

- [ ] **All 5 custom objects** have completed Description fields
- [ ] **All 25+ custom fields** have completed Description fields
- [ ] **All standard object enhancements** have completed Description fields
- [ ] **Descriptions are clear and professional** (AppExchange standard)
- [ ] **No placeholder text** remains in any Description field

---

## 🎯 **Why This Matters**

1. **Documentation Foundation**: This is the first layer of our comprehensive documentation strategy
2. **AppExchange Compliance**: Proper field descriptions are required for security review
3. **Team Onboarding**: New developers and admins can understand the data model immediately
4. **Maintenance**: Clear descriptions make troubleshooting and updates easier
5. **Quality Assurance**: Proper documentation reflects professional development standards

**Complete this task by Wednesday, August 13th to ensure Sprint 1 meets our Definition of Done criteria.**
