import { LightningElement,track } from 'lwc';
import findAccount from '@salesforce/apex/accountController.findAccount';
export default class AccountLWC extends LightningElement {
  
    //@track status is the variable holding the text shown on screen.
    // it's like "turning on notifications" for LWC: "if this variable changes, re-render right away"
    // Why it starts empty
// Before the button is clicked, status is empty, so nothing is shown under the button.
// After the click, inside .then() or .catch() we write text into it
//  (e.g. 'Found: Dickenson plc'), and thanks to @track the screen shows that text automatically.
    @track status;// Variable with an initial value

   handleClick(){// This method runs when the user clicks the button in the HTML (because we wrote onclick={handleClick}).
   // Here we call the Apex method we wrote earlier. It goes to the Salesforce server, runs the SOQL query (looks for 'Dickenson plc'),
   // // and returns the result, not immediately but through a Promise
   console.log('Button clicked, calling Apex...');
    findAccount()
   
    .then(result => { console.log('Promise resolved, result:', result);
         this.status = 'Found:' + result.Name })// this block runs if the method found the account (i.e. didn't throw)
    
         .catch(error => {  console.log('Promise rejected, error:', error);
        this.status = 'Account is not found' })// this block runs if the method didn't find the account
    
        .finally(() => { console.log('Search completed') });// This block always runs, regardless of success (.then()) or error (.catch()).
   }

}
// The dot before .then()/.catch()/.finally() means: "take what the previous step returned (a Promise) and call this method on it". Without the dot JS wouldn't know we want to call a Promise method,
//  rather than create something new.