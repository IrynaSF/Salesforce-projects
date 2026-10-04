trigger ChildTrigger on Child__c (before insert) {
    ChildEmplManagerTriggerHandler.renameChildren(Trigger.new);
}
//этому методу обязательно нужны сами записи, которые сейчас создаются, потому что задача — изменить их поля (Name).
// Без Trigger.new метод физически не может знать, какие записи менять — он получает их как параметр и работает именно с ними.
