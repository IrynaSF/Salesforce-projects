public class DepartmentEmployee {
    public static void testDepartmentEmployee(){
        
     Department__c existingDept = [SELECT Id, Name FROM Department__c WHERE Name = 'IT' LIMIT 1];
        
        //2.Создаем список Employee (наш ребенек) из трех записей
       List<Employee__c> emploees = new  List<Employee__c> ();
        
        Employee__c emplPeter = new Employee__c();
         emplPeter.Name = 'Peter Wills';
         emplPeter.Position__c = 'Developer';
         emplPeter.Salary__c = 120000;
        ////привязки к Department через Lookup поле Department__c
        //так как у нас связь через Lookup между Employee__c и Department__c
         emplPeter.Department__c = existingDept.Id;
         emploees.add(emplPeter);
        
        Employee__c emplBetty = new Employee__c();
         emplBetty.Name = 'Betty Bound';
         emplBetty.Position__c = 'Manager';
         emplBetty.Salary__c = 10000;
         emplBetty.Department__c = existingDept.Id;
         emploees.add(emplBetty);
        
        ///Добавляем несуществующую запись, чтобы вызвать ошибку. 
        Employee__c emplMishel = new Employee__c();
         emplMishel.Name = 'Mishel Korby';
         emplMishel.Position__c = 'Designer';
         emplMishel.Salary__c = 900000;
         emplMishel.Department__c = '001000000000000AAA';//Не существующая запись. 
         emploees.add(emplMishel);
        
        //3.оборачиваем insert emploees в try/catch/finally
        try{
            //выполняем DML операцию
            insert emploees;
            System.debug('Employees after insert: ' + emploees);
        }catch(DmlException e){
            //Ловим ошибку и выводим описание в лог
            System.debug('Error inserting employees: ' + e.getMessage());
        }finally{
            System.debug('Insert completed');
        }      
        
            //4.Селектим родителя с ребенком
        
        List<Department__c> department = [
            SELECT Id, Name,
            (SELECT Id, Name,Position__c FROM Employees__r )
            FROM Department__c
            WHERE Id = :existingDept.Id
        ];
        System.debug(department);
        
        //Проверяем можем ли мы манипулировать с нашими данными
        emploees[0].Position__c = 'Senior Developer';
         update emploees[0];
    }
}
