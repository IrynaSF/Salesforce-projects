import { LightningElement, api } from 'lwc';
import getJobStatus from '@salesforce/apex/ControllerBatchScheduler.getJobStatus';
import startJob     from '@salesforce/apex/ControllerBatchScheduler.startJob';
import stopJob      from '@salesforce/apex/ControllerBatchScheduler.stopJob';

export default class BatchSchedulerLWC extends LightningElement {

    // Параметры из App Builder
    @api batchName = '';
    @api cronTime  = '';

    // Статус job
    jobStatus = 'NOT STARTED';

    // Заголовок карточки
    get cardTitle() {
        return 'Scheduler: ' + this.batchName;
    }

    // Загружаем статус при открытии
 connectedCallback() {
    // Проверяем что batchName не пустой
    if(!this.batchName) return;
    
    getJobStatus({ batchName: this.batchName })
        .then(result => this.jobStatus = result)
        .catch(error => this.jobStatus = 'Error');
}

    // Кнопка Launch
    handleLaunch() {
        startJob({ batchName: this.batchName, cronTime: this.cronTime })
            .then(result => this.jobStatus = result)
            .catch(error => this.jobStatus = 'Error');
    }

    // Кнопка Stop
    handleStop() {
        stopJob({ batchName: this.batchName })
            .then(result => this.jobStatus = result)
            .catch(error => this.jobStatus = 'Error');
    }
}