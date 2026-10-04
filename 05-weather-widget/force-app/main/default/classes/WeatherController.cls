global with sharing class WeatherController {

    @AuraEnabled(cacheable=true)
    global static WeatherResponseWrapper getWeather(String cityInput) {
        
Map<String, String> iconMap = new Map<String, String>{
    'Clear' => '/resource/weatherClear',
    'Rain' => '/resource/weatherRain',
    'Snow' => '/resource/weatherSnow',
    'Clouds' => '/resource/weatherClouds',
    'Thunderstorm' => '/resource/weatherThunderstorm',
    'SunRain' => '/resource/weatherSunRain',
    'Fog' => '/resource/weatherFog',
    'Wind' => '/resource/weatherWind',
    'Default' => '/resource/weatherDefault'
};
        
        // Шаг 1: получить API key и город по умолчанию из Custom Metadata
        Weather_Setting__mdt setting = [SELECT Api_Key__c, Default_City__c FROM Weather_Setting__mdt LIMIT 1];
        
        // Шаг 2:SOQL запрос, который получает текущего пользователя с его полем City 
       User currentUser = [SELECT City FROM User WHERE Id = :UserInfo.getUserId()];
       
       String city;
if (String.isNotBlank(cityInput)) {
    city = cityInput;
//} else if (currentUser != null && String.isNotBlank(currentUser.City)) {
  //  city = currentUser.City}
}else {
    city = setting.Default_City__c;
}
     System.debug('City to query: ' + city);   
        // Шаг 3: построить endpoint
    String encodedCity = EncodingUtil.urlEncode(city, 'UTF-8');
   String endpoint = 'callout:OpenWeatherMap_Auth/data/2.5/weather?q=' + encodedCity + '&appid=' + setting.Api_Key__c + '&units=metric';
        
        // Шаг 4: создать и отправить HTTP-запрос
        HttpRequest req = new HttpRequest();//создаём пустой "конверт" для будущего запроса, пока в нём ничего не заполнено.
        req.setEndpoint(endpoint);//кладём в этот конверт адрес (ту самую строку, что собрали на Шаге 3).
        req.setMethod('GET');//указываем тип запроса: 'GET' означает "просто получить данные", ничего не отправляя серверу взамен.

        Http http = new Http();//создаём отдельный объект, который умеет реально отправлять запросы в интернет (сам HttpRequest этого не умеет — он только "хранит" данные).
        HttpResponse res = http.send(req);//вот тут происходит сам сетевой запрос: передаём заполненный req объекту http, он реально идёт на сервер OpenWeatherMap, ждёт ответа, и кладёт результат (статус-код + JSON-текст) в новую переменную res.
        System.debug('RAW RESPONSE: ' + res.getBody());

        // Шаг 5: распарсить JSON и вернуть
        WeatherResponseWrapper result = (WeatherResponseWrapper) JSON.deserialize(res.getBody(), WeatherResponseWrapper.class);
      
        result.iconUrl = iconMap.get(result.weather[0].main);
        result.windIconUrl = iconMap.get('Wind');

return result;
           
    }
}
