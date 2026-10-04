public with sharing class InvoiceController {
    
    public Opportunity opp { get; set; }
    public Contact primaryContact { get; set; }
    public Organization myCompany { get; set; }
    public List<OpportunityLineItem> products { get; set; }
    public Decimal totalAmount { get; set; }

    public InvoiceController(ApexPages.StandardController stdController) {
        Id oppId = stdController.getId();
        
       
        if (Schema.sObjectType.Organization.isAccessible()) {
            this.myCompany = [
                SELECT Name, Street, City, State, PostalCode, Country, Phone 
                FROM Organization 
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        }
        
        
        if (Schema.sObjectType.Opportunity.isAccessible()) {
            this.opp = [
                SELECT Id, Name, Invoice_Number__c, Amount, CloseDate, Owner.Name
                FROM Opportunity 
                WHERE Id = :oppId
                WITH SECURITY_ENFORCED
            ];
        }
        
        if (Schema.sObjectType.OpportunityContactRole.isAccessible()) {
            List<OpportunityContactRole> roles = [
                SELECT Contact.Id, Contact.Name, Contact.Email, Contact.Phone,
                       Contact.MailingStreet, Contact.MailingCity, 
                       Contact.MailingState, Contact.MailingPostalCode,
                       Contact.Account.Name
                FROM OpportunityContactRole 
                WHERE OpportunityId = :oppId 
                AND IsPrimary = true 
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            if (!roles.isEmpty()) {
                this.primaryContact = roles[0].Contact;
            }
        }
        
       
        if (Schema.sObjectType.OpportunityLineItem.isAccessible()) {
            this.products = [
                SELECT Id, PricebookEntry.Product2.Name, Quantity, UnitPrice, TotalPrice
                FROM OpportunityLineItem
                WHERE OpportunityId = :oppId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate ASC
            ];
            
            
            this.totalAmount = 0;
            for (OpportunityLineItem item : this.products) {
                this.totalAmount += item.TotalPrice;
            }
        }
    }
}
