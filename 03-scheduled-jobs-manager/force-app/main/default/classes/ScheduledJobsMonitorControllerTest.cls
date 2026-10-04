@isTest
public class ScheduledJobsMonitorControllerTest {

    // Simple Schedulable class for the test only
    class TestScheduler implements Schedulable {
        public void execute(SchedulableContext ctx) {
            // empty: for the test only
        }
    }

    @isTest
    static void testGetActiveJobs() {
        // Use TestScheduler
        System.schedule(
            'Test Monitor Job',
            '0 0 8 * * ?',
            new TestScheduler()
        );

        Test.startTest();
            List<CronTrigger> jobs =
                ScheduledJobsMonitorController.getActiveJobs();
        Test.stopTest();

        System.assertEquals(5, jobs.size());
        System.assertEquals('WAITING', jobs[0].State);
    }
}
