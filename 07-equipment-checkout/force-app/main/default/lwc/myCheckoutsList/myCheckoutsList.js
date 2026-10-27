//CHILD: shows all equipment currently checked out to the selected employee.
import { LightningElement, api, wire } from 'lwc';
import getMyCheckouts from '@salesforce/apex/EquipmentController.getMyCheckouts'; //Apex: unreturned checkouts of the selected contact.
import returnEquipment from '@salesforce/apex/EquipmentController.returnEquipment'; //Apex: returns the equipment.
import { refreshApex } from '@salesforce/apex';

export default class MyCheckoutsList extends LightningElement {
    @api contactId;//Public property: contact Id passed in from the parent.
    isLoading = false;//Loading flag
   
    @wire(getMyCheckouts, {contactId: '$contactId'}) myCheckouts;//The key (contactId) is the Apex parameter name.
//'$contactId' makes the wire reactive to the @api contactId property

// Lifecycle check: component inserted into the page
connectedCallback() {
    console.log('MyCheckoutsList connectedCallback: contactId =', this.contactId);
}

    get hasCheckouts(){
        return this.myCheckouts.data && this.myCheckouts.data.length > 0;
    }

      // "Return" button click
    async handleReturn(event) {
        // 1. Get the checkout Id stored on the button via data-id
        const returnCheckoutId = event.currentTarget.dataset.id;

        // 2. Show the spinner
        this.isLoading = true;

        try {
            // 3. Call Apex imperatively and wait for the result
            await returnEquipment({ checkoutId: returnCheckoutId });

            // 4. Refresh the wired list from the server
            await refreshApex(this.myCheckouts);

            // 5. Notify the parent that something was returned (event without data)
            this.dispatchEvent(new CustomEvent('returned'));
        } catch (error) {
            // 6. If Apex returned an error, log a readable message
            console.error('Return failed: ', error.body.message);
        } finally {
            // 7. ALWAYS hide the spinner
            this.isLoading = false;
        }
    }
}
