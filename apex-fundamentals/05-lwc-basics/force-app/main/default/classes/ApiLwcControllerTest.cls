@isTest
public class ApiLwcControllerTest {
@TestSetup
static void setupTestData() {
 insert new List<Account>
{     new Account(Name = 'TestAccountApi', Phone = '16449165', Industry = 'Banking'), 
    new Account(Name = 'TestAccountApi', Phone = '6464659498', Industry = 'Education') };
}
    @isTest
    static void testGetAccounts(){
     
        Test.startTest();
        List<Account> result = ApiLwcController.getAccounts();
        Test.stopTest();

        // 3. ПРОВЕРКА (Assert)
        // Проверяем, что список не пустой и содержит наши данные
        System.assertEquals(2, result.size(), 'The list of accounts must not be empty.');
        System.assertEquals('TestAccountApi', result[0].Name, 'Account name mismatch');
    }
}
