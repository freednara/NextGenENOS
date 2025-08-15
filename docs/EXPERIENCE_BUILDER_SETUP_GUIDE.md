# 🏗️ **Experience Builder Setup Guide - ENOS Product Catalog**

## 📋 **Overview**

This guide walks you through setting up the complete product catalog experience in Experience Builder, including the Products page, Product Detail page, and site header configuration.

## 🚀 **Step 1: Access Experience Builder**

### **Navigate to Experience Builder:**

1. In your Salesforce org, go to **Setup** → **User Interface** → **Lightning Experience**
2. Click **All Sites** or look for **Experience Builder**
3. If you don't see an existing site, you'll need to create one first

### **Create Experience Site (if needed):**

1. Click **New** to create a new Experience Cloud site
2. Choose **Customer Account Portal** template
3. Name it **"ENOS"**
4. Set the URL path (e.g., `/enos`)
5. Click **Create**

---

## 📄 **Step 2: Create the "Products" Page**

### **Create Standard Page:**

1. In Experience Builder, click **Pages** in the left sidebar
2. Click **New Page**
3. Choose **Standard Page**
4. Name it **"Products"**
5. Click **Create**

### **Add Product Browser Component:**

1. In the **Components** panel (right side), find **productBrowser**
2. Drag the **productBrowser** LWC onto the main content area
3. The component will automatically:
   - Display all available products in a responsive grid
   - Provide search functionality
   - Show product images, names, descriptions, and prices
   - Include "Add to Cart" buttons
4. Click **Save**

---

## 🔍 **Step 3: Create the "Product Detail" Page**

### **Create Object Page:**

1. Click **New Page** again
2. Choose **Object Page**
3. Select **Product2** as the object
4. Name it **"Product Detail"**
5. Click **Create**

### **Add Product Detail Component:**

1. Drag the **productDetail** LWC onto the page
2. The component will automatically:
   - Get the `recordId` from the page URL
   - Display detailed product information
   - Show product images, descriptions, and stock status
   - Include quantity selector and "Add to Cart" functionality
3. Click **Save**

---

## 🎨 **Step 4: Configure the Site Header**

### **Edit Theme Layout:**

1. Click **Theme** in the left sidebar
2. Click **Edit** on the default theme
3. In the header section, you'll see the default navigation

### **Add Mini Cart Component:**

1. In the **Components** panel, find **miniCart**
2. Drag the **miniCart** LWC to the right side of the header
3. The component will:
   - Display current cart status
   - Show item count and total
   - Listen for real-time cart updates
   - Provide quick access to cart details

### **Save Theme Changes:**

1. Click **Save** to apply the header changes
2. The mini cart will now be visible on all pages

---

## 🔗 **Step 5: Link the Pages Together**

### **Navigation Setup:**

The pages are now automatically linked! Here's how it works:

1. **Products Page** → **Product Detail Page:**
   - Product cards in `productBrowser` are now clickable
   - Clicking a product card navigates to the detail page
   - The `recordId` is automatically passed in the URL

2. **Product Detail Page** → **Products Page:**
   - Users can navigate back using browser back button
   - Or add breadcrumb navigation if desired

### **How the Linking Works:**

- **HTML Structure:** Each product card is wrapped in a clickable `<a>` tag
- **JavaScript Navigation:** Uses `NavigationMixin` to navigate to Product2 record pages
- **Event Handling:** Add to Cart button prevents navigation (uses `stopPropagation`)
- **URL Structure:** `/enos/s/product-detail/[PRODUCT_ID]`

---

## �� **Step 6: Test the Experience**

### **Test Product Browsing:**

1. Navigate to the **Products** page
2. Verify that:
   - All products are displayed in a grid
   - Search functionality works
   - Product cards are clickable
   - Add to Cart buttons work independently

### **Test Product Details:**

1. Click on any product card
2. Verify that:
   - Product detail page loads correctly
   - Product information is displayed
   - Add to Cart functionality works
   - Navigation back to products works

### **Test Mini Cart:**

1. Add products to cart from either page
2. Verify that:
   - Mini cart updates in real-time
   - Cart count and total are accurate
   - Cart updates are reflected immediately

---

## 🔧 **Technical Implementation Details**

### **Component Architecture:**

```
productBrowser (Products Page)
├── Displays product grid
├── Handles search functionality
├── Manages product navigation
└── Integrates with cart system

productDetail (Product Detail Page)
├── Gets recordId from page context
├── Displays detailed product info
├── Manages quantity selection
└── Handles add to cart actions

miniCart (Header Component)
├── Listens for cart updates
├── Displays current cart status
├── Provides cart access
└── Updates in real-time
```

### **Navigation Flow:**

```
Products Page → Click Product Card → Product Detail Page
     ↑                                              ↓
     ← Browser Back / Navigation ← ← ← ← ← ← ← ← ← ←
```

### **Data Flow:**

1. **Product Browser:** Calls `ENOS_ProductController.getProducts()` and `ENOS_ProductController.searchProducts()`
2. **Product Detail:** Gets product data via `@wire(getRecord)` using page `recordId`
3. **Mini Cart:** Listens for cart update messages via Lightning Message Service

---

## 🎨 **Customization Options**

### **Styling Customization:**

- Modify CSS in each component's `.css` file
- Adjust grid layouts, colors, and spacing
- Customize hover effects and transitions

### **Layout Customization:**

- Add additional components to pages
- Create custom page layouts
- Add navigation menus and breadcrumbs

### **Functionality Enhancement:**

- Add product filtering by category
- Implement product comparison
- Add wishlist functionality
- Enhance search with filters

---

## ✅ **Verification Checklist**

- [ ] Experience site created and accessible
- [ ] Products page displays product grid correctly
- [ ] Product cards are clickable and navigate to detail pages
- [ ] Product detail pages show correct product information
- [ ] Add to Cart buttons work without triggering navigation
- [ ] Mini cart displays in header and updates in real-time
- [ ] Search functionality works on products page
- [ ] Navigation between pages works smoothly
- [ ] All components are properly styled and responsive

---

## 🚨 **Troubleshooting**

### **Common Issues:**

1. **Products not displaying:**
   - Check that Product2 records exist in the org
   - Verify ENOS_ProductController Apex class is deployed
   - Check browser console for JavaScript errors

2. **Navigation not working:**
   - Ensure productDetail page is created as Product2 object page
   - Verify NavigationMixin is properly imported
   - Check that recordId is being passed correctly

3. **Mini cart not updating:**
   - Verify CartUpdate message channel is deployed
   - Check that cart update events are being published
   - Ensure miniCart component is listening for updates

### **Debug Steps:**

1. Check browser console for errors
2. Verify component deployment status
3. Test Apex methods in Developer Console
4. Check Experience Builder component availability

---

## 🎉 **Success!**

Once you've completed all steps, you'll have a fully functional product catalog experience where customers can:

- Browse products in an attractive grid layout
- Search and filter products
- View detailed product information
- Add products to cart
- See real-time cart updates
- Navigate seamlessly between pages

Your ENOS e-commerce platform is now ready for customer use! 🚀
