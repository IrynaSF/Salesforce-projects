global class OrderConfirmationEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, 
        Messaging.InboundEnvelope envelope) {
       //1.Получаем: Messaging.InboundEmail и обновляем Opportunity
       Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
//2. Парсим Subject: "Invoice INV-000001 - Umbrella" → достаём INV-000001
//String.split() — разбить строку по разделителю
String subject = email.subject;
String[] parts = subject.split(' ');
String invoiceNumber = parts[1];
//3.Ищем Opportunity WHERE Invoice_Number__c = 'INV-000001'
//SOQL Схема 
// защита — что если Opportunity не найдена - Обернуть в список:
List<Opportunity> opps = [SELECT Id, StageName FROM Opportunity 
                           WHERE Invoice_Number__c = :invoiceNumber 
                           LIMIT 1];

if (!opps.isEmpty()) {
    Opportunity opp = opps[0];
    //4.Проверяем Stage = 'Negotiation/Review'
    if (opp.StageName == 'Negotiation/Review'){
        //5.Парсим Body письма на слово Approved или Rejected
       if (email.plainTextBody.contains('Approved')) {
    //6.Approved → Stage = 'Closed Won'
    
    opp.StageName = 'Closed Won'; 
} else if (email.plainTextBody.contains('Rejected')) {    
//7.Rejected → Stage = 'Closed Lost'
 opp.StageName = 'Closed Lost'; 
}
//8.Обновляем Opportunity
update opp; 
    }
}  
    return result;
}

}
