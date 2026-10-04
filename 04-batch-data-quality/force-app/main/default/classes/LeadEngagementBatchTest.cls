@isTest
public class LeadEngagementBatchTest {
    @isTest
    static void testBatch() {
        // 1. Create a Lead with status 'Open - Not Contacted'
        Lead ld = new Lead(
            LastName = 'Test Lead',
            Company  = 'Test Company',
            Status   = 'Open - Not Contacted'
        );
        insert ld;

        // 2. Run the Batch
        Test.startTest();
            Database.executeBatch(new LeadEngagementBatch());
        Test.stopTest();

        // 3. Check that Status was updated
        Lead updated = [SELECT Status FROM Lead WHERE Id = :ld.Id];
        System.assertEquals('Working - Contacted', updated.Status);
    }
}
