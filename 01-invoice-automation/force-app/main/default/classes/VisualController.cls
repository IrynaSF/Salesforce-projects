public with sharing class VisualController {
    public Opportunity opp { get; set; }
    public Organization companyInfo { get; set; }
    public OpportunityContactRole primaryContact { get; set; }
    public List<OpportunityLineItem> lineItems { get; set; }
    public Date generationDate { get; set; }

    public VisualController(ApexPages.StandardController stdController) {
        Id oppId = stdController.getId();
        this.generationDate = Date.today();

        this.companyInfo = [SELECT Name, Street, City, State, PostalCode, Country 
                            FROM Organization LIMIT 1];

       this.opp = [SELECT Name, Invoice_Number__c, Amount, CloseDate, 
            OwnerId, Owner.Name
            FROM Opportunity WHERE Id = :oppId];

        List<OpportunityContactRole> contacts = [
            SELECT Contact.Name, Contact.Phone, Contact.Email, 
                   Contact.Account.Name, Contact.MailingStreet
            FROM OpportunityContactRole 
            WHERE OpportunityId = :oppId AND IsPrimary = true LIMIT 1
        ];
        if (!contacts.isEmpty()) this.primaryContact = contacts[0];

        this.lineItems = [SELECT PricebookEntry.Product2.Name, Quantity, 
                                 UnitPrice, TotalPrice 
                          FROM OpportunityLineItem 
                          WHERE OpportunityId = :oppId];
    }
}
