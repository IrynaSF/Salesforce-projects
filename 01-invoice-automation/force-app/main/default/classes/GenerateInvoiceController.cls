public with sharing class GenerateInvoiceController {
    @AuraEnabled
    public static void generateAndAttachPDF(Id oppId) {
        Opportunity opp = [
            SELECT Invoice_Number__c, Name 
            FROM Opportunity 
            WHERE Id = :oppId 
            LIMIT 1
        ];

        String fileName;
        if (opp.Invoice_Number__c != null && opp.Invoice_Number__c != '') {
            fileName = opp.Invoice_Number__c;
        } else {
            fileName = 'Invoice-' + opp.Name;
        }

        PageReference pdfPage = Page.VisualInvoice;
        pdfPage.getParameters().put('id', oppId);
        Blob pdfBlob = Test.isRunningTest() 
            ? Blob.valueOf('Test') 
            : pdfPage.getContentAsPDF();

        List<ContentDocumentLink> existingFiles = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :oppId
            AND ContentDocument.Title = :fileName
            LIMIT 1
        ];

        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.VersionData = pdfBlob;

        if (!existingFiles.isEmpty()) {
            cv.ContentDocumentId = existingFiles[0].ContentDocumentId;
            cv.PathOnClient = fileName + '.pdf';
            cv.ReasonForChange = 'Invoice updated';
        } else {
            cv.PathOnClient = fileName + '.pdf';
            cv.FirstPublishLocationId = oppId;
        }

        insert cv;
    }
}
