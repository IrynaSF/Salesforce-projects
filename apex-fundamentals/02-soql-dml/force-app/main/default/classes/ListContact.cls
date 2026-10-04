public class ListContact {
    public static void OneContact(){
        List<Contact> cont = new  List<Contact>();// Create an empty list
        Contact con = new Contact();// create one new object
        con.LastName = 'Smith';
        cont.add(con); // add this contact to the list
        System.debug(cont);
    }

}
