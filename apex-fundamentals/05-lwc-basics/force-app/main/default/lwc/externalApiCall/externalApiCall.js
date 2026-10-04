//@track makes LWC watch the variable and re-render the page automatically when it changes
import { LightningElement, track} from 'lwc';

export default class ExternalApiCall  extends LightningElement {

    // Our variables
 @track status;
 @track userData;
 @track hasData;

handleClick(){
this.status = 'Fetching data...';

fetch('https://jsonplaceholder.typicode.com/users/1')
    .then(response => response.json()) // response.json() returns a new Promise, because parsing JSON (turning raw response text into a JavaScript object) is also asynchronous,
    // and takes time. The arrow function response => response.json() returns the result automatically, and this new Promise is passed to the next .then() in the chain.
    // The second .then(data => {...}) waits for that Promise and receives the ready, parsed data in the data parameter.
    
    .then(data => {
        this.userData = data;// Store the received data in our @track variable userData
        this.hasData = true;// Set the "flag" to true: this shows the <template lwc:if={hasData}> block in the HTML
        this.status = 'Data loaded successfully!';
    })
    .catch(error => {
        this.status = 'Error: ' + error.message;
    })
    .finally(() => {
        console.log('Fetch completed');
    });

}
}
















// add the site as a Trusted Site
// Setup → search for CSP Trusted Sites
//New  CSP Trusted Sites
// Click "New Trusted URL" (top right of the table)
// Trusted Site Name, e.g. RestCountries
//Trusted Site URL — https://restcountries.com
// Check Active
// In the Context section, check Connect-src
//Save