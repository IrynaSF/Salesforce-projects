public with sharing class macroTaskController {
 @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsList(){

        List<Account> accList = [SELECT Id, Name FROM Account Limit 5];
    return accList;
    }

}
