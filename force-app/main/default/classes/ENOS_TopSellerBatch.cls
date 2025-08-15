/**
 * @description Batch job to calculate and flag the top selling products.
 *
 * This batch job analyzes OrderItem records from the last 90 days to identify
 * the most frequently ordered products and automatically flags them as top sellers.
 * The job should be scheduled to run weekly or nightly for optimal performance.
 *
 * @author ENOS Development Team
 * @version 1.0.0
 * @since 2024-12-01
 */
public class ENOS_TopSellerBatch implements Database.Batchable<AggregateResult>, Database.Stateful {
  // Track if we've already cleared the flags in this batch run
  private Boolean hasClearedFlags = false;

  /**
   * @description Gathers the records for the job to process.
   * Finds the top 200 most ordered products from the last 90 days.
   *
   * @param bc The batchable context
   * @return Iterable of AggregateResult containing product order counts
   */
  public Iterable<AggregateResult> start(Database.BatchableContext bc) {
    try {
      // Query for the most frequently ordered products in the last 90 days
      // This gives us a good balance between recent trends and statistical significance
      // Get configurable batch size limit
      Integer batchLimit = ENOS_ConfigurationUtils.getBatchSizeLimit();
      if (batchLimit == null || batchLimit <= 0) {
        batchLimit = 1000; // Default fallback
      }
      
      return [
        SELECT COUNT(Id) totalOrders, Product2Id, Product2.Name
        FROM OrderItem
        WHERE CreatedDate = LAST_90_DAYS AND Product2Id != NULL
        GROUP BY Product2Id, Product2.Name
        ORDER BY COUNT(Id) DESC
        LIMIT :batchLimit
      ];
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error in ENOS_TopSellerBatch.start(): ' + e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
      throw new AuraHandledException(
        'Failed to start top seller calculation: ' + e.getMessage()
      );
    }
  }

