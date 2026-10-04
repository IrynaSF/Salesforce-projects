public class BatchSchedulerUniversal implements Schedulable {

    // Batch class name
    private String batchClassName;

    // Constructor: takes the class name
    public BatchSchedulerUniversal(String className) {
        // store className in batchClassName
        this.batchClassName = className;
    }

    public void execute(SchedulableContext ctx) {
        // 1. Find the class by its name string
        Type batchType =Type.forName(batchClassName);
         // Create an instance of this class
         Database.Batchable<sObject> batch =
         (Database.Batchable<sObject>) batchType.newInstance();
         // Run the batch
         Database.executeBatch(batch, 200);

       

    }
}
