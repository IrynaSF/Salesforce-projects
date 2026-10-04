public class MenySoql {
    public static void QueryPractice(){
        List<Account> acc = [SELECT Id, Name FROM Account WHERE Industry = 'Consulting'];
         System.debug(acc);
        List<Lead> lead = [SELECT Id, LastName, Company FROM Lead WHERE Status = 'Open - Not Contacted'];
        System.debug(lead);
        List<Opportunity> opp = [SELECT Id, Name FROM  Opportunity WHERE Amount > 10000];
         System.debug(opp);
        List<Contact> cont =[SELECT Id, LastName, FirstName FROM Contact WHERE Email != null];
         System.debug(cont);
    }

}
