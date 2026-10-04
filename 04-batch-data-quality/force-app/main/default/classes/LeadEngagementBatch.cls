public class LeadEngagementBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Status FROM Lead ' +
            'WHERE Status = \'Open - Not Contacted\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        for(Lead lead : scope) {
            lead.Status = 'Working - Contacted';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('LeadEngagementBatch finished!');
    }
}
