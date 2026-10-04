import { LightningElement,wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/WireLwcController.getAccounts';
import getOpportunities from '@salesforce/apex/WireLwcController.getOpportunities';
const COLUMNS = [ { label: 'Name', fieldName: 'Name', type: 'text' }

, { label: 'Stage', fieldName: 'StageName', type: 'text' }, 

{ label: 'Amount', fieldName: 'Amount', type: 'currency' } ];
export default class WireOpportunityList extends LightningElement {

opportunityColumns = COLUMNS

@track selectedAccountId;

@wire(getAccounts)
accounts;


@wire(getOpportunities, { accountId: '$selectedAccountId' })
opportunities;
get accountOptions() {
    return this.accounts.data
        ? this.accounts.data.map(acc => ({ label: acc.Name, value: acc.Id }))
        : [];
}
handleAccountSelect(event) {
    this.selectedAccountId = event.target.value;
    console.log('Selected account:', this.selectedAccountId);
}

}