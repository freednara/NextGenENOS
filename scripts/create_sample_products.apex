// Create 50 sample products with proper PricebookEntry records for ENOS testing
// This script ensures products have active price book entries for cart functionality
// Note: Using lowercase field names that actually exist in the org

try {
    // Get the Standard Price Book ID
    Id standardPricebookId = null;
    List<Pricebook2> standardPricebooks = [
        SELECT Id, Name, IsActive 
        FROM Pricebook2 
        WHERE IsStandard = true AND IsActive = true 
        LIMIT 1
    ];
    
    if (standardPricebooks.isEmpty()) {
        System.debug('❌ No active Standard Price Book found');
        return;
    }
    
    standardPricebookId = standardPricebooks[0].Id;
    System.debug('✅ Using Standard Price Book: ' + standardPricebooks[0].Name + ' (ID: ' + standardPricebookId + ')');
    
    // Create 50 diverse sample products
    List<Product2> products = new List<Product2>();
    
    // Electronics Category (15 products)
    products.add(new Product2(Name = 'ENOS Laptop Pro', Description = 'High-performance laptop for professionals', Family = 'Electronics', IsActive = true, stock_quantity__c = 50, is_top_seller__c = true, image_url__c = 'https://example.com/laptop.jpg'));
    products.add(new Product2(Name = 'ENOS Smartphone X', Description = 'Latest smartphone with advanced features', Family = 'Electronics', IsActive = true, stock_quantity__c = 100, is_top_seller__c = true, image_url__c = 'https://example.com/smartphone.jpg'));
    products.add(new Product2(Name = 'ENOS Wireless Headphones', Description = 'Premium noise-canceling headphones', Family = 'Electronics', IsActive = true, stock_quantity__c = 75, is_top_seller__c = false, image_url__c = 'https://example.com/headphones.jpg'));
    products.add(new Product2(Name = 'ENOS Gaming Console', Description = 'Next-gen gaming console for immersive gameplay', Family = 'Electronics', IsActive = true, stock_quantity__c = 30, is_top_seller__c = true, image_url__c = 'https://example.com/console.jpg'));
    products.add(new Product2(Name = 'ENOS Smart TV', Description = '4K Ultra HD Smart TV with streaming apps', Family = 'Electronics', IsActive = true, stock_quantity__c = 45, is_top_seller__c = false, image_url__c = 'https://example.com/tv.jpg'));
    products.add(new Product2(Name = 'ENOS Tablet Pro', Description = 'Professional tablet for creative work', Family = 'Electronics', IsActive = true, stock_quantity__c = 60, is_top_seller__c = false, image_url__c = 'https://example.com/tablet.jpg'));
    products.add(new Product2(Name = 'ENOS Smart Watch', Description = 'Fitness and health monitoring smartwatch', Family = 'Electronics', IsActive = true, stock_quantity__c = 80, is_top_seller__c = true, image_url__c = 'https://example.com/watch.jpg'));
    products.add(new Product2(Name = 'ENOS Bluetooth Speaker', Description = 'Portable wireless speaker with deep bass', Family = 'Electronics', IsActive = true, stock_quantity__c = 65, is_top_seller__c = false, image_url__c = 'https://example.com/speaker.jpg'));
    products.add(new Product2(Name = 'ENOS Wireless Earbuds', Description = 'True wireless earbuds with noise cancellation', Family = 'Electronics', IsActive = true, stock_quantity__c = 90, is_top_seller__c = true, image_url__c = 'https://example.com/earbuds.jpg'));
    products.add(new Product2(Name = 'ENOS Gaming Mouse', Description = 'High-precision gaming mouse with RGB lighting', Family = 'Electronics', IsActive = true, stock_quantity__c = 55, is_top_seller__c = false, image_url__c = 'https://example.com/mouse.jpg'));
    products.add(new Product2(Name = 'ENOS Mechanical Keyboard', Description = 'Premium mechanical keyboard for typing enthusiasts', Family = 'Electronics', IsActive = true, stock_quantity__c = 40, is_top_seller__c = false, image_url__c = 'https://example.com/keyboard.jpg'));
    products.add(new Product2(Name = 'ENOS Webcam Pro', Description = '4K webcam for professional video calls', Family = 'Electronics', IsActive = true, stock_quantity__c = 70, is_top_seller__c = false, image_url__c = 'https://example.com/webcam.jpg'));
    products.add(new Product2(Name = 'ENOS Power Bank', Description = 'High-capacity portable charger for devices', Family = 'Electronics', IsActive = true, stock_quantity__c = 85, is_top_seller__c = true, image_url__c = 'https://example.com/powerbank.jpg'));
    products.add(new Product2(Name = 'ENOS Wireless Charger', Description = 'Fast wireless charging pad for smartphones', Family = 'Electronics', IsActive = true, stock_quantity__c = 95, is_top_seller__c = false, image_url__c = 'https://example.com/charger.jpg'));
    
    // Office Category (12 products)
    products.add(new Product2(Name = 'ENOS Ergonomic Chair', Description = 'Comfortable office chair for long work hours', Family = 'Office', IsActive = true, stock_quantity__c = 25, is_top_seller__c = false, image_url__c = 'https://example.com/chair.jpg'));
    products.add(new Product2(Name = 'ENOS Standing Desk', Description = 'Adjustable standing desk for health-conscious workers', Family = 'Office', IsActive = true, stock_quantity__c = 30, is_top_seller__c = true, image_url__c = 'https://example.com/desk.jpg'));
    products.add(new Product2(Name = 'ENOS Monitor Stand', Description = 'Adjustable monitor stand for ergonomic viewing', Family = 'Office', IsActive = true, stock_quantity__c = 35, is_top_seller__c = false, image_url__c = 'https://example.com/monitorstand.jpg'));
    products.add(new Product2(Name = 'ENOS Desk Lamp', Description = 'LED desk lamp with adjustable brightness', Family = 'Office', IsActive = true, stock_quantity__c = 50, is_top_seller__c = false, image_url__c = 'https://example.com/lamps.jpg'));
    products.add(new Product2(Name = 'ENOS File Cabinet', Description = 'Secure filing cabinet with lock mechanism', Family = 'Office', IsActive = true, stock_quantity__c = 20, is_top_seller__c = false, image_url__c = 'https://example.com/cabinet.jpg'));
    products.add(new Product2(Name = 'ENOS Whiteboard', Description = 'Large magnetic whiteboard for brainstorming', Family = 'Office', IsActive = true, stock_quantity__c = 15, is_top_seller__c = false, image_url__c = 'https://example.com/whiteboard.jpg'));
    products.add(new Product2(Name = 'ENOS Printer Pro', Description = 'High-quality office printer with wireless connectivity', Family = 'Office', IsActive = true, stock_quantity__c = 10, is_top_seller__c = false, image_url__c = 'https://example.com/printer.jpg'));
    products.add(new Product2(Name = 'ENOS Scanner', Description = 'Document scanner for digitizing paperwork', Family = 'Office', IsActive = true, stock_quantity__c = 18, is_top_seller__c = false, image_url__c = 'https://example.com/scanner.jpg'));
    products.add(new Product2(Name = 'ENOS Shredder', Description = 'Cross-cut paper shredder for security', Family = 'Office', IsActive = true, stock_quantity__c = 22, is_top_seller__c = false, image_url__c = 'https://example.com/shredder.jpg'));
    products.add(new Product2(Name = 'ENOS Coffee Maker', Description = 'Professional coffee maker for office break rooms', Family = 'Office', IsActive = true, stock_quantity__c = 12, is_top_seller__c = true, image_url__c = 'https://example.com/coffee.jpg'));
    products.add(new Product2(Name = 'ENOS Water Cooler', Description = 'Bottled water cooler for office hydration', Family = 'Office', IsActive = true, stock_quantity__c = 8, is_top_seller__c = false, image_url__c = 'https://example.com/water.jpg'));
    products.add(new Product2(Name = 'ENOS Microwave', Description = 'Compact microwave for office kitchens', Family = 'Office', IsActive = true, stock_quantity__c = 14, is_top_seller__c = false, image_url__c = 'https://example.com/microwave.jpg'));
    
    // Home & Garden Category (10 products)
    products.add(new Product2(Name = 'ENOS Smart Thermostat', Description = 'WiFi-enabled smart thermostat for energy savings', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 40, is_top_seller__c = true, image_url__c = 'https://example.com/thermostat.jpg'));
    products.add(new Product2(Name = 'ENOS Security Camera', Description = 'Wireless security camera with night vision', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 55, is_top_seller__c = false, image_url__c = 'https://example.com/camera.jpg'));
    products.add(new Product2(Name = 'ENOS Smart Lock', Description = 'Keyless smart lock with mobile app control', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 35, is_top_seller__c = false, image_url__c = 'https://example.com/lock.jpg'));
    products.add(new Product2(Name = 'ENOS LED Bulbs', Description = 'Smart LED bulbs with color changing capability', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 120, is_top_seller__c = true, image_url__c = 'https://example.com/bulbs.jpg'));
    products.add(new Product2(Name = 'ENOS Robot Vacuum', Description = 'Automatic robot vacuum with mapping technology', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 25, is_top_seller__c = true, image_url__c = 'https://example.com/vacuum.jpg'));
    products.add(new Product2(Name = 'ENOS Garden Sprinkler', Description = 'Smart garden sprinkler with weather integration', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 30, is_top_seller__c = false, image_url__c = 'https://example.com/sprinkler.jpg'));
    products.add(new Product2(Name = 'ENOS Plant Monitor', Description = 'Soil moisture and light sensor for plants', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 45, is_top_seller__c = false, image_url__c = 'https://example.com/plantmonitor.jpg'));
    products.add(new Product2(Name = 'ENOS Smart Doorbell', Description = 'Video doorbell with motion detection', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 38, is_top_seller__c = false, image_url__c = 'https://example.com/doorbell.jpg'));
    products.add(new Product2(Name = 'ENOS Air Purifier', Description = 'HEPA air purifier with air quality monitoring', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 28, is_top_seller__c = false, image_url__c = 'https://example.com/purifier.jpg'));
    products.add(new Product2(Name = 'ENOS Smart Blinds', Description = 'Automated window blinds with schedule control', Family = 'Home & Garden', IsActive = true, stock_quantity__c = 20, is_top_seller__c = false, image_url__c = 'https://example.com/blinds.jpg'));
    
    // Sports & Fitness Category (8 products)
    products.add(new Product2(Name = 'ENOS Fitness Tracker', Description = 'Advanced fitness tracker with heart rate monitor', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 75, is_top_seller__c = true, image_url__c = 'https://example.com/tracker.jpg'));
    products.add(new Product2(Name = 'ENOS Yoga Mat', Description = 'Premium non-slip yoga mat for home practice', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 100, is_top_seller__c = false, image_url__c = 'https://example.com/yogamat.jpg'));
    products.add(new Product2(Name = 'ENOS Dumbbells Set', Description = 'Adjustable dumbbells for strength training', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 40, is_top_seller__c = false, image_url__c = 'https://example.com/dumbbells.jpg'));
    products.add(new Product2(Name = 'ENOS Resistance Bands', Description = 'Set of resistance bands for full-body workouts', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 85, is_top_seller__c = false, image_url__c = 'https://example.com/bands.jpg'));
    products.add(new Product2(Name = 'ENOS Jump Rope', Description = 'Professional jump rope for cardio training', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 60, is_top_seller__c = false, image_url__c = 'https://example.com/jumprope.jpg'));
    products.add(new Product2(Name = 'ENOS Foam Roller', Description = 'High-density foam roller for muscle recovery', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 45, is_top_seller__c = false, image_url__c = 'https://example.com/foamroller.jpg'));
    products.add(new Product2(Name = 'ENOS Water Bottle', Description = 'Insulated water bottle for hydration during workouts', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 150, is_top_seller__c = true, image_url__c = 'https://example.com/waterbottle.jpg'));
    products.add(new Product2(Name = 'ENOS Gym Bag', Description = 'Spacious gym bag with shoe compartment', Family = 'Sports & Fitness', IsActive = true, stock_quantity__c = 35, is_top_seller__c = false, image_url__c = 'https://example.com/gymbag.jpg'));
    
    // Kitchen & Dining Category (5 products)
    products.add(new Product2(Name = 'ENOS Air Fryer', Description = 'Digital air fryer for healthy cooking', Family = 'Kitchen & Dining', IsActive = true, stock_quantity__c = 65, is_top_seller__c = true, image_url__c = 'https://example.com/airfryer.jpg'));
    products.add(new Product2(Name = 'ENOS Instant Pot', Description = 'Multi-functional pressure cooker for quick meals', Family = 'Kitchen & Dining', IsActive = true, stock_quantity__c = 55, is_top_seller__c = false, image_url__c = 'https://example.com/instantpot.jpg'));
    products.add(new Product2(Name = 'ENOS Blender Pro', Description = 'High-speed blender for smoothies and soups', Family = 'Kitchen & Dining', IsActive = true, stock_quantity__c = 70, is_top_seller__c = false, image_url__c = 'https://example.com/blender.jpg'));
    products.add(new Product2(Name = 'ENOS Coffee Grinder', Description = 'Burr coffee grinder for fresh coffee beans', Family = 'Kitchen & Dining', IsActive = true, stock_quantity__c = 42, is_top_seller__c = false, image_url__c = 'https://example.com/grinder.jpg'));
    products.add(new Product2(Name = 'ENOS Food Scale', Description = 'Digital kitchen scale for precise measurements', Family = 'Kitchen & Dining', IsActive = true, stock_quantity__c = 58, is_top_seller__c = false, image_url__c = 'https://example.com/scale.jpg'));
    
    // Insert products
    insert products;
    System.debug('✅ Created ' + products.size() + ' products');
    
    // Create PricebookEntry records for each product
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    
    for (Product2 product : products) {
        // Generate realistic prices based on product category
        Decimal basePrice = 0;
        if (product.Family == 'Electronics') {
            basePrice = Math.random() * 800 + 200; // $200-$1000
        } else if (product.Family == 'Office') {
            basePrice = Math.random() * 500 + 100; // $100-$600
        } else if (product.Family == 'Home & Garden') {
            basePrice = Math.random() * 400 + 150; // $150-$550
        } else if (product.Family == 'Sports & Fitness') {
            basePrice = Math.random() * 200 + 50;  // $50-$250
        } else if (product.Family == 'Kitchen & Dining') {
            basePrice = Math.random() * 300 + 100; // $100-$400
        }
        
        pricebookEntries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = product.Id,
            UnitPrice = basePrice,
            IsActive = true
        ));
    }
    
    // Insert price book entries
    insert pricebookEntries;
    System.debug('✅ Created ' + pricebookEntries.size() + ' price book entries');
    
    // Verify the setup
    Integer productCount = [SELECT COUNT() FROM Product2 WHERE IsActive = true];
    Integer pbeCount = [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :standardPricebookId AND IsActive = true];
    
    System.debug('🎉 Sample products setup completed!');
    System.debug('  Total Products: ' + productCount);
    System.debug('  Total Pricebook Entries: ' + pbeCount);
    
    // Show top sellers
    List<Product2> topSellers = [SELECT Id, Name, Family, is_top_seller__c FROM Product2 WHERE is_top_seller__c = true];
    System.debug('🏆 Top Sellers: ' + topSellers.size());
    for (Product2 topSeller : topSellers) {
        System.debug('  ' + topSeller.Name + ' (' + topSeller.Family + ')');
    }
    
    // Show category breakdown
    System.debug('📊 Product Categories:');
    List<AggregateResult> categoryCounts = [SELECT Family, COUNT(Id) total FROM Product2 WHERE IsActive = true GROUP BY Family ORDER BY Family];
    for (AggregateResult ar : categoryCounts) {
        System.debug('  ' + ar.get('Family') + ': ' + ar.get('total') + ' products');
    }
    
} catch (Exception e) {
    System.debug('❌ Error creating sample products: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
