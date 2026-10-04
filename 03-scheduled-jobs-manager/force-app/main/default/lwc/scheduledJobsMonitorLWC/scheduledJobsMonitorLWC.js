import { LightningElement, wire } from 'lwc';
import getActiveJobs from '@salesforce/apex/ScheduledJobsMonitorController.getActiveJobs';

export default class ScheduledJobsMonitor extends LightningElement {
    jobs = [];
    error;

    // @wire loads the data automatically
    @wire(getActiveJobs)
    wiredJobs({ data, error }) {
        // if data: store it in jobs
        // if error: store it in error and log it with console.error
        if (data) {
            // Store the data if it arrived successfully
            this.jobs = data;
            this.error = undefined;
        } else if (error) {
            // Store/handle the error
            this.error = error;
            this.jobs = [];
            console.error('Loading error:', error);
        }
    }


     // Getter: flattens the nested fields
    get formattedJobs() {
        return this.jobs.map(job => ({
            Id:             job.Id,
            jobName:        job.CronJobDetail.Name,
            NextFireTime:   job.NextFireTime,
            TimesTriggered: job.TimesTriggered,
            CronExpression: job.CronExpression
        }));
    }

    // Getter: number of jobs
    get totalJobs() {
        // return the count
        return this.jobs ? this.jobs.length : 0;
    }

    // Getter: is the list empty?
    get isEmpty() {
        // return true if empty
         return !this.jobs || this.jobs.length === 0;
    }
}