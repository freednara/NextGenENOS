# ENOS Flow Implementation Guide

## 📋 **Document Information**
- **Last Updated**: December 2024
- **Version**: 1.0
- **Status**: Active
- **Maintainer**: ENOS Development Team

---

## 🎯 **Overview**

This guide provides detailed, step-by-step instructions for implementing all ENOS flows using Salesforce Flow Builder. This approach ensures reliable deployment and easier maintenance compared to manual metadata editing.

---

## 🚀 **Flow Implementation Strategy**

### **Why Use Flow Builder Instead of Metadata Files?**

1. **Reliability**: Built-in validation prevents deployment errors
2. **Maintainability**: Visual interface easier to modify and debug
3. **Performance**: Optimized by Salesforce for best performance
4. **Debugging**: Built-in debugging tools and error handling
5. **Documentation**: Self-documenting visual flows

### **Flow Types Used in ENOS**

1. **Screen Flows**: User interaction flows (checkout, support)
2. **Record-Triggered Flows**: Automated processes (order processing, inventory)
3. **Scheduled-Triggered Flows**: Time-based automation (cart recovery)
4. **Platform Event-Triggered Flows**: Real-time integrations

---

## 🔄 **Flow 1: Enhanced Checkout Flow**

### **Purpose**
Multi-step checkout process with cart review, shipping, payment, and order confirmation.

### **Implementation Steps**

#### **Step 1: Create Flow in Flow Builder**
1. **Navigate to**: Setup → Process Automation → Flows
2. **Click**: "New Flow"
3. **Choose**: "Screen Flow"
4. **Click**: "Next"

#### **Step 2: Configure Flow Properties**
```
Flow Label: ENOS Enhanced Checkout
Flow API Name: ENOS_Enhanced_Checkout
Flow Description: Multi-step checkout process for ENOS e-commerce platform
```

#### **Step 3: Add Flow Variables**
Click on the **Variables** tab and add these variables:

```
Variable 1:
- API Name: cartId
- Data Type: Text
- Input/Output Type: Input
- Description: Cart ID passed from component

Variable 2:
- API Name: customerEmail
- Data Type: Text
- Input/Output Type: Input
- Description: Customer email address

Variable 3:
- API Name: cartTotal
- Data Type: Currency
- Input/Output Type: Input
- Description: Cart total amount

Variable 4:
- API Name: shippingStreet
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Shipping street address

Variable 5:
- API Name: shippingCity
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Shipping city

Variable 6:
- API Name: shippingState
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Shipping state/province

Variable 7:
- API Name: shippingZip
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Shipping ZIP/postal code

Variable 8:
- API Name: shippingCountry
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Shipping country

Variable 9:
- API Name: paymentMethod
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Payment method selected

Variable 10:
- API Name: cardNumber
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Masked card number

Variable 11:
- API Name: expiryDate
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Card expiry date

Variable 12:
- API Name: cvv
- Data Type: Text
- Input/Output Type: Input/Output
- Description: Card CVV

Variable 13:
- API Name: orderNumber
- Data Type: Text
- Input/Output Type: Output
- Description: Generated order number

Variable 14:
- API Name: orderTotal
- Data Type: Currency
- Input/Output Type: Output
- Description: Order total amount
```

#### **Step 4: Build Flow Screens**

**Screen 1: Cart Review**
1. **Drag a Screen element** to the canvas
2. **Configure the screen**:
   ```
   Label: Cart Review
   Allow Back: false
   Allow Finish: false
   Show Footer: true
   Show Header: true
   ```

3. **Add fields to the screen**:
   ```
   Field 1: Display Text
   - Label: Cart Summary
   - Field Text: Review your cart items before proceeding to checkout
   - Help Text: Please verify all items and quantities

   Field 2: Display Text
   - Label: Cart Items
   - Field Text: Cart items will be displayed here
   - Help Text: Your selected products

   Field 3: Display Text
   - Label: Total Amount
   - Field Text: Total: {!cartTotal}
   - Help Text: Order total including tax

   Field 4: Button
   - Label: Continue to Shipping
   - Variant: Brand
   - Icon: utility:chevronright
   ```

**Screen 2: Shipping Information**
1. **Drag another Screen element** to the canvas
2. **Configure the screen**:
   ```
   Label: Shipping Information
   Allow Back: true
   Allow Finish: false
   Show Footer: true
   Show Header: true
   ```

3. **Add fields to the screen**:
   ```
   Field 1: Display Text
   - Label: Shipping Header
   - Field Text: Please provide your shipping information
   - Help Text: We'll use this for delivery

   Field 2: Input Field
   - Label: Street Address
   - Field Type: Text
   - Required: true
   - Help Text: Enter your street address
   - Store: shippingStreet

   Field 3: Input Field
   - Label: City
   - Field Type: Text
   - Required: true
   - Help Text: Enter your city
   - Store: shippingCity

   Field 4: Input Field
   - Label: State/Province
   - Field Type: Text
   - Required: true
   - Help Text: Enter your state or province
   - Store: shippingState

   Field 5: Input Field
   - Label: ZIP/Postal Code
   - Field Type: Text
   - Required: true
   - Help Text: Enter your ZIP or postal code
   - Store: shippingZip

   Field 6: Input Field
   - Label: Country
   - Field Type: Text
   - Required: true
   - Help Text: Enter your country
   - Store: shippingCountry

   Field 7: Button
   - Label: Back to Cart Review
   - Variant: Neutral
   - Icon: utility:chevronleft

   Field 8: Button
   - Label: Continue to Payment
   - Variant: Brand
   - Icon: utility:chevronright
   ```

**Screen 3: Payment Information**
1. **Drag another Screen element** to the canvas
2. **Configure the screen**:
   ```
   Label: Payment Information
   Allow Back: true
   Allow Finish: false
   Show Footer: true
   Show Header: true
   ```

3. **Add fields to the screen**:
   ```
   Field 1: Display Text
   - Label: Payment Header
   - Field Text: Please provide your payment information
   - Help Text: Your payment is secure

   Field 2: Input Field
   - Label: Payment Method
   - Field Type: Text
   - Required: true
   - Help Text: Credit card, PayPal, etc.
   - Store: paymentMethod

   Field 3: Input Field
   - Label: Card Number
   - Field Type: Text
   - Required: true
   - Help Text: Enter card number (masked for security)
   - Store: cardNumber

   Field 4: Input Field
   - Label: Expiry Date
   - Field Type: Text
   - Required: true
   - Help Text: MM/YY format
   - Store: expiryDate

   Field 5: Input Field
   - Label: CVV
   - Field Type: Text
   - Required: true
   - Help Text: 3-4 digit security code
   - Store: cvv

   Field 6: Button
   - Label: Back to Shipping
   - Variant: Neutral
   - Icon: utility:chevronleft

   Field 7: Button
   - Label: Complete Order
   - Variant: Brand
   - Icon: utility:check
   ```

**Screen 4: Order Confirmation**
1. **Drag another Screen element** to the canvas
2. **Configure the screen**:
   ```
   Label: Order Confirmation
   Allow Back: false
   Allow Finish: true
   Show Footer: true
   Show Header: true
   ```

3. **Add fields to the screen**:
   ```
   Field 1: Display Text
   - Label: Confirmation Header
   - Field Text: Thank you for your order!
   - Help Text: Your order has been placed successfully

   Field 2: Display Text
   - Label: Order Number
   - Field Text: Order Number: {!orderNumber}
   - Help Text: Use this for tracking

   Field 3: Display Text
   - Label: Order Total
   - Field Text: Total: {!orderTotal}
   - Help Text: Final amount charged

   Field 4: Display Text
   - Label: Estimated Delivery
   - Field Text: Estimated Delivery: 5-7 business days
   - Help Text: Standard shipping time

   Field 5: Display Text
   - Label: Next Steps
   - Field Text: You will receive an email confirmation shortly. Track your order in your account.
   - Help Text: What happens next
   ```

#### **Step 5: Add Flow Logic Elements**

**Element 1: Decision - Validate Cart**
1. **Drag a Decision element** between Screen 1 and Screen 2
2. **Configure**:
   ```
   Label: Validate Cart
   Default Outcome: Error
   Outcomes:
   - Outcome 1: Valid Cart
     - Condition: {!cartId} != null
   - Outcome 2: Invalid Cart
     - Condition: {!cartId} == null
   ```

**Element 2: Assignment - Store Shipping Info**
1. **Drag an Assignment element** between Screen 2 and Screen 3
2. **Configure**:
   ```
   Label: Store Shipping Info
   Assignments:
   - Variable: shippingStreet
     - Operator: Equals
     - Value: {!Street_Address_Input}
   - Variable: shippingCity
     - Operator: Equals
     - Value: {!City_Input}
   - Variable: shippingState
     - Operator: Equals
     - Value: {!State_Input}
   - Variable: shippingZip
     - Operator: Equals
     - Value: {!ZIP_Input}
   - Variable: shippingCountry
     - Operator: Equals
     - Value: {!Country_Input}
   ```

**Element 3: Assignment - Store Payment Info**
1. **Drag an Assignment element** between Screen 3 and Screen 4
2. **Configure**:
   ```
   Label: Store Payment Info
   Assignments:
   - Variable: paymentMethod
     - Operator: Equals
     - Value: {!Payment_Method_Input}
   - Variable: cardNumber
     - Operator: Equals
     - Value: {!Card_Number_Input}
   - Variable: expiryDate
     - Operator: Equals
     - Value: {!Expiry_Date_Input}
   - Variable: cvv
     - Operator: Equals
     - Value: {!CVV_Input}
   ```

**Element 4: Assignment - Generate Order Number**
1. **Drag another Assignment element** before Screen 4
2. **Configure**:
   ```
   Label: Generate Order Number
   Assignments:
   - Variable: orderNumber
     - Operator: Equals
     - Value: "ENOS-" + TEXT(TODAY()) + "-" + TEXT(RANDOM())
   - Variable: orderTotal
     - Operator: Equals
     - Value: {!cartTotal}
   ```

#### **Step 6: Connect All Elements**
Connect the elements in this order:
```
Start → Cart Review → Validate Cart → Shipping Information → Store Shipping Info → Payment Information → Store Payment Info → Generate Order Number → Order Confirmation
```

#### **Step 7: Test the Flow**
1. **Click**: "Save" to save your flow
2. **Click**: "Run" to test the flow
3. **Enter test data** for each screen
4. **Verify navigation** between screens
5. **Check variable assignments**

#### **Step 8: Activate the Flow**
1. **Click**: "Activate" button
2. **Set entry criteria** (if needed)
3. **Configure user access** permissions

---

## 🔄 **Flow 2: Order Processing Flow**

### **Purpose**
Automated order creation from cart data with transactional processing.

### **Implementation Steps**

#### **Step 1: Create Flow in Flow Builder**
1. **New Flow**: "ENOS Order Processing"
2. **Type**: "Record-Triggered Flow"
3. **Trigger**: When Cart__c.Status__c changes to "Ready for Order"

#### **Step 2: Configure Trigger**
```
Object: Cart__c
Trigger: A record is created or updated
Entry Criteria: {!$Record.Status__c} = "Ready for Order"
Optimization: Run only when specified conditions are met
```

#### **Step 3: Add Flow Elements**

**Element 1: Get Cart Data**
```
Type: Get Records
Object: Cart__c
Filter: Id equals {!$Record.Id}
Store: cartRecord
```

**Element 2: Get Cart Items**
```
Type: Get Records
Object: Cart_Item__c
Filter: Cart__c equals {!cartRecord.Id}
Store: cartItems
```

**Element 3: Create Order**
```
Type: Create Records
Object: Order
Fields:
- AccountId: {!cartRecord.Contact__r.AccountId}
- EffectiveDate: {!$Flow.CurrentDateTime}
- Status: "Draft"
- Type: "Standard Order"
- Pricebook2Id: "Standard Price Book"
Store: createdOrder
```

**Element 4: Create Order Items (Loop)**
```
Type: Loop
Collection: {!cartItems}
Loop Variable: cartItem
Actions:
  - Create OrderItem record:
    - OrderId: {!createdOrder.Id}
    - PricebookEntryId: {!cartItem.PricebookEntryId__c}
    - Quantity: {!cartItem.Quantity__c}
    - UnitPrice: {!cartItem.Unit_Price__c}
```

**Element 5: Update Cart Status**
```
Type: Update Records
Object: Cart__c
Filter: Id equals {!$Record.Id}
Fields:
- Status__c: "Converted"
- Order__c: {!createdOrder.Id}
```

**Element 6: Send Confirmation Email**
```
Type: Send Email
To: {!cartRecord.Contact__r.Email}
Subject: "Order Confirmation - {!createdOrder.OrderNumber}"
Body: "Your order has been created successfully..."
```

#### **Step 4: Configure Error Handling**
```
Add Fault Path from each element:
- Set Error Message variable
- Log error to custom object
- Send notification to admin
```

#### **Step 5: Test and Activate**
1. **Test with sample cart data**
2. **Verify order creation**
3. **Activate the flow**

---

## 🔄 **Flow 3: Cart Abandonment Recovery**

### **Purpose**
Automated follow-up for abandoned carts to increase conversion rates.

### **Implementation Steps**

#### **Step 1: Create Flow in Flow Builder**
1. **New Flow**: "ENOS Cart Recovery"
2. **Type**: "Scheduled-Triggered Flow"
3. **Schedule**: Daily at 9:00 AM

#### **Step 2: Configure Schedule**
```
Frequency: Daily
Time: 9:00 AM
Time Zone: Your org's timezone
```

#### **Step 3: Add Flow Elements**

**Element 1: Find Abandoned Carts**
```
Type: Get Records
Object: Cart__c
Filter:
- Status__c equals "Active"
- LastModifiedDate less than {!$Flow.CurrentDateTime - 1}
- Contact__r.Email not equal to null
Store: abandonedCarts
```

**Element 2: Loop Through Abandoned Carts**
```
Type: Loop
Collection: {!abandonedCarts}
Loop Variable: abandonedCart
```

**Element 3: Send Recovery Email**
```
Type: Send Email
To: {!abandonedCart.Contact__r.Email}
Subject: "Complete Your ENOS Order"
Body: "Hi! We noticed you left some items in your cart..."
```

**Element 4: Update Cart Status**
```
Type: Update Records
Object: Cart__c
Filter: Id equals {!abandonedCart.Id}
Fields:
- Status__c: "Abandoned"
- Recovery_Email_Sent__c: true
- Recovery_Email_Date__c: {!$Flow.CurrentDateTime}
```

#### **Step 4: Configure Email Templates**
1. **Create email template** for cart recovery
2. **Include cart items** and total amount
3. **Add call-to-action** button to return to cart

#### **Step 5: Test and Activate**
1. **Test with sample abandoned carts**
2. **Verify email sending**
3. **Activate the flow**

---

## 🔄 **Flow 4: Product Recommendations**

### **Purpose**
Analyze user behavior and suggest relevant products.

### **Implementation Steps**

#### **Step 1: Create Flow in Flow Builder**
1. **New Flow**: "ENOS Product Recommendations"
2. **Type**: "Record-Triggered Flow"
3. **Trigger**: When View_Tracking__c is created

#### **Step 2: Configure Trigger**
```
Object: View_Tracking__c
Trigger: A record is created
Entry Criteria: None (run on all new view tracking records)
```

#### **Step 3: Add Flow Elements**

**Element 1: Analyze User Behavior**
```
Type: Get Records
Object: View_Tracking__c
Filter: Contact__c equals {!$Record.Contact__c}
Store: userBehavior
```

**Element 2: Get Recommendations**
```
Type: Get Records
Object: Product2
Filter: Is_Top_Seller__c equals true
Store: recommendations
```

