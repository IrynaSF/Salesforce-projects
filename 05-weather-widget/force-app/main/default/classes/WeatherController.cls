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
        
        // Step 1: get the API key and the default city from Custom Metadata
        Weather_Setting__mdt setting = [SELECT Api_Key__c, Default_City__c FROM Weather_Setting__mdt LIMIT 1];
        
        // Step 2: SOQL query that gets the current user with their City field
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
        // Step 3: build the endpoint
    String encodedCity = EncodingUtil.urlEncode(city, 'UTF-8');
   String endpoint = 'callout:OpenWeatherMap_Auth/data/2.5/weather?q=' + encodedCity + '&appid=' + setting.Api_Key__c + '&units=metric';
        
        // Step 4: create and send the HTTP request
        HttpRequest req = new HttpRequest();// create an empty "envelope" for the future request, nothing is filled in yet.
        req.setEndpoint(endpoint);// put the address into the envelope (the string built in Step 3).
        req.setMethod('GET');// set the request type: 'GET' means "just get data" without sending anything to the server.

        Http http = new Http();// create a separate object that can actually send requests to the internet (HttpRequest itself can't, it only "holds" the data).
        HttpResponse res = http.send(req);// this is where the network call happens: the filled req goes to the http object, which calls the OpenWeatherMap server, waits for the reply and puts the result (status code + JSON text) into the new res variable.
        System.debug('RAW RESPONSE: ' + res.getBody());

        // Step 5: parse the JSON and return it
        WeatherResponseWrapper result = (WeatherResponseWrapper) JSON.deserialize(res.getBody(), WeatherResponseWrapper.class);
      
        result.iconUrl = iconMap.get(result.weather[0].main);
        result.windIconUrl = iconMap.get('Wind');

return result;
           
    }
}
