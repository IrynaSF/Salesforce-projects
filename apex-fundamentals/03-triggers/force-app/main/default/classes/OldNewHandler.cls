public with sharing class OldNewHandler {
    //Логика для события Before Update: изменения полей самой записи. 
    public static void handlerBeforUpdate (List<Opportunity> newOpp,List<Opportunity> oldOpp){
        List<Task> tasksToCreate = new List<Task>();

   //  Проходим по списку с использованием индекса, чтобы связать конкретную старую версию записи с её же конкретной новой версией
   for (Integer i = 0; i < oldOpp.size(); i++){
        Opportunity oldRecord = oldOpp[i];
        Opportunity newRecord = newOpp[i];

    //Проверяем, что у конкретной записи поле Amount не пустое ни в старой, ни в новой версии, и что у неё же сумма была меньше 2000, а стала 2000 или больше
        if(oldRecord.Amount != null  &&  newRecord.Amount != null  && oldRecord.Amount < 2000  &&  newRecord.Amount >= 2000 ){
            newRecord.StageName = 'Negotiation/Review';
            System.debug('Amount crossed 2000 threshold, Stage auto-set to Negotiation/Review');
            //После того как сделка переведена в новую стейдж, формируется таск. 
              Task alertTask = new Task(); //Создаем новый таск. 
                alertTask.Subject = 'Contact client — deal moved to Negotiation/Review (Amount ≥ 2000)';//Здесь мы задаем значение поля Subject: то, что увидит пользователь, как Название задачи  в списке Tasks. 
                alertTask.WhatId = newRecord.Id;//*
                tasksToCreate.add(alertTask);//Здесь мы добавляем наш таск. 


        }
   }
     if (!tasksToCreate.isEmpty()) { //Проверяем, чтобы наш таск не был пустым. 
    insert tasksToCreate;//Инсертим наш таск в организацию. 
}

    }



}
