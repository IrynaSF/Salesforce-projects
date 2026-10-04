public class DataQualityScheduler implements Schedulable {

    // Batch class name
    private String batchClassName;

    // Constructor
    public DataQualityScheduler(String className) {
        // store className in batchClassName
       this.batchClassName = className;
    }

    public void execute(SchedulableContext ctx) {
        // 1. Type.forName(batchClassName)
        // 2. newInstance()
        // 3. Database.executeBatch(batch, 200)
         // Find the class by its name string
        Type batchType = Type.forName(batchClassName);
        // Create an instance of this class
        Database.Batchable<sObject> batch =
            (Database.Batchable<sObject>) batchType.newInstance();
        // Run the Batch
        Database.executeBatch(batch, 200);// 200 is the chunk size: how many records the Batch processes in one execute() call.
                               /// The standard value for most cases
    }
    // Static method: schedules both jobs
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
