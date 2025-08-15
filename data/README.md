# ENOS Data Migration Guide

This directory contains all data migration configurations and sample data for the ENOS e-commerce platform.

## Directory Structure

```
data/
├── README.md                           # This file
├── products.json                       # Sample product data (20 products)
├── sfdmu/                             # SFDMU configuration files
│   ├── export.json                    # Export plan configuration
│   ├── import.json                    # Import plan configuration
│   └── csv/                           # CSV data files
│       ├── Category__c.csv            # Product categories (5 categories)
│       ├── Product2.csv               # Products with categories (20 products)
│       ├── Pricebook2.csv             # Standard price book
│       └── PricebookEntry.csv         # Product pricing data
└── docs/                              # Documentation
    └── DATA_MIGRATION_WITH_SFDX_HARDIS.md
```

## Data Objects

### 1. Category\_\_c

- **Purpose**: Product categorization for filtering and organization
- **Fields**: Name, Description**c, Is_Active**c, Sort_Order\_\_c
- **Sample Data**: 5 categories (Audio, Wearables, Home, Gaming, Accessories)
- **Import Strategy**: Upsert by Name

### 2. Product2

- **Purpose**: Core product catalog with detailed information
- **Fields**: Name, ProductCode, Description, Stock_Quantity**c, Is_Top_Seller**c, Image_URL**c, Category**c
- **Sample Data**: 20 realistic tech products with category assignments
- **Import Strategy**: Upsert by ProductCode
- **Relationships**: Lookup to Category\_\_c by Name

### 3. Pricebook2

- **Purpose**: Standard price book for product pricing
- **Fields**: Name, IsActive
- **Sample Data**: Standard Price Book entry
- **Import Strategy**: Upsert by Name

### 4. PricebookEntry

- **Purpose**: Product pricing within the price book
- **Fields**: UnitPrice, IsActive
- **Sample Data**: Pricing for all 20 products
- **Import Strategy**: Insert (new records)
- **Relationships**: Lookup to Pricebook2 by Name, Product2 by ProductCode

## Migration Process

### Prerequisites

- Salesforce CLI (`sf`)
- sfdx-hardis plugin installed
- Authenticated target org
- Proper CRUD/FLS permissions

### Execution Order

1. **Setup**: `sf hardis:org:configure:data -o [ORG_ALIAS]`
2. **Export** (if needed): `sf hardis:org:data:export -o [ORG_ALIAS] -p data/sfdmu`
3. **Import**: `sf hardis:org:data:import -o [ORG_ALIAS] -p data/sfdmu`

### Import Dependencies

The import process automatically handles dependencies:

1. Categories are imported first
2. Pricebook2 is imported
3. Products are imported with category lookups
4. PricebookEntries are imported with product and pricebook lookups

## Sample Data Details

### Categories

- **Audio**: High-quality audio equipment and accessories
- **Wearables**: Smart watches and fitness tracking devices
- **Home**: Smart home automation and IoT devices
- **Gaming**: Professional gaming peripherals and accessories
- **Accessories**: Essential tech accessories and peripherals

### Products

- **20 diverse tech products** covering all categories
- **Realistic descriptions** and specifications
- **Stock quantities** for inventory management
- **Top seller flags** for featured product display
- **Placeholder images** for visual representation

### Pricing

- **Standard pricing** in the Standard Price Book
- **Realistic price points** for each product category
- **Active price entries** for immediate availability

## Data Quality

### Validation Rules

- All products have valid category assignments
- Product codes are unique and meaningful
- Stock quantities are positive integers
- Pricing data is complete for all products
- Category descriptions provide clear context

### Maintenance

- Update product data via SFDMU export/import cycles
- Add new categories as business needs evolve
- Maintain pricing accuracy through regular updates
- Monitor stock levels and update quantities

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure running user has CRUD access to all objects
2. **Lookup Failures**: Verify category names match exactly between Product2 and Category\_\_c
3. **Import Failures**: Check CSV format and field mappings in import.json
4. **Data Inconsistencies**: Use export to verify current org state before import

### Support

- Refer to `docs/DATA_MIGRATION_WITH_SFDX_HARDIS.md` for detailed commands
- Check Salesforce CLI logs for detailed error messages
- Validate CSV data format before import attempts

## Future Enhancements

### Planned Additions

- **Inventory tracking** with real-time stock updates
- **Product variants** (size, color, etc.)
- **Bulk pricing** for quantity discounts
- **Product reviews** and ratings
- **Related products** for cross-selling

### Data Expansion

- **More product categories** as business grows
- **International pricing** for global markets
- **Seasonal pricing** and promotions
- **Product bundles** and packages
- **Customer segmentation** data
