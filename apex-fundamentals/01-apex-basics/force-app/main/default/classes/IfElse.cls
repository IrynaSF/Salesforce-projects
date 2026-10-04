public with sharing class IfElse {
    public static void checkLeadStatus(Id leadId){
        List<Lead> lead = [
            SELECT Id, LastName, Company, Status 
            FROM Lead
            WHERE Id = :leadId //ищем конкретный Lead
        ];

        if(lead[0].Status == 'Open - Not Contacted'){
             System.debug('Lead needs attention!');
        }
        else if(lead[0].Status  == 'Working - Contacted'){
            System.debug('Lead is being worked');
        
        }else {
         System.debug('Lead is closed');
        }

    }
}










//Задание 1 — if/else
//Пишем метод checkLeadStatus(Id leadId):
//SOQL — ищем Lead по Id, вибираем поле Status
//Через if/else проверяем:
//если Status == 'Open - Not Contacted' → System.debug('Lead needs attention!')
//если Status == 'Working - Contacted' → System.debug('Lead is being worked')
//иначе → System.debug('Lead is closed')
