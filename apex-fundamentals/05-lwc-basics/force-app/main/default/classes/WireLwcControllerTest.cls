@isTest
public class WireLwcControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Создаем Аккаунт
        Account acc = new Account(Name = 'TestAccountWire', Phone = '16449165', Industry = 'Banking');
        insert acc;
        // Создаем связанные Opportunity (так как метод getOpportunities ищет именно их)
        insert new List<Opportunity>{
            new Opportunity(Name = 'Opp 1', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id),
            new Opportunity(Name = 'Opp 2', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id)
        };
    }
    @isTest
    static void testGetAccounts() {
        // Тест для метода получения аккаунтов
        Test.startTest();
        List<Account> result = WireLwcController.getAccounts();
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Должен быть 1 аккаунт');
    }
    @isTest
    static void testGetOpportunities() {
        // 1. Получаем ID созданного в setupTestData аккаунта
        Account acc = [SELECT Id FROM Account LIMIT 1];
     
        // 2. Вызываем метод
        Test.startTest();
        // Передаем реальную переменную acc.Id, а не объявление типа (Id accountId)
        List<Opportunity> result = WireLwcController.getOpportunities(acc.Id);
        Test.stopTest();
        // 3. ПРОВЕРКА (Assert)
        // Мы создали 2 Opportunity для этого аккаунта
        System.assertEquals(2, result.size(), 'Список возможностей должен содержать 2 записи');
        System.assertEquals('Opp 1', result[0].Name, 'Имя первой возможности не совпадает');
    }
}
