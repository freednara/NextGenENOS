# NextGenENOS ENOS Test Data Documentation

## Overview

This directory contains comprehensive test data sets and scripts for the NextGenENOS ENOS application. The test data is designed to support various testing scenarios from unit testing to performance testing and demonstrations.

## 🗂️ Available Test Data Sets

### 1. Basic Sample Data

**File**: `insert-sample-data.apex`

- **Records**: 10 accounts, 10 contacts, 10 products, 10 price entries
- **Purpose**: Basic functional testing and initial setup
- **Usage**: Quick setup for development and basic testing

### 2. Comprehensive Test Data

**File**: `insert-comprehensive-test-data.apex`

- **Records**: 25 accounts, 50 contacts, 100 products, 15 categories
- **Additional**: Carts, orders, view tracking, notifications
- **Purpose**: Full-featured testing with realistic data volumes
- **Usage**: Integration testing, feature validation, user acceptance testing

### 3. Performance Test Data

**File**: `load-test-performance-data.apex`

- **Records**: 100 accounts, 500 contacts, 500 products, 200 carts
- **Additional**: 1500+ order items, 5000+ view tracking records
- **Purpose**: Performance testing and load testing
- **Usage**: Governor limit testing, bulk operations validation

### 4. Demo Scenarios

**File**: `create-demo-scenarios.apex`

- **Scenarios**: 5 complete business scenarios
- **Purpose**: Sales demonstrations and customer showcases
- **Usage**: Live demos, training sessions, customer presentations

## 📊 Data Categories

### Accounts & Contacts

- **Industries**: Technology, Healthcare, Education, Manufacturing, Retail, Finance, Government
- **Account Types**: Customer - Direct, Customer - Channel, Partner, Prospect
- **Geographic Distribution**: Major US cities across multiple states
- **Contact Roles**: IT Directors, Procurement Managers, Operations Managers, etc.

### Products & Pricing

- **Categories**:
  - Audio & Sound (Headphones, Speakers, Microphones)
  - Computing & Laptops (Business laptops, Gaming desktops, Workstations)
  - Mobile & Wearables (Smartphones, Smartwatches, Accessories)
  - Gaming & Entertainment (Consoles, Keyboards, VR Headsets)
  - Smart Home & IoT (Hub systems, Smart bulbs, Security cameras)
  - Networking & Connectivity (Routers, Switches, WiFi systems)
  - Storage & Memory (Hard drives, SSDs, Cloud storage)
  - Power & Charging (Power banks, UPS systems, Charging stations)

- **Price Range**: $12.99 - $4,999.99
- **Stock Levels**: 8 - 500 units per product
- **Top Sellers**: Marked products for analytics testing

### Orders & Transactions

- **Order Types**: Draft, Activated, Completed
- **Order Sizes**: Small (1-3 items) to Enterprise bulk (50+ items)
- **Date Range**: Recent orders spanning last 90 days
- **Order Values**: $50 - $250,000+ for enterprise orders

### Analytics Data

- **View Tracking**: 200+ to 5000+ product views
- **User Behavior**: Multiple views per user, trending products
- **Notification Requests**: Pending and sent notifications
- **Time Distribution**: Views across different time periods

## 🚀 Quick Start Guide

### 1. Basic Setup (Recommended for Development)

```apex
// Run in Developer Console or SF CLI
// File: scripts/apex/insert-sample-data.apex
// Creates: 10 accounts, 10 contacts, 10 products
// Time: ~30 seconds
```

### 2. Full Feature Testing

```apex
// Run in Developer Console or SF CLI
// File: scripts/apex/insert-comprehensive-test-data.apex
// Creates: Complete dataset with 100+ products and all features
// Time: ~2-3 minutes
```

### 3. Performance Testing

```apex
// Run in Developer Console or SF CLI
// File: scripts/apex/load-test-performance-data.apex
// Creates: Large dataset for performance validation
// Time: ~5-10 minutes
```

### 4. Demo Preparation

```apex
// Run in Developer Console or SF CLI
// File: scripts/apex/create-demo-scenarios.apex
// Creates: 5 business scenarios for demonstrations
// Time: ~1 minute
```
