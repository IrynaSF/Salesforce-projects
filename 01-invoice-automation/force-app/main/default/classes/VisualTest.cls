@IsTest
private class VisualTest {
    @TestSetup
    static void setupTestData() {
         Account acc = new Account(Name = 'Test Account');
        insert acc;
    Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;
   PricebookEntry pbe = new PricebookEntry
        (Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(),
        UnitPrice = 100, IsActive = true);
        insert pbe;

   Opportunity opp = new Opportunity(
            Name      = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
           Pricebook2Id = Test.getStandardPricebookId(),
            AccountId = acc.Id
        );
        insert opp;
Contact con = new Contact(FirstName = 'Tom',LastName = 'Test', AccountId = acc.Id);
        insert con;

  OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId     = con.Id,
            IsPrimary     = true
        );
        insert ocr;

 OpportunityLineItem oli = new OpportunityLineItem
        (OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 5, TotalPrice = 1000);
        insert oli;
    }
@isTest
static void testVisual_withContact(){
    Opportunity opp1 = [SELECT Id, Name, StageName, CloseDate,Pricebook2Id 
    FROM Opportunity 
    WHERE Name = 'Test Opp' LIMIT 1];

ApexPages.StandardController stdController = new ApexPages.StandardController(opp1);

Test.startTest();
VisualController ctrl = new VisualController(stdController);
Test.stopTest();

Assert.isNotNull(ctrl.opp, 'Opportunity there should not be null');
Assert.isNotNull(ctrl.companyInfo, 'Organization there should not be null');
Assert.isNotNull(ctrl.primaryContact, 'Contact there should not be null');
Assert.isNotNull(ctrl.lineItems, 'Products there should not be null');
Assert.isNotNull(ctrl.generationDate, 'Date there should not be null');


}

@isTest
static void testVisua_withoutContact(){

   Account acc1 = [SELECT Id, Name
    FROM Account 
    WHERE Name = 'Test Account' LIMIT 1];

Opportunity oppNoContact = new Opportunity(
    Name = 'No Contact Opp',
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(10),
    Pricebook2Id = Test.getStandardPricebookId(),
    AccountId = acc1.Id
);
insert oppNoContact;

ApexPages.StandardController stdController = new ApexPages.StandardController(oppNoContact);

Test.startTest();
VisualController ctrl = new VisualController(stdController);
Test.stopTest();


Assert.isNotNull(ctrl.opp, 'Opportunity there should not be null');
Assert.isNotNull(ctrl.companyInfo, 'Organization there should not be null');
Assert.isNull(ctrl.primaryContact, 'Contact there should be null');
Assert.isNotNull(ctrl.lineItems, 'Products there should not be null');
Assert.isNotNull(ctrl.generationDate, 'Date there should not be null');


}
}
