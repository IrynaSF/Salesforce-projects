public with sharing class microTaskController {
    //Метод возвращает первое имя акаунта которое найдет
    //Перед getAccountName напиши String — потому что мы возвращаем имя аккаунта.
    @AuraEnabled(cacheable=true)
    public static String getAccountName(){

        //Выполняем SOQL запрос
List<Account> acclist = [SELECT Name FROM Account  LIMIT 1];
 return accList[0].Name;// ваозвращаем имя акаунта обращаясь к первому элементу из списка через [0], а к полю через точку

    }
}
