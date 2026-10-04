import { LightningElement, api } from 'lwc';
import getJobStatus from '@salesforce/apex/ControllerBatchScheduler.getJobStatus';
import startJob     from '@salesforce/apex/ControllerBatchScheduler.startJob';
import stopJob      from '@salesforce/apex/ControllerBatchScheduler.stopJob';

export default class BatchSchedulerLWC extends LightningElement {

    // Parameters from App Builder
    @api batchName = '';
    @api cronTime  = '';

    // Job status
    jobStatus = 'NOT STARTED';

    // Card title
    get cardTitle() {
        return 'Scheduler: ' + this.batchName;
    }

    // Load the status on open
 connectedCallback() {
    // Check that batchName is not empty
    if(!this.batchName) return;
    
    getJobStatus({ batchName: this.batchName })
        .then(result => this.jobStatus = result)
        .catch(error => this.jobStatus = 'Error');
}

    // Launch button
    handleLaunch() {
        startJob({ batchName: this.batchName, cronTime: this.cronTime })
            .then(result => this.jobStatus = result)
            .catch(error => this.jobStatus = 'Error');
    }

    // Stop button
    handleStop() {
        stopJob({ batchName: this.batchName })
            .then(result => this.jobStatus = result)
            .catch(error => this.jobStatus = 'Error');
    }
}