//PARENT
import { LightningElement, wire, track } from 'lwc';
import getContacts from '@salesforce/apex/EquipmentController.getContacts';

export default class MyEquipmentPanel extends LightningElement {
        // Id of the selected contact (reactive field)
    selectedContactId;

     // Get the contact list from Apex
    @wire(getContacts) contacts;

            // Returns statistics (nested field of an object)
     stats = {
        lastReturnedCount : 0
    };

        // Convert contacts to {label, value} for the combobox
    get contactOptions() {
        // 1. Data has not arrived yet: empty list
        if (!this.contacts.data) {
            return [];
        }
        // 2. Map each contact to {label, value}
        return this.contacts.data.map(contact => ({
            label: contact.Name,
            value: contact.Id  
            //Test 
        }));
    }
        // Is a contact selected (for lwc:if in HTML)
    get hasSelectedContact() {
        return Boolean(this.selectedContactId);
    }
        // The user selected a contact in the combobox
    handleContactChange(event) {
        this.selectedContactId = event.detail.value;
    }
        // Lifecycle: component inserted into the page
    connectedCallback() {
        console.log('myEquipmentPanel connected');
    }

    // Lifecycle: component removed from the page
    disconnectedCallback() {
        console.log('myEquipmentPanel disconnected');
    }

        // The child reported a return: increase the counter
    handleReturned() {
        this.stats.lastReturnedCount = this.stats.lastReturnedCount + 1;
    }
}