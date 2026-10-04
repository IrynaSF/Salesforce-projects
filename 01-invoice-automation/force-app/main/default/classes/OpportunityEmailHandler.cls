global class OpportunityEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try {
            // 1. Получаем тему письма и ищем номер после знака #
            String subject = email.subject;
            if (!subject.contains('#')) {
                System.debug('Invoice number marker (#) not found in subject');
                return result;
            }

            String invoiceNumber = subject.substringAfter('#').trim();
            System.debug('Searching for Opportunity with Invoice Number: ' + invoiceNumber);
            
            // 2. Ищем Opportunity (любую, где совпал номер)
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

            // 3. Читаем текст ответа (проверяем и Plain Text, и HTML)
            String bodyText = (email.plainTextBody != null) ? email.plainTextBody : email.htmlBody;
            
            if (bodyText != null) {
                // Если находим Approved - двигаем на стадию закрыто/выиграно
                if (bodyText.containsIgnoreCase('Approved')) {
                    opp.StageName = 'Closed Won'; 
                    System.debug('Status updated to Closed Won');
                } 
                // Если находим Rejected - закрываем как проиграно
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
