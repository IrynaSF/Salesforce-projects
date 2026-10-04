public with sharing class CurrencyRatesService {
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getRates(String baseCurrencyCode) { // The parameter is our base currency, passed in when the method is called.
        
        // Step 1: read the saved API key from Custom Metadata (needed to authenticate with the external service)
        Currency_Setting__mdt setting = [SELECT Api_Key__c FROM Currency_Setting__mdt LIMIT 1];

         System.debug('Api_Key__c found: ' + (setting != null));

         // Step 2: build the full request URL: Named Credential name + API version + key + path + selected currency
         String endpoint = 'callout:ExchangeRate_Auth/v6/' + setting.Api_Key__c + '/latest/' + baseCurrencyCode;
         
         System.debug('Endpoint: ' + endpoint);

        // Step 3: create a GET HTTP request, send it and get the server response (res)
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');       
        Http http = new Http();
        HttpResponse res = http.send(req);
      System.debug('Status Code: ' + res.getBody());
        System.debug('Status Code: ' + res.getStatusCode());
        System.debug('Status: ' + res.getStatus());

 // Step 4: turn the raw text response (JSON string) into an Apex data structure, a Map we can work with in code
 Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

 System.debug('Top-level keys: ' + body.keySet());
 
   // Step 5: go one level deeper and take only the part of the response with the rates (conversion_rates), not the whole response
Map<String, Object> conversionRates = (Map<String, Object>) body.get('conversion_rates');

System.debug('Number of currencies: ' + conversionRates.size());

// Steps 6-7: create a new, "clean" Map (rates) and fill it in a loop over all currencies
Map<String, Decimal> rates = new Map<String, Decimal>();
// Step 7: iterate over the keys and values of the source Map and fill the new Map
for (String currencyCode : conversionRates.keySet()) {
    Decimal rate = (Decimal) conversionRates.get(currencyCode);
    rates.put(currencyCode, rate);
}
System.debug('Rates map size: ' + rates.size());

// Step 8: create one "log" record (Currency_Rate_Log__c) with four fields (raw JSON, status, time, base currency)
// and save it right away (insert rateLog): this matters because we need this record's Id next
Currency_Rate_Log__c rateLog = new Currency_Rate_Log__c();

// Save the JSON response in the Response_JSON__c field
rateLog.Response_JSON__c = res.getBody(); 

// Save the response status in the Status__c field
rateLog.Status__c = (String)body.get('result'); 

// Save the request date and time in the Update_DateTime__c field
rateLog.Update_DateTime__c = System.now(); 

// Save the base currency in the Base_Currency__c field
rateLog.Base_Currency__c = baseCurrencyCode; 

insert rateLog;

System.debug('rateLog inserted, Id: ' + rateLog.Id);

// Steps 9-10: loop over rates again, but this time don't save right away; just prepare a list of future records
// in memory, each holding the currency code, the rate and a Lookup to the log just created
List<Currency_Rate__c> ratesToInsert = new List<Currency_Rate__c>();

// Step 10: iterate over the rates Map and create Currency_Rate__c objects
for (String currencyCode : rates.keySet()) {
    Decimal rateValue = rates.get(currencyCode);
    
    // Create a new Currency_Rate__c object and fill in its fields
    Currency_Rate__c newRate = new Currency_Rate__c();
    newRate.Currency_Code__c = currencyCode;
    newRate.Rate__c = rateValue;
    
   // Link the Currency_Rate__c object to the Currency_Rate_Log__c record
    newRate.Currency_Rate_Log__c = rateLog.Id; 
    
  // Add the object to the list for a later insert
    ratesToInsert.add(newRate);
}
  System.debug('Number of Currency_Rate__c to insert: ' + ratesToInsert.size());
   System.debug('Currency_Rate__c to insert: ' + ratesToInsert);
// Step 11: only now, when the list is complete, do one bulk insert to save the DML "budget"
if (!ratesToInsert.isEmpty()) {
    insert ratesToInsert;
   
}

System.debug('Returning rates map with ' + rates.size() + ' currencies');
// Step 12: return the Map of currency rates
       return rates;
    }
}
