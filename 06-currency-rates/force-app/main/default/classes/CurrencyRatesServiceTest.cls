@isTest
private class CurrencyRatesServiceTest {

    // Вложенный класс-заглушка (мок), реализующий HttpCalloutMock
    private class CurrencyRatesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result":"success","base_code":"USD","conversion_rates":{"EUR":0.92,"GBP":0.79,"CNY":7.15}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetRates() {
      
    
        //  подключить мок
        Test.setMock(HttpCalloutMock.class, new CurrencyRatesMock());
        
        Test.startTest();
          Map<String, Decimal> rates = CurrencyRatesService.getRates('USD');
        Test.stopTest();
        
        //  проверить результат через System.assertEquals
        System.assertEquals(0.92, rates.get('EUR'), 'The exchange rate EUR must be equal 0.92');

//  Проверка на неравенство (System.assertNotEquals)
System.assertNotEquals(null, rates, 'Map with rates should not be null');

//  Базовая проверка условия (System.assert)
System.assert(rates.containsKey('EUR'), 'Map should contain currency EUR');
    }
}
