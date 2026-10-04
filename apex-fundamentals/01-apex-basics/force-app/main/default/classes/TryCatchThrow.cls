// Task 1: a simple try/catch
// Write a method findTrainingById(Id trainingId):
// inside try: a SOQL query that finds Training__c by Id
// If the list is empty, use throw to raise an AuraHandledException
// Inside catch: catch the exception and print it with System.debug
// Inside finally: System.debug('Search completed')

public with sharing class TryCatchThrow {
    public static void findTrainingById(Id trainingId) {
               
try {
    // main code
        List<Training__c> listTrain = [
            SELECT Id 
            FROM Training__c
            WHERE Id = :trainingId 
        ];

if (listTrain.isEmpty()) {
    throw new AuraHandledException('The list is empty');
}
} catch (Exception e) {
    // if something broke
      System.debug(e.getMessage());
} finally {
    // always runs
    System.debug('Search completed');
}

    }
}

 //Execute
//TryCatchThrow.findTrainingById(null);


//  Useful methods of the Exception class:
//***e.getMessage(): returns a short description of what went wrong.
//***e.getStackTraceString(): shows the exact line and call chain where the error happened.
//***e.getTypeName(): returns the error type (e.g. System.MathException).
