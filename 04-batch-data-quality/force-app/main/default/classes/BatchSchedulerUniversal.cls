public class BatchSchedulerUniversal implements Schedulable {

    // Имя Batch класса
    private String batchClassName;

    // Конструктор — принимает имя класса
    public BatchSchedulerUniversal(String className) {
        // сохраняем className в batchClassName
        this.batchClassName = className;
    }

    public void execute(SchedulableContext ctx) {
        // 1 Находим класс по имени строки
        Type batchType =Type.forName(batchClassName);
         //Создаем объект этого класа
         Database.Batchable<sObject> batch =
         (Database.Batchable<sObject>) batchType.newInstance();
         //Запускаем batch
         Database.executeBatch(batch, 200);

       

    }
}
