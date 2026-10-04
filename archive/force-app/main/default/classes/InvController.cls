public with sharing class InvController {
    public Opportunity opp {get;set;}
    public Organization myCompany{get;set;}
    public OpportunityContactRole primaryContact{get;set;}
    public List <OpportunityLineItem> products{get;set;}

    public InvController (ApexPages.StandardController stdController){
        this.opp=[SELECT Id,Name,Owner.Name,Invoice_Number__c,Amount
            FROM Opportunity
            WHERE Id=:stdController.getId()];
        this.myCompany=[SELECT Name,Street,City,State,Country,PostalCode
            FROM Organization 
            LIMIT 1];
        List<OpportunityContactRole> contacts=[SELECT Contact.Name,Contact.Account.Name,Contact.Phone,Contact.Email
            FROM OpportunityContactRole
            WHERE OpportunityId=:opp.Id AND IsPrimary=true
            LIMIT 1];
        if(!contacts.isEmpty()) {
            this.primaryContact = contacts[0];
        }
        this.products=[
            SELECT Product2.Name,Quantity,UnitPrice,TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId=:opp.Id
        ];
    }

    public PageReference generateAndSave() {
        // 1. Determine the file name: never null
        String fileName = (opp.Invoice_Number__c != null && opp.Invoice_Number__c != '')
            ? opp.Invoice_Number__c
            : 'Invoice-' + opp.Name;

        // 2. Generate the PDF
        PageReference pdf = Page.VisualController;
        pdf.getParameters().put('id', opp.Id);
        Blob body;
        if (Test.isRunningTest()) { body = Blob.valueOf('Test'); }
        else { body = pdf.getContentAsPDF(); }

        // 3. Find the existing file by the correct name
        List<ContentDocument> oldFiles = [
            SELECT Id FROM ContentDocument 
            WHERE Title = :fileName 
            LIMIT 1
        ];

        // 4. Create the ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName + '.pdf';
        cv.VersionData = body;

        if (!oldFiles.isEmpty()) {
            // Update the existing file
            cv.ContentDocumentId = oldFiles[0].Id;
        }
        insert cv;

        // 5. If the file is new, attach it to the Opportunity
        if (oldFiles.isEmpty()) {
            Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            ContentDocumentLink link = new ContentDocumentLink();
            link.LinkedEntityId = opp.Id;
            link.ContentDocumentId = docId;
            link.ShareType = 'V';
            insert link;
        }

        PageReference resultPage = new PageReference('/' + opp.Id);
        return resultPage;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getInvoiceEmailDetails(Id oppId) {
        Map<String, String> result = new Map<String, String>();
        
        Opportunity opp = [SELECT Invoice_Number__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
        
        OpportunityContactRole ocr = [SELECT Contact.Name, Contact.Email 
                                      FROM OpportunityContactRole 
                                      WHERE OpportunityId = :oppId AND IsPrimary = true LIMIT 1];
        
        EmailTemplate et = [SELECT Subject, HtmlValue FROM EmailTemplate 
                            WHERE Name = 'Invoice Notification' LIMIT 1];
        
        ContentDocumentLink link = [SELECT ContentDocumentId FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :oppId 
                                    ORDER BY SystemModstamp DESC LIMIT 1];

        result.put('subject', 'Invoice No. ' + opp.Invoice_Number__c);
        result.put('body', et.HtmlValue);
        result.put('recipientName', ocr.Contact.Name);
        result.put('recipientEmail', ocr.Contact.Email);
        result.put('fileId', link.ContentDocumentId);

        return result;
    }
}
