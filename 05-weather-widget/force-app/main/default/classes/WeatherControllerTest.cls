@isTest
private class WeatherControllerTest {
    @isTest
    static void testGetWeather() {
        // Step 1: plug in our Mock instead of the real callout
        Test.setMock(HttpCalloutMock.class, new WeatherMockResponse());

        Test.startTest();
        // Step 2: call the controller method itself
        WeatherResponseWrapper result = WeatherController.getWeather('London');
        Test.stopTest();

        // Step 3: checks (Assert)
        System.assertEquals('London', result.name);
        System.assertEquals(20.5, result.main.temp);
        System.assertEquals('Clear', result.weather[0].main);
    }
}
