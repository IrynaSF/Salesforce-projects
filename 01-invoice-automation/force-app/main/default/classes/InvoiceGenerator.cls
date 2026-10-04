public with sharing class InvoiceGenerator {
    
    @AuraEnabled
    public static String generateInvoicePDF(Id opportunityId) {
        try {
            Opportunity opp = [
                SELECT Id, Invoice_Number__c 
                FROM Opportunity 
                WHERE Id = :opportunityId
            ];
            
            String fileName = opp.Invoice_Number__c;
            
            PageReference pdfPage = Page.InvoicePDF;
            pdfPage.getParameters().put('id', opportunityId);
            
            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }
            
            List<ContentDocumentLink> existingLinks = [
                SELECT ContentDocumentId, 
                       ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :opportunityId
                AND ContentDocument.Title = :fileName
            ];
            
            if (!existingLinks.isEmpty()) {
                ContentVersion newVersion = new ContentVersion();
                newVersion.ContentDocumentId = existingLinks[0].ContentDocumentId;
                newVersion.VersionData = pdfBlob;
                newVersion.Title = fileName;
                newVersion.PathOnClient = fileName + '.pdf';
                insert newVersion;
                return 'Invoice updated: ' + fileName;
            } else {
                ContentVersion cv = new ContentVersion();
                cv.Title = fileName;
                cv.PathOnClient = fileName + '.pdf';
                cv.VersionData = pdfBlob;
                cv.IsMajorVersion = true;
                insert cv;
                
                Id contentDocumentId = [
                    SELECT ContentDocumentId 
                    FROM ContentVersion 
                    WHERE Id = :cv.Id
                ].ContentDocumentId;
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = opportunityId;
                cdl.ShareType = 'V';
                insert cdl;
                
                return 'Invoice created: ' + fileName;
            }
        } catch (Exception e) {
            throw new AuraHandledException(
                'Error generating invoice: ' + e.getMessage()
            );
        }
    }
}
