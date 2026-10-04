@isTest
private class WeatherControllerTest {
    @isTest
    static void testGetWeather() {
        // Шаг 1: подключаем наш Mock вместо реального callout
        Test.setMock(HttpCalloutMock.class, new WeatherMockResponse());

        Test.startTest();
        // Шаг 2: вызываем сам метод контроллера
        WeatherResponseWrapper result = WeatherController.getWeather('London');
        Test.stopTest();

        // Шаг 3: проверки (Assert)
        System.assertEquals('London', result.name);
        System.assertEquals(20.5, result.main.temp);
        System.assertEquals('Clear', result.weather[0].main);
    }
}
