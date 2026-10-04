public class DatabaseErrorHandling {
    public static void TestDatabaseErrorHandling(){
    
        Department__c newDept = [SELECT Id, Name FROM Department__c WHERE Name = 'HR' LIMIT 1];
        
        System.debug ('Befor insert:' + newDept);
        
        //Создаем список из двух записей. 
        List<Employee__c> empls = new  List<Employee__c> ();
        
        Employee__c emplRicher = new Employee__c();
        emplRicher.Name = 'Richer Test';
        emplRicher.Department__c =newDept.Id;
        empls.add(emplRicher);
        
        //С ошибкой. У кастомных объектов Name обязательно поле к заполнению .
        Employee__c emplMonica = new Employee__c();
        emplMonica.Department__c = newDept.Id;
        empls.add(emplMonica);
        
        //С ошибкой.Неверно указан департмент. 
        Employee__c emplBob = new Employee__c();
        emplBob.Name = 'Bob Test';
        emplBob.Department__c = '001000000000000AAA';
        empls.add(emplBob);
        
        try {
    insert empls;
    System.debug('After insert: ' + empls);
    } catch (DmlException e) {
    System.debug('Error inserting employees: ' + e.getMessage());
    }
        
        //из https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_database.htm
        Database.SaveResult[] checkList = Database.insert(empls, false);
        //// Перебор каждого полученного результата
        for (Database.SaveResult check : checkList){
            if (check.isSuccess()){
                // Операция прошла успешно, поэтому получаем ID обработанной записи
                System.debug('Successfully inserted employee. Employee__c ID: ' + check.getId());
                
            }else{
            // Операция завершилась неудачей, поэтому получаем все ошибки
            for(Database.Error err : check.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Account fields that affected this error: ' + err.getFields());
           
            }
        }
    }
    
}
}
