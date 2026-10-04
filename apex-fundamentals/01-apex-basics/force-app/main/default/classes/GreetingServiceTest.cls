@isTest
private class GreetingServiceTest {
    @isTest
    static void testGetGreeting() {
        // Шаг 1: создать тестовую запись Account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
          Test.startTest();
        // Шаг 2: вызов тестируемого метода — МЕЖДУ startTest() и stopTest()
        String result = GreetingService.getGreeting(testAccount.Id);
        Test.stopTest();
           // Шаг 3: проверка — ПОСЛЕ stopTest()
        System.assertEquals('Hello, Test Account!', result);
    }
}
