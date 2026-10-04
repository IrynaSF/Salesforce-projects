public with sharing class LwcController {
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getInvoiceData(Id oppId) {
        Map<String, String> data = new Map<String, String>();

        for (OpportunityContactRole ocr : [
            SELECT Contact.Name, Contact.Email, Opportunity.Invoice_Number__c
            FROM OpportunityContactRole
            WHERE OpportunityId = :oppId AND IsPrimary = true
            LIMIT 1
        ]) {
            data.put('contactName', ocr.Contact.Name);
            data.put('contactEmail', ocr.Contact.Email);
            data.put('invoiceNumber', ocr.Opportunity.Invoice_Number__c);
        }

        // Ищем PDF файл привязанный к этой Opportunity
        List<ContentDocumentLink> files = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :oppId
            AND ContentDocument.FileType = 'PDF'
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
        ];

        if (!files.isEmpty()) {
            data.put('contentDocumentId', files[0].ContentDocumentId);
        }

        return data;
    }
}
