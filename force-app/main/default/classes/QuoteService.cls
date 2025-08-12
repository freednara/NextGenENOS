public with sharing class QuoteService {
    @AuraEnabled(cacheable=true)
    public static List<Quote> getQuotes(Id accountId) {
        try {
            if (!StoreConnectSecurityUtil.hasReadPermission('Quote')) {
                throw new StoreConnectSecurityUtil.SecurityException('User lacks permission to read quotes');
            }
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            return [
                SELECT Id, Name, Status, TotalPrice, CreatedDate
                FROM Quote
                WHERE AccountId = :accountId
                ORDER BY CreatedDate DESC
            ];
        } catch (StoreConnectSecurityUtil.SecurityException e) {
            throw new AuraHandledException('Security violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving quotes: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Quote createQuote(Id accountId) {
        try {
            if (!StoreConnectSecurityUtil.hasCreatePermission('Quote')) {
                throw new StoreConnectSecurityUtil.SecurityException('User lacks permission to create quotes');
            }
            if (accountId == null) {
                throw new IllegalArgumentException('Account ID cannot be null');
            }
            Quote newQuote = new Quote(
                Name = 'New Quote',
                AccountId = accountId,
                Status = 'Draft',
                ExpirationDate = System.today().addDays(30)
            );

            StoreConnectSecurityUtil.validateRecordAccess(new List<Quote>{newQuote}, 'CREATE');

            insert newQuote;
            return newQuote;
        } catch (StoreConnectSecurityUtil.SecurityException e) {
            throw new AuraHandledException('Security violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error creating quote: ' + e.getMessage());
        }
    }
}
