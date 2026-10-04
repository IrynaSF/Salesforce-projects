@isTest
public class AccountSummaryBatchTest {
    @isTest
    static void testBatch() {
        // 1. Create an Account without Opportunities
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // 2. Run the Batch
        Test.startTest();
            Database.executeBatch(new AccountSummaryBatch());
        Test.stopTest();

        // 3. Check that Description was updated
        Account updated = [SELECT Description FROM Account WHERE Id = :acc.Id];
        System.assertEquals('No Active Deals - Follow Up Need',
            updated.Description);
    }
}
