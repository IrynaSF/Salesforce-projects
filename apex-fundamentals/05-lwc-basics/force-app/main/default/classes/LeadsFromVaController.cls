// Task: LWC "Leads from Virginia" with a .then() chain
// Scenario: the user clicks "Load Virginia Leads"; the component calls Apex through a Promise chain,
// gets all leads from the state of Virginia and shows them on the page.

public with sharing class LeadsFromVaController {
   
    @AuraEnabled(cacheable=true)
    
   public static List<Lead> getVirginiaLeads() {
        
         List<Lead> leads = [SELECT Id, FirstName, LastName, State, Status FROM Lead WHERE State IN ('VA', 'Virginia') ORDER BY LastName ASC ];// IN is used to catch both spellings
         System.debug('All leads from Virginia:' + leads );

         return leads;

    }
}
