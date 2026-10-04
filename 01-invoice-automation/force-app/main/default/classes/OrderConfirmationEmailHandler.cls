global class OrderConfirmationEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, 
        Messaging.InboundEnvelope envelope) {
       //1. Receive Messaging.InboundEmail and update the Opportunity
       Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
//2. Parse the Subject: "Invoice INV-000001 - Umbrella" → extract INV-000001
//String.split() splits a string by a delimiter
String subject = email.subject;
String[] parts = subject.split(' ');
String invoiceNumber = parts[1];
//3. Find the Opportunity WHERE Invoice_Number__c = 'INV-000001'
//SOQL pattern
// guard: what if the Opportunity is not found? Wrap the result in a list:
List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity 
                           WHERE Invoice_Number__c = :invoiceNumber 
                           LIMIT 1];

if (!opps.isEmpty()) {
    Opportunity opp = opps[0];
    //4. Check Stage = 'Negotiation/Review'
    if (opp.StageName == 'Negotiation/Review'){
        //5. Parse the email Body for the word Approved or Rejected
       if (email.plainTextBody.contains('Approved')) {
    //6.Approved → Stage = 'Closed Won'
    
    opp.StageName = 'Closed Won'; 
} else if (email.plainTextBody.contains('Rejected')) {    
//7.Rejected → Stage = 'Closed Lost'
 opp.StageName = 'Closed Lost'; 
}
//8. Update the Opportunity
update opp; 
    }
}  
    return result;
}

}
