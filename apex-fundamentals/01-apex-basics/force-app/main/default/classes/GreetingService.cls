public with sharing class GreetingService {
    public static String getGreeting(Id accountId) {
        // Шаг 1: SOQL-запрос — получить Account по Id, выбрать поле Name
        Account acc = [SELECT Name FROM Account WHERE Id = :accountId];
    
        // Шаг 2: собрать и вернуть строку с именем аккаунта
        return 'Hello, ' + acc.Name + '!';
    }
}
