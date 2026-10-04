global class CurrencyRatesScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {

      List<Currency_Rate_Log__c> lastLog = [
        SELECT Base_Currency__c 
        FROM Currency_Rate_Log__c
         ORDER BY Update_DateTime__c 
         DESC LIMIT 1
         ];

             if (!lastLog.isEmpty()) {
             getApi(lastLog[0] .Base_Currency__c);
    } else {
      
        getApi('USD');
    }
    
}

   @future(callout=true)
       public static void getApi (String baseCurrencyCode) {
             CurrencyRatesService.getRates(baseCurrencyCode);
        }
    }
