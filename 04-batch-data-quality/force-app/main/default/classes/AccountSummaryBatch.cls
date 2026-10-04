public class AccountSummaryBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // SOQL — найди Account у которых
        // нет активных Opportunity (IsClosed = false)
      return Database.getQueryLocator(
    'SELECT Id, Name FROM Account WHERE Id NOT IN ' +
    '(SELECT AccountId FROM Opportunity WHERE IsClosed = false)'
);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // Для каждого Account:
        // Description = 'No Active Deals - Follow Up Needed'
        // update scope
        for(Account acc : scope){
            acc.Description = 'No Active Deals - Follow Up Need';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('AccountSummaryBatch finished!');
    }
}
