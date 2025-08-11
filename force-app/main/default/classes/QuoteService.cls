/**
 * @description Service class for handling quote creation and management.
 * 
 * This class provides functionality to convert shopping carts to formal quotes,
 * enabling B2B customers to request quotes for large orders.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public with sharing class QuoteService {

    /**
     * @description Converts a user's active cart into a formal Quote and deletes the cart.
     * This method creates a Quote record with QuoteLineItems based on the cart contents,
     * then cleans up the cart to prevent duplicate processing.
     * 
     * @param cartId The ID of the Cart__c to convert
     * @return The ID of the newly created Quote
     * @throws AuraHandledException if quote creation fails
     */
    @AuraEnabled
    public static Id createQuoteFromCart(Id cartId) {
        try {
            // 1. Security Checks - Ensure user can create Quote and QuoteLineItem records
            SecurityUtils.checkObjectCreateable('Quote');
            SecurityUtils.checkObjectCreateable('QuoteLineItem');
            SecurityUtils.checkObjectReadable('Cart__c');
            SecurityUtils.checkObjectReadable('Cart_Item__c');
            SecurityUtils.checkObjectDeletable('Cart__c');

            // 2. Validate input parameter
            if (cartId == null) {
                throw new IllegalArgumentException('Cart ID cannot be null.');
            }

            // 3. Query cart data with security validation
            Cart__c cart = getCartWithSecurity(cartId);
            List<Cart_Item__c> cartItems = getCartItemsWithSecurity(cartId);

            // 4. Validate cart has items
            if (cartItems.isEmpty()) {
                throw new IllegalArgumentException('Cannot create quote from empty cart.');
            }

            // 5. Create the parent Quote record
            Quote newQuote = createQuoteRecord(cart);

            // 6. Create Quote Line Items from Cart Items
            List<QuoteLineItem> quoteItems = createQuoteLineItems(newQuote.Id, cartItems);

            // 7. Clean up the cart (delete cart and items)
            deleteCartAndItems(cartId);

            return newQuote.Id;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Quote creation error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Failed to create quote: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves quotes for the current user's account.
     * This method is cacheable for performance optimization in the UI.
     * 
     * @return List of Quote records for the current user's account
     * @throws AuraHandledException if quote retrieval fails
     */
    @AuraEnabled(cacheable=true)
    public static List<Quote> getQuotes() {
        try {
            // 1. Security Checks - Ensure user can read Quote records
            SecurityUtils.checkObjectReadable('Quote');
            SecurityUtils.checkFieldReadAccess('Quote', new List<String>{
                'Id', 'Name', 'Status', 'GrandTotal', 'CreatedDate', 'ExpirationDate'
            });

            // 2. Get current user's account ID
            Id userAccountId = getCurrentUserAccountId();
            if (userAccountId == null) {
                throw new AuraHandledException('User is not associated with an Account.');
            }

            // 3. Query quotes for the user's account
            List<Quote> quotes = [
                SELECT Id, Name, Status, GrandTotal, CreatedDate, ExpirationDate
                FROM Quote 
                WHERE AccountId = :userAccountId 
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];

            return quotes;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Quote retrieval error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Failed to retrieve quotes: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves cart information with security validation.
     * Ensures the user can only access their own cart.
     * 
     * @param cartId The ID of the cart to retrieve
     * @return Cart__c record with contact and account information
     * @throws IllegalArgumentException if cart not found or access denied
     */
    private static Cart__c getCartWithSecurity(Id cartId) {
        // Get current user's contact ID
        Id userContactId = getCurrentUserContactId();
        if (userContactId == null) {
            throw new IllegalArgumentException('User is not associated with a Contact.');
        }

        // Query for cart with ownership validation
        List<Cart__c> carts = [
            SELECT Id, Contact__c, Contact__r.AccountId, Status__c
            FROM Cart__c
            WHERE Id = :cartId
            AND Contact__c = :userContactId
            AND Status__c = 'Active'
            LIMIT 1
        ];

        if (carts.isEmpty()) {
            throw new IllegalArgumentException('Cart not found or access denied.');
        }

        return carts[0];
    }

    /**
     * @description Retrieves cart items with security validation.
     * Ensures the user can only access items from their own cart.
     * 
     * @param cartId The ID of the cart to retrieve items from
     * @return List of Cart_Item__c records
     * @throws IllegalArgumentException if cart items not found or access denied
     */
    private static List<Cart_Item__c> getCartItemsWithSecurity(Id cartId) {
        // Query for cart items
        List<Cart_Item__c> cartItems = [
            SELECT Id, Product__c, Quantity__c, Unit_Price__c, Line_Total__c
            FROM Cart_Item__c
            WHERE Cart__c = :cartId
            ORDER BY CreatedDate
        ];

        if (cartItems.isEmpty()) {
            throw new IllegalArgumentException('No items found in cart.');
        }

        return cartItems;
    }

    /**
     * @description Creates a new Quote record based on cart information.
     * 
     * @param cart The cart record containing contact and account information
     * @return New Quote record ready for insertion
     */
    private static Quote createQuoteRecord(Cart__c cart) {
        Quote newQuote = new Quote(
            Name = 'Web Quote - ' + System.today().format(),
            AccountId = cart.Contact__r.AccountId,
            ContactId = cart.Contact__c,
            Pricebook2Id = getStandardPricebookId(),
            Status = 'Draft',
            ExpirationDate = System.today().addDays(30), // Quote expires in 30 days
            Description = 'Quote created from online shopping cart on ' + System.today().format()
        );

        insert newQuote;
        return newQuote;
    }

    /**
     * @description Creates QuoteLineItem records from cart items.
     * 
     * @param quoteId The ID of the parent Quote record
     * @param cartItems List of cart items to convert
     * @return List of QuoteLineItem records ready for insertion
     */
    private static List<QuoteLineItem> createQuoteLineItems(Id quoteId, List<Cart_Item__c> cartItems) {
        List<QuoteLineItem> quoteItems = new List<QuoteLineItem>();
        
        // Get PricebookEntry IDs for all products in one query
        Set<Id> productIds = new Set<Id>();
        for (Cart_Item__c item : cartItems) {
            productIds.add(item.Product__c);
        }

        Map<Id, Id> productToPricebookEntry = new Map<Id, Id>();
        for (PricebookEntry pbe : [
            SELECT Id, Product2Id 
            FROM PricebookEntry 
            WHERE Product2Id IN :productIds 
            AND Pricebook2.IsStandard = true
        ]) {
            productToPricebookEntry.put(pbe.Product2Id, pbe.Id);
        }

        // Create QuoteLineItem records
        for (Cart_Item__c item : cartItems) {
            Id pricebookEntryId = productToPricebookEntry.get(item.Product__c);
            if (pricebookEntryId != null) {
                quoteItems.add(new QuoteLineItem(
                    QuoteId = quoteId,
                    Product2Id = item.Product__c,
                    Quantity = item.Quantity__c,
                    UnitPrice = item.Unit_Price__c,
                    PricebookEntryId = pricebookEntryId,
                    Description = 'Line item converted from shopping cart'
                ));
            }
        }

        if (!quoteItems.isEmpty()) {
            insert quoteItems;
        }

        return quoteItems;
    }

    /**
     * @description Deletes the cart and all associated cart items.
     * This cleanup prevents duplicate quote creation and maintains data integrity.
     * 
     * @param cartId The ID of the cart to delete
     */
    private static void deleteCartAndItems(Id cartId) {
        // Delete cart items first (due to master-detail relationship)
        List<Cart_Item__c> itemsToDelete = [
            SELECT Id 
            FROM Cart_Item__c 
            WHERE Cart__c = :cartId
        ];
        
        if (!itemsToDelete.isEmpty()) {
            delete itemsToDelete;
        }

        // Delete the cart
        Cart__c cartToDelete = [SELECT Id FROM Cart__c WHERE Id = :cartId LIMIT 1];
        delete cartToDelete;
    }

    /**
     * @description Gets the standard pricebook ID for quote creation.
     * 
     * @return ID of the standard pricebook
     */
    private static Id getStandardPricebookId() {
        // In production orgs, use the actual standard pricebook ID
        // For development/testing, use Test.getStandardPricebookId()
        if (Test.isRunningTest()) {
            return Test.getStandardPricebookId();
        } else {
            // Query for the standard pricebook
            List<Pricebook2> standardPricebooks = [
                SELECT Id 
                FROM Pricebook2 
                WHERE IsStandard = true 
                LIMIT 1
            ];
            return standardPricebooks.isEmpty() ? null : standardPricebooks[0].Id;
        }
    }

    /**
     * @description Gets the current user's account ID.
     * 
     * @return ID of the current user's account, or null if not found
     */
    private static Id getCurrentUserAccountId() {
        try {
            User currentUser = [
                SELECT AccountId 
                FROM User 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1
            ];
            return currentUser.AccountId;
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Could not retrieve user account ID: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @description Gets the current user's contact ID.
     * 
     * @return ID of the current user's contact, or null if not found
     */
    private static Id getCurrentUserContactId() {
        try {
            User currentUser = [
                SELECT ContactId 
                FROM User 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1
            ];
            return currentUser.ContactId;
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Could not retrieve user contact ID: ' + e.getMessage());
            return null;
        }
    }
}
