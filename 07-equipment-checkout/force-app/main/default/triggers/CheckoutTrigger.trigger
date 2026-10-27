 // Calls the handler methods: preventDoubleCheckout (before insert), markEquipmentInUse (after insert), markEquipmentAvailable (after update).
trigger CheckoutTrigger on Checkout__c (before insert, after insert, after update) {
    if (Trigger.isBefore && Trigger.isInsert) {
            CheckoutTriggerHandler.preventDoubleCheckout(Trigger.new);
          
        }

            if (Trigger.isAfter && Trigger.isInsert) {
        CheckoutTriggerHandler.markEquipmentInUse(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        CheckoutTriggerHandler.markEquipmentAvailable(Trigger.new, Trigger.oldMap);
    }
}