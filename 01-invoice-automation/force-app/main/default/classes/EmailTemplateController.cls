public with sharing class EmailTemplateController {
    @AuraEnabled
    public static Map<String, String> getRenderedTemplate(String developerName, Id recordId) {

        EmailTemplate et = [
            SELECT Id, Subject, HtmlValue, Body
            FROM EmailTemplate
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];

        // Get Opportunity data directly
        Opportunity opp = [
            SELECT Name, Amount, Invoice_Number__c,
                   Owner.Name
            FROM Opportunity
            WHERE Id = :recordId
            LIMIT 1
        ];

        // Get the contact name
        String contactFirstName = '';
        List<OpportunityContactRole> ocrs = [
            SELECT Contact.FirstName, Contact.Name
            FROM OpportunityContactRole
            WHERE OpportunityId = :recordId
            AND IsPrimary = true
            LIMIT 1
        ];
        if (!ocrs.isEmpty() && ocrs[0].Contact.FirstName != null) {
            contactFirstName = ocrs[0].Contact.FirstName;
        }

        // Render the subject via Salesforce merge fields
        Messaging.RenderEmailTemplateBodyResult subjectResult =
            Messaging.renderEmailTemplate(null, recordId,
                new List<String>{ et.Subject })[0];

        // Build the body manually: reliable and without grey tables
        String invoiceNumber = opp.Invoice_Number__c != null ? opp.Invoice_Number__c : '';
        String oppName = opp.Name != null ? opp.Name : '';
        String amount = opp.Amount != null
            ? '$' + String.valueOf(opp.Amount.setScale(2))
            : '';
        String ownerName = opp.Owner.Name != null ? opp.Owner.Name : '';

        String htmlBody =
            '<p>Dear ' + contactFirstName + ',</p>' +
            '<p>Thank you for your business with Iryna!</p>' +
            '<p>Please find attached invoice ' + invoiceNumber + ' for your review.</p>' +
            '<p>' +
                'Invoice Number: ' + invoiceNumber + '<br/>' +
                'Opportunity: ' + oppName + '<br/>' +
                'Amount: ' + amount +
            '</p>' +
            '<p>If you have any questions, please contact us.</p>' +
            '<p>Payment is due within 30 days from the invoice date.</p>' +
            '<p>Best regards,<br/>' + ownerName + '</p>';

        return new Map<String, String>{
            'subject'  => subjectResult.getMergedBody(),
            'htmlBody' => htmlBody
        };
    }
}
