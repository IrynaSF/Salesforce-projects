trigger OldNewTrigger on Opportunity (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        OldNewHandler.handlerBeforUpdate(Trigger.new, Trigger.old);
    }
}
