@isTest
public class AccountSummaryBatchTest {
    @isTest
    static void testBatch() {
        // 1. Создай Account без Opportunity
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // 2. Запусти Batch
        Test.startTest();
            Database.executeBatch(new AccountSummaryBatch());
        Test.stopTest();

        // 3. Проверь что Description обновился
        Account updated = [SELECT Description FROM Account WHERE Id = :acc.Id];
        System.assertEquals('No Active Deals - Follow Up Need',
            updated.Description);
    }
}
