public with sharing class TrainingController {

    @AuraEnabled(cacheable=true)

    //Первый метод который забирает необходимую информацию
    public static List<Training__c> getTrainings() {
        List<Training__c> train = [
            SELECT Id, Name,  Course_Name__c, Status__c, Completion_Date__c, Contact__c 
            FROM Training__c
            ORDER BY Name ASC
        ];
    return train;
    }

@AuraEnabled    
    public static void updateTrainingStatus(Id trainingId, String newStatus){

List<Training__c> updStatus = [
    SELECT Id FROM Training__c WHERE Id = :trainingId
];

//Присвоить новое значение полю Status__c у найденной записи
updStatus[0].Status__c = newStatus;

//Обновляем поля у обьекта
update updStatus;

    }
}


//updStatus — это список (List<Training__c>), который вернул наш SOQL запрос. Даже если нашлась одна запись — она всё равно лежит внутри списка.
//updStatus[0] — берём первый (и единственный) элемент из этого списка — это наш конкретный объект Training__c.
//.Status__c = newStatus — присваиваем полю Status__c этого объекта новое значение из параметра newStatus (того, что передали снаружи при вызове метода).
//Важно — на этом шаге изменение произошло только в памяти (в переменной updStatus), но в базе данных Salesforce ничего ещё не изменилось!







// Salesforce все кастомные объекты (те, что мы создаем сами, в отличие от стандартных типа Account, Contact, Lead) автоматически получают суффикс __c в своём API Name.
