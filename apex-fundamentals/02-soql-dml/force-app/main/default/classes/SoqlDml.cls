// Part 1: nested SOQL query
// Write an Apex method getAccountsWithContacts() that:
// Returns List<Account>
// SOQL query: select Id, Name and a nested subquery that gets Id, LastName of related Contacts
// LIMIT 5 (to keep the output small)
public class SoqlDml {
    public static void getAccountsWithContacts(){
        List<Account> accCont = [SELECT Id, Name, (SELECT Id, LastName FROM Contacts) FROM Account LIMIT 5];
 // Part 2: DML operation
// After getting the list of Accounts, create (insert) a new Contact linked to the first Account in the list (acc[0]).
         Contact newCont = new Contact();
         newCont.LastName = 'Smith';
        newCont.AccountId = accCont[0].Id;
        insert newCont;
    }

}
// Why acc[0]
// Our acc list (the SOQL result) contains several Account records (up to 5, per LIMIT 5).
// To link the new Contact to one specific Account we need to pick one element from the list. acc[0]
// means the "first" element (remember: indexing starts at 0).
