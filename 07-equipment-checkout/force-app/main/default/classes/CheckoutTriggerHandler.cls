public with sharing class CheckoutTriggerHandler {
    
    public static void preventDoubleCheckout(List<Checkout__c> newCheckouts) {
       
        //Collect the Equipment Ids from the new checkouts.
        Set<Id> equipmentIds = new Set<Id>();
        for (Checkout__c  check : newCheckouts) {
            if ( check.Equipment__c != null ) {
                equipmentIds.add(check.Equipment__c);
            }
         
        }
        //Find checkouts of this equipment that have not been returned yet.
        List<Checkout__c> openCheckouts = [
            SELECT Id, Equipment__c
            FROM Checkout__c
            WHERE Equipment__c IN :equipmentIds 
            AND Return_Date__c = null
        ];
        //Collect the Ids of equipment that is already checked out.
        Set<Id> busyEquipmentIds = new Set<Id>();

        for (Checkout__c openCheckout : openCheckouts) {
            busyEquipmentIds.add(openCheckout.Equipment__c);
        }

        // Block new Checkouts for busy Equipment.

       for (Checkout__c newCheckout : newCheckouts) {
       if (busyEquipmentIds.contains(newCheckout.Equipment__c)) {
        newCheckout.addError('This equipment is already checked out and has not been returned yet.');
    }
}
    }
    //After a checkout is created, set the equipment status to In Use.
    public static void markEquipmentInUse(List<Checkout__c> newCheckouts) {

        Map<Id, Equipment__c> equipmentToUpdate = new Map<Id, Equipment__c>();
        
        for (Checkout__c newCheckout : newCheckouts) {
            if (newCheckout.Equipment__c != null) {
                //Build the equipment record in memory (Id + changed field only).
                Equipment__c equipment = new Equipment__c(
                    Id = newCheckout.Equipment__c,
                    Status__c = 'In Use'
                );
                equipmentToUpdate.put(equipment.Id, equipment);
            }

        }
            if (!equipmentToUpdate.isEmpty()) {
                update equipmentToUpdate.values();
}
               
            }
            //When Return_Date__c is filled in on update, set the equipment status back to Available.
    public static void markEquipmentAvailable(List<Checkout__c> newCheckouts, Map <Id, Checkout__c> oldMap) {
      
        Map<Id, Equipment__c> equipmentToUpdate = new Map<Id, Equipment__c>();

         for (Checkout__c newCheckout : newCheckouts){
          Checkout__c oldCheckout = oldMap.get(newCheckout.Id);
            if (oldCheckout.Return_Date__c == null && newCheckout.Return_Date__c != null && newCheckout.Equipment__c != null) {
                
                    Equipment__c equipment = new Equipment__c(
                        Id = newCheckout.Equipment__c,
                        Status__c = 'Available'
                    );
                    equipmentToUpdate.put(equipment.Id, equipment);
            }
            }
    
    if (!equipmentToUpdate.isEmpty()) {
        update equipmentToUpdate.values();
    }
    }

    }