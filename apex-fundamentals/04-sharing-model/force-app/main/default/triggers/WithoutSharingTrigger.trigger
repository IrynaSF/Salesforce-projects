trigger WithoutSharingTrigger on Employee__c (before insert) {
    WithoutSharingHandler.debugVisibleRecords();
}
