public class DataQualityScheduler implements Schedulable {

    // Имя Batch класса
    private String batchClassName;

    // Конструктор
    public DataQualityScheduler(String className) {
        // сохраняем className в batchClassName
       this.batchClassName = className;
    }

    public void execute(SchedulableContext ctx) {
        // 1. Type.forName(batchClassName)
        // 2. newInstance()
        // 3. Database.executeBatch(batch, 200)
         // Находим класс по имени строки
        Type batchType = Type.forName(batchClassName);
        // Создаём объект этого класса
        Database.Batchable<sObject> batch =
            (Database.Batchable<sObject>) batchType.newInstance();
        // Запускаем Batch
        Database.executeBatch(batch, 200);//200 — это размер порции (chunk size) — сколько записей Batch обрабатывает за один вызов execute().
                               /// Стандартный — для большинства случаев
    }
    // Статический метод — запускает оба job
    public static void scheduleAll() {
        System.schedule(
            'Lead Source Job',
            '0 0 9 ? * MON',
            new DataQualityScheduler('LeadSourceBatch')
        );
        System.schedule(
            'Opportunity At Risk Job',
            '0 0 10 ? * FRI',
            new DataQualityScheduler('OpportunityAtRiskBatch')
        );
        System.debug('Both jobs scheduled!');
    }
}
