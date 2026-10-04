@isTest
public class BatchSchedulerControllerTest {

    // Тест 1 — getJobStatus когда job не существует
    @isTest
    static void testGetJobStatusEmpty() {
        String status = BatchSchedulerController.getJobStatus();
        System.assertEquals('NOT STARTED', status);
    }

    // Тест 2 — startJob успешно
    @isTest
    static void testStartJob() {
        Test.startTest();
            String result = BatchSchedulerController.startJob(
                'LeadEngagementBatch', '08:00'
            );
        Test.stopTest();
        System.assertEquals('Scheduler started at 08:00', result);
    }

    // Тест 3 — startJob job уже существует
    @isTest
    static void testStartJobAlreadyRunning() {
        System.schedule('Universal Batch Job', '0 0 8 * * ?',
            new UniversalBatchScheduler('LeadEngagementBatch'));
        Test.startTest();
            String result = BatchSchedulerController.startJob(
                'LeadEngagementBatch', '08:00'
            );
        Test.stopTest();
        System.assertEquals('Scheduler is already running!', result);
    }

    // Тест 4 — stopJob успешно
    @isTest
    static void testStopJob() {
        System.schedule('Universal Batch Job', '0 0 8 * * ?',
            new UniversalBatchScheduler('LeadEngagementBatch'));
        Test.startTest();
            String result = BatchSchedulerController.stopJob();
        Test.stopTest();
        System.assertEquals('Scheduler stopped!', result);
    }

    // Тест 5 — stopJob job не найден
    @isTest
    static void testStopJobNotFound() {
        Test.startTest();
            String result = BatchSchedulerController.stopJob();
        Test.stopTest();
        System.assertEquals('No active scheduler found!', result);
    }
}
