public with sharing class ScheduledJobsMonitorController {
   @AuraEnabled(cacheable=true)
public static List<CronTrigger> getActiveJobs() {
   // 1. Method start: was the method called?
    System.debug('=== getActiveJobs START: ' + System.now() + ' ===');


    List<CronTrigger> jobs = [
        SELECT
        Id,
        CronJobDetail.Name,// job name
        State, // WAITING status
        NextFireTime,// next run
         TimesTriggered, // how many times it has run
         CronExpression // schedule, e.g. 0 0 8 * * ?
         FROM CronTrigger
         WHERE State  = 'WAITING'  // active only
         ORDER BY NextFireTime ASC // nearest first
    ];
    // 5. Method end: what we return
    System.debug('Found jobs: ' + jobs.size());
    return jobs;
 
}
}

//Execute Anon  List<CronTrigger> jobs = ScheduledJobsMonitorController.getActiveJobs();
// Task: monitoring Scheduled Jobs
// Scenario
// Build an LWC that shows a list of all active Scheduled Jobs in the org with their details.
   // Return all CronTriggers where State = 'WAITING'
    // Fields: Id, CronJobDetail.Name, State,
    //        NextFireTime, TimesTriggered, CronExpression
    // Sort by NextFireTime ASC
