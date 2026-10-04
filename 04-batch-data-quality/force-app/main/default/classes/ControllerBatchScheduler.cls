public with sharing class ControllerBatchScheduler {

    // SOQL: find the job by Batch name
    private static List<CronTrigger> findJobs(String batchName) {
        return [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = :batchName
            LIMIT 1
        ];
    }

    // Status
@AuraEnabled
public static String getJobStatus(String batchName) {
    // Added a check
    if(String.isBlank(batchName)) return 'NOT STARTED';
    
    List<CronTrigger> jobs = findJobs(batchName);
    return jobs.isEmpty() ? 'NOT STARTED' : jobs[0].State;
}

    // Launch button
    // batchName: Batch class name
    // cronTime: schedule
    // Both come from the LWC via @api from App Builder
    @AuraEnabled
    public static String startJob(String batchName, String cronTime) {
        String message = 'Scheduler started!';
        if(String.isBlank(batchName)) {
            message = 'Batch name is empty!';
        } else if(!findJobs(batchName).isEmpty()) {
            message = 'Already running!';
        } else {
            System.schedule(batchName, cronTime,
                new BatchSchedulerUniversal(batchName));
        }
        return message;
    }

    // Stop button
    @AuraEnabled
    public static String stopJob(String batchName) {
        String message = 'Scheduler stopped!';
        List<CronTrigger> jobs = findJobs(batchName);
        if(jobs.isEmpty()) {
            message = 'No active scheduler found!';
        } else {
            System.abortJob(jobs[0].Id);
        }
        return message;
    }
}
