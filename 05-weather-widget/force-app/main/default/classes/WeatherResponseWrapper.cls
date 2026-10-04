global class WeatherResponseWrapper {

    @AuraEnabled global List<Weather> weather;
    @AuraEnabled global Main main;
    @AuraEnabled global Wind wind;
    @AuraEnabled global String name;
    @AuraEnabled global String iconUrl;
    @AuraEnabled global String windIconUrl;
    @AuraEnabled global Sys sys; //sys (маленькими буквами, в начале строки)  обязано остаться именно sys, потому что именно оно "смотрит" на ключ "sys" в JSON.

    global class Weather {
        @AuraEnabled global Integer id;
        @AuraEnabled global String main;
        @AuraEnabled global String description;
        @AuraEnabled global String icon;
    }

    global class Main {
        @AuraEnabled global Decimal temp;
        @AuraEnabled global Decimal feels_like;
        @AuraEnabled global Integer humidity;
    }

    global class Wind {
        @AuraEnabled global Decimal speed;
    }

    global class Sys {
        @AuraEnabled global      String country;
    }
}
