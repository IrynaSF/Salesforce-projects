public with sharing class SalesDashboardController {
public class AccountWrapper {


    @AuraEnabled public String accountId;
    @AuraEnabled public String accountName;
    @AuraEnabled public Decimal totalClosedAmount;
    @AuraEnabled public List<Opportunity> opportunities;


    // the constructor takes a single account
    public AccountWrapper(Account acc) {
        this.accountId   = acc.Id;
        this.accountName = acc.Name;
        this.opportunities = acc.Opportunities;


        // sum the amounts in a loop
        Decimal total = 0;
        for ( Opportunity opp : acc.Opportunities) {
            if (opp.Amount != null) {
                total += opp.Amount;
            }
        }
        this.totalClosedAmount = total;
    }
}
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getAllAccountsData(){// Data for Tab mode
        List<AccountWrapper> result = new List<AccountWrapper>();
           // Accounts + their won deals with the required fields
        List<Account> accsWithOpps = [
            SELECT Id,Name,
                   (SELECT Id,Name, CreatedDate, CloseDate, Amount
                    FROM Opportunities
                    WHERE IsClosed = true AND IsWon = true)
            FROM Account WHERE Id IN
  ( SELECT AccountId
    FROM Opportunity
    WHERE IsClosed = true AND IsWon = true
  )];
  System.debug('Accounts with closed won opportunities: ' + accsWithOpps.size());
        for(Account acc : accsWithOpps){
            result.add(new AccountWrapper(acc));
           
        }
   
        return result;
   
    }
    @AuraEnabled(cacheable=true)
  public static  AccountWrapper getAccountData(Id accountId){// data for Account Page mode
 Account acc = [SELECT Id, Name,(SELECT Id, Name, CreatedDate, CloseDate, Amount
                    FROM Opportunities
                    WHERE IsClosed = true AND IsWon = true) FROM Account WHERE Id = :accountId LIMIT 1];
                     System.debug('Account data: ' + acc);
            return new AccountWrapper(acc);
         }
         @AuraEnabled(cacheable=true)
         public static List<OpportunityLineItem> getProducts(Id opportunityId){// products for the modal window
            List<OpportunityLineItem> products = [SELECT Id, Product2Id, Product2.Name, OpportunityId, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId];
                System.debug('Products for opportunity ' + opportunityId + ': ' + products.size());
            return products;    
           
         }
         
}
