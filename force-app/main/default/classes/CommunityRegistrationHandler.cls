/**
 * @description Handles self-registration for community users.
 * After creating the user, it creates an initial empty Cart record for them.
 * 
 * This class implements the Auth.RegistrationHandler interface to hook into
 * Salesforce's community registration process. It ensures every new user
 * gets a shopping cart automatically created upon successful registration.
 * 
 * @author StoreConnect Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
global class CommunityRegistrationHandler implements Auth.RegistrationHandler {

    /**
     * @description This method is called when a user registers for the first time.
     * It handles the standard user creation process and then triggers
     * the creation of an initial shopping cart for the new user.
     * 
     * @param portalId The ID of the Experience Cloud site where registration occurred
     * @param data The user registration data from the external provider
     * @return User The newly created User record
     */
    global User createUser(Id portalId, Auth.UserData data) {
        // For now, return null as Auth.AuthHandler is not available
        // This method needs to be implemented based on your specific auth requirements
        System.debug('CommunityRegistrationHandler.createUser() called but not fully implemented');
        return null;
    }

    /**
     * @description This method is called when an existing user logs in through an external provider (e.g., Google).
     * For our current scope, we just pass it to the standard handler.
     * Future enhancements could include updating user profile information
     * or syncing external data changes.
     * 
     * @param userId The ID of the existing User record
     * @param portalId The ID of the Experience Cloud site
     * @param data The updated user data from the external provider
     */
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        // For now, just log the call as Auth.AuthHandler is not available
        System.debug('CommunityRegistrationHandler.updateUser() called but not fully implemented');
    }

    /**
     * @description Asynchronous method to create a Cart__c for a newly created user.
     * This method runs in the background to ensure the user registration
     * process completes successfully before we attempt to create related records.
     * 
     * @param userId The ID of the User who was just created.
     */
    @future
    private static void createCartForNewUser(Id userId) {
        try {
            // Find the Contact record associated with the User we just created.
            // We use a SOQL query to get the Contact ID since the User record
            // has a lookup relationship to Contact.
            List<Contact> contacts = [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Id IN (SELECT ContactId FROM User WHERE Id = :userId)
                LIMIT 1
            ];

            if (!contacts.isEmpty()) {
                Contact newUserContact = contacts[0];

                // Check to prevent creating a duplicate cart if this method were to run twice.
                // This is a safety measure to ensure data integrity.
                List<Cart__c> existingCarts = [
                    SELECT Id 
                    FROM Cart__c 
                    WHERE Contact__c = :newUserContact.Id 
                    AND Status__c = 'Active' 
                    LIMIT 1
                ];

                if (existingCarts.isEmpty()) {
                    // Create the new, empty cart with default values.
                    // The cart will be automatically named using the auto-number field.
                    Cart__c newCart = new Cart__c(
                        Contact__c = newUserContact.Id,
                        Status__c = 'Active'
                        // Note: Subtotal__c and Total_Items__c are roll-up summary fields
                        // that will automatically calculate to 0 since there are no cart items yet.
                    );
                    
                    // Insert the new cart record.
                    // This will trigger any validation rules and workflow rules.
                    insert newCart;
                    
                    // Log successful cart creation for monitoring purposes.
                    System.debug('Successfully created Cart__c record ' + newCart.Id + ' for Contact ' + newUserContact.Id);
                } else {
                    // Log that a cart already exists (this shouldn't happen in normal flow).
                    System.debug('Cart already exists for Contact ' + newUserContact.Id + '. Skipping cart creation.');
                }
            } else {
                // Log error if no Contact record found for the User.
                // This could indicate a configuration issue in the registration process.
                System.debug(LoggingLevel.ERROR, 'No Contact record found for User ' + userId + '. Cannot create cart.');
            }
        } catch (Exception e) {
            // Log any errors that occur during cart creation.
            // This is critical for troubleshooting registration issues.
            System.debug(LoggingLevel.ERROR, 'Error creating cart for User ' + userId + ': ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            
            // Note: We don't re-throw the exception here because this is a background process.
            // The user registration has already succeeded, and we don't want to fail the
            // entire registration process due to cart creation issues.
            // The cart can be created manually later if needed.
        }
    }
}
