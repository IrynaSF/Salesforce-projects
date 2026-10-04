trigger ChildTrigger on Child__c (before insert) {
    ChildEmplManagerTriggerHandler.renameChildren(Trigger.new);
}
// this method needs the records being created right now, because its job is to change their fields (Name).
// Without Trigger.new the method has no way to know which records to change: it receives them as a parameter and works with them.
