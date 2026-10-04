public with sharing class CurrencyRatesCalculator {


@AuraEnabled(cacheable=true)

public static List<String> getBaseCurrencyOptions() {
    List<String> options = new List<String>();
    List<Schema.PicklistEntry> entries = Currency_Rate_Log__c.Base_Currency__c.getDescribe().getPicklistValues();
    
    for (Schema.PicklistEntry entry : entries) {
        if (entry.isActive()) {
            options.add(entry.getValue());
        }
    }
    return options;
}


public static Map<String, Decimal> getCalculalatorSelectedCurrency (Map<String, Decimal> rates,  Decimal baseRate){

    //  Создаем новую мапу для результатов пересчета
Map<String, Decimal> recalculatedRates = new Map<String, Decimal>();


    //  С помощью цикла перебираем ключи (коды валют) из исходной мапы
    for (String currencyCode : rates.keySet()) {

        Decimal originalRate = rates.get(currencyCode); //  Получаем исходный курс валюты из исходной мапы
        
        // Делаем расчет по  формуле
        Decimal newRate = (originalRate / baseRate).setScale(5);
        
        //  Вкладываем полученный результат в новую мапу
        recalculatedRates.put(currencyCode, newRate);
    }
    return recalculatedRates;
}

///Календарь. 

public static Currency_Rate_Log__c  getLogCalendar (String isoDate) {

   //Мы получаем дату как строчку, и с помощью Date.valueOf() эта строчка превращается в настоящий Apex-тип Date, потому что SOQL сравнивает даты, а не строки. 
    Date selectedDate = Date.valueOf(isoDate);

    //Первый SOQL — забирает саму запись Currency_Rate_Log__c за нужную дату:
    List<Currency_Rate_Log__c> logs = [
        SELECT Id, Base_Currency__c, Update_DateTime__c, Status__c,
        (SELECT Currency_Code__c, Rate__c FROM Currency_Rates__r)
        FROM Currency_Rate_Log__c
        WHERE DAY_ONLY(Update_DateTime__c) = :selectedDate
        LIMIT 1
    ];
    if (!logs.isEmpty()) {
        return logs[0]; // возвращаем найденную запись
    } else {
        return null; // если запись не найдена, возвращаем null
    }
}
@AuraEnabled(cacheable=true)
    public static CurrencyDisplayWrapper  sendLogToLWC (String isoDate, String selectedCurrency) {

    // Создаем объект-обертку Если логи есть, мы будем вкладывать их сюда.Если логов нет, он остается пустым, Отсюда информация передается LWC. 
    CurrencyDisplayWrapper result = new CurrencyDisplayWrapper();

    Currency_Rate_Log__c log = getLogCalendar(isoDate);//  Получаем запись лога за выбранную дату

    //Еще одна проверка. 
    if (log == null) {
    return result;
}

//это курсы как они есть в базе, то есть курс каждой валюты относительно исходной базовой валюты лога (той, что была указана при запросе к API в тот день, например, USD)
    Map<String, Decimal> rates = new Map<String, Decimal>();

    for (Currency_Rate__c rate : log.Currency_Rates__r) {
        rates.put(rate.Currency_Code__c, rate.Rate__c);
    }

    Decimal baseRate = rates.get(selectedCurrency);

    //это новые, пересчитанные курсы, но уже относительно валюты, которую выбрал пользователь (selectedCurrency) — то есть другие числа, посчитанные по формуле originalRate / baseRate
    Map<String, Decimal> recalculatedRates = getCalculalatorSelectedCurrency(rates, baseRate);

    result.rates = recalculatedRates;
    result.updateDateTime = log.Update_DateTime__c;
    result.status = log.Status__c;

    return result;

}
}
