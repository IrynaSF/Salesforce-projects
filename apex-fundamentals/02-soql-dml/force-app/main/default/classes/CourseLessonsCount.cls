public class CourseLessonsCount {
    
    public static void  TestCourseLessonsCount(){
       Course__c course = [
           SELECT Id, Name 
           FROM Course__c 
           WHERE Name = 'Audit'
           LIMIT 1
       ];
        
        List<Lesson__c> less = new List<Lesson__c>();
        
        Lesson__c lessThree = new Lesson__c();
        lessThree.Name = 'Lesson3';
        lessThree.Course__c = course.Id;
        less.add(lessThree);
        
        insert less;
        System.debug('Quantity Lesson after insert:' + less);
        
        // With a Master-Detail relationship you can't update records like this!!!
        // On update you can't change a Master-Detail
        // field: it is set only once on insert and is frozen afterwards
        ////===================
        // //lessThree.Name = 'AuditLesson3';
        //lessThree.Course__c = course.Id;
        //update lessThree;
        //==============================
        ////lessThree.Course__c = course.Id; the value of this field is still
        // held in the lessThree variable in memory.
        //  When we call update lessThree;
        //  Salesforce tries to send all populated fields of the object to the database.
        //   But because reparenting is disabled by default for a Master-Detail field,
        //   the system treats it as read-only on update
        //   and throws a System.DmlException
       //================================
       // You need to create a new (clean) Lesson__c instance for
       // the update, passing only the record Id and the fields
       // you want to change.
       // 
        Lesson__c lessToUpdate = new Lesson__c();
       lessToUpdate.Id = lessThree.Id;        // Pass the Id so Salesforce knows which record to update
        lessToUpdate.Name = 'AuditLesson3';    // Change only the name

    // The Course__c field is empty here, so Salesforce won't try to update it
      update lessToUpdate; 
        
        // query again to see our changes in the database
        Course__c updated = [
            SELECT Id, Total_Lessons__c
            FROM Course__c 
            WHERE Id = :course.Id
        ];
        
      System.debug('Total lessons: ' + updated.Total_Lessons__c);
    }
}
