# 🔒 **CSP Image Loading Fix Guide**

## 🚨 **Issue Description**
Your ENOS platform is experiencing **Content Security Policy (CSP) violations** that prevent product images from loading. The error shows:

```
Refused to load the image '<URL>' because it violates the following Content Security Policy directive: "img-src 'self' data: blob: <URL> <URL> <URL>..."
```

## 🔧 **Solution: Configure CSP Trusted Sites**

### **Step 1: Access Salesforce Setup**
1. Log into your Salesforce org
2. Click the **Setup** gear icon (⚙️)
3. In the Quick Find box, type: **CSP Trusted Sites**
4. Click **CSP Trusted Sites**

### **Step 2: Add Image Domains**
You need to add the domains where your product images are hosted. Based on the logs, add these domains:

#### **Common Image Hosting Domains:**
- `https://example.com` (if your images are hosted there)
- `https://*.cloudinary.com` (for Cloudinary images)
- `https://*.amazonaws.com` (for AWS S3 images)
- `https://*.salesforce.com` (for Salesforce-hosted images)
- `https://*.force.com` (for Force.com hosted images)

#### **How to Add:**
1. Click **New Trusted Site**
2. Fill in the form:
   - **Trusted Site Name**: `Product Images - [Domain Name]`
   - **Trusted Site URL**: `https://example.com` (replace with actual domain)
   - **Context**: Select **Communities** (if using Experience Cloud)
   - **Active**: ✅ Check this box
3. Click **Save**

### **Step 3: Verify Configuration**
After adding the domains:
1. Wait 5-10 minutes for changes to propagate
2. Refresh your ENOS platform
3. Check if product images now load correctly

## 🎯 **Alternative Solutions**

### **Option 1: Use Salesforce File Storage**
Instead of external image URLs, store images as Salesforce Files:
1. Upload images to Salesforce Files
2. Update product records to use Salesforce File URLs
3. This eliminates CSP issues entirely

### **Option 2: Use Base64 Encoded Images**
Convert images to base64 strings and embed them directly in the HTML:
```html
<img src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ..." alt="Product Image">
```

### **Option 3: Use Lightning Design System Icons**
Replace broken images with SLDS icons as fallbacks:
```html
<lightning-icon icon-name="standard:products" size="large" alternative-text="Product Image"></lightning-icon>
```

## 🔍 **Troubleshooting**

### **Check Current CSP Settings**
1. Go to **Setup > CSP Trusted Sites**
2. Review existing trusted sites
3. Ensure the domains you need are listed and active

### **Test Specific Domains**
1. Open browser Developer Tools (F12)
2. Go to Console tab
3. Look for specific CSP violation messages
4. Note the exact domain being blocked

### **Verify Experience Cloud Settings**
If using Experience Cloud:
1. Go to **Setup > Digital Experiences > All Sites**
2. Select your site
3. Go to **Administration > Security**
4. Check CSP settings there as well

## 📋 **Quick Action Items**

- [ ] **Immediate**: Add `https://example.com` to CSP Trusted Sites
- [ ] **Short-term**: Identify all image domains being used
- [ ] **Long-term**: Consider migrating to Salesforce Files for better security

## 🎉 **Expected Result**
After implementing these fixes:
- ✅ Product images will load without CSP violations
- ✅ User experience will improve significantly
- ✅ No more console error messages about blocked images

## 📞 **Need Help?**
If you continue to experience issues:
1. Check the Salesforce Developer Console for detailed error logs
2. Verify that all required domains are added to CSP Trusted Sites
3. Ensure the domains are active and properly configured
