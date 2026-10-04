@isTest
public class OpportunityPipelineBatchTest {
    @isTest
    static void testBatch() {
        // 1. Создай Account и просроченную Opportunity
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name      = 'Test Deal',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(-5), // просрочена!
            Amount    = 1000
        );
        insert opp;

        // 2. Запусти Batch
        Test.startTest();
            Database.executeBatch(new OpportunityPipelineBatch());
        Test.stopTest();

        // 3. Проверь что Description обновился
        Opportunity updated = [
            SELECT Description FROM Opportunity WHERE Id = :opp.Id
        ];
        System.assertEquals('Overdue - Needs Attention', updated.Description);
    }
}
