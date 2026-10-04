public class Test1 {
    public static  List<Account>  getAllAccounts(){
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 10];
        return acc;
    }

}
//execute
//List<Account> result = Test1.getAllAccounts();
//System.debug(result);
////Разбор
//List<Account> result — мы объявляем новую переменную result, которая будет хранить список аккаунтов. 
// Тип List<Account> нужен обязательно, потому что Apex — строго типизированный язык (в отличие от JS), и нужно явно сказать "что именно" будет лежать в этой переменной.
// Test1.getAllAccounts() — здесь мы вызываем наш метод. Разберём почему именно так:
//Test1 — это имя класса, где находится метод
//.getAllAccounts() — обращение к методу через точку, как обычный вызов метода
