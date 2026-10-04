import { LightningElement,track } from 'lwc';
import getContacts from '@salesforce/apex/TrackLwcController.getContacts';

export default class TrackContactFilter extends LightningElement {
@track contacts;
@track filteredContacts;
@track searchTerm;

connectedCallback() {
       getContacts()
            .then(result => {
                this.contacts = result;
                // Initialize the filtered list with the source data
                this.filteredContacts = result;
            })
            .catch(error => {
                console.error('Loading error:', error);
            });
    }

    // Method that handles user input
    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();

        // Filter the source array and write the result into the filtered one
        this.filteredContacts = this.contacts.filter(cont => 
            cont.LastName.toLowerCase().includes(searchTerm)
        );
    }
    get contactsCount() {
    return this.filteredContacts ? this.filteredContacts.length : 0;
}

get isListEmpty() {
    return !this.filteredContacts || this.filteredContacts.length === 0;
}
}