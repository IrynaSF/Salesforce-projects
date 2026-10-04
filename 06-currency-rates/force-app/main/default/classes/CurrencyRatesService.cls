public with sharing class CurrencyRatesService {
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getRates(String baseCurrencyCode) { //Указываем параметр. Это наша  валюта, которая будет передаваться при вызове метода. 
        
        // Шаг 1 — идём в Custom Metadata и достаём сохранённый API-ключ (нужен для авторизации в внешнем сервисе)
        Currency_Setting__mdt setting = [SELECT Api_Key__c FROM Currency_Setting__mdt LIMIT 1];

         System.debug('Api_Key__c found: ' + (setting != null));

         // Шаг 2 — "склеиваем" полный адрес запроса: имя Named Credential + версия API + сам ключ + путь + выбранная валюта
         String endpoint = 'callout:ExchangeRate_Auth/v6/' + setting.Api_Key__c + '/latest/' + baseCurrencyCode;
         
         System.debug('Endpoint: ' + endpoint);

        // Шаг 3 — создаём HTTP-запрос методом GET, отправляем его, получаем ответ от сервера (res)
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');       
        Http http = new Http();
        HttpResponse res = http.send(req);
      System.debug('Status Code: ' + res.getBody());
        System.debug('Status Code: ' + res.getStatusCode());
        System.debug('Status: ' + res.getStatus());

 // Шаг 4 — превращаем "сырой" текстовый ответ (JSON-строку) в структуру данных Apex — Map, с которой можно работать программно
 Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

 System.debug('Top-level keys: ' + body.keySet());
 
   //Шаг 5 — "спускаемся" на один уровень глубже — достаём именно ту часть ответа, где лежат курсы валют (conversion_rates), а не весь ответ целиком
Map<String, Object> conversionRates = (Map<String, Object>) body.get('conversion_rates');

System.debug('Number of currencies: ' + conversionRates.size());

//Шаг 6-7 — создаём новую, "чистую" Map (rates) и заполняем её циклом, проходя по всем валютам
Map<String, Decimal> rates = new Map<String, Decimal>();
// Шаг 7: Итерируемся по ключам и значениям исходной Map и заполняем новую Map
for (String currencyCode : conversionRates.keySet()) {
    Decimal rate = (Decimal) conversionRates.get(currencyCode);
    rates.put(currencyCode, rate);
}
System.debug('Rates map size: ' + rates.size());

// Шаг 8 — создаём одну запись-"журнал" (Currency_Rate_Log__c) с четырьмя полями (сырой JSON, статус, время, базовая валюта)
// и сразу сохраняем её (insert rateLog) — это важно, потому что дальше нам нужен Id этой записи
Currency_Rate_Log__c rateLog = new Currency_Rate_Log__c();

// Сохраняем JSON-ответ в поле Response_JSON__c
rateLog.Response_JSON__c = res.getBody(); 

// Сохраняем статус ответа в поле Status__c
rateLog.Status__c = (String)body.get('result'); 

// Сохраняем дату и время запроса в поле Update_DateTime__c
rateLog.Update_DateTime__c = System.now(); 

// Сохраняем базовую валюту в поле Base_Currency__c
rateLog.Base_Currency__c = baseCurrencyCode; 

insert rateLog;

System.debug('rateLog inserted, Id: ' + rateLog.Id);

//Шаг 9-10 — проходим циклом по rates ещё раз, но на этот раз не сохраняем сразу, а просто готовит список будущих записей
// в памяти — каждая содержит код валюты, курс, и ссылку (Lookup) на только что созданный лог
List<Currency_Rate__c> ratesToInsert = new List<Currency_Rate__c>();

// Шаг 10: Итерируемся по Map курсов валют и создаем объекты Currency_Rate__c
for (String currencyCode : rates.keySet()) {
    Decimal rateValue = rates.get(currencyCode);
    
    // Создаем новый объект Currency_Rate__c и заполняем его поля
    Currency_Rate__c newRate = new Currency_Rate__c();
    newRate.Currency_Code__c = currencyCode;
    newRate.Rate__c = rateValue;
    
   // Связываем объект Currency_Rate__c с записью Currency_Rate_Log__c
    newRate.Currency_Rate_Log__c = rateLog.Id; 
    
  // Добавляем объект в список для последующей вставки
    ratesToInsert.add(newRate);
}
  System.debug('Number of Currency_Rate__c to insert: ' + ratesToInsert.size());
   System.debug('Currency_Rate__c to insert: ' + ratesToInsert);
//Шаг 11 — только теперь, когда список полностью готов, делаем одну массовую вставку — экономим "бюджет" DML-операций
if (!ratesToInsert.isEmpty()) {
    insert ratesToInsert;
   
}

System.debug('Returning rates map with ' + rates.size() + ' currencies');
// Шаг 12: Возвращаем Map с курсами валют
       return rates;
    }
}
