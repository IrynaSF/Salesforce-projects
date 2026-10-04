global class OpportunityEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try {
            // 1. Get the email subject and find the number after the # sign
            String subject = email.subject;
            if (!subject.contains('#')) {
                System.debug('Invoice number marker (#) not found in subject');
                return result;
            }

            String invoiceNumber = subject.substringAfter('#').trim();
            System.debug('Searching for Opportunity with Invoice Number: ' + invoiceNumber);
            
            // 2. Find the Opportunity (any one with a matching number)
            List<Opportunity> opps = [
                SELECT Id, StageName 
                FROM Opportunity 
                WHERE Invoice_Number__c = :invoiceNumber 
                LIMIT 1
            ];
            
            if (opps.isEmpty()) {
                System.debug('Opportunity not found for invoice: ' + invoiceNumber);
                return result;
            }

            Opportunity opp = opps[0];

            // 3. Read the reply text (check both Plain Text and HTML)
            String bodyText = (email.plainTextBody != null) ? email.plainTextBody : email.htmlBody;
            
            if (bodyText != null) {
                // If we find Approved, move to the Closed Won stage
                if (bodyText.containsIgnoreCase('Approved')) {
                    opp.StageName = 'Closed Won'; 
                    System.debug('Status updated to Closed Won');
                } 
                // If we find Rejected, close as lost
                else if (bodyText.containsIgnoreCase('Rejected')) {
                    opp.StageName = 'Closed Lost';
                    System.debug('Status updated to Closed Lost');
                }
                
                update opp;
            }
            
            result.success = true;
            
        } catch (Exception e) {
            result.success = false;
            System.debug('Error in Email Handler: ' + e.getMessage());
        }
        
        return result;
    }
}
