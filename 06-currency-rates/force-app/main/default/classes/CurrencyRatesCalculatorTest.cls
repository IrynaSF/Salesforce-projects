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
         
        Decimal baseRate = 1.0; // Assuming USD is the base currency
        
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

    // Step 2: save the record to the test database
        insert testLog;

            // Step 3: call the method under test, passing the date as a STRING, to get the log record for that date
   Currency_Rate_Log__c result = CurrencyRatesCalculator.getLogCalendar('2026-09-14');

       // Step 4: check that the method found anything at all (not null)
       System.assertNotEquals(null, result, 'Log should be found for this date');
      
    // Step 5: check that it found THE right record by comparing the base currency
    System.assertEquals(testLog.Base_Currency__c, result.Base_Currency__c, 'Base currency should match');
    
    }
    @isTest
static void testGetLogCalendar_NoLogFound() {

    // Call the method with a date that definitely has no record in the database
    Currency_Rate_Log__c result = CurrencyRatesCalculator.getLogCalendar('2026-08-20');

    // Check that the result is exactly null
    System.assertEquals(null, result, 'No log should be found for this date');
}

@isTest
static void testSendLogToLWC_LogFound() {

    // Step 1: create and insert a test log (as in the previous test)
    Currency_Rate_Log__c testLog = new Currency_Rate_Log__c(
        Base_Currency__c = 'USD',
        Update_DateTime__c = DateTime.newInstance(2026, 9, 10, 8, 0, 0),
        Status__c = 'Success'
    );
    insert testLog;

    // Step 2: create related currency rate records:
    // a list of Currency_Rate__c, each referencing testLog.Id through the Currency_Rate_Log__c field
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

    // Step 3: call the method under test with the same date as in Step 1,
    // plus the currency code the user "selected" (one of those from Step 2)
    CurrencyDisplayWrapper result = CurrencyRatesCalculator.sendLogToLWC('2026-09-10', 'EUR');

    // Step 4: check that the wrapper is filled in correctly
    System.assertNotEquals(null, result.rates, 'Wrapper rates map should not be null');
    System.assertEquals(1.0, result.rates.get('EUR'), 'EUR rate should match'); // compare with the manually calculated value
}

@isTest
static void testSendLogToLWC_NoLogFound() {

    // Call the method with a date that definitely has no log in the database
    CurrencyDisplayWrapper result = CurrencyRatesCalculator.sendLogToLWC('2026-08-20', 'USD');

    // Check that the wrapper itself is NOT null (in Apex we always create new CurrencyDisplayWrapper())
    System.assertNotEquals(null, result, 'Wrapper should not be null');

    // Check that its rates field is empty (null, because this branch doesn't fill it)
    System.assertEquals(null, result.rates, 'Rates map should be null when no log is found');
}
}
