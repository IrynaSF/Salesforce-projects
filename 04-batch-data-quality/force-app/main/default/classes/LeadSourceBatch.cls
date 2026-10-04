public class LeadSourceBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Находим Lead где LeadSource = null
        return Database.getQueryLocator(
            'SELECT Id, Name, Status FROM Lead ' + 'WHERE LeadSource = null'

        );
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        // LeadSource = 'Other'
        // update scope
        //for — обновляет поле у каждой записи в памяти
//update — сохраняет все изменения в базу одним DML
        for(Lead lead : scope){
            lead.LeadSource = 'Other';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('LeadSourceBatch finished!');
    }
}
