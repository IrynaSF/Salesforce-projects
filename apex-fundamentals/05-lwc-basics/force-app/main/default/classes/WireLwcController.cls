public with sharing class WireLwcController {
     @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 10];
System.debug('Number of accounts found:'+ accounts.size());
 return accounts;
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(Id accountId) {
        if (accountId == null) return new List<Opportunity>();
List<Opportunity> oppList = [SELECT Id, Name, StageName, Amount 
                FROM Opportunity 
                WHERE AccountId = :accountId];
System.debug ('Opportunities found: ' + oppList.size());
        return oppList;
    }
}
