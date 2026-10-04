public with sharing class TrainingController {

    @AuraEnabled(cacheable=true)

    // First method: retrieves the required information
    public static List<Training__c> getTrainings() {
        List<Training__c> train = [
            SELECT Id, Name,  Course_Name__c, Status__c, Completion_Date__c, Contact__c 
            FROM Training__c
            ORDER BY Name ASC
        ];
    return train;
    }

@AuraEnabled    
    public static void updateTrainingStatus(Id trainingId, String newStatus){

List<Training__c> updStatus = [
    SELECT Id FROM Training__c WHERE Id = :trainingId
];

// Assign a new value to the Status__c field of the found record
updStatus[0].Status__c = newStatus;

// Update the object's fields
update updStatus;

    }
}


//updStatus is the list (List<Training__c>) returned by our SOQL query. Even if one record is found, it is still inside a list.
//updStatus[0]: take the first (and only) element of the list, our specific Training__c object.
//.Status__c = newStatus: assign the newStatus parameter value (passed in from outside) to this object's Status__c field.
// Important: at this step the change exists only in memory (in updStatus); nothing has changed in the Salesforce database yet!







// In Salesforce all custom objects (the ones we create, unlike standard ones such as Account, Contact, Lead) automatically get the __c suffix in their API Name.
