@isTest
public class OpportSchedulerClassTest {
    @isTest
    static void testScheduler() {
        // 1. Создаем Account (нужен для Opportunity)
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        // 2. Создай Opportunity со статусом 'Closed Won'
        Opportunity opp = new Opportunity(
            Name = 'Big Deal',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            Amount =100,
            CloseDate = Date.today());
            // сегодня — входит в LAST_N_DAYS:30
            
        insert opp;

        //    CloseDate = Date.today() (сегодня — входит в LAST_N_DAYS:30)
        //    Name НЕ должен начинаться с 'Follow-up'
        
        // 3. Запусти Scheduler
        Test.startTest();
            System.schedule(
                'Test Follow-up Job',
                '0 0 8 * * ?',
                new OpportSchedulerClass()
            );
        Test.stopTest(); // execute() выполняется здесь
        
        // 4. Проверь что создалась новая Follow-up Opportunity
        List<Opportunity> followUps = [
            SELECT Id, Name FROM Opportunity
            WHERE Name LIKE 'Follow-up%'
        ];
        System.assertEquals(1, followUps.size());
    }
}
