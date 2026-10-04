@isTest
public class ScheduledJobsMonitorControllerTest {

    // Простой Schedulable класс только для теста
    class TestScheduler implements Schedulable {
        public void execute(SchedulableContext ctx) {
            // пустой — только для теста
        }
    }

    @isTest
    static void testGetActiveJobs() {
        // Используем TestScheduler
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
