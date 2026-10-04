public class ParentChilds {
    public static void testParent(){
        List<Parent__c> parent = [
            SELECT Id, Name, (SELECT Id, Name FROM Childs__r )
            FROM Parent__c
        ];
        System.debug(parent);
        //тип название переменной= new
        Child__c child = new Child__c();
        child.Name = 'Test';
        
        insert child;
        System.debug([SELECT Id, Name, (SELECT Id, Name FROM Childs__r )
            FROM Parent__c]);
         //создаем новую запись и потом селектим ее
         Child__c numbers = new Child__c();
        numbers.Quantity__c = 25;
        insert numbers;
        //селектим запись
        Child__c found = [SELECT Id, Name, Quantity__c FROM Child__c WHERE Id = :numbers.Id];
         System.debug(found);
    }

}
