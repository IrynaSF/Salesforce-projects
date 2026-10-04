@isTest
public class LeadEngagementBatchTest {
    @isTest
    static void testBatch() {
        // 1. Создай Lead со статусом 'Open - Not Contacted'
        Lead ld = new Lead(
            LastName = 'Test Lead',
            Company  = 'Test Company',
            Status   = 'Open - Not Contacted'
        );
        insert ld;

        // 2. Запусти Batch
        Test.startTest();
            Database.executeBatch(new LeadEngagementBatch());
        Test.stopTest();

        // 3. Проверь что Status обновился
        Lead updated = [SELECT Status FROM Lead WHERE Id = :ld.Id];
        System.assertEquals('Working - Contacted', updated.Status);
    }
}
