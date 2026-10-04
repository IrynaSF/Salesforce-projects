trigger WithSharingTrigger on   Employee__c (before insert) {
    WithSharingHandler.debugVisibleRecords();

}
