public with sharing class accountController {
    @AuraEnabled
    // the return type is Account because that is the data type the method returns
    public static Account findAccount() { 
        System.debug('Searching for account...');
        // Our SOQL query with a condition: the fields we need + the WHERE condition for the specific name
        // we need
        List<Account> acc = [SELECT Id, Name FROM Account WHERE Name ='Dickenson plc'];
         
        // Check whether our list is empty: if (acc.isEmpty()) { ... }
        //throw new AuraHandledException('Account is not found');
        // If the condition above is true (the list really is empty), execution is immediately
        // stopped and a special error with the text 'Account is not found' is "thrown".

        // The throw new AuraHandledException(...) construct does two things in sequence:
        //**new AuraHandledException('Error text'): we create (construct) a new error object (new)
        // in memory and put a clear message into it.
        //**throw: we take the object we just created and "throw" it
        // to stop code execution.
        // [0]; means the first element of the list; the task returns one account, so it's the first one anyway
        // indexing in Apex, as in JS, starts at 0, so the first element is [0], not [1]
System.debug('Result size: ' + acc.size());
        if (acc.isEmpty()){
            throw new AuraHandledException('Account is not found');
        }
         System.debug('Account name: ' + acc[0].Name);
            return acc[0];

    }
}
 
//** Key points about throw. Why: when Salesforce's built-in rules don't see an error,
// e.g. in our business logic a discount exceeds 50% or
// a field is filled in incorrectly. How it works: when Apex hits throw,
// it immediately stops the current method. What happens next:
// the error is either caught by a try-catch block or shown to the user on screen as
// a red message.

//** Why AuraHandledException is needed:
// When something goes wrong in Apex (e.g. the record wasn't found), we need to report
// it to the JavaScript side so the user sees a clear error rather than a "broken" page.
// A regular Apex Exception doesn't reach JS cleanly: JS only gets a generic
// "something went wrong" without the specific text.
// AuraHandledException is the only exception type that reliably
// passes the error text to the LWC side, where it can be caught with .catch() and
// shown to the user.






















/// Task: find an Account by name using a Promise
