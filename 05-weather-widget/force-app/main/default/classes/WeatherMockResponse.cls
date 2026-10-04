@isTest
global  class WeatherMockResponse implements HttpCalloutMock {
    global  HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"name":"London","main":{"temp":20.5,"humidity":50},"weather":[{"main":"Clear","description":"clear sky"}],"wind":{"speed":3.0},"sys":{"country":"GB"}}');
        return res;
    }
}