**Element 3: Send Recommendations**
```
Type: Send Email
To: {!$Record.Contact__r.Email}
Subject: "Personalized Product Recommendations"
Body: "Based on your browsing history..."
```

#### **Step 4: Test and Activate**
1. **Test with sample view tracking data**
2. **Verify recommendation logic**
3. **Activate the flow**

---

## 🔄 **Flow 5: Customer Support**

### **Purpose**
Handle support requests and create cases automatically.

### **Implementation Steps**

#### **Step 1: Create Flow in Flow Builder**
1. **New Flow**: "ENOS Customer Support"
2. **Type**: "Screen Flow"
3. **Purpose**: Support request collection and case creation

#### **Step 2: Build Support Screens**
1. **Support Request Screen**: Collect issue details
2. **Case Creation**: Automatically create support case
3. **Confirmation Screen**: Show case number and next steps

#### **Step 3: Add Case Creation Logic**
```
Type: Create Records
Object: Case
Fields:
- Subject: "ENOS Support: {!issueType}"
- Description: {!description}
- Priority: {!priority}
- Origin: "Web"
- Status: "New"
```

#### **Step 4: Test and Activate**
1. **Test support request flow**
2. **Verify case creation**
3. **Activate the flow**

---

## 🔧 **Flow Testing & Validation**

### **Testing Strategy**

#### **1. Unit Testing**
- **Test each screen** individually
- **Validate input fields** with various data types
- **Test navigation** between screens
- **Verify error handling**

#### **2. Integration Testing**
- **Test complete user journeys**
- **Validate data flow** between components
- **Test error scenarios** and recovery
- **Performance testing** with large datasets

#### **3. User Acceptance Testing**
- **Test with real users**
- **Validate business logic**
- **Test edge cases** and exceptions
- **Mobile responsiveness** testing

### **Testing Commands**
```bash
# Test flow execution
sf apex run --command "// Test flow logic here"

# Check flow status
sf data query --query "SELECT Id, Status FROM Flow WHERE ProcessType = 'Flow'"
```

---

## 🚨 **Common Issues & Solutions**

### **Flow Deployment Issues**

#### **1. "Error parsing file" Messages**
**Solution**: Use Flow Builder UI instead of metadata files

#### **2. Variable Reference Errors**
**Solution**: Check variable names and data types

#### **3. Object Access Errors**
**Solution**: Verify object permissions and field access

### **Runtime Issues**

#### **1. Flow Execution Failures**
**Solution**: Check governor limits and error handling

#### **2. Data Validation Errors**
**Solution**: Implement proper input validation

#### **3. Integration Issues**
**Solution**: Verify component-to-flow navigation

---

## 📚 **Resources & References**

### **Salesforce Documentation**
- [Flow Builder User Guide](https://help.salesforce.com/s/articleView?id=flow_builder.htm)
- [Flow Best Practices](https://help.salesforce.com/s/articleView?id=flow_considerations.htm)
- [Flow Error Handling](https://help.salesforce.com/s/articleView?id=flow_error_handling.htm)

### **ENOS-Specific Resources**
- [Deployment Instructions](../ENOS_DEPLOYMENT_INSTRUCTIONS.md)
- [Permission Set Reference](../PERMISSION_SET_REFERENCE.md)
- [API Reference](../API_REFERENCE.md)

---

## 🔄 **Maintenance & Updates**

### **Regular Tasks**
1. **Weekly**: Monitor flow execution logs
2. **Monthly**: Review flow performance
3. **Quarterly**: Update flow logic and validation

### **Update Procedures**
1. **Test changes** in sandbox first
2. **Document all modifications**
3. **Update this guide** as needed
4. **Notify team members** of changes

---

## 📝 **Change Log**

### **Version 1.0 (December 2024)**
- Initial flow implementation guide created
- Detailed step-by-step instructions for all flows
- Testing strategies and troubleshooting guide
- Best practices and maintenance procedures

---

**Note**: This guide should be updated whenever new flows are added or existing flows are modified. All team members are responsible for keeping this documentation current and accurate.
