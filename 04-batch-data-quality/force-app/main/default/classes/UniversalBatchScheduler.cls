public class UniversalBatchScheduler implements Schedulable {

    // Name of the selected Batch, comes from the LWC
    private String batchClassName;

    // Constructor: store the class name
    public UniversalBatchScheduler(String className) {
        this.batchClassName = className;
    }

    // Salesforce calls this method on schedule
    public void execute(SchedulableContext ctx) {
        // Find the class by its name string
        Type batchType = Type.forName(batchClassName);
        // Create an instance of this class
        Database.Batchable<sObject> batch =
            (Database.Batchable<sObject>) batchType.newInstance();
        // Run the Batch
        Database.executeBatch(batch, 200);
    }
}
