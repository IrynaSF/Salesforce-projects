@isTest

private class OrderConfirmationEmailHandlerTest{
    @testSetup
    static void setupData() {
 Account acc = new Account(Name = 'Test Acc');
        insert acc;
 
    Opportunity opp = new Opportunity(
            Name      = 'Test Opp',
            StageName = 'Negotiation/Review',
            CloseDate = Date.today().addDays(10),
            Amount    = 1000.00,
            AccountId = acc.Id
        );
        insert opp;
        
    }

@isTest
    static void testHandleInboundEmail_approved(){
  Opportunity opp = [SELECT Id, Name, Invoice_Number__c,StageName  FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
String fileName = opp.Invoice_Number__c;

Messaging.InboundEmail email = new Messaging.InboundEmail();
       email.subject = 'Invoice ' + fileName + ' - Test';
        email.plainTextBody = 'Approved';
Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
Test.startTest();
OrderConfirmationEmailHandler handler = new OrderConfirmationEmailHandler();
handler.handleInboundEmail(email, envelope); 
    Test.stopTest();
 Opportunity updatedOpp = [SELECT Id, Name, Invoice_Number__c,StageName FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
Assert.areEqual('Closed Won', updatedOpp.StageName, 'The deal stage should have updated');
}

@isTest
static void testHandleInboundEmail_rejected(){
  Opportunity opp = [SELECT Id, Name, Invoice_Number__c,StageName  FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
String fileName = opp.Invoice_Number__c;

Messaging.InboundEmail email = new Messaging.InboundEmail();
       email.subject = 'Invoice ' + fileName + ' - Test';
        email.plainTextBody = 'Rejected';
Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
Test.startTest();
OrderConfirmationEmailHandler handler = new OrderConfirmationEmailHandler();
handler.handleInboundEmail(email, envelope); 
    Test.stopTest();
 Opportunity updatedOpp = [SELECT Id, Name, Invoice_Number__c,StageName  FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
Assert.areEqual('Closed Lost', updatedOpp.StageName, 'The deal stage should have updated');
}

@isTest
static void testHandleInboundEmail_wrongStage(){
Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc' LIMIT 1];

Opportunity wrongStageOpp = new Opportunity(
    Name      = 'Wrong Stage Opp',
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(10),
    Amount    = 1000.00,
    AccountId = acc.Id
);  
insert wrongStageOpp;
Opportunity wrongOpp = [SELECT Id, Invoice_Number__c,StageName  FROM Opportunity WHERE Name = 'Wrong Stage Opp' LIMIT 1];
String fileName = wrongOpp.Invoice_Number__c;


Messaging.InboundEmail email = new Messaging.InboundEmail();
       email.subject = 'Invoice ' + fileName + ' - Test';
        email.plainTextBody = 'Rejected';
Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
Test.startTest();
OrderConfirmationEmailHandler handler = new OrderConfirmationEmailHandler();
handler.handleInboundEmail(email, envelope); 
    Test.stopTest();
Opportunity oppupdate = [SELECT Id, Name, Invoice_Number__c,StageName  FROM Opportunity WHERE Name = 'Wrong Stage Opp' LIMIT 1];
Assert.areEqual('Prospecting', oppupdate.StageName, 'The deal stage should have updated');
}
}
