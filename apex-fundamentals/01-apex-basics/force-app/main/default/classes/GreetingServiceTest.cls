@isTest
private class GreetingServiceTest {
    @isTest
    static void testGetGreeting() {
        // Step 1: create a test Account record
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
          Test.startTest();
        // Step 2: call the method under test BETWEEN startTest() and stopTest()
        String result = GreetingService.getGreeting(testAccount.Id);
        Test.stopTest();
           // Step 3: check AFTER stopTest()
        System.assertEquals('Hello, Test Account!', result);
    }
}
