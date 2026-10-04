@isTest
public class LeadSourceBatchTest {
    @isTest
    static void testBatch() {
        // 1. Create a Lead without a LeadSource
        Lead ld = new Lead(
            LastName = 'Test Lead',
            Company  = 'Test Company'
            // LeadSource is not set, so it will be null
        );
        insert ld;

        // 2. Run the Batch
        Test.startTest();
            Database.executeBatch(new LeadSourceBatch());
        Test.stopTest();

        // 3. Check that LeadSource was updated
        Lead updated = [SELECT LeadSource FROM Lead WHERE Id = :ld.Id];
        System.assertEquals('Other', updated.LeadSource);
    }
}
