/**
 * @description Service class for retrieving and creating Quotes.
 *
 * Provides methods to fetch quotes for the current user and to convert
 * the active cart into a quote. Security is enforced using
 * StoreConnectSecurityUtil.
 */
public with sharing class QuoteService {
  /**
   * @description Retrieves quotes for the current user's account.
   *
   * @return List of Quote records
   */
  @AuraEnabled(cacheable=true)
  public static List<Quote> getQuotes() {
    try {
      // Security checks
      if (!StoreConnectSecurityUtil.hasReadPermission('Quote')) {
        throw new StoreConnectSecurityUtil.SecurityException(
          'User lacks read access to Quote.'
        );
      }
      for (
        String fieldName : new List<String>{
          'Name',
          'Status',
          'GrandTotal',
          'TotalPrice',
          'CreatedDate',
          'AccountId'
        }
      ) {
        if (
          !StoreConnectSecurityUtil.hasFieldReadPermission('Quote', fieldName)
        ) {
          throw new StoreConnectSecurityUtil.SecurityException(
            'No access to field Quote.' + fieldName
          );
        }
      }

      Id accountId = getCurrentUserAccountId();
      if (accountId == null) {
        return new List<Quote>();
      }

      return [
        SELECT Id, Name, Status, GrandTotal, TotalPrice, CreatedDate
        FROM Quote
        WHERE AccountId = :accountId
        ORDER BY CreatedDate DESC
        LIMIT 100
      ];
    } catch (StoreConnectSecurityUtil.SecurityException e) {
      throw new AuraHandledException('Security violation: ' + e.getMessage());
    } catch (Exception e) {
      throw new AuraHandledException(
        'Unable to retrieve quotes at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Retrieves quotes for a specific account (alternative method for flexibility).
   *
   * @param accountId The Account ID to retrieve quotes for
   * @return List of Quote records
   */
  @AuraEnabled(cacheable=true)
  public static List<Quote> getQuotesForAccount(Id accountId) {
    try {
      if (!StoreConnectSecurityUtil.hasReadPermission('Quote')) {
        throw new StoreConnectSecurityUtil.SecurityException(
          'User lacks permission to read quotes'
        );
      }
      if (accountId == null) {
        throw new IllegalArgumentException('Account ID cannot be null');
      }

      return [
        SELECT Id, Name, Status, GrandTotal, TotalPrice, CreatedDate
        FROM Quote
        WHERE AccountId = :accountId
        ORDER BY CreatedDate DESC
        LIMIT 100
      ];
    } catch (StoreConnectSecurityUtil.SecurityException e) {
      throw new AuraHandledException('Security violation: ' + e.getMessage());
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error retrieving quotes: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Converts the current user's active cart into a Quote.
   *
   * @return The newly created Quote record
   */
  @AuraEnabled
  public static Quote createQuoteFromCart() {
    try {
      // Security checks
      if (!StoreConnectSecurityUtil.hasCreatePermission('Quote')) {
        throw new StoreConnectSecurityUtil.SecurityException(
          'User lacks create access to Quote.'
        );
      }
      for (
        String fieldName : new List<String>{
          'Name',
          'AccountId',
          'Status',
          'Pricebook2Id'
        }
      ) {
        if (
          !StoreConnectSecurityUtil.hasFieldEditPermission('Quote', fieldName)
        ) {
          throw new StoreConnectSecurityUtil.SecurityException(
            'No edit access to field Quote.' + fieldName
          );
        }
      }
      if (!StoreConnectSecurityUtil.hasReadPermission('Cart__c')) {
        throw new StoreConnectSecurityUtil.SecurityException(
          'User lacks read access to Cart.'
        );
      }

      Id contactId = getCurrentUserContactId();
      if (contactId == null) {
        throw new AuraHandledException(
          'User is not associated with a contact.'
        );
      }

      Cart__c cart = [
        SELECT Id, Contact__r.AccountId
        FROM Cart__c
        WHERE Contact__c = :contactId AND Status__c = 'Active'
        LIMIT 1
      ];

      Quote q = new Quote(
        Name = 'Quote for Cart ' + cart.Id,
        AccountId = cart.Contact__r.AccountId,
        Pricebook2Id = getStandardPricebookId(),
        Status = 'Draft'
      );

      StoreConnectSecurityUtil.validateRecordAccess(
        new List<Quote>{ q },
        'CREATE'
      );
      insert q;
      return q;
    } catch (StoreConnectSecurityUtil.SecurityException e) {
      throw new AuraHandledException('Security violation: ' + e.getMessage());
    } catch (Exception e) {
      throw new AuraHandledException(
        'Unable to create quote at this time. Please try again later.'
      );
    }
  }

  /**
   * @description Creates a new Quote for a specific account (alternative method).
   *
   * @param accountId The Account ID to create the quote for
   * @return The newly created Quote record
   */
  @AuraEnabled
  public static Quote createQuote(Id accountId) {
    try {
      if (!StoreConnectSecurityUtil.hasCreatePermission('Quote')) {
        throw new StoreConnectSecurityUtil.SecurityException(
          'User lacks permission to create quotes'
        );
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

      StoreConnectSecurityUtil.validateRecordAccess(
        new List<Quote>{ newQuote },
        'CREATE'
      );
      insert newQuote;
      return newQuote;
    } catch (StoreConnectSecurityUtil.SecurityException e) {
      throw new AuraHandledException('Security violation: ' + e.getMessage());
    } catch (Exception e) {
      throw new AuraHandledException('Error creating quote: ' + e.getMessage());
    }
  }

  /**
   * @description Helper to get the current user's Account Id.
   *
   * @return Id of Account or null
   */
  private static Id getCurrentUserAccountId() {
    if (!StoreConnectSecurityUtil.hasReadPermission('User')) {
      throw new StoreConnectSecurityUtil.SecurityException(
        'User lacks read access to User.'
      );
    }
    for (String fieldName : new List<String>{ 'ContactId' }) {
      if (!StoreConnectSecurityUtil.hasFieldReadPermission('User', fieldName)) {
        throw new StoreConnectSecurityUtil.SecurityException(
          'No access to field User.' + fieldName
        );
      }
    }
    if (!StoreConnectSecurityUtil.hasReadPermission('Contact')) {
      throw new StoreConnectSecurityUtil.SecurityException(
        'User lacks read access to Contact.'
      );
    }
    if (
      !StoreConnectSecurityUtil.hasFieldReadPermission('Contact', 'AccountId')
    ) {
      throw new StoreConnectSecurityUtil.SecurityException(
        'No access to field Contact.AccountId'
      );
    }

    List<User> users = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    return users.isEmpty()
      ? null
      : users[0].Contact == null ? null : users[0].Contact.AccountId;
  }

  /**
   * @description Helper to get the current user's Contact Id.
   *
   * @return Id of Contact or null
   */
  private static Id getCurrentUserContactId() {
    if (!StoreConnectSecurityUtil.hasReadPermission('User')) {
      throw new StoreConnectSecurityUtil.SecurityException(
        'User lacks read access to User.'
      );
    }
    if (!StoreConnectSecurityUtil.hasFieldReadPermission('User', 'ContactId')) {
      throw new StoreConnectSecurityUtil.SecurityException(
        'No access to field User.ContactId'
      );
    }

    List<User> users = [
      SELECT ContactId
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    return users.isEmpty() ? null : users[0].ContactId;
  }

  /**
   * @description Retrieves the standard pricebook Id.
   *
   * @return Id of standard Pricebook2
   */
  private static Id getStandardPricebookId() {
    return Test.isRunningTest()
      ? Test.getStandardPricebookId()
      : [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
  }
}
