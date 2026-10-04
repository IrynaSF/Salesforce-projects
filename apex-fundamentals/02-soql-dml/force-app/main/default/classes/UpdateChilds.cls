public class UpdateChilds {
    public static void TestUpdateChilds(){
        
        List<Child__c> childs = [
            SELECT Id, Name
            FROM Child__c 
           
        ];
         System.debug('Befor update:' + childs );
// Change the names in our list
//Integer i = 0: initialize our variable with 0
//i < childs.size(): the loop condition
//i++: increase the variable by one
for (Integer i = 0; i < childs.size(); i++) {
    childs[i].Name = 'ChildTest' + (i + 1);
}
      
         update childs;
System.debug('After update:' + childs );
    
        }
    }
