public with sharing class ENOS_InvoiceController {
    
    public class InvoiceResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String invoiceNumber;
        @AuraEnabled public Id invoiceId;
        @AuraEnabled public Id contentVersionId;
    }

    @AuraEnabled
    public static InvoiceResult generateInvoice(Id cartId, String templateName) {
        // cartId is optional - if not provided, will find current user's active cart

        try {
            ENOS_InvoiceService.GenerateResponse response = 
                ENOS_InvoiceService.generate(cartId, templateName);

            InvoiceResult result = new InvoiceResult();
            result.success = response.success;
            result.message = response.message;
            result.invoiceNumber = response.invoiceNumber;
            result.invoiceId = response.invoiceId;
            result.contentVersionId = response.contentVersionId;
            return result;
            
        } catch (ENOS_InvoiceService.InvoiceException ex) {
            ENOS_ExceptionUtils.throwOperationFailure('generate invoice', ex);
            return null;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'generateInvoice unexpected: ' + e.getMessage());
            ENOS_ExceptionUtils.throwUnexpectedError('generating the invoice');
            return null;
        }
    }
}
