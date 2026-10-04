public with sharing class ScheduledJobsMonitorController {
   @AuraEnabled(cacheable=true)
public static List<CronTrigger> getActiveJobs() {
   // 1. Начало метода — метод вызвался?
    System.debug('=== getActiveJobs START: ' + System.now() + ' ===');


    List<CronTrigger> jobs = [
        SELECT
        Id,
        CronJobDetail.Name,// название job
        State, // статус WAITING
        NextFireTime,// следующий запуск
         TimesTriggered, // сколько раз запускался
         CronExpression // расписание 0 0 8 * * ?
         FROM CronTrigger
         WHERE State  = 'WAITING'  // только активные
         ORDER BY NextFireTime ASC //сначала ближайшие
    ];
    // 5. Конец метода — что возвращаем
    System.debug('Found jobs: ' + jobs.size());
    return jobs;
 
}
}

//Execute Anon  List<CronTrigger> jobs = ScheduledJobsMonitorController.getActiveJobs();
//Задание — мониторинг Scheduled Jobs
//Сценарий
//нужно создать LWC компонент который показывает список всех активных Scheduled Jobs в org с их деталями.
   // Верни все CronTrigger где State = 'WAITING'
    // Поля: Id, CronJobDetail.Name, State,
    //        NextFireTime, TimesTriggered, CronExpression
    // Отсортируй по NextFireTime ASC
