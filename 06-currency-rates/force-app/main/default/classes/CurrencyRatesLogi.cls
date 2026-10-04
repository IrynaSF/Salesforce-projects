public with sharing class CurrencyRatesLogi {
       @AuraEnabled(cacheable=true)
    public static CurrencyDisplayWrapper getCurrencyRatesCalculator(String selectedCurrency) {

        //Шаг 1: получить последний лог
        List<Currency_Rate_Log__c>  lastLog = [SELECT Id, Base_Currency__c, Update_DateTime__c,Status__c FROM Currency_Rate_Log__c ORDER BY Update_DateTime__c DESC LIMIT 1];
        System.debug('Logs found: ' + lastLog.size());
        
        Currency_Rate_Log__c Log;

       // ifзапись лога существует работаем дальше, else вызываем метод постучаться на api
    if (!lastLog.isEmpty()) {
    Log = lastLog[0];
} else {
    CurrencyRatesService.getRates(selectedCurrency);
}


        //Шаг 2: получить все связанные курсы валют
        List<Currency_Rate__c> currencyRates = [SELECT Currency_Code__c, Rate__c FROM Currency_Rate__c WHERE Currency_Rate_Log__c = :Log.Id];
        System.debug('Found ' + currencyRates.size() + ' currency rates');

        //Шаг 3: создать Map с курсами валют
        Map<String, Decimal> rates = new Map<String, Decimal>();

        for (Currency_Rate__c rate : currencyRates) {
            rates.put(rate.Currency_Code__c, rate.Rate__c);
        }

        System.debug('Rates map size: ' + rates.size());

        //получить курс выбранной валюты (selectedCurrency) из ratesполучить курс выбранной валюты (selectedCurrency) из rates
        Decimal baseRate = rates.get(selectedCurrency);

        System.debug('Base rate for ' + selectedCurrency + ': ' + baseRate);

Map<String, Decimal> recalculatedRates = CurrencyRatesCalculator.getCalculalatorSelectedCurrency(rates, baseRate);//Вызываем наш третий метод. 

CurrencyDisplayWrapper result = new CurrencyDisplayWrapper();//Создаём объект-обёртку, в который будем складывать результаты

result.rates = recalculatedRates; //Сохраняем в объект-обёртку пересчитанные курсы валют
result.updateDateTime = Log.Update_DateTime__c; //Сохраняем в объект-обёртку дату и время последнего обновления курсов валют
result.status = Log.Status__c; //Сохраняем в объект-обёртку статус последнего обновления курсов валют

return result;

    }
}
