// Task 1: SOQL with ORDER BY, LIMIT, OFFSET
// Write an Apex method getTopAccounts() that:
// Returns List<Account>
// SOQL query: select Id, Name, AnnualRevenue from Account
// Sort by AnnualRevenue descending (largest companies first)
// Take only 5 records (LIMIT)
// Skip the first 2 records (OFFSET), i.e. you get records 3 to 7 by ranking
public with sharing class Soql {
    public static List<Account> getTopAccounts() {
        List<Account> acc = [
            SELECT Id, Name, AnnualRevenue
             FROM Account 
              ORDER BY AnnualRevenue DESC
               LIMIT 5
               OFFSET 2
               ];
        System.debug('Top accounts: ' + acc);
 return acc;
    }
}
