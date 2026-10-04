public class createAndUpdateLead {
    public static void getcreateAndUpdateLead(){
        
        List<Lead> leads = new List<Lead>();
        
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.Company = 'Test Company';
        lead.Status = 'Open - Not Contacted';
        leads.add(lead);
        
        insert lead;
        System.debug('Leads insert:' + lead );
        
        lead.Status = 'Working - Contacted';
        update leads;
        
        System.debug('Leads update:' + lead );
      
    }

}
