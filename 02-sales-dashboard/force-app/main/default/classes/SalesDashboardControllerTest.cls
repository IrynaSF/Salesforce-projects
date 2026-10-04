@IsTest
public class SalesDashboardControllerTest {
    @TestSetup
    static void setupTestData() {


        Account acc = new Account(Name = 'Test Account');
        insert acc;


        Opportunity opp1 = new Opportunity
        (Name = 'Test Opp 1',
        AccountId = acc.Id,
         StageName = 'Closed Won',
          CloseDate = Date.today(),
          Amount = 1000);
        insert opp1;


        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;


        PricebookEntry pbe = new PricebookEntry
        (Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(),
        UnitPrice = 100, IsActive = true);
        insert pbe;


        OpportunityLineItem oli = new OpportunityLineItem
        (OpportunityId = opp1.Id, PricebookEntryId = pbe.Id, Quantity = 5, TotalPrice = 1000);
        insert oli;


    }  
    @isTest
static void testGetAllAccountsData() {
    Test.startTest();
        List<SalesDashboardController.AccountWrapper> accountsData = SalesDashboardController.getAllAccountsData();
    Test.stopTest();
        System.assertNotEquals(0, accountsData.size(), 'Should return at least one account');
        System.assertEquals('Test Account', accountsData[0].accountName, 'Account name should match');
        System.assertEquals(1000, accountsData[0].totalClosedAmount, 'Total closed amount should match');
        System.debug(accountsData[0].totalClosedAmount);
        System.assertEquals(1, accountsData[0].opportunities.size(), 'Should have one opportunity');
    }
    @isTest
    static void testGetAccountData() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    Test.startTest();
        SalesDashboardController.AccountWrapper accountData = SalesDashboardController.getAccountData(acc.Id);
    Test.stopTest();
        System.assertEquals('Test Account', accountData.accountName, 'Account name should match');
        System.assertEquals(1000, accountData.totalClosedAmount, 'Total closed amount should match');
        System.assertEquals(1, accountData.opportunities.size(), 'Should have one opportunity');
    }
    @isTest
    static void testGetProducts() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp 1' LIMIT 1];
    Test.startTest();
        List<OpportunityLineItem> products = SalesDashboardController.getProducts(opp.Id);
    Test.stopTest();
        System.assertEquals(1, products.size(), 'Should return one product');
        System.assertEquals('Test Product', products[0].Product2.Name, 'Product name should match');
        System.assertEquals(1000, products[0].TotalPrice, 'Total price should match');  
}
   
}
