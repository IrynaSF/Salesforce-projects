public with sharing class GenerateInvoiceAction {
    // the variables we actually use
    public Opportunity opp { get; set; }
    public List<OpportunityLineItem> lineItems { get; set; }
    public OpportunityContactRole primaryContact { get; set; }

    public GenerateInvoiceAction(ApexPages.StandardController stdController) {
        Id oppId = stdController.getId();

        // 1. Load everything about the Opportunity in one query
        this.opp = [SELECT Name, Amount, Invoice_Number__c, 
                    (SELECT PricebookEntry.Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItems)
                    FROM Opportunity WHERE Id = :oppId];

        // Put the product list into a variable for easy access on the page
        this.lineItems = opp.OpportunityLineItems;

        // 2. Find the primary contact
        List<OpportunityContactRole> contacts = [SELECT Contact.Name, Contact.Phone, Contact.Email, Opportunity.Account.Name 
                                                 FROM OpportunityContactRole 
                                                 WHERE OpportunityId = :oppId AND IsPrimary = true LIMIT 1];
        
        this.primaryContact = contacts.isEmpty() ? null : contacts[0];
    }
}
