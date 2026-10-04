public with sharing class OldNewHandler {
    // Logic for the Before Update event: changing fields on the record itself.
    public static void handlerBeforUpdate (List<Opportunity> newOpp,List<Opportunity> oldOpp){
        List<Task> tasksToCreate = new List<Task>();

   //  Loop by index to pair each old version of a record with its own new version
   for (Integer i = 0; i < oldOpp.size(); i++){
        Opportunity oldRecord = oldOpp[i];
        Opportunity newRecord = newOpp[i];

    // Check that Amount is not empty in both the old and the new version, and that it was below 2000 and became 2000 or more
        if(oldRecord.Amount != null  &&  newRecord.Amount != null  && oldRecord.Amount < 2000  &&  newRecord.Amount >= 2000 ){
            newRecord.StageName = 'Negotiation/Review';
            System.debug('Amount crossed 2000 threshold, Stage auto-set to Negotiation/Review');
            // Once the deal moves to the new stage, a task is created.
              Task alertTask = new Task(); // Create a new task.
                alertTask.Subject = 'Contact client — deal moved to Negotiation/Review (Amount ≥ 2000)';// Set the Subject: what the user sees as the task name in the Tasks list.
                alertTask.WhatId = newRecord.Id;//*
                tasksToCreate.add(alertTask);// Add our task.


        }
   }
     if (!tasksToCreate.isEmpty()) { // Make sure the task list is not empty.
    insert tasksToCreate;// Insert the tasks into the org.
}

    }



}
