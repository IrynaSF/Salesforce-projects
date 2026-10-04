public class SimpleInvalidInsert {
    public static void testTooLongField(){
        
        // Добавляем Position__c уже к существующей записи. 
        Employee__c richer = [SELECT Id, Name, Position__c FROM Employee__c WHERE Name = 'Richer Test' LIMIT 1];
        
        //Строка больше 100 символов 
        richer.Position__c = 'This is a very long position title that definitely exceeds the one hundred character limit for this field in Salesforce';
        
        Database.SaveResult result = Database.update(richer, false);

     if (result.isSuccess()) {
    System.debug('Successfully updated. ID: ' + result.getId());
     } else {
    for (Database.Error err : result.getErrors()) {
        System.debug('Error: ' + err.getMessage());
    }
}
        
    }

}
