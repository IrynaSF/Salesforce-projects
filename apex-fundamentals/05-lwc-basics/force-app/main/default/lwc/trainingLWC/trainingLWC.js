import { LightningElement, track, wire } from 'lwc';
import getTrainings from '@salesforce/apex/TrainingController.getTrainings';
import updateTrainingStatus from '@salesforce/apex/TrainingController.updateTrainingStatus';

export default class TrainingLWC extends LightningElement {

    @track status;
    @wire(getTrainings) trainings; // автоматически загружает данные

    handleClick(event){//Метод
 //event.target — это та кнопка, на которую нажали.
//dataset.id — это значение атрибута data-id именно этой кнопки.
const id = event.target.dataset.id;

// Императивный вызов updateTrainingStatus
// После того как получили id — вызываем Apex метод вручную (императивно), передавая параметры в виде объекта:
updateTrainingStatus({ trainingId: id, newStatus: 'Completed' })
  .then(() => { this.status = 'Status updated!' })
.catch(error => { this.status = 'Error: ' + error.body.message })
    }
}





//Императивный вызов JavaScript в Salesforce — это вызов метода сервера (Apex) вручную из вашего JS-кода в компонентах (обычно в Lightning Web Components — LWC).
// // В отличие от декларативного подхода, этот метод активируется строго по вашей команде, а не автоматически платформой