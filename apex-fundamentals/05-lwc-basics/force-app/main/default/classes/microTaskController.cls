public with sharing class microTaskController {
    // The method returns the name of the first account it finds
    // Write String before getAccountName because we return the account name.
    @AuraEnabled(cacheable=true)
    public static String getAccountName(){

        // Run the SOQL query
List<Account> acclist = [SELECT Name FROM Account  LIMIT 1];
 return accList[0].Name;// return the account name: first element of the list via [0], the field via dot notation

    }
}
