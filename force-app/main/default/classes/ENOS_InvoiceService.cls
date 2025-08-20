public with sharing class ENOS_InvoiceService {
    
    public class InvoiceException extends Exception {}
    
    public class GenerateResponse {
        public Boolean success;
        public String message;
        public String invoiceNumber;
        public Id invoiceId;
        public Id contentVersionId;
    }

    public static GenerateResponse generate(Id cartId, String templateNameOpt) {
        GenerateResponse response = new GenerateResponse();
        
        try {
            // --- 0) Validate + security ---
            if (!Schema.sObjectType.Cart__c.isAccessible()) {
                throw new InvoiceException('Insufficient access to Cart.');
            }

            // --- 1) Load cart + items ---
            Cart__c cart;
            
            if (cartId != null) {
                // Use provided cart ID
                cart = [
                    SELECT Id, Contact__c, Status__c, Subtotal__c, Total_Items__c
                    FROM Cart__c 
                    WHERE Id = :cartId 
                    LIMIT 1
                ];
            } else {
                // Get current user's active cart
                Id userId = UserInfo.getUserId();
                List<Cart__c> userCarts = [
                    SELECT Id, Contact__c, Status__c, Subtotal__c, Total_Items__c
                    FROM Cart__c 
                    WHERE Contact__c IN (
                        SELECT ContactId 
                        FROM User 
                        WHERE Id = :userId
                    )
                    AND Status__c = 'Open'
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                
                if (userCarts.isEmpty()) {
                    throw new InvoiceException('No active cart found for current user.');
                }
                
                cart = userCarts[0];
            }
            
            if (cart.Status__c != 'Active') {
                throw new InvoiceException('Only active carts can be invoiced.');
            }

            List<Cart_Item__c> items = [
                SELECT Id, Quantity__c, Unit_Price__c, Line_Total__c,
                       Product__c, Product__r.Name, Product__r.ProductCode
                FROM Cart_Item__c
                WHERE Cart__c = :cart.Id
            ];
            
            if (items.isEmpty()) {
                throw new InvoiceException('Cart has no items.');
            }

            // --- 2) Generate HTML invoice content ---
            String invoiceHtml = generateInvoiceHtml(cart, items);
            
            // --- 3) Create ContentVersion (File) ---
            System.debug('📄 Creating ContentVersion with HTML length: ' + invoiceHtml.length());
            
            ContentVersion cv = new ContentVersion(
                Title = 'ENOS-Invoice-' + Datetime.now().format('yyyy-MM-dd-HHmmss'),
                PathOnClient = 'ENOS-Invoice-' + Datetime.now().format('yyyy-MM-dd') + '.html',
                VersionData = Blob.valueOf(invoiceHtml),
                ContentLocation = 'S',
                IsMajorVersion = true
            );
            
            System.debug('📄 ContentVersion object created: ' + cv);
            
            // Insert directly without FLS strip for ContentVersion (it's a standard object)
            try {
                insert cv;
                System.debug('📄 ContentVersion inserted successfully with ID: ' + cv.Id);
            } catch (Exception insertEx) {
                System.debug('❌ ContentVersion insert failed: ' + insertEx.getMessage());
                throw new InvoiceException('Failed to insert invoice file: ' + insertEx.getMessage());
            }
            
            // Get the ContentDocument ID
            List<ContentVersion> insertedVersions = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :cv.Id
            ];
            
            System.debug('📄 Retrieved ContentVersion records: ' + insertedVersions.size());
            
            if (insertedVersions.isEmpty()) {
                throw new InvoiceException('Failed to create invoice file - no ContentVersion found after insert.');
            }
            
            // Clean up old invoice files for this user
            cleanupOldInvoiceFiles(cart.Contact__c);
            
            // --- 4) Return success response ---
            response.success = true;
            response.message = 'Invoice generated successfully';
            response.invoiceNumber = 'INV-' + String.valueOf(Datetime.now().getTime());
            response.invoiceId = cart.Id;
            response.contentVersionId = insertedVersions[0].ContentDocumentId;
            
        } catch (Exception e) {
            response.success = false;
            response.message = e.getMessage();
            System.debug(LoggingLevel.ERROR, 'ENOS_InvoiceService.generate error: ' + e.getMessage());
        }
        
        return response;
    }
    
    private static String generateInvoiceHtml(Cart__c cart, List<Cart_Item__c> items) {
        String html = '<!DOCTYPE html>';
        html += '<html><head>';
        html += '<meta charset="utf-8">';
        html += '<title>ENOS Invoice</title>';
        html += '<style>';
        html += 'body { font-family: Arial, sans-serif; margin: 40px; color: #333; }';
        html += '.header { text-align: center; border-bottom: 2px solid #0070d2; padding-bottom: 20px; margin-bottom: 30px; }';
        html += '.company-name { font-size: 28px; font-weight: bold; color: #0070d2; }';
        html += '.invoice-details { margin-bottom: 30px; }';
        html += '.invoice-row { display: flex; justify-content: space-between; margin-bottom: 10px; }';
        html += '.items-table { width: 100%; border-collapse: collapse; margin: 30px 0; }';
        html += '.items-table th, .items-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }';
        html += '.items-table th { background-color: #f8f9fa; font-weight: bold; }';
        html += '.total-row { font-weight: bold; font-size: 18px; }';
        html += '.footer { margin-top: 50px; text-align: center; color: #666; font-size: 14px; }';
        html += '</style></head><body>';
        
        // Header
        html += '<div class="header">';
        html += '<div class="company-name">ENOS Platform</div>';
        html += '<div>Professional E-Commerce Solutions</div>';
        html += '</div>';
        
        // Invoice Details
        html += '<div class="invoice-details">';
        html += '<div class="invoice-row"><strong>Invoice Number:</strong> INV-' + String.valueOf(Datetime.now().getTime()) + '</div>';
        html += '<div class="invoice-row"><strong>Date:</strong> ' + Datetime.now().format('MMMM dd, yyyy') + '</div>';
        html += '<div class="invoice-row"><strong>Cart ID:</strong> ' + cart.Id + '</div>';
        html += '</div>';
        
        // Items Table
        html += '<table class="items-table">';
        html += '<thead><tr>';
        html += '<th>Product</th>';
        html += '<th>Product Code</th>';
        html += '<th>Quantity</th>';
        html += '<th>Unit Price</th>';
        html += '<th>Line Total</th>';
        html += '</tr></thead><tbody>';
        
        Decimal totalAmount = 0;
        for (Cart_Item__c item : items) {
            html += '<tr>';
            html += '<td>' + (item.Product__r.Name != null ? item.Product__r.Name : 'Unknown Product') + '</td>';
            html += '<td>' + (item.Product__r.ProductCode != null ? item.Product__r.ProductCode : 'N/A') + '</td>';
            html += '<td>' + (item.Quantity__c != null ? String.valueOf(item.Quantity__c) : '0') + '</td>';
            html += '<td>$' + (item.Unit_Price__c != null ? String.valueOf(item.Unit_Price__c.setScale(2)) : '0.00') + '</td>';
            html += '<td>$' + (item.Line_Total__c != null ? String.valueOf(item.Line_Total__c.setScale(2)) : '0.00') + '</td>';
            html += '</tr>';
            
            if (item.Line_Total__c != null) {
                totalAmount += item.Line_Total__c;
            }
        }
        
        html += '</tbody></table>';
        
        // Total
        html += '<div class="total-row">';
        html += '<div class="invoice-row">';
        html += '<span>Total Amount:</span>';
        html += '<span>$' + totalAmount.setScale(2) + '</span>';
        html += '</div>';
        html += '</div>';
        
        // Footer
        html += '<div class="footer">';
        html += '<p>Thank you for your business!</p>';
        html += '<p>Generated by ENOS Platform on ' + Datetime.now().format('MMMM dd, yyyy \'at\' h:mm a') + '</p>';
        html += '</div>';
        
        html += '</body></html>';
        return html;
    }
    
    private static void cleanupOldInvoiceFiles(Id contactId) {
        try {
            if (contactId == null) return;
            
            // Find old invoice files for this contact
            List<ContentDocument> oldFiles = [
                SELECT Id 
                FROM ContentDocument 
                WHERE Title LIKE 'ENOS-Invoice-%' 
                AND CreatedBy.ContactId = :contactId
                ORDER BY CreatedDate DESC
            ];
            
            // Keep only the last 5 files, delete the rest
            if (oldFiles.size() > 5) {
                List<ContentDocument> filesToDelete = new List<ContentDocument>();
                for (Integer i = 5; i < oldFiles.size(); i++) {
                    filesToDelete.add(oldFiles[i]);
                }
                
                if (!filesToDelete.isEmpty()) {
                    delete filesToDelete;
                    System.debug('Cleaned up ' + filesToDelete.size() + ' old invoice files');
                }
            }
        } catch (Exception e) {
            // Don't fail invoice generation if cleanup fails
            System.debug(LoggingLevel.WARN, 'Invoice cleanup failed: ' + e.getMessage());
        }
    }
}
