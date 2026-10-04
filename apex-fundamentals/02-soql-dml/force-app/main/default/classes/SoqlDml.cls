//Часть 1 — вложенный SOQL запрос
//Пишем Apex метод getAccountsWithContacts(), который:
//Возвращает List<Account>
//SOQL запрос — выбираем Id, Name, и вложенный подзапрос который получает Id, LastName из связанных Contacts
//Ограниченипе LIMIT 5 (чтобы не перегружать вывод)
public class SoqlDml {
    public static void getAccountsWithContacts(){
        List<Account> accCont = [SELECT Id, Name, (SELECT Id, LastName FROM Contacts) FROM Account LIMIT 5];
 //Часть 2 — DML операция
//После получения списка Accounts — создай (через insert) новый Contact, привязанный к первому Account из списка (acc[0]).       
         Contact newCont = new Contact();
         newCont.LastName = 'Smith';
        newCont.AccountId = accCont[0].Id;
        insert newCont;
    }

}
//Почему именно acc[0]
//Наш список acc (результат SOQL) содержит несколько Account записей (до 5, согласно LIMIT 5).
// Чтобы привязать новый Contact к одному конкретному Account — нужно выбрать один элемент из списка. acc[0]
// означает "первый" элемент (помним — индексация начинается с 0).
