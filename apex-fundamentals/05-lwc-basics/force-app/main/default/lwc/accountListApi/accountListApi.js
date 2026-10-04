import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/ApiLwcController.getAccounts';
export default class AccountListApi extends LightningElement {
@track accounts;

 connectedCallback() {
        this.loadAccounts();
    }
    loadAccounts() {
       
        getAccounts()
            .then(result => {
                this.accounts = result; 
console.log('Accounts loaded:', this.accounts);
                this.error = undefined;
            })
            .catch(error => {
                this.error = error; // 
                this.accounts = undefined;
                console.error('Error retrieving accounts:', error);
            });
    }
}