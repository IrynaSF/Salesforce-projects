@isTest
public class BatchSchedulerControllerTest {

    // Test 1: getJobStatus when the job doesn't exist
    @isTest
    static void testGetJobStatusEmpty() {
        String status = BatchSchedulerController.getJobStatus();
        System.assertEquals('NOT STARTED', status);
    }

    // Test 2: startJob succeeds
    @isTest
    static void testStartJob() {
        Test.startTest();
            String result = BatchSchedulerController.startJob(
                'LeadEngagementBatch', '08:00'
            );
        Test.stopTest();
        System.assertEquals('Scheduler started at 08:00', result);
    }

    // Test 3: startJob when the job already exists
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

    // Test 4: stopJob succeeds
    @isTest
    static void testStopJob() {
        System.schedule('Universal Batch Job', '0 0 8 * * ?',
            new UniversalBatchScheduler('LeadEngagementBatch'));
        Test.startTest();
            String result = BatchSchedulerController.stopJob();
        Test.stopTest();
        System.assertEquals('Scheduler stopped!', result);
    }

    // Test 5: stopJob when the job is not found
    @isTest
    static void testStopJobNotFound() {
        Test.startTest();
            String result = BatchSchedulerController.stopJob();
        Test.stopTest();
        System.assertEquals('No active scheduler found!', result);
    }
}
