public class ContactDepartmentBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Найди Contact где Department = null
        // (нет отдела — нужно проверить)
            return Database.getQueryLocator(
    'SELECT Id, LastName FROM Contact WHERE Department = null '
);
    
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        // Department = 'Needs Review'
        // update scope
          for(Contact con : scope){
            con.Department = 'Needs Review';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('ContactDepartmentBatch finished!');
    }
}
