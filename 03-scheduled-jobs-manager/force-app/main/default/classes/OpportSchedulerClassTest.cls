@isTest
public class OpportSchedulerClassTest {
    @isTest
    static void testScheduler() {
        // 1. Create an Account (required for the Opportunity)
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        // 2. Create an Opportunity with the 'Closed Won' status
        Opportunity opp = new Opportunity(
            Name = 'Big Deal',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            Amount =100,
            CloseDate = Date.today());
            // today: falls within LAST_N_DAYS:30
            
        insert opp;

        //    CloseDate = Date.today() (today: falls within LAST_N_DAYS:30)
        //    Name must NOT start with 'Follow-up'
        
        // 3. Run the Scheduler
        Test.startTest();
            System.schedule(
                'Test Follow-up Job',
                '0 0 8 * * ?',
                new OpportSchedulerClass()
            );
        Test.stopTest(); // execute() runs here
        
        // 4. Check that a new Follow-up Opportunity was created
        List<Opportunity> followUps = [
            SELECT Id, Name FROM Opportunity
            WHERE Name LIKE 'Follow-up%'
        ];
        System.assertEquals(1, followUps.size());
    }
}
