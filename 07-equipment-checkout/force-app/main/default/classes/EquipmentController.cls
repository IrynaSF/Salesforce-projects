public with sharing class EquipmentController {
   
    @AuraEnabled(cacheable=true)
     public static List<Equipment__c> getAvailableEquipment () {
        
        List<Equipment__c> availableEquipment = [
            SELECT Id, Name, Status__c, Type__c
            FROM Equipment__c
            WHERE Status__c = 'Available'
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
        return availableEquipment;
    }
  
     @AuraEnabled
    public static void checkoutEquipment(Id equipmentId, Id employeeId) { //Receives the Id of the equipment the user wants to take.
        try {
            Checkout__c checkout = new Checkout__c();
            checkout.Equipment__c = equipmentId;//Equipment Id from the parameters.
            checkout.Employee__c = employeeId; // Id of the employee who takes the equipment.
            insert checkout;
       
        } catch (DmlException e) {
            throw new AuraHandledException(
               e.getDmlMessage(0)
            );
        }
    }

    // Receives the Id of the checkout being returned
    @AuraEnabled

    public static void returnEquipment(Id checkoutId) {
        try{
    //In-memory record with the Id and the changed field only.
    Checkout__c checkout = new Checkout__c(
        Id = checkoutId,
        Return_Date__c = Date.today()
    );
    update checkout;

   }catch (DmlException e) {
    throw new AuraHandledException(
        e.getDmlMessage(0)
    );
   }
}

//Returns only the unreturned equipment of one employee.

@AuraEnabled(cacheable=true)

    public static List<Checkout__c> getMyCheckouts(Id contactId){
        //If no employee is passed, return an empty list right away.
         if (contactId == null){
            return new List<Checkout__c>(); //Return an empty list, not null.
         }
         //Find this employee's unreturned checkouts.
         return [
            SELECT Id, Equipment__r.Name
            FROM Checkout__c
            WHERE Employee__c = :contactId
            AND Return_Date__c = null
            WITH USER_MODE
            ORDER BY CreatedDate DESC
         ];

    }

    //All contacts (Name + Id), without checkouts
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){
        return [
            SELECT Id, Name
            FROM Contact
            WITH USER_MODE
            ORDER BY Name
        ];
    }
}
