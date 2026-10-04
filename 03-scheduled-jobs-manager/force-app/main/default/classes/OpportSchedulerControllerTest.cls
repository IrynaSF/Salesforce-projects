@isTest
private class OpportSchedulerControllerTest {

    private static String TARGET_JOB_NAME = 'Daily Opportunity Follow-up Job';

    @isTest
    static void testSchedulerAndControllerWorkflow() {
        // 1. Создаем тестовые данные (Вчерашняя закрытая сделка)
        Account testAcc = new Account(Name = 'Test Client');
        insert testAcc;

        Opportunity oldOpp = new Opportunity(
            Name = 'Super Deal',
            AccountId = testAcc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-1), // Вчера
            Amount = 10000
        );
        insert oldOpp;

        // 2. Тестируем начальный статус (Должен быть NOT STARTED)
        String initialStatus = OpportSchedulerController.getJobStatus();
        System.assertEquals('Status: NOT STARTED', initialStatus);

        // 3. Тестируем пустой запуск (Ошибка)
        String errorResult = OpportSchedulerController.startScheduledJob('');
        System.assertEquals('Please select a launch time first.', errorResult);

        // 4. Тестируем кнопку Launch Job (Успешный запуск)
        Test.startTest();
        
        String launchResult = OpportSchedulerController.startScheduledJob('08:00');
        System.assert(launchResult.contains('Successfully!'));

        // Проверяем, что статус изменился на WAITING
        String runningStatus = OpportSchedulerController.getJobStatus();
        System.assertEquals('Status: WAITING', runningStatus);

        // Тест-сессия принудительно заставит планировщик выполниться СЕЙЧАС
        Test.stopTest();

        // Проверяем, что новая сделка создалась
        List<Opportunity> followUpOpps = [SELECT Name FROM Opportunity WHERE Name LIKE 'Follow-up%'];
        System.assertEquals(1, followUpOpps.size());
        System.assertEquals('Follow-up: Super Deal', followUpOpps[0].Name);

        // 5. Тестируем кнопку Stop Job (Успешная остановка)
        Test.startTest();
        String abortResult = OpportSchedulerController.abortScheduledJob();
        System.assert(abortResult.contains('Success!'));

        // Убеждаемся, что статус снова NOT STARTED
        String finalStatus = OpportSchedulerController.getJobStatus();
        System.assertEquals('Status: NOT STARTED', finalStatus);
        Test.stopTest();
    }
}
