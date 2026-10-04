public class UpdateChilds {
    public static void TestUpdateChilds(){
        
        List<Child__c> childs = [
            SELECT Id, Name
            FROM Child__c 
           
        ];
         System.debug('Befor update:' + childs );
//Меням имена в нашем списке
//Integer i = 0- инициализируем нашу переменную значением 0
//i < childs.size(); указываем условие
//i++ Увеличьте значение переменной на единицу
for (Integer i = 0; i < childs.size(); i++) {
    childs[i].Name = 'ChildTest' + (i + 1);
}
      
         update childs;
System.debug('After update:' + childs );
    
        }
    }
