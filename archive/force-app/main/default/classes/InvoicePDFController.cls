public with sharing class InvoicePDFController {
    
    private Opportunity opp;
    
    public String orgName { get; set; }
    public String orgStreet { get; set; }
    public String orgCity { get; set; }
    public String orgState { get; set; }
    public String orgPostalCode { get; set; }
    public Contact primaryContact { get; set; }
    public List<OpportunityLineItem> opportunityProducts { get; set; }
    
    public InvoicePDFController(ApexPages.StandardController std) {
        this.opp = (Opportunity)std.getRecord();
        
        this.opp = [
            SELECT Id, Name, Amount, Invoice_Number__c, Owner.Name
            FROM Opportunity 
            WHERE Id = :this.opp.Id
        ];
        
        loadOrganizationInfo();
        loadPrimaryContact();
        loadProducts();
    }
    
    private void loadOrganizationInfo() {
        Organization org = [
            SELECT Name, Street, City, State, PostalCode 
            FROM Organization 
            LIMIT 1
        ];
        this.orgName = org.Name;
        this.orgStreet = org.Street;
        this.orgCity = org.City;
        this.orgState = org.State;
        this.orgPostalCode = org.PostalCode;
    }
    
    private void loadPrimaryContact() {
        List<OpportunityContactRole> roles = [
            SELECT Contact.Name, Contact.Email, 
                   Contact.Phone, Contact.Account.Name
            FROM OpportunityContactRole
            WHERE OpportunityId = :this.opp.Id
            AND IsPrimary = true
            LIMIT 1
        ];
        if (!roles.isEmpty()) {
            this.primaryContact = roles[0].Contact;
        }
    }
    
    private void loadProducts() {
        this.opportunityProducts = [
            SELECT Product2.Name, Quantity, UnitPrice, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :this.opp.Id
            ORDER BY CreatedDate
        ];
    }
}
