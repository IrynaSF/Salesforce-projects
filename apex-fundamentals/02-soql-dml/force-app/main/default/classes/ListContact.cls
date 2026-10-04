public class ListContact {
    public static void OneContact(){
        List<Contact> cont = new  List<Contact>();//Создаем пстой список
        Contact con = new Contact();// создаем один новый обьект
        con.LastName = 'Smith';
        cont.add(con); // добавляем этот контакт в список
        System.debug(cont);
    }

}
