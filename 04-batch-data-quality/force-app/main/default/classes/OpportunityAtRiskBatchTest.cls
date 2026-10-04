@isTest
public class OpportunityAtRiskBatchTest {
    @isTest
    static void testBatch() {
        // 1. Create an Account and an Opportunity with no activity
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name          = 'Test Deal',
            AccountId     = acc.Id,
            StageName     = 'Prospecting',
            CloseDate     = Date.today().addDays(30),
            Amount        = 5000
        );
        insert opp;

        // 2. Run the Batch
        Test.startTest();
            Database.executeBatch(new OpportunityAtRiskBatch());
        Test.stopTest();

        // 3. Check that Description was updated
        Opportunity updated = [
            SELECT Description FROM Opportunity WHERE Id = :opp.Id
        ];
        System.assertEquals('At Risk', updated.Description);
    }
}
