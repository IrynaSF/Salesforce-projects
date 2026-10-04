@isTest
public class WireLwcControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create an Account
        Account acc = new Account(Name = 'TestAccountWire', Phone = '16449165', Industry = 'Banking');
        insert acc;
        // Create related Opportunities (since getOpportunities looks for exactly these)
        insert new List<Opportunity>{
            new Opportunity(Name = 'Opp 1', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id),
            new Opportunity(Name = 'Opp 2', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id)
        };
    }
    @isTest
    static void testGetAccounts() {
        // Test for the method that gets accounts
        Test.startTest();
        List<Account> result = WireLwcController.getAccounts();
        Test.stopTest();
        System.assertEquals(1, result.size(), 'There should be 1 account');
    }
    @isTest
    static void testGetOpportunities() {
        // 1. Get the ID of the account created in setupTestData
        Account acc = [SELECT Id FROM Account LIMIT 1];
     
        // 2. Call the method
        Test.startTest();
        // Pass the real variable acc.Id, not a type declaration (Id accountId)
        List<Opportunity> result = WireLwcController.getOpportunities(acc.Id);
        Test.stopTest();
        // 3. CHECK (Assert)
        // We created 2 Opportunities for this account
        System.assertEquals(2, result.size(), 'The opportunity list should contain 2 records');
        System.assertEquals('Opp 1', result[0].Name, 'The first opportunity name does not match');
    }
}
