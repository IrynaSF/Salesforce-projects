//Задание — LWC компонент "Leads from Virginia" с цепочкой .then()
//Сценарий: Пользователь нажимает кнопку "Load Virginia Leads" — компонент через Promise-цепочку вызывает Apex,
// получает всех лидов из штата Вирджиния, и показывает их список на странице.

public with sharing class LeadsFromVaController {
   
    @AuraEnabled(cacheable=true)
    
   public static List<Lead> getVirginiaLeads() {
        
         List<Lead> leads = [SELECT Id, FirstName, LastName, State, Status FROM Lead WHERE State IN ('VA', 'Virginia') ORDER BY LastName ASC ];//IN испольщзуем чтобы поймать все варианты
         System.debug('All leads from Virginia:' + leads );

         return leads;

    }
}
