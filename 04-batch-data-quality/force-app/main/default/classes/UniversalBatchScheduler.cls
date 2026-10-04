public class UniversalBatchScheduler implements Schedulable {

    // Имя выбранного Batch — приходит из LWC
    private String batchClassName;

    // Конструктор — сохраняем имя класса
    public UniversalBatchScheduler(String className) {
        this.batchClassName = className;
    }

    // Salesforce вызывает этот метод по расписанию
    public void execute(SchedulableContext ctx) {
        // Находим класс по имени строки
        Type batchType = Type.forName(batchClassName);
        // Создаём объект этого класса
        Database.Batchable<sObject> batch =
            (Database.Batchable<sObject>) batchType.newInstance();
        // Запускаем Batch
        Database.executeBatch(batch, 200);
    }
}
