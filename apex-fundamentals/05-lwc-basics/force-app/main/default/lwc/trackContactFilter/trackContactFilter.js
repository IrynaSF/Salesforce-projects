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
                // Инициализируем отфильтрованный список исходными данными
                this.filteredContacts = result;
            })
            .catch(error => {
                console.error('Loading error:', error);
            });
    }

    // Метод для обработки ввода пользователя
    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();

        // Фильтруем исходный массив и записываем в отфильтрованный
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