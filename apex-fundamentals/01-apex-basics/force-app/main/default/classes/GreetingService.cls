public with sharing class GreetingService {
    public static String getGreeting(Id accountId) {
        // Step 1: SOQL query: get the Account by Id, select the Name field
        Account acc = [SELECT Name FROM Account WHERE Id = :accountId];
    
        // Step 2: build and return a string with the account name
        return 'Hello, ' + acc.Name + '!';
    }
}
