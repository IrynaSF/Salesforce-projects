public class OpportunityAtRiskBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Find Opportunities where:
        // IsClosed = false
        // LastActivityDate < LAST_N_DAYS:30
        return Database.getQueryLocator(
 'SELECT Id, Name, CloseDate, LastActivityDate ' +
'FROM Opportunity ' +
'WHERE IsClosed = false ' +
'AND (LastActivityDate < LAST_N_DAYS:30 OR LastActivityDate = null)'
     );
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        // Description = 'At Risk'
        // update scope 
        for(Opportunity opp : scope){
            opp.Description = 'At Risk';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('OpportunityAtRiskBatch finished!');
    }
}
