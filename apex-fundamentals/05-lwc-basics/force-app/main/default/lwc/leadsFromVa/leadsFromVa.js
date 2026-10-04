import { LightningElement,track } from 'lwc';
import getVirginiaLeads from '@salesforce/apex/LeadsFromVaController.getVirginiaLeads'

export default class LeadsFromVa extends LightningElement {

    // Our variables
@track status = ''; // variable holding the text
@track leads = [];  // empty array that we fill ourselves inside the third .then() after Apex returns the result.
@track hasLeads = false; // a simple boolean (true/false) that controls the visibility of the lwc:if={hasLeads} block in the HTML.
// When the data is loaded we set this.hasLeads = true, and the HTML reacts to the change.

handleLoad() { // Method declaration: it runs when the user clicks the button (named this way because the HTML has onclick={handleLoad})

this.status = 'Loading...'; // show the user the process has started while we wait for the server (our <p>{status}</p> in the HTML)

// Call the Apex method: it goes to the server, runs the SOQL query and finds the Virginia leads. It returns a Promise, not the data itself but a "promise" that data will arrive later.
getVirginiaLeads()

// Receive the list of leads returned by Apex.
// Runs when Apex responds successfully. rawLeads is the list of leads returned by Apex (raw, unprocessed).
.then(rawLeads => { // rawLeads: raw leads
    console.log('Received leads:', rawLeads.length);// Log the number of leads received, just to check the data actually arrived.
    return rawLeads;
})

// Pass the list on
    .then(leads => { // called leads because we process them here
                // The second .then receives the data from the previous block
                // map() goes over each lead and creates a new object for it; the result goes into formattedLeads (a new array, the original leads is untouched).

                const formattedLeads = leads.map(lead => {
                    return {
                        //...lead: copy all existing fields of this lead (Id, FirstName, LastName, Status) with the spread operator
                        ...lead, 
                        fullName: `${lead.FirstName} ${lead.LastName}`//**add** a new field joining first and last name with a **template literal** (a string with `` and ${}).
                    };
                })
                
                // Pass the new, formatted list (with fullName added to each lead) on to the next .then()
                return formattedLeads;
        })

        // Receives formattedLeads, the formatted list of leads (with the added fullName field) returned by the second .then().
           .then(formattedLeads => {
            // Store the final list in @track leads: thanks to reactivity, the HTML updates automatically and for:each={leads} starts showing data.
    this.leads = formattedLeads;
    /// Set the "flag" to true: this shows the <template lwc:if={hasLeads}> block in the HTML, which was hidden before.
    this.hasLeads = true;
    // Update the status text: it now shows the exact number of leads found
    this.status = 'Found ' + formattedLeads.length + ' leads from Virginia'; 
})
      
        .catch(error => { this.status = 'Error: ' + error.body.message })
        .finally(() => {console.log('Loading completed') })
}

}
// Template literals are JavaScript syntax for strings enclosed in backticks (``) instead of single or double quotes.
// // They make working with strings much easier with two key features: embedded expressions and multi-line strings.