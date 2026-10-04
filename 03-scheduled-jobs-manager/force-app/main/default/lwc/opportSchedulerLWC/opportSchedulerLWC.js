import { LightningElement, track } from 'lwc';
import getJobStatus      from '@salesforce/apex/OpportSchedulerController.getJobStatus';
import startScheduledJob from '@salesforce/apex/OpportSchedulerController.startScheduledJob';
import abortScheduledJob from '@salesforce/apex/OpportSchedulerController.abortScheduledJob';

export default class OpportSchedulerLWC extends LightningElement {

    selectedTime  = '';  // время выбранное пользователем
    @track resultMessage = ''; // сообщение которое видит пользователь

    get timeOptions() {
        return [
            { label: '02:00 AM', value: '02:00' },
            { label: '06:00 AM', value: '06:00' },
            { label: '08:00 AM', value: '08:00' },
            { label: '12:00 PM', value: '12:00' }
        ];
    }

    // Загружаем статус при открытии — вместо @wire
    async connectedCallback() {
        const status = await getJobStatus();// вручную вызываем Apex
        this.resultMessage = status;
    }

    handleTimeChange(event) {  //сохраняет выбранное время
        this.selectedTime = event.detail.value;
    }

    async handleLaunch() { //запускает job + обновляет статус
        try {
            const result = await startScheduledJob({
                launchTime: this.selectedTime
            });
            this.resultMessage = result;
            // Вручную вытягиваем свежий статус
            const status = await getJobStatus();
            this.resultMessage = status;
        } catch(error) {
            this.resultMessage = 'Error: ' + error.body.message;
        }
    }

    async handleStop() { //запускает job + обновляет статус
        try {
            const result = await abortScheduledJob();
            this.resultMessage = result;
            // Вручную вытягиваем свежий статус
            const status = await getJobStatus();
            this.resultMessage = status;
        } catch(error) {
            this.resultMessage = 'Error: ' + error.body.message;
        }
    }
}