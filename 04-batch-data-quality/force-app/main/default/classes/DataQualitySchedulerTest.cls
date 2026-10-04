@isTest
public class DataQualitySchedulerTest {

    @isTest
    static void testSchedulerWithLead() {
        Test.startTest();
            System.schedule(
                'Test Lead Source Job',
                '0 0 9 ? * MON',
                new DataQualityScheduler('LeadSourceBatch')
            );
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test Lead Source Job'
        ];
        System.assertNotEquals(0, jobs.size());
    }

    @isTest
    static void testSchedulerWithOpportunity() {
        Test.startTest();
            System.schedule(
                'Test Opportunity At Risk Job',
                '0 0 10 ? * FRI',
                new DataQualityScheduler('OpportunityAtRiskBatch')
            );
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test Opportunity At Risk Job'
        ];
        System.assertNotEquals(0, jobs.size());
    }

    @isTest
    static void testScheduleAll() {
        Test.startTest();
            DataQualityScheduler.scheduleAll();
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id FROM CronTrigger
            WHERE CronJobDetail.Name IN (
                'Lead Source Job',
                'Opportunity At Risk Job'
            )
        ];
        System.assertEquals(2, jobs.size(), 'It must be 2 job');
    }
}
