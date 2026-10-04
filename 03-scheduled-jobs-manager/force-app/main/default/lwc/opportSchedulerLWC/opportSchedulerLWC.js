import { LightningElement, track } from 'lwc';
import getJobStatus      from '@salesforce/apex/OpportSchedulerController.getJobStatus';
import startScheduledJob from '@salesforce/apex/OpportSchedulerController.startScheduledJob';
import abortScheduledJob from '@salesforce/apex/OpportSchedulerController.abortScheduledJob';

export default class OpportSchedulerLWC extends LightningElement {

    selectedTime  = '';  // time selected by the user
    @track resultMessage = ''; // message shown to the user

    get timeOptions() {
        return [
            { label: '02:00 AM', value: '02:00' },
            { label: '06:00 AM', value: '06:00' },
            { label: '08:00 AM', value: '08:00' },
            { label: '12:00 PM', value: '12:00' }
        ];
    }

    // Load the status on open, instead of @wire
    async connectedCallback() {
        const status = await getJobStatus();// call Apex manually
        this.resultMessage = status;
    }

    handleTimeChange(event) {  // stores the selected time
        this.selectedTime = event.detail.value;
    }

    async handleLaunch() { // starts the job + refreshes the status
        try {
            const result = await startScheduledJob({
                launchTime: this.selectedTime
            });
            this.resultMessage = result;
            // Manually fetch the fresh status
            const status = await getJobStatus();
            this.resultMessage = status;
        } catch(error) {
            this.resultMessage = 'Error: ' + error.body.message;
        }
    }

    async handleStop() { // stops the job + refreshes the status
        try {
            const result = await abortScheduledJob();
            this.resultMessage = result;
            // Manually fetch the fresh status
            const status = await getJobStatus();
            this.resultMessage = status;
        } catch(error) {
            this.resultMessage = 'Error: ' + error.body.message;
        }
    }
}