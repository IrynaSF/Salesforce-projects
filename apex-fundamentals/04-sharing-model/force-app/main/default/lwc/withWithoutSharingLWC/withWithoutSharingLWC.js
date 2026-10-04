import { LightningElement, wire} from 'lwc';
import getSharedVisibleRecords from '@salesforce/apex/WithSharingHandler.getSharedVisibleRecords';
import getVisibleRecords from '@salesforce/apex/WithoutSharingHandler.getVisibleRecords'; 
export default class WithWithoutSharingLWC extends LightningElement {

@wire(getSharedVisibleRecords) sharedRecords;
@wire(getVisibleRecords) unsharedRecords;

columns = [
    {label: 'Name', fieldName: 'Name',type: 'text'},
    {label: 'Position', fieldName: 'Position__c',type: 'text'},
    {label: 'Salary', fieldName: 'Salary__c',type: 'currency'}
];
}