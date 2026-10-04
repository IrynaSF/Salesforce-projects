//Задание 1 — простой try/catch
//Напиши метод findTrainingById(Id trainingId):
//нутри try — SOQL запрос, который ищет Training__c по Id
//Если список пустой — используй throw чтобы выбросить AuraHandledException
//Внутри catch — поймай исключение и выведи его через System.debug
//Внутри finally — System.debug('Search completed')

public with sharing class TryCatchThrow {
    public static void findTrainingById(Id trainingId) {
               
try {
    // основной код
        List<Training__c> listTrain = [
            SELECT Id 
            FROM Training__c
            WHERE Id = :trainingId 
        ];

if (listTrain.isEmpty()) {
    throw new AuraHandledException('The list is empty');
}
} catch (Exception e) {
    // если сломалось
      System.debug(e.getMessage());
} finally {
    // выполняется всегда
    System.debug('Search completed');
}

    }
}

 //Execute
//TryCatchThrow.findTrainingById(null);


//  Полезные методы класса Exception:
//***e.getMessage() — возвращает короткое описание того, что пошло не так.e.
//***getStackTraceString() — показывает точную строку и цепочку вызовов,где произошла ошибка.
//***e.getTypeName() — возвращает тип ошибки (например, System.MathException).
