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
        
        //При связи Master-Detail так обновлять записи нельзя!!!!!
        //При update нельзя менять Master-Detail
        // поле — оно устанавливается только один раз при insert и потом заморожено
        ////===================
        // //lessThree.Name = 'AuditLesson3';
        //lessThree.Course__c = course.Id;
        //update lessThree;
        //==============================
        ////lessThree.Course__c = course.Id;, значение этого поля всё равно
        // хранится в переменной lessThree в оперативной памяти.
        //  Когда мы вызываем update lessThree;, 
        //  Salesforce пытается отправить в базу данных все заполненные поля объекта.
        //   Но так как для поля Master-Detail по умолчанию запрещено 
        //   перепривязывание (Reparenting), система расценивает его при обновлении 
        //   как «недоступное для редактирования» (Read-Only) и выбрасывает System.DmlException
       //================================
       // Нужно создать новый (чистый)экземпляр объекта Lesson__c для 
       // выполнения операции update, передав туда только Id записи и те поля, 
       // которые  хотитим изменить.
       // 
        Lesson__c lessToUpdate = new Lesson__c();
       lessToUpdate.Id = lessThree.Id;        // Передаем Id, чтобы Salesforce знал, какую запись обновлять
        lessToUpdate.Name = 'AuditLesson3';    // Меняем только имя

    // Поле Course__c здесь пустое, поэтому Salesforce не будет пытаться его обновить
      update lessToUpdate; 
        
        //селектимся еще раз чтобы БД увидела наши изменения
        Course__c updated = [
            SELECT Id, Total_Lessons__c
            FROM Course__c 
            WHERE Id = :course.Id
        ];
        
      System.debug('Total lessons: ' + updated.Total_Lessons__c);
    }
}
