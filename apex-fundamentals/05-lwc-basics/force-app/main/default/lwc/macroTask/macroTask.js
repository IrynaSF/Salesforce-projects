import { LightningElement, track, wire } from 'lwc';
import getAccountsList from '@salesforce/apex/macroTaskController.getAccountsList';

export default class MacroTask extends LightningElement {

    // Reactive variable: holds the status text.
    // Initial value is an empty string. When it changes, LWC automatically updates <p>{status}</p> on the page.
@track status = '';

// Reactive variable: holds the list of accounts.
//  Initial value is an empty array []. When data arrives, for:each in the HTML automatically
// renders the list on the page.
@track accounts = [];

// Tells LWC: "call the Apex method getAccountsList and put the result into the wiredAccounts variable".
@wire(getAccountsList) wiredAccounts;
    

     handleLoad(){
        // Synchronous message to the browser console
        console.log('Message: the button was pressed');

        // Changes the status variable and LWC instantly updates the text on the page.
        this.status = 'Loading accounts...'

  setTimeout(() => {

    this.status = 'Accounts loaded!'

    // Take the data that @wire has already loaded and put it into accounts.
    // As soon as accounts gets data, for:each in the HTML renders the list of accounts on
    //  the page.
    this.accounts = this.wiredAccounts.data;
            console.log('Background process completed');
        }, 3000);

     }
    } 
    // Order on the stack:
// The user clicks the button → handleLoad goes onto the Call Stack
// console.log runs: a message appears in the console
// this.status = 'Loading accounts...' runs: text appears on the page
// JS hits setTimeout: hands it to the browser and doesn't wait
// handleLoad finishes and is removed from the stack
// After 3 seconds the browser puts the callback into the Macrotask Queue
// The Event Loop picks it up and runs it: the list of accounts appears on the page