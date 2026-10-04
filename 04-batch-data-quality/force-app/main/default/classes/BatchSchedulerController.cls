public with sharing class BatchSchedulerController {

    // ══════════════════════════════════════════════
    // Константа — имя job в одном месте
    // Если нужно переименовать — меняем только здесь
    // Используется во всех методах через :JOB_NAME
    // ══════════════════════════════════════════════
    private static final String JOB_NAME = 'Universal Batch Job';

    // ══════════════════════════════════════════════
    // Private метод — SOQL в одном месте
    // Вынесен чтобы не дублировать в трёх методах
    // Возвращает активный CronTrigger если job существует
    // ══════════════════════════════════════════════
    private static List<CronTrigger> findJobs() {
        return [
            SELECT Id, State FROM CronTrigger
            WHERE CronJobDetail.Name = :JOB_NAME
            LIMIT 1
        ];
    }

    // ══════════════════════════════════════════════
    // Метод для отображения статуса в LWC
    // Вызывается при загрузке компонента через @wire
    // cacheable=true — можно использовать с @wire
    // Возвращает 'NOT STARTED' если job не найден
    // Или реальный статус WAITING/COMPLETE если найден
    // ══════════════════════════════════════════════
    @AuraEnabled(cacheable=true)
    public static String getJobStatus() {
        List<CronTrigger> jobs = findJobs();
        // Тернарный оператор:
        // если jobs пустой → 'NOT STARTED'
        // если jobs найден → реальный статус
        return jobs.isEmpty() ? 'NOT STARTED' : jobs[0].State;
    }

    // ══════════════════════════════════════════════
    // Метод для кнопки Launch Job
    // Принимает два параметра из LWC:
    // batchName  = имя выбранного Batch класса
    // launchTime = время запуска например '08:00'
    // Возвращает строку с результатом для Toast
    // ══════════════════════════════════════════════
    @AuraEnabled
    public static String startJob(String batchName, String launchTime) {

        // По умолчанию — сообщение об успехе
        // Перезаписывается если есть ошибка
        String message = 'Scheduler started at ' + launchTime;

        if(String.isBlank(launchTime)) {
            // Пользователь не выбрал время
            message = 'Please select a launch time!';

        } else if(String.isBlank(batchName)) {
            // Пользователь не выбрал Batch
            message = 'Please select a batch!';

        } else if(!findJobs().isEmpty()) {
            // Job уже существует — защита от дублирования
            message = 'Scheduler is already running!';

        } else {
            // Все проверки прошли — создаём job

            // Парсинг: "08:00" → Cron строку
            // substring(3, 5) → минуты: "08:00" → "00"
            // substring(0, 2) → часы:   "08:00" → "08"
            // Результат cron: "0 00 08 * * ?"
            // = каждый день в 08:00
            String cron = '0 '
                + launchTime.substring(3, 5) + ' '
                + launchTime.substring(0, 2)
                + ' * * ?';

            // Создаём Scheduled job
            // JOB_NAME — константа из верхней части класса
            // cron — расписание собранное выше
            // new UniversalBatchScheduler(batchName) — передаём имя Batch
            System.schedule(JOB_NAME, cron,
                new UniversalBatchScheduler(batchName));
        }

        // Один return — возвращаем сообщение в LWC
        return message;
    }

    // ══════════════════════════════════════════════
    // Метод для кнопки Stop Job
    // Находит активный job и останавливает его
    // Не принимает параметров — имя job берёт из JOB_NAME
    // Возвращает строку с результатом для Toast
    // ══════════════════════════════════════════════
    @AuraEnabled
    public static String stopJob() {

        // По умолчанию — сообщение об успехе
        String message = 'Scheduler stopped!';

        // Ищем активный job через private метод findJobs()
        List<CronTrigger> jobs = findJobs();

        if(jobs.isEmpty()) {
            // Job не найден — нечего останавливать
            message = 'No active scheduler found!';
        } else {
            // Job найден — останавливаем через System.abortJob
            // jobs[0].Id — Id первого (и единственного) job
            System.abortJob(jobs[0].Id);
        }

        // Один return — возвращаем сообщение в LWC
        return message;
    }
}
