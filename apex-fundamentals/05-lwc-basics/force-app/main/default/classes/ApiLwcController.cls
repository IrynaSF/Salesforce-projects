public with sharing class ApiLwcController {
   @AuraEnabled(cacheable=true)
   public static List<Account> getAccounts() {
    List<Account> accounts = [SELECT Id, Name,Phone,Industry  FROM Account LIMIT 10];
    System.debug('Number of accounts found:'+ accounts.size());
        return accounts;
    }   
    
}
