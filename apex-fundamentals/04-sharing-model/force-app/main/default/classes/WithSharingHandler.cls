public with sharing class WithSharingHandler {
        @AuraEnabled(cacheable=true)
public static List<Employee__c> getSharedVisibleRecords() {
    return [SELECT Id, Name, Position__c, Salary__c FROM Employee__c];
}
     public static void debugVisibleRecords() {
        List<Employee__c> visible = [SELECT Id, Name FROM Employee__c];
        System.debug('WITH SHARING — visible entries: ' + visible.size());
        for (Employee__c emploees : visible) {
            System.debug(emploees.Name);
        }
    }
}
