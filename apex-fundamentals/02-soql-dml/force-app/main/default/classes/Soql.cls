//Задание 1 — SOQL с ORDER BY, LIMIT, OFFSET
//Пишем Apex метод getTopAccounts(), который:
//Возвращает List<Account>
//SOQL запрос: выбираем Id, Name, AnnualRevenue из Account
//Сортируем по AnnualRevenue по убыванию (самые крупные компании сверху)
//Берем только 5 записей (LIMIT)
//ПропПропускаем  первые 2 записи (OFFSET) — то есть получишь записи с 3-й по 7-ю по рейтингу
public with sharing class Soql {
    public static List<Account> getTopAccounts() {
        List<Account> acc = [
            SELECT Id, Name, AnnualRevenue
             FROM Account 
              ORDER BY AnnualRevenue DESC
               LIMIT 5
               OFFSET 2
               ];
        System.debug('Top accounts: ' + acc);
 return acc;
    }
}
