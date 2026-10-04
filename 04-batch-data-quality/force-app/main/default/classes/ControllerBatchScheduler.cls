public with sharing class ControllerBatchScheduler {

    // SOQL — ищет job по имени Batch
    private static List<CronTrigger> findJobs(String batchName) {
        return [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = :batchName
            LIMIT 1
        ];
    }

    // Статус
@AuraEnabled
public static String getJobStatus(String batchName) {
    // Добавь проверку
    if(String.isBlank(batchName)) return 'NOT STARTED';
    
    List<CronTrigger> jobs = findJobs(batchName);
    return jobs.isEmpty() ? 'NOT STARTED' : jobs[0].State;
}

    // Кнопка Launch
    // batchName — имя Batch класса
    // cronTime  — расписание
    // Оба приходят из LWC через @api из App Builder
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

    // Кнопка Stop
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
