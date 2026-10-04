public with sharing class OpportSchedulerController {

// use the class name as the unique job name
// the name is taken directly from the class name
// via OpportSchedulerClass.class.getName().
//OpportSchedulerClass  ← Apex class name
//.class                ← access the Type object of this class
//.getName()            ← get the class name as a string
private static String getJobName() {
    return OpportSchedulerClass.class.getName();
}

//  findJobs() method
private static List<CronTrigger> findJobs() {
    return [
        SELECT Id, State 
        FROM CronTrigger 
        WHERE CronJobDetail.Name = :getJobName() 
        LIMIT 1
    ];
}


    // Method that returns the status for the LWC
    // cacheable=true: can be used with @wire
    // Returns 'NOT STARTED' if the job is not found
    // Or the real status from CronTrigger if found
    @AuraEnabled(cacheable=true)
    public static String getJobStatus() {
        List<CronTrigger> jobs = findJobs();
        return jobs.isEmpty() ? 'NOT STARTED' : jobs[0].State;
    }

    // Method for the Launch Job button
    // Takes a time in "08:00" format from the LWC combobox
    // Returns a result string to show to the user
    @AuraEnabled
    public static String startScheduledJob(String launchTime) {

        // Variable for the user message
        // Default: success message
        String message = 'Scheduler started at ' + launchTime;

        if(String.isBlank(launchTime)) {
            // The user didn't select a time: ask them to select one
            message = 'Please select a launch time!';

        } else if(!findJobs().isEmpty()) {
            // The job already exists: protection against duplicates
            message = 'Scheduler is already running!';

        } else {
            // Parsing: "08:00" → CRON string
            // substring(3, 5) → minutes: "08:00" → "00"
            // substring(0, 2) → hours:   "08:00" → "08"
            // Result: "0 00 08 * * ?" = every day at 08:00
            String cron = '0 '
                + launchTime.substring(3, 5) + ' '
                + launchTime.substring(0, 2)
                + ' * * ?';

            // Create the Scheduled job
           System.schedule(getJobName(), cron, new OpportSchedulerClass());
        }

        // Single return: send the message back to the LWC
        return message;
    }

    // Method for the Stop Job button
    // Finds the active job and stops it
    // Returns a result string to show to the user
    @AuraEnabled
    public static String abortScheduledJob() {

        // Variable for the user message
        // Default: success message
        String message = 'Scheduler stopped!';
        List<CronTrigger> jobs = findJobs();

        if(jobs.isEmpty()) {
            // Job not found: nothing to stop
            message = 'No active scheduler found!';
        } else {
            // Job found: stop it
            System.abortJob(jobs[0].Id);
        }

        // Single return: send the message back to the LWC
        return message;
    }
}

// Controller class
// Acts as a bridge for the LWC. Takes the time selected by the user,
// parses it and registers the job in the Salesforce schedule.
