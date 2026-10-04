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

    // Batch class options
    batchOptions = [
        { label: 'Account Summary',       value: 'AccountSummaryBatch' },
        { label: 'Contact Department',    value: 'ContactDepartmentBatch' },
        { label: 'Lead Engagement',       value: 'LeadEngagementBatch' },
        { label: 'Opportunity Pipeline',  value: 'OpportunityPipelineBatch' }
    ];

    // Time options
    timeOptions = [
        { label: '08:00', value: '08:00' },
        { label: '10:00', value: '10:00' },
        { label: '12:00', value: '12:00' },
        { label: '18:00', value: '18:00' }
    ];

    // Load the status when the component opens
    @wire(getJobStatus)
    wiredStatus(result) {
        this.wiredResult = result;
        if(result.data) {
            this.jobStatus = result.data;
        }
    }

    // Batch selection from the list
    handleBatchChange(event) {
        this.selectedBatch = event.detail.value;
    }

    // Time selection from the list
    handleTimeChange(event) {
        this.selectedTime = event.detail.value;
    }

    // Launch button
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

    // Stop button
    async handleStop() {
        try {
            const result = await stopJob();
            this.showToast('Success', result, 'success');
            await refreshApex(this.wiredResult);
        } catch(error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    // Toast notification
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}