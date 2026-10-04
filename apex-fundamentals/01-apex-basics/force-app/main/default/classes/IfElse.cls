public with sharing class IfElse {
    public static void checkLeadStatus(Id leadId){
        List<Lead> lead = [
            SELECT Id, LastName, Company, Status 
            FROM Lead
            WHERE Id = :leadId // find a specific Lead
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










// Task 1: if/else
// Write a method checkLeadStatus(Id leadId):
// SOQL: find the Lead by Id, select the Status field
// Use if/else to check:
// if Status == 'Open - Not Contacted' → System.debug('Lead needs attention!')
// if Status == 'Working - Contacted' → System.debug('Lead is being worked')
// otherwise → System.debug('Lead is closed')
