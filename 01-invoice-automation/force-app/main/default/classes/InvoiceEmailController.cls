public with sharing class InvoiceEmailController {
    
    @AuraEnabled(cacheable=true)
    public static InvoiceEmailData getInvoiceEmailData(Id opportunityId) {
        try {
            InvoiceEmailData data = new InvoiceEmailData();
            
            Opportunity opp = [
                SELECT Id, Name, Amount, Invoice_Number__c, 
                       Owner.Name, Owner.Email
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
            ];
            
            data.invoiceNumber = opp.Invoice_Number__c;
            data.opportunityName = opp.Name;
            data.amount = opp.Amount;
            
            List<OpportunityContactRole> roles = [
                SELECT Contact.Id, Contact.Name, 
                       Contact.Email, Contact.FirstName
                FROM OpportunityContactRole
                WHERE OpportunityId = :opportunityId
                AND IsPrimary = true
                LIMIT 1
            ];
            
            if (!roles.isEmpty()) {
                data.recipientName = roles[0].Contact.Name;
                data.recipientEmail = roles[0].Contact.Email;
                data.contactFirstName = roles[0].Contact.FirstName;
            } else {
                throw new AuraHandledException(
                    'No primary contact found for this opportunity.'
                );
            }
            
            Organization org = [SELECT Name FROM Organization LIMIT 1];
            data.organizationName = org.Name;
            
            data.emailSubject = 'Invoice ' + opp.Invoice_Number__c + 
                                ' - ' + opp.Name;
            data.emailBody = buildEmailBody(data);
            data.pdfUrl = getPDFUrl(opportunityId, opp.Invoice_Number__c);
            
            return data;
            
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Error loading invoice data: ' + e.getMessage()
            );
        }
    }
    
    private static String buildEmailBody(InvoiceEmailData data) {
        String firstName = data.contactFirstName != null ? 
                          data.contactFirstName : 'Customer';
        
        String body = 'Dear ' + firstName + ',\n\n';
        body += 'Thank you for your business with ' + 
                data.organizationName + '!\n\n';
        body += 'Please find attached invoice ' + 
                data.invoiceNumber + ' for your review.\n\n';
        body += 'Invoice Details:\n';
        body += '- Invoice Number: ' + data.invoiceNumber + '\n';
        body += '- Opportunity: ' + data.opportunityName + '\n';
        body += '- Amount Due: $' + data.amount + '\n\n';
        body += 'Payment is due within 30 days from the invoice date.\n\n';
        body += 'If you have any questions, please do not hesitate ';
        body += 'to contact us.\n\n';
        body += 'Best regards,\n';
        body += data.organizationName;
        
        return body;
    }
    
    private static String getPDFUrl(Id opportunityId, String invoiceNumber) {
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, 
                   ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :opportunityId
            AND ContentDocument.Title = :invoiceNumber
            LIMIT 1
        ];
        
        if (!links.isEmpty()) {
            return '/sfc/servlet.shepherd/version/download/' + 
                   links[0].ContentDocument.LatestPublishedVersionId;
        }
        
        return null;
    }
    
    @AuraEnabled
    public static String sendInvoiceEmail(
        Id opportunityId, 
        String emailBody
    ) {
        try {
            Opportunity opp = [
                SELECT Id, Invoice_Number__c, Name
                FROM Opportunity
                WHERE Id = :opportunityId
            ];
            
            List<OpportunityContactRole> roles = [
                SELECT Contact.Email, Contact.Name
                FROM OpportunityContactRole
                WHERE OpportunityId = :opportunityId
                AND IsPrimary = true
                LIMIT 1
            ];
            
            if (roles.isEmpty()) {
                throw new AuraHandledException(
                    'No primary contact found.'
                );
            }
            
            String recipientEmail = roles[0].Contact.Email;
            String recipientName = roles[0].Contact.Name;
            
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId, 
                       ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :opportunityId
                AND ContentDocument.Title = :opp.Invoice_Number__c
                LIMIT 1
            ];
            
            if (links.isEmpty()) {
                throw new AuraHandledException(
                    'Invoice PDF not found. Please generate invoice first.'
                );
            }
            
            ContentVersion cv = [
                SELECT VersionData, Title
                FROM ContentVersion
                WHERE Id = :links[0].ContentDocument.LatestPublishedVersionId
            ];
            
            Organization org = [SELECT Name FROM Organization LIMIT 1];
            
            Messaging.SingleEmailMessage email = 
                new Messaging.SingleEmailMessage();
            
            email.setToAddresses(new String[] { recipientEmail });
            email.setSubject(
                'Invoice ' + opp.Invoice_Number__c + ' - ' + opp.Name
            );
            email.setPlainTextBody(emailBody);
            email.setSenderDisplayName(org.Name);
            
            Messaging.EmailFileAttachment attachment = 
                new Messaging.EmailFileAttachment();
            attachment.setFileName(opp.Invoice_Number__c + '.pdf');
            attachment.setBody(cv.VersionData);
            email.setFileAttachments(
                new Messaging.EmailFileAttachment[] { attachment }
            );
            
            email.setSaveAsActivity(true);
            email.setWhatId(opportunityId);
            
            Messaging.sendEmail(
                new Messaging.SingleEmailMessage[] { email }
            );
            
            return 'Invoice sent successfully to ' + recipientName + 
                   ' (' + recipientEmail + ')';
            
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Error sending email: ' + e.getMessage()
            );
        }
    }
    
    public class InvoiceEmailData {
        @AuraEnabled public String invoiceNumber;
        @AuraEnabled public String opportunityName;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public String recipientName;
        @AuraEnabled public String recipientEmail;
        @AuraEnabled public String contactFirstName;
        @AuraEnabled public String organizationName;
        @AuraEnabled public String emailSubject;
        @AuraEnabled public String emailBody;
        @AuraEnabled public String pdfUrl;
    }
}
