public with sharing class BatchSchedulerController {

    // ══════════════════════════════════════════════
    // Constant: the job name in one place
    // To rename it, change it only here
    // Used in all methods via :JOB_NAME
    // ══════════════════════════════════════════════
    private static final String JOB_NAME = 'Universal Batch Job';

    // ══════════════════════════════════════════════
    // Private method: SOQL in one place
    // Extracted to avoid duplicating it in three methods
    // Returns the active CronTrigger if the job exists
    // ══════════════════════════════════════════════
    private static List<CronTrigger> findJobs() {
        return [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = :JOB_NAME
            LIMIT 1
        ];
    }

    // ══════════════════════════════════════════════
    // Method that returns the status for the LWC
    // Called when the component loads via @wire
    // cacheable=true: can be used with @wire
    // Returns 'NOT STARTED' if the job is not found
    // Or the real WAITING/COMPLETE status if found
    // ══════════════════════════════════════════════
    @AuraEnabled(cacheable=true)
    public static String getJobStatus() {
        List<CronTrigger> jobs = findJobs();
        // Ternary operator:
        // if jobs is empty → 'NOT STARTED'
        // if a job is found → the real status
        return jobs.isEmpty() ? 'NOT STARTED' : jobs[0].State;
    }

    // ══════════════════════════════════════════════
    // Method for the Launch Job button
    // Takes two parameters from the LWC:
    // batchName  = name of the selected Batch class
    // launchTime = launch time, e.g. '08:00'
    // Returns a result string for the Toast
    // ══════════════════════════════════════════════
    @AuraEnabled
    public static String startJob(String batchName, String launchTime) {

        // Default: success message
        // Overwritten if there is an error
        String message = 'Scheduler started at ' + launchTime;

        if(String.isBlank(launchTime)) {
            // The user didn't select a time
            message = 'Please select a launch time!';

        } else if(String.isBlank(batchName)) {
            // The user didn't select a Batch
            message = 'Please select a batch!';

        } else if(!findJobs().isEmpty()) {
            // The job already exists: protection against duplicates
            message = 'Scheduler is already running!';

        } else {
            // All checks passed: create the job

            // Parsing: "08:00" → CRON string
            // substring(3, 5) → minutes: "08:00" → "00"
            // substring(0, 2) → hours:   "08:00" → "08"
            // CRON result: "0 00 08 * * ?"
            // = every day at 08:00
            String cron = '0 '
                + launchTime.substring(3, 5) + ' '
                + launchTime.substring(0, 2)
                + ' * * ?';

            // Create the Scheduled job
            // JOB_NAME: constant from the top of the class
            // cron: the schedule built above
            // new UniversalBatchScheduler(batchName): pass the Batch name
            System.schedule(JOB_NAME, cron,
                new UniversalBatchScheduler(batchName));
        }

        // Single return: send the message back to the LWC
        return message;
    }

    // ══════════════════════════════════════════════
    // Method for the Stop Job button
    // Finds the active job and stops it
    // Takes no parameters: the job name comes from JOB_NAME
    // Returns a result string for the Toast
    // ══════════════════════════════════════════════
    @AuraEnabled
    public static String stopJob() {

        // Default: success message
        String message = 'Scheduler stopped!';

        // Find the active job via the private findJobs() method
        List<CronTrigger> jobs = findJobs();

        if(jobs.isEmpty()) {
            // Job not found: nothing to stop
            message = 'No active scheduler found!';
        } else {
            // Job found: stop it with System.abortJob
            // jobs[0].Id: Id of the first (and only) job
            System.abortJob(jobs[0].Id);
        }

        // Single return: send the message back to the LWC
        return message;
    }
}
