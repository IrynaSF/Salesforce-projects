import { LightningElement, track, wire } from 'lwc';
import getTrainings from '@salesforce/apex/TrainingController.getTrainings';
import updateTrainingStatus from '@salesforce/apex/TrainingController.updateTrainingStatus';

export default class TrainingLWC extends LightningElement {

    @track status;
    @wire(getTrainings) trainings; // loads the data automatically

    handleClick(event){// Method
 //event.target is the button that was clicked.
//dataset.id is the value of that button's data-id attribute.
const id = event.target.dataset.id;

// Imperative call of updateTrainingStatus
// Once we have the id, call the Apex method manually (imperatively), passing parameters as an object:
updateTrainingStatus({ trainingId: id, newStatus: 'Completed' })
  .then(() => { this.status = 'Status updated!' })
.catch(error => { this.status = 'Error: ' + error.body.message })
    }
}





// An imperative call in Salesforce JavaScript is calling a server (Apex) method manually from your JS code in components (usually Lightning Web Components, LWC).
// // Unlike the declarative approach (@wire), it runs only when your code says so, not automatically by the platform