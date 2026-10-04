public with sharing class SendEmailController {
    @AuraEnabled
    public static void sendEmail(
        String toAddress,
        String subject,
        String body,
        String contentDocumentId
    ) {
        if (toAddress == null || toAddress.trim() == '') {
            throw new AuraHandledException('Email address is empty');
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{ toAddress });
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(true);
        mail.setOptOutPolicy('FILTER');

        // Attach the PDF if there is one
        if (contentDocumentId != null && contentDocumentId != '') {
            List<ContentVersion> cvList = [
                SELECT VersionData, Title, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId = :contentDocumentId
                AND IsLatest = true
                LIMIT 1
            ];
            if (!cvList.isEmpty()) {
                ContentVersion cv = cvList[0];
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(cv.Title + '.pdf');
                attachment.setBody(cv.VersionData);
                attachment.setContentType('application/pdf');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[]{ attachment });
            }
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
    }
}
