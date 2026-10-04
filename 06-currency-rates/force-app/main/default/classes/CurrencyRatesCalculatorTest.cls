@isTest
private  class CurrencyRatesCalculatorTest {
   @isTest
static void testGetBaseCurrencyOptions() {
        List<String> baseCurrencyOptions = CurrencyRatesCalculator.getBaseCurrencyOptions();
        System.assert(!baseCurrencyOptions.isEmpty(), 'Base currency options should not be empty');
    
    }
        
 @isTest
    static void testGetCalculalatorSelectedCurrency() {
        Map<String, Decimal> testRates = new Map<String, Decimal>();
        testRates.put('USD', 1.0);
        testRates.put('EUR', 0.85);
         
        Decimal baseRate = 1.0; // При условии, что USD является базовой валютой
        
        Map<String, Decimal> recalculatedRates = CurrencyRatesCalculator.getCalculalatorSelectedCurrency(testRates, baseRate);

        System.assertEquals(0.85, recalculatedRates.get('EUR'), 'EUR rate should be 0.85');
        
       
    }

    @isTest
    static void testGetLogCalendar() {
        // Create a test log record
        Currency_Rate_Log__c testLog = new Currency_Rate_Log__c(
            Base_Currency__c = 'USD',
            Update_DateTime__c = DateTime.newInstance(2026, 9, 14, 10, 0, 0),
            Status__c = 'Success'
        );

    // Шаг 2: сохраняем запись в тестовую базу данных
        insert testLog;

            // Шаг 3: вызываем метод, который тестируем, передав дату СТРОКОЙ, чтобы получить запись лога за эту дату
   Currency_Rate_Log__c result = CurrencyRatesCalculator.getLogCalendar('2026-09-14');

       // Шаг 4: проверяем, что метод вообще что-то нашёл (не null)
       System.assertNotEquals(null, result, 'Log should be found for this date');
      
    // Шаг 5: проверяем, что нашлась именно ТА запись — сверяем базовую валюту
    System.assertEquals(testLog.Base_Currency__c, result.Base_Currency__c, 'Base currency should match');
    
    }
    @isTest
static void testGetLogCalendar_NoLogFound() {

    // Вызываем метод с датой, на которую точно нет записи в базе
    Currency_Rate_Log__c result = CurrencyRatesCalculator.getLogCalendar('2026-08-20');

    // Проверяем, что результат — именно null
    System.assertEquals(null, result, 'No log should be found for this date');
}

@isTest
static void testSendLogToLWC_LogFound() {

    // Шаг 1: создаём и вставляем тестовый лог (как в предыдущем тесте)
    Currency_Rate_Log__c testLog = new Currency_Rate_Log__c(
        Base_Currency__c = 'USD',
        Update_DateTime__c = DateTime.newInstance(2026, 9, 10, 8, 0, 0),
        Status__c = 'Success'
    );
    insert testLog;

    // Шаг 2: создаём связанные записи курсов валют — 
    // список Currency_Rate__c, каждая ссылается на testLog.Id через поле Currency_Rate_Log__c
    List<Currency_Rate__c> testRates = new List<Currency_Rate__c>();
    testRates.add(new Currency_Rate__c(
        Currency_Code__c = 'EUR',
        Rate__c = 1.0,
        Currency_Rate_Log__c = testLog.Id
    ));
    testRates.add(new Currency_Rate__c(
        Currency_Code__c = 'GBP',
        Rate__c = 0.75,
        Currency_Rate_Log__c = testLog.Id
    ));
    insert testRates;

    // Шаг 3: вызываем тестируемый метод — та же дата, что в Шаге 1, 
    // плюс код валюты, которую "выбрал" пользователь (одна из тех, что в Шаге 2)
    CurrencyDisplayWrapper result = CurrencyRatesCalculator.sendLogToLWC('2026-09-10', 'EUR');

    // Шаг 4: проверяем, что wrapper заполнен как надо
    System.assertNotEquals(null, result.rates, 'Wrapper rates map should not be null');
    System.assertEquals(1.0, result.rates.get('EUR'), 'EUR rate should match'); // сравни с посчитанным вручную значением
}

@isTest
static void testSendLogToLWC_NoLogFound() {

    // Вызываем метод с датой, на которую точно нет лога в базе
    CurrencyDisplayWrapper result = CurrencyRatesCalculator.sendLogToLWC('2026-08-20', 'USD');

    // Проверяем, что сам wrapper НЕ null (мы же в Apex создаём new CurrencyDisplayWrapper() всегда)
    System.assertNotEquals(null, result, 'Wrapper should not be null');

    // Проверяем, что поле rates внутри него — пустое (null, потому что мы его не заполняли в этой ветке)
    System.assertEquals(null, result.rates, 'Rates map should be null when no log is found');
}
}
