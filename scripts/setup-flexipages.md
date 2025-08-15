# ENOS FlexiPage Setup Guide

Since automated flexipage deployment is encountering template compatibility issues, follow these manual steps to configure your Lightning pages:

## 🏠 **1. Create ENOS Home Page**

### Steps:

1. **Go to Setup** → **App Manager**
2. **Find your ENOS app** → **Edit**
3. **Navigation** → **Add Tab**
4. **Lightning Page** → **New Lightning Page**

### Configuration:

- **Name**: `ENOS Home`
- **Template**: `Header and Two Columns`
- **Type**: `App Page`

### Components to Add:

- **Main Column**: `productBrowser`
- **Sidebar**: `miniCart`
- **Header**: Rich Text with welcome message

---

## 📱 **2. Create Product Catalog Page**

### Steps:

1. **Lightning Pages** → **New**
2. **App Page** → **Header and Two Columns**

### Configuration:

- **Name**: `Product Catalog`
- **Template**: `Header and Two Columns`

### Components:

- **Main**: `productCatalog`
- **Sidebar**: `miniCart`, `recentlyViewed`
- **Header**: "Product Catalog" rich text

---

## 🛒 **3. Create Shopping Cart Page**

### Steps:

1. **Lightning Pages** → **New**
2. **App Page** → **Header and Two Columns**

### Configuration:

- **Name**: `Shopping Cart`

### Components:

- **Main**: `shoppingCart`
- **Sidebar**: `productBrowser` (recommendations), `orderHistory`
- **Header**: Shopping cart banner

---

## 📦 **4. Enhanced Product Detail Page**

### Steps:

1. **Object Manager** → **Product2**
2. **Lightning Record Pages** → **New**

### Configuration:

- **Name**: `Product Detail Enhanced`
- **Template**: `Header, Two Columns, and Footer`

### Components:

- **Header**: `force:highlightsPanel`
- **Main**: `productDetail`, `force:detailPanel`
- **Sidebar**: `productBrowser` (related), `recentlyViewed`
- **Footer**: Related lists

---

## 🌐 **5. ENOS Community Pages**

### Setup Requirements:

1. **Open Experience Builder**
2. **Go to ENOS community**
3. **Create new pages**

### Home Page Components:

- **Header**: Welcome banner with rich text
- **Main**: `productBrowser`
- **Sidebar**: `miniCart`, Quick navigation

### Catalog Page Components:

- **Header**: Product catalog banner
- **Main**: `productCatalog`
- **Sidebar**: `miniCart`, Filter help, Category links

### Cart Page Components:

- **Header**: Shopping cart banner
- **Main**: `shoppingCart`
- **Sidebar**: Checkout help, Continue shopping links

---

## 🔧 **Quick Setup Commands**

After creating pages manually, you can assign them:

```bash
# Open your org
sf org open --target-org ENOS-Test

# Navigate to:
# 1. Setup → App Manager → ENOS → Edit
# 2. Setup → Digital Experiences → All Sites → ENOS → Workspaces
```

---

## ✅ **Verification Steps**

### Internal App:

1. **App Launcher** → **ENOS**
2. **Test ProductBrowser** displays products
3. **Test MiniCart** functionality
4. **Navigate between pages** smoothly

### Community:

1. **Navigate to** `https://[domain].my.site.com/enos`
2. **Test guest browsing** (if enabled)
3. **Test authenticated user** experience
4. **Verify cart functionality**

---

## 🎨 **Styling Tips**

### Rich Text Banners:

```html
<!-- Hero Banner -->
<div
  style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; padding: 60px 20px; border-radius: 12px; margin-bottom: 30px;"
>
  <h1 style="font-size: 3rem; margin: 0;">🌟 Welcome to ENOS</h1>
  <p style="font-size: 1.2rem; margin: 20px 0;">
    Next Generation E-commerce Platform
  </p>
</div>

<!-- Product Catalog Header -->
<div
  style="background: #f8f9fa; padding: 30px; text-align: center; border-radius: 8px; margin-bottom: 20px;"
>
  <h1 style="color: #333; margin: 0; font-size: 2.5rem;">🛍️ Product Catalog</h1>
  <p style="color: #666; margin: 15px 0 0 0;">
    Explore our complete product range
  </p>
</div>

<!-- Shopping Cart Header -->
<div
  style="background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; text-align: center; padding: 40px 20px; border-radius: 12px;"
>
  <h1 style="font-size: 2.8rem; margin: 0;">🛒 Your Shopping Cart</h1>
  <p style="font-size: 1.1rem; margin: 15px 0 0 0;">
    Review and proceed to checkout
  </p>
</div>
```

---

## 🚀 **Next Steps**

After setting up the pages:

1. **Test all LWC components** work correctly
2. **Configure page assignments** in App Manager
3. **Set up community navigation** in Experience Builder
4. **Test end-to-end** user journeys
5. **Customize branding** and styling

Your ENOS application will be fully functional with beautiful, responsive Lightning pages! 🎉
