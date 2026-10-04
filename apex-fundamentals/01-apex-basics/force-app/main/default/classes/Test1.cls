public class Test1 {
    public static  List<Account>  getAllAccounts(){
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 10];
        return acc;
    }

}
//execute
//List<Account> result = Test1.getAllAccounts();
//System.debug(result);
//// Breakdown
//List<Account> result: we declare a new variable result that holds a list of accounts.
// The List<Account> type is required because Apex is strongly typed (unlike JS), so we must state explicitly what the variable holds.
// Test1.getAllAccounts(): here we call our method. Why it's written this way:
//Test1 is the name of the class that contains the method
//.getAllAccounts() calls the method with dot notation, like any method call
