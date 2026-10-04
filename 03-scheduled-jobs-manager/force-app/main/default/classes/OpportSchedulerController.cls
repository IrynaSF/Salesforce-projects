public with sharing class OpportSchedulerController {

// используем имя класса в качестве уникального имени задачи
//имя берётся напрямую из имени класса
//через OpportSchedulerClass.class.getName().
//OpportSchedulerClass  ← имя Apex класса
//.class                ← обращаемся к объекту Type этого класса
//.getName()            ← получаем имя класса как строку
private static String getJobName() {
    return OpportSchedulerClass.class.getName();
}

//  метод findJobs()
private static List<CronTrigger> findJobs() {
    return [
        SELECT Id, State 
        FROM CronTrigger 
        WHERE CronJobDetail.Name = :getJobName() 
        LIMIT 1
    ];
}


    // Метод для отображения статуса в LWC
    // cacheable=true — можно использовать с @wire
    // Возвращает 'NOT STARTED' если job не найден
    // Или реальный статус из CronTrigger если найден
    @AuraEnabled(cacheable=true)
    public static String getJobStatus() {
        List<CronTrigger> jobs = findJobs();
        return jobs.isEmpty() ? 'NOT STARTED' : jobs[0].State;
    }

    // Метод для кнопки Launch Job
    // Принимает время в формате "08:00" из combobox в LWC
    // Возвращает строку с результатом для отображения пользователю
    @AuraEnabled
    public static String startScheduledJob(String launchTime) {

        // Переменная для сообщения пользователю
        // По умолчанию — сообщение об успехе
        String message = 'Scheduler started at ' + launchTime;

        if(String.isBlank(launchTime)) {
            // Пользователь не выбрал время — просим выбрать
            message = 'Please select a launch time!';

        } else if(!findJobs().isEmpty()) {
            // Job уже существует — защита от дублирования
            message = 'Scheduler is already running!';

        } else {
            // Парсинг: "08:00" → Cron строку
            // substring(3, 5) → минуты: "08:00" → "00"
            // substring(0, 2) → часы:   "08:00" → "08"
            // Результат: "0 00 08 * * ?" = каждый день в 08:00
            String cron = '0 '
                + launchTime.substring(3, 5) + ' '
                + launchTime.substring(0, 2)
                + ' * * ?';

            // Создаём Scheduled job
           System.schedule(getJobName(), cron, new OpportSchedulerClass());
        }

        // Один return — возвращаем сообщение в LWC
        return message;
    }

    // Метод для кнопки Stop Job
    // Находит активный job и останавливает его
    // Возвращает строку с результатом для отображения пользователю
    @AuraEnabled
    public static String abortScheduledJob() {

        // Переменная для сообщения пользователю
        // По умолчанию — сообщение об успехе
        String message = 'Scheduler stopped!';
        List<CronTrigger> jobs = findJobs();

        if(jobs.isEmpty()) {
            // Job не найден — нечего останавливать
            message = 'No active scheduler found!';
        } else {
            // Job найден — останавливаем
            System.abortJob(jobs[0].Id);
        }

        // Один return — возвращаем сообщение в LWC
        return message;
    }
}

// Класс контроллер
// Служит мостом для LWC. Принимает выбранное пользователем время,
// парсит его и регистрирует задачу в расписании Salesforce.
