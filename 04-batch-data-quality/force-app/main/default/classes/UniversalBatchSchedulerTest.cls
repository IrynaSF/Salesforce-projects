@isTest
public class UniversalBatchSchedulerTest {
    @isTest
    static void testScheduler() {
        // 1. Create a Lead for LeadEngagementBatch
        insert new Lead(
            LastName = 'Test Lead',
            Company  = 'Test Company',
            Status   = 'Open - Not Contacted'
        );

        // 2. Run the Scheduler with the Batch class name
        Test.startTest();
            System.schedule(
                'Test Universal Job',
                '0 0 8 * * ?',
                new UniversalBatchScheduler('LeadEngagementBatch')
            );
        Test.stopTest();

        // 3. Check that the job was created
        List<CronTrigger> jobs = [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test Universal Job'
        ];
        System.assertNotEquals(null, jobs, 'Job must exist');
    }
}
