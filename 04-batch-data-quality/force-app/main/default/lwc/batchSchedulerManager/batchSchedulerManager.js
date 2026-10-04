import { LightningElement, wire } from 'lwc';
import { ShowToastEvent }  from 'lightning/platformShowToastEvent';
import { refreshApex }     from '@salesforce/apex';
import getJobStatus from '@salesforce/apex/BatchSchedulerController.getJobStatus';
import startJob     from '@salesforce/apex/BatchSchedulerController.startJob';
import stopJob      from '@salesforce/apex/BatchSchedulerController.stopJob';

export default class BatchSchedulerManager extends LightningElement {

    selectedBatch = '';
    selectedTime  = '';
    jobStatus     = 'NOT STARTED';
    wiredResult;

    // Варианты Batch классов
    batchOptions = [
        { label: 'Account Summary',       value: 'AccountSummaryBatch' },
        { label: 'Contact Health Check',  value: 'ContactHealthCheckBatch' },
        { label: 'Lead Engagement',       value: 'LeadEngagementBatch' },
        { label: 'Opportunity Pipeline',  value: 'OpportunityPipelineBatch' }
    ];

    // Варианты времени
    timeOptions = [
        { label: '08:00', value: '08:00' },
        { label: '10:00', value: '10:00' },
        { label: '12:00', value: '12:00' },
        { label: '18:00', value: '18:00' }
    ];

    // Загружаем статус при открытии компонента
    @wire(getJobStatus)
    wiredStatus(result) {
        this.wiredResult = result;
        if(result.data) {
            this.jobStatus = result.data;
        }
    }

    // Выбор Batch из списка
    handleBatchChange(event) {
        this.selectedBatch = event.detail.value;
    }

    // Выбор времени из списка
    handleTimeChange(event) {
        this.selectedTime = event.detail.value;
    }

    // Кнопка Launch
    async handleLaunch() {
        try {
            const result = await startJob({
                batchName:  this.selectedBatch,
                launchTime: this.selectedTime
            });
            this.showToast('Success', result, 'success');
            await refreshApex(this.wiredResult);
        } catch(error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Кнопка Stop
    async handleStop() {
        try {
            const result = await stopJob();
            this.showToast('Success', result, 'success');
            await refreshApex(this.wiredResult);
        } catch(error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Toast уведомление
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}