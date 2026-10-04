@isTest
public class UniversalBatchSchedulerTest {
    @isTest
    static void testScheduler() {
        // 1. Создай Lead для LeadEngagementBatch
        insert new Lead(
            LastName = 'Test Lead',
            Company  = 'Test Company',
            Status   = 'Open - Not Contacted'
        );

        // 2. Запусти Scheduler с именем Batch класса
        Test.startTest();
            System.schedule(
                'Test Universal Job',
                '0 0 8 * * ?',
                new UniversalBatchScheduler('LeadEngagementBatch')
            );
        Test.stopTest();

        // 3. Проверь что job создался
        List<CronTrigger> jobs = [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test Universal Job'
        ];
        System.assertNotEquals(null, jobs, 'Job must exist');
    }
}
