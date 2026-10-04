@isTest

private class LwcTest{

@testSetup
    static void setupData() {
 Account acc = new Account(Name = 'Test Acc');
        insert acc;
  Contact con = new Contact(
            FirstName = 'Alex',
            LastName  = 'Test',
            AccountId = acc.Id
        );
        insert con;
    Opportunity opp = new Opportunity(
            Name      = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Amount    = 1000.00,
            AccountId = acc.Id
        );
        insert opp;
  OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId     = con.Id,
            IsPrimary     = true
        );
        insert ocr;
}

@isTest
static void testGetInvoiceData_withPdf(){
    Opportunity opp = [SELECT Id, Name, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];
String fileName = opp.Invoice_Number__c;
//2. Create a ContentVersion with a PDF file attached to this Opportunity
  ContentVersion cv = new ContentVersion(
        Title                  = fileName,
        PathOnClient = fileName + '.pdf',
        VersionData            = Blob.valueOf('Original'),
        FirstPublishLocationId = opp.Id
    );
    insert cv;

//3. Call the controller method


Test.startTest();
        Map<String, String> result = LwcController.getInvoiceData(opp.Id); 
    Test.stopTest();
//4. Check the result

  Assert.isTrue(result.containsKey('contactName'),  'Should contain contactName key');
Assert.isTrue(result.containsKey('contactEmail'),  'Should contain contactEmail key');
Assert.isTrue(result.containsKey('invoiceNumber'),  'Should contain invoiceNumber key');
Assert.isTrue(result.containsKey('contentDocumentId'),  'Should contain contentDocumentId key');
}

@isTest
static void testGetInvoiceData_withoutPdf(){
    Opportunity opp = [SELECT Id, Name, Invoice_Number__c FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];

Test.startTest();
        Map<String, String> result = LwcController.getInvoiceData(opp.Id); 
    Test.stopTest();


Assert.isTrue(result.containsKey('contactName'), '...');
Assert.isTrue(result.containsKey('contactEmail'), '...');
Assert.isTrue(result.containsKey('invoiceNumber'), '...');
Assert.isFalse(result.containsKey('contentDocumentId'), 'Should not contain contentDocumentId');

}

@isTest
static void testGetInvoiceData_wrongId(){
Id fakeId = '006000000000001AAA';

        Test.startTest();
   Map<String, String> result = LwcController.getInvoiceData(fakeId);
        Test.stopTest();
Assert.isTrue(result.isEmpty(), 'Result should be empty for invalid Id');
}
}
