public with sharing class CurrencyRatesLogi {
       @AuraEnabled(cacheable=true)
    public static CurrencyDisplayWrapper getCurrencyRatesCalculator(String selectedCurrency) {

        // Step 1: get the latest log
        List<Currency_Rate_Log__c>  lastLog = [SELECT Id, Base_Currency__c, Update_DateTime__c,Status__c FROM Currency_Rate_Log__c ORDER BY Update_DateTime__c DESC LIMIT 1];
        System.debug('Logs found: ' + lastLog.size());
        
        Currency_Rate_Log__c Log;

       // if a log record exists, continue; otherwise call the method that hits the API
    if (!lastLog.isEmpty()) {
    Log = lastLog[0];
} else {
    CurrencyRatesService.getRates(selectedCurrency);
}


        // Step 2: get all related currency rates
        List<Currency_Rate__c> currencyRates = [SELECT Currency_Code__c, Rate__c FROM Currency_Rate__c WHERE Currency_Rate_Log__c = :Log.Id];
        System.debug('Found ' + currencyRates.size() + ' currency rates');

        // Step 3: build a Map of currency rates
        Map<String, Decimal> rates = new Map<String, Decimal>();

        for (Currency_Rate__c rate : currencyRates) {
            rates.put(rate.Currency_Code__c, rate.Rate__c);
        }

        System.debug('Rates map size: ' + rates.size());

        // get the rate of the selected currency (selectedCurrency) from rates
        Decimal baseRate = rates.get(selectedCurrency);

        System.debug('Base rate for ' + selectedCurrency + ': ' + baseRate);

Map<String, Decimal> recalculatedRates = CurrencyRatesCalculator.getCalculalatorSelectedCurrency(rates, baseRate);// Call our third method.

CurrencyDisplayWrapper result = new CurrencyDisplayWrapper();// Create the wrapper object that collects the results

result.rates = recalculatedRates; // Store the recalculated currency rates in the wrapper
result.updateDateTime = Log.Update_DateTime__c; // Store the date and time of the last rates update in the wrapper
result.status = Log.Status__c; // Store the status of the last rates update in the wrapper

return result;

    }
}
