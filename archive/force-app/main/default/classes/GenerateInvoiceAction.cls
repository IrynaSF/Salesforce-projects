public with sharing class GenerateInvoiceAction {
    // переменные, которые реально используем 
    public Opportunity opp { get; set; }
    public List<OpportunityLineItem> lineItems { get; set; }
    public OpportunityContactRole primaryContact { get; set; }

    public GenerateInvoiceAction(ApexPages.StandardController stdController) {
        Id oppId = stdController.getId();

        // 1. Загружаем всё об Opportunity одним запросом
        this.opp = [SELECT Name, Amount, Invoice_Number__c, 
                    (SELECT PricebookEntry.Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItems)
                    FROM Opportunity WHERE Id = :oppId];

        // Помещаем список товаров в переменную для удобства обращения на странице
        this.lineItems = opp.OpportunityLineItems;

        // 2. Ищем первичный контакт
        List<OpportunityContactRole> contacts = [SELECT Contact.Name, Contact.Phone, Contact.Email, Opportunity.Account.Name 
                                                 FROM OpportunityContactRole 
                                                 WHERE OpportunityId = :oppId AND IsPrimary = true LIMIT 1];
        
        this.primaryContact = contacts.isEmpty() ? null : contacts[0];
    }
}
