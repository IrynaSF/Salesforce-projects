public class globalSearch {
    public static void getglobalSearch(String keyword){
        List<List<SObject>> result =[
            FIND : keyword
            IN ALL FIELDS
            RETURNING
            Account(Id, Name),
            Contact(Id, FirstName, LastName),
            Opportunity(Id, Name, Amount)
        ];
        
        System.debug('Accounts found:' + result[0]);
         System.debug('Contacts found:' + result[1]);
         System.debug('Opportunities found:' + result[2]);
    }

}
