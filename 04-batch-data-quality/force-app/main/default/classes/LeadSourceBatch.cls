public class LeadSourceBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Find Leads where LeadSource = null
        return Database.getQueryLocator(
            'SELECT Id, Name, Status FROM Lead ' + 'WHERE LeadSource = null'

        );
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        // LeadSource = 'Other'
        // update scope
        // for: updates the field on each record in memory
// update: saves all changes to the database with a single DML
        for(Lead lead : scope){
            lead.LeadSource = 'Other';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('LeadSourceBatch finished!');
    }
}
