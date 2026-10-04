public without sharing class WithoutSharingHandler {
    @AuraEnabled(cacheable=true)
public static List<Employee__c> getVisibleRecords() {
    return [SELECT Id, Name, Position__c, Salary__c FROM Employee__c];
}
   public static void debugVisibleRecords() {
        List<Employee__c> visible = [SELECT Id, Name FROM Employee__c];
        System.debug('WITHOUT  SHARING — visible entries: ' + visible.size());
        for (Employee__c emploees : visible) {
            System.debug(emploees.Name);
        }
    }
}
