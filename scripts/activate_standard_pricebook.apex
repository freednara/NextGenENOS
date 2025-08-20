// Activate Standard Price Book for cart functionality
// This script ensures the Standard Price Book is active so PricebookEntry records can be used

try {
    // Query for the Standard Price Book
    List<Pricebook2> standardPricebooks = [
        SELECT Id, Name, IsActive, IsStandard 
        FROM Pricebook2 
        WHERE IsStandard = true 
        LIMIT 1
    ];
    
    if (!standardPricebooks.isEmpty()) {
        Pricebook2 standardPb = standardPricebooks[0];
        
        if (!standardPb.IsActive) {
            // Activate the Standard Price Book
            standardPb.IsActive = true;
            update standardPb;
            System.debug('✅ Standard Price Book activated successfully: ' + standardPb.Name);
        } else {
            System.debug('ℹ️ Standard Price Book is already active: ' + standardPb.Name);
        }
    } else {
        System.debug('⚠️ No Standard Price Book found');
    }
    
    // Verify PricebookEntry records exist
    Integer pbeCount = [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2.IsStandard = true];
    System.debug('📊 PricebookEntry records in Standard Price Book: ' + pbeCount);
    
} catch (Exception e) {
    System.debug('❌ Error activating Standard Price Book: ' + e.getMessage());
}
