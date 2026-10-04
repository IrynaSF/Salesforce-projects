@isTest
public with sharing class OldNewHandlerTest {
    @isTest
    public static void testStageAutoAdvance() {
        Opportunity oppTest = new Opportunity();
        oppTest.Name = 'Test Opportunity';
        oppTest.StageName = 'Prospecting';
        oppTest.CloseDate = Date.today().addDays(30);
        oppTest.Amount = 500;
       
        insert oppTest;
        
        Test.startTest();
        oppTest.Amount = 3000;
        update oppTest;
        Test.stopTest();

        // Query the records from the org again and check the Stage Name.
        Opportunity oppUpdated = [
            SELECT StageName
             FROM Opportunity 
             WHERE Id = :oppTest.Id
        ];
        
System.assertEquals('Negotiation/Review', oppUpdated.StageName);
    }
}
