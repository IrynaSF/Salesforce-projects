@isTest
public class LeadSourceBatchTest {
    @isTest
    static void testBatch() {
        // 1. Создай Lead без LeadSource
        Lead ld = new Lead(
            LastName = 'Test Lead',
            Company  = 'Test Company'
            // LeadSource не указываем — будет null
        );
        insert ld;

        // 2. Запусти Batch
        Test.startTest();
            Database.executeBatch(new LeadSourceBatch());
        Test.stopTest();

        // 3. Проверь что LeadSource обновился
        Lead updated = [SELECT LeadSource FROM Lead WHERE Id = :ld.Id];
        System.assertEquals('Other', updated.LeadSource);
    }
}
