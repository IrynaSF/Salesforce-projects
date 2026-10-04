public with sharing class SalesDashboardController {
public class AccountWrapper {


    @AuraEnabled public String accountId;
    @AuraEnabled public String accountName;
    @AuraEnabled public Decimal totalClosedAmount;
    @AuraEnabled public List<Opportunity> opportunities;


    // конструктор принимает один аккаунт
    public AccountWrapper(Account acc) {
        this.accountId   = acc.Id;
        this.accountName = acc.Name;
        this.opportunities = acc.Opportunities;


        // считаем сумму в цикле
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
    public static List<AccountWrapper> getAllAccountsData(){//Данные для Tab режима
        List<AccountWrapper> result = new List<AccountWrapper>();
           // Аккаунты + их закрытые сделки с нужными полями
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
  public static  AccountWrapper getAccountData(Id accountId){//данные для Account Page режима
 Account acc = [SELECT Id, Name,(SELECT Id, Name, CreatedDate, CloseDate, Amount
                    FROM Opportunities
                    WHERE IsClosed = true AND IsWon = true) FROM Account WHERE Id = :accountId LIMIT 1];
                     System.debug('Account data: ' + acc);
            return new AccountWrapper(acc);
         }
         @AuraEnabled(cacheable=true)
         public static List<OpportunityLineItem> getProducts(Id opportunityId){//товары для модального окна
            List<OpportunityLineItem> products = [SELECT Id, Product2Id, Product2.Name, OpportunityId, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId];
                System.debug('Products for opportunity ' + opportunityId + ': ' + products.size());
            return products;    
           
         }
         
}
