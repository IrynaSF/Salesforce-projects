import { LightningElement,track,wire } from 'lwc';
import getAccountName from '@salesforce/apex/microTaskController.getAccountName';

export default class MicroTask extends LightningElement {
    @track status = '';
    
    @wire(getAccountName)
accountName;

     handleLoad(){
        // Synchronous message to the browser console
        console.log('Message: the button was pressed');

        // Overall order:
//Promise.resolve(): create a resolved Promise
//.then(): goes to the Microtask Queue
// JS finishes the synchronous code (setTimeout is registered)
// Only then does JS take .then() from the queue and run it

        Promise.resolve().then(() => {
    this.status = this.accountName.data;
    console.log('The status has changed');
});

// Order
// JS sees setTimeout and hands it to the browser
// The browser runs the timer in the background
// JS keeps executing the rest of the code
// After 3 seconds the browser puts the function into the Callback Queue
// The Event Loop takes it from there, but only when the Call Stack and the Microtask Queue are empty
// Only then does console.log run
     setTimeout(() => {
            console.log('Background process completed');
        }, 3000);

     }
}


// Scenario: the component loads account data from the server.
// While loading it shows "Loading...". When the data arrives it shows the account name.