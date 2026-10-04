@isTest
private class CurrencyRatesServiceTest {

    // Nested stub class (mock) implementing HttpCalloutMock
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
      
    
        //  plug in the mock
        Test.setMock(HttpCalloutMock.class, new CurrencyRatesMock());
        
        Test.startTest();
          Map<String, Decimal> rates = CurrencyRatesService.getRates('USD');
        Test.stopTest();
        
        //  check the result with System.assertEquals
        System.assertEquals(0.92, rates.get('EUR'), 'The exchange rate EUR must be equal 0.92');

//  Inequality check (System.assertNotEquals)
System.assertNotEquals(null, rates, 'Map with rates should not be null');

//  Basic condition check (System.assert)
System.assert(rates.containsKey('EUR'), 'Map should contain currency EUR');
    }
}
