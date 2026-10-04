@isTest
private class OpportSchedulerControllerTest {

    private static String TARGET_JOB_NAME = 'Daily Opportunity Follow-up Job';

    @isTest
    static void testSchedulerAndControllerWorkflow() {
        // 1. Create test data (a deal closed yesterday)
        Account testAcc = new Account(Name = 'Test Client');
        insert testAcc;

        Opportunity oldOpp = new Opportunity(
            Name = 'Super Deal',
            AccountId = testAcc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-1), // Yesterday
            Amount = 10000
        );
        insert oldOpp;

        // 2. Test the initial status (must be NOT STARTED)
        String initialStatus = OpportSchedulerController.getJobStatus();
        System.assertEquals('Status: NOT STARTED', initialStatus);

        // 3. Test launching with no time (error)
        String errorResult = OpportSchedulerController.startScheduledJob('');
        System.assertEquals('Please select a launch time first.', errorResult);

        // 4. Test the Launch Job button (successful start)
        Test.startTest();
        
        String launchResult = OpportSchedulerController.startScheduledJob('08:00');
        System.assert(launchResult.contains('Successfully!'));

        // Check that the status changed to WAITING
        String runningStatus = OpportSchedulerController.getJobStatus();
        System.assertEquals('Status: WAITING', runningStatus);

        // The test context forces the scheduler to run NOW
        Test.stopTest();

        // Check that a new deal was created
        List<Opportunity> followUpOpps = [SELECT Name FROM Opportunity WHERE Name LIKE 'Follow-up%'];
        System.assertEquals(1, followUpOpps.size());
        System.assertEquals('Follow-up: Super Deal', followUpOpps[0].Name);

        // 5. Test the Stop Job button (successful stop)
        Test.startTest();
        String abortResult = OpportSchedulerController.abortScheduledJob();
        System.assert(abortResult.contains('Success!'));

        // Make sure the status is NOT STARTED again
        String finalStatus = OpportSchedulerController.getJobStatus();
        System.assertEquals('Status: NOT STARTED', finalStatus);
        Test.stopTest();
    }
}
