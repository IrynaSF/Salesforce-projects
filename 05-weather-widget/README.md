# 05 · Weather Widget (REST API integration)

## Business scenario

Field sales reps plan visits and want to see **current weather for a city** directly on their Salesforce home page, without leaving the app. This was my first external REST integration from Apex.

## How it works

```
weatherWidget (LWC)
 └─ user types a city ─► @wire(getWeather, { cityInput: '$cityInput' })   reactive
      └─ WeatherController.getWeather(city)
           ├─ reads API key + default city from Custom Metadata (Weather_Setting__mdt)
           ├─ GET callout:OpenWeatherMap_Auth/data/2.5/weather?q=<city>&units=metric
           ├─ JSON.deserialize → WeatherResponseWrapper (typed)
           └─ maps the weather condition to an icon in Static Resources
```

The card shows city and country, temperature, humidity, wind speed and a weather description with a matching icon.

## Components

| Type | Name | Purpose |
|------|------|---------|
| Apex | `WeatherController` | Builds the request, performs the callout, parses the response, picks icons |
| Apex | `WeatherResponseWrapper` | Typed classes mirroring the OpenWeatherMap JSON (`weather[]`, `main`, `wind`, `sys`) |
| Apex | `WeatherMockResponse` | `HttpCalloutMock` returning a fixed JSON payload for tests |
| Apex | `WeatherControllerTest` | Tests the controller with `Test.setMock` |
| LWC | `weatherWidget` | City input and weather card |

## Org setup required

- **Named Credential** `OpenWeatherMap_Auth` → `https://api.openweathermap.org`
- **Custom Metadata Type** `Weather_Setting__mdt` with fields `Api_Key__c`, `Default_City__c` and one record holding your own API key
- Static Resources for icons: `weatherClear`, `weatherRain`, `weatherSnow`, `weatherClouds`, `weatherThunderstorm`, `weatherFog`, `weatherWind`, `weatherDefault`

> The API key is never hard-coded. It lives in a Custom Metadata record in the org and is not part of this repository.

## What I learned

- Apex HTTP callouts (`HttpRequest`, `Http`, `HttpResponse`) and Named Credentials
- Typed JSON deserialization into wrapper classes
- Keeping configuration (keys, defaults) in Custom Metadata instead of code
- Testing callouts with `HttpCalloutMock`
- Reactive `@wire` parameters in LWC
