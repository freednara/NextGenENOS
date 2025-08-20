#!/bin/bash

# Fix LWC Component Naming Mismatch
# This script renames the component files to match their directory names

echo "Fixing ENOS LWC component naming..."

# ENOS_miniCart
echo "Fixing ENOS_miniCart..."
cd force-app/main/default/lwc/ENOS_miniCart
mv miniCart.js ENOS_miniCart.js 2>/dev/null || echo "ENOS_miniCart.js already exists"
mv miniCart.html ENOS_miniCart.html 2>/dev/null || echo "ENOS_miniCart.html already exists"
mv miniCart.css ENOS_miniCart.css 2>/dev/null || echo "ENOS_miniCart.css already exists"
mv miniCart.js-meta.xml ENOS_miniCart.js-meta.xml 2>/dev/null || echo "ENOS_miniCart.js-meta.xml already exists"
cd ../../../..

# ENOS_myQuotes
echo "Fixing ENOS_myQuotes..."
cd force-app/main/default/lwc/ENOS_myQuotes
mv myQuotes.js ENOS_myQuotes.js 2>/dev/null || echo "ENOS_myQuotes.js already exists"
mv myQuotes.html ENOS_myQuotes.html 2>/dev/null || echo "ENOS_myQuotes.html already exists"
mv myQuotes.css ENOS_myQuotes.css 2>/dev/null || echo "ENOS_myQuotes.css already exists"
mv myQuotes.js-meta.xml ENOS_myQuotes.js-meta.xml 2>/dev/null || echo "ENOS_myQuotes.js-meta.xml already exists"
cd ../../../..

# ENOS_orderHistory
echo "Fixing ENOS_orderHistory..."
cd force-app/main/default/lwc/ENOS_orderHistory
mv orderHistory.js ENOS_orderHistory.js 2>/dev/null || echo "ENOS_orderHistory.js already exists"
mv orderHistory.html ENOS_orderHistory.html 2>/dev/null || echo "ENOS_orderHistory.html already exists"
mv orderHistory.css ENOS_orderHistory.css 2>/dev/null || echo "ENOS_orderHistory.css already exists"
mv orderHistory.js-meta.xml ENOS_orderHistory.js-meta.xml 2>/dev/null || echo "ENOS_orderHistory.js-meta.xml already exists"
cd ../../../..

# ENOS_paymentGateway
echo "Fixing ENOS_paymentGateway..."
cd force-app/main/default/lwc/ENOS_paymentGateway
mv paymentGateway.js ENOS_paymentGateway.js 2>/dev/null || echo "ENOS_paymentGateway.js already exists"
mv paymentGateway.html ENOS_paymentGateway.html 2>/dev/null || echo "ENOS_paymentGateway.html already exists"
mv paymentGateway.css ENOS_paymentGateway.css 2>/dev/null || echo "ENOS_paymentGateway.css already exists"
mv paymentGateway.js-meta.xml ENOS_paymentGateway.js-meta.xml 2>/dev/null || echo "ENOS_paymentGateway.js-meta.xml already exists"
cd ../../../..

# ENOS_productBrowser
echo "Fixing ENOS_productBrowser..."
cd force-app/main/default/lwc/ENOS_productBrowser
mv productBrowser.js ENOS_productBrowser.js 2>/dev/null || echo "ENOS_productBrowser.js already exists"
mv productBrowser.html ENOS_productBrowser.html 2>/dev/null || echo "ENOS_productBrowser.html already exists"
mv productBrowser.css ENOS_productBrowser.css 2>/dev/null || echo "ENOS_productBrowser.css already exists"
mv productBrowser.js-meta.xml ENOS_productBrowser.js-meta.xml 2>/dev/null || echo "ENOS_productBrowser.js-meta.xml already exists"
cd ../../../..

# ENOS_productCatalog
echo "Fixing ENOS_productCatalog..."
cd force-app/main/default/lwc/ENOS_productCatalog
mv productCatalog.js ENOS_productCatalog.js 2>/dev/null || echo "ENOS_productCatalog.js already exists"
mv productCatalog.html ENOS_productCatalog.html 2>/dev/null || echo "ENOS_productCatalog.html already exists"
mv productCatalog.css ENOS_productCatalog.css 2>/dev/null || echo "ENOS_productCatalog.css already exists"
mv productCatalog.js-meta.xml ENOS_productCatalog.js-meta.xml 2>/dev/null || echo "ENOS_productCatalog.js-meta.xml already exists"
cd ../../../..

# ENOS_productDetail
echo "Fixing ENOS_productDetail..."
cd force-app/main/default/lwc/ENOS_productDetail
mv productDetail.js ENOS_productDetail.js 2>/dev/null || echo "ENOS_productDetail.js already exists"
mv productDetail.html ENOS_productDetail.html 2>/dev/null || echo "ENOS_productDetail.html already exists"
mv productDetail.css ENOS_productDetail.css 2>/dev/null || echo "ENOS_productDetail.css already exists"
mv productDetail.js-meta.xml ENOS_productDetail.js-meta.xml 2>/dev/null || echo "ENOS_productDetail.js-meta.xml already exists"
cd ../../../..

# ENOS_recentlyViewed
echo "Fixing ENOS_recentlyViewed..."
cd force-app/main/default/lwc/ENOS_recentlyViewed
mv recentlyViewed.js ENOS_recentlyViewed.js 2>/dev/null || echo "ENOS_recentlyViewed.js already exists"
mv recentlyViewed.html ENOS_recentlyViewed.html 2>/dev/null || echo "ENOS_recentlyViewed.html already exists"
mv recentlyViewed.css ENOS_recentlyViewed.css 2>/dev/null || echo "ENOS_recentlyViewed.css already exists"
mv recentlyViewed.js-meta.xml ENOS_recentlyViewed.js-meta.xml 2>/dev/null || echo "ENOS_recentlyViewed.js-meta.xml already exists"
cd ../../../..

# ENOS_shoppingCart
echo "Fixing ENOS_shoppingCart..."
cd force-app/main/default/lwc/ENOS_shoppingCart
mv shoppingCart.js ENOS_shoppingCart.js 2>/dev/null || echo "ENOS_shoppingCart.js already exists"
mv shoppingCart.html ENOS_shoppingCart.html 2>/dev/null || echo "ENOS_shoppingCart.html already exists"
mv shoppingCart.css ENOS_shoppingCart.css 2>/dev/null || echo "ENOS_shoppingCart.css already exists"
mv shoppingCart.js-meta.xml ENOS_shoppingCart.js-meta.xml 2>/dev/null || echo "ENOS_shoppingCart.js-meta.xml already exists"
cd ../../../..

echo "LWC component naming fixed!"
echo "Now you can deploy the components to see them in Experience Builder."

