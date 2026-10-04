public class OpportunityPipelineBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Найди Opportunity где:
        // CloseDate < TODAY (просрочена)
        // IsClosed = false (ещё не закрыта)
                   return Database.getQueryLocator(
 'SELECT Id, Name, CloseDate, StageName ' +
'FROM Opportunity ' +
'WHERE CloseDate < TODAY AND IsClosed = false'
     );
   
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        // Description = 'Overdue - Needs Attention'
        // update scope
            for(Opportunity opp : scope){
            opp.Description = 'Overdue - Needs Attention';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('OpportunityPipelineBatch finished!');
    }
}