  /**
   * @description Processes the data in chunks.
   * Clears existing top seller flags and sets new ones based on order frequency.
   *
   * @param bc The batchable context
   * @param scope The current batch of records to process
   */
  public void execute(
    Database.BatchableContext bc,
    List<AggregateResult> scope
  ) {
    try {
      // First, clear all existing "Top Seller" flags.
      // This is done once by the first batch execution.
      if (!hasClearedFlags) {
        clearExistingTopSellerFlags();
        hasClearedFlags = true;
      }

      // Now, collect the Product IDs from the current batch scope.
      Set<Id> topProductIds = new Set<Id>();
      for (AggregateResult ar : scope) {
        Id productId = (Id) ar.get('Product2Id');
        if (productId != null) {
          topProductIds.add(productId);
        }
      }

      // Flag the new top sellers.
      if (!topProductIds.isEmpty()) {
        flagTopSellers(topProductIds);
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error in ENOS_TopSellerBatch.execute(): ' + e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );

      // Log the error but don't fail the entire batch
      // This ensures other products can still be processed
      System.debug(
        LoggingLevel.ERROR,
        'Continuing batch processing despite error in current scope'
      );
    }
  }

  /**
   * @description Runs once at the end of the batch job.
   * Logs completion and optionally sends notifications.
   *
   * @param bc The batchable context
   */
  public void finish(Database.BatchableContext bc) {
    try {
      // Log successful completion
      System.debug(
        LoggingLevel.INFO,
        'Top Seller Batch job finished successfully.'
      );

      // Get job statistics for monitoring
      AsyncApexJob job = [
        SELECT
          Id,
          Status,
          NumberOfErrors,
          JobItemsProcessed,
          TotalJobItems,
          CreatedBy.Email
        FROM AsyncApexJob
        WHERE Id = :bc.getJobId()
      ];

      // Log detailed completion information
      System.debug(LoggingLevel.INFO, 'Job Status: ' + job.Status);
      System.debug(
        LoggingLevel.INFO,
        'Items Processed: ' + job.JobItemsProcessed
      );
      System.debug(LoggingLevel.INFO, 'Total Items: ' + job.TotalJobItems);
      System.debug(LoggingLevel.INFO, 'Errors: ' + job.NumberOfErrors);

      // Optionally send an email to an admin that the job is complete
      if (job.NumberOfErrors > 0) {
        sendCompletionNotification(job, true); // Error notification
      } else {
        sendCompletionNotification(job, false); // Success notification
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error in ENOS_TopSellerBatch.finish(): ' + e.getMessage()
      );
      System.debug(
        LoggingLevel.ERROR,
        'Stack trace: ' + e.getStackTraceString()
      );
    }
  }

  /**
   * @description Clears all existing top seller flags from products.
   * This ensures a clean slate for the new top seller calculation.
   */
  private void clearExistingTopSellerFlags() {
    try {
      // Query for all products currently flagged as top sellers
      List<Product2> productsToClear = [
        SELECT Id, Name, Is_Top_Seller__c
        FROM Product2
        WHERE Is_Top_Seller__c = TRUE
        LIMIT 1000
      ];

      if (!productsToClear.isEmpty()) {
        // Clear the top seller flag
        for (Product2 product : productsToClear) {
          product.Is_Top_Seller__c = false;
        }

        // Update the products
        update productsToClear;

        System.debug(
          LoggingLevel.INFO,
          'Cleared top seller flags from ' +
            productsToClear.size() +
            ' products'
        );
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error clearing top seller flags: ' + e.getMessage()
      );
      throw e; // Re-throw to fail the batch if we can't clear flags
    }
  }

  /**
   * @description Flags the specified products as top sellers.
   *
   * @param topProductIds Set of Product IDs to flag as top sellers
   */
  private void flagTopSellers(Set<Id> topProductIds) {
    try {
      // Query for the products to update
      List<Product2> productsToUpdate = [
        SELECT Id, Name, Is_Top_Seller__c
        FROM Product2
        WHERE Id IN :topProductIds
      ];

      if (!productsToUpdate.isEmpty()) {
        // Set the top seller flag
        for (Product2 product : productsToUpdate) {
          product.Is_Top_Seller__c = true;
        }

        // Update the products
        update productsToUpdate;

        System.debug(
          LoggingLevel.INFO,
          'Flagged ' + productsToUpdate.size() + ' products as top sellers'
        );
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error flagging top sellers: ' + e.getMessage()
      );
      throw e; // Re-throw to fail the batch if we can't flag products
    }
  }

  /**
   * @description Sends completion notification to administrators.
   *
   * @param job The completed batch job information
   * @param hasErrors Whether the job completed with errors
   */
  private void sendCompletionNotification(AsyncApexJob job, Boolean hasErrors) {
    try {
      // Get admin users to notify
      List<User> adminUsers = [
        SELECT Id, Email, Name
        FROM User
        WHERE Profile.Name LIKE '%Admin%' AND IsActive = TRUE
        LIMIT 10
      ];

      if (adminUsers.isEmpty()) {
        System.debug(
          LoggingLevel.WARN,
          'No admin users found for notification'
        );
        return;
      }

      // Prepare email content
      String subject = hasErrors
        ? 'Top Seller Batch Job Completed with Errors'
        : 'Top Seller Batch Job Completed Successfully';

      String body = 'Top Seller Batch Job has completed.\n\n';
      body += 'Job ID: ' + job.Id + '\n';
      body += 'Status: ' + job.Status + '\n';
      body += 'Items Processed: ' + job.JobItemsProcessed + '\n';
      body += 'Total Items: ' + job.TotalJobItems + '\n';
      body += 'Errors: ' + job.NumberOfErrors + '\n';
      body += 'Completed By: ' + job.CreatedBy.Email + '\n';
      body += 'Completion Time: ' + System.now() + '\n\n';

      if (hasErrors) {
        body += 'Please review the job logs for error details.\n';
      } else {
        body += 'All products have been successfully updated with top seller flags.\n';
      }

      // Send emails to admin users
      List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

      for (User adminUser : adminUsers) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ adminUser.Email });
        email.setSubject(subject);
        email.setPlainTextBody(body);
        emails.add(email);
      }

      if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
        System.debug(
          LoggingLevel.INFO,
          'Sent completion notifications to ' + emails.size() + ' admin users'
        );
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Error sending completion notification: ' + e.getMessage()
      );
      // Don't fail the batch for notification errors
    }
  }
}
