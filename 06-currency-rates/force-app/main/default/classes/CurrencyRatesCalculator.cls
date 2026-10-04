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

    //  Create a new map for the recalculated results
Map<String, Decimal> recalculatedRates = new Map<String, Decimal>();


    //  Loop over the keys (currency codes) of the source map
    for (String currencyCode : rates.keySet()) {

        Decimal originalRate = rates.get(currencyCode); //  Get the original currency rate from the source map
        
        // Calculate using the formula
        Decimal newRate = (originalRate / baseRate).setScale(5);
        
        //  Put the result into the new map
        recalculatedRates.put(currencyCode, newRate);
    }
    return recalculatedRates;
}

/// Calendar.

public static Currency_Rate_Log__c  getLogCalendar (String isoDate) {

   // We receive the date as a string; Date.valueOf() turns it into a real Apex Date, because SOQL compares dates, not strings.
    Date selectedDate = Date.valueOf(isoDate);

    // The first SOQL gets the Currency_Rate_Log__c record itself for the requested date:
    List<Currency_Rate_Log__c> logs = [
        SELECT Id, Base_Currency__c, Update_DateTime__c, Status__c,
        (SELECT Currency_Code__c, Rate__c FROM Currency_Rates__r)
        FROM Currency_Rate_Log__c
        WHERE DAY_ONLY(Update_DateTime__c) = :selectedDate
        LIMIT 1
    ];
    if (!logs.isEmpty()) {
        return logs[0]; // return the found record
    } else {
        return null; // if no record is found, return null
    }
}
@AuraEnabled(cacheable=true)
    public static CurrencyDisplayWrapper  sendLogToLWC (String isoDate, String selectedCurrency) {

    // Create the wrapper object. If there are logs, we put them here. If not, it stays empty. The data goes to the LWC from here.
    CurrencyDisplayWrapper result = new CurrencyDisplayWrapper();

    Currency_Rate_Log__c log = getLogCalendar(isoDate);//  Get the log record for the selected date

    // One more check.
    if (log == null) {
    return result;
}

// these are the rates as stored in the database, i.e. each currency's rate against the log's original base currency (the one used for the API call that day, e.g. USD)
    Map<String, Decimal> rates = new Map<String, Decimal>();

    for (Currency_Rate__c rate : log.Currency_Rates__r) {
        rates.put(rate.Currency_Code__c, rate.Rate__c);
    }

    Decimal baseRate = rates.get(selectedCurrency);

    // these are the new, recalculated rates against the currency selected by the user (selectedCurrency), i.e. different numbers calculated as originalRate / baseRate
    Map<String, Decimal> recalculatedRates = getCalculalatorSelectedCurrency(rates, baseRate);

    result.rates = recalculatedRates;
    result.updateDateTime = log.Update_DateTime__c;
    result.status = log.Status__c;

    return result;

}
}
