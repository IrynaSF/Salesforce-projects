public with sharing class ChildEmplManagerTriggerHandler {

    //Метод для нашего триггера, который будет менять имена детей автоматически после создания 
      public static void renameChildren(List<Child__c> newChildren) {
 
        //возвращает одно число — сколько записей подошло под условие.
        Integer existingCount = [SELECT COUNT() FROM Child__c];//*** 
        for (Integer i = 0; i < newChildren.size(); i++) {
            newChildren[i].Name = 'ChildTest' + (existingCount + i + 1); //existingCount — сколько записей уже было в базе до этого insert,i — индекс текущей записи внутри этой конкретной "пачки",+ 1 — та же самая причуда, что была раньше в исходном коде: раз i начинается с 0, а не с 1, добавляем единицу, чтобы нумерация выглядела человечно (1, 2, 3...), а не (0, 1, 2...)
        }
    }

    

    //Метод, который будет вытаскивать рекорд менеджеров с определенными правами доступа (Доступ к филду Salary. )
      public static void findManagersWithSalaryAccess() {

        //Получаем список объектов FieldPermissions, где ParentId — это Id того Permission Set (или Profile), у которого есть Read-доступ к Salary.
       List<PermissionSetAssignment> assignments = [
        SELECT AssigneeId, Assignee.Name //** 
        FROM PermissionSetAssignment 
        WHERE PermissionSetId IN (
            SELECT ParentId 
            FROM FieldPermissions 
            WHERE Field = 'Employee__c.Salary__c' //*
            AND PermissionsRead = true
        )
    ];

    //Цикл. for (Тип переменная : коллекция)
    for (PermissionSetAssignment permission : assignments) {
        System.debug('Manager with Salary access: ' + permission.AssigneeId + ' - ' + permission.Assignee.Name);
    }
    }
}
//*сам объект FieldPermissions устроен так, что его поле Field (обычное текстовое поле) хранит значения именно в формате "ИмяОбъекта.ИмяПоля" — это просто соглашение,
// как Salesforce записывает "какое именно поле имеется в виду" внутри системной таблицы. Мы просто сравниваем: "есть ли строка, равная ровно этому тексту".
//** Assignee.Name (в SELECT, БЕЗ кавычек) — это НАСТОЯЩАЯ связь через Lookup
//Тут точка означает: "у PermissionSetAssignment есть Lookup-поле Assignee (ссылается на User), возьми у связанной записи User поле Name". Это реальный relationship-переход между объектами — то, что мы уже делали раньше (например, parent.ChildrenLeads__r в LWC-компоненте).
//Ключевое отличие: в кавычках — просто текст-совпадение; без кавычек, в SELECT/WHERE как имя поля — реальная связь между объектами через Lookup.
//*** Что такое COUNT() в SOQL
//Обычный SOQL-запрос (SELECT Id, Name FROM ...) возвращает список записей (List<sObject>) — каждая строка результата содержит все запрошенные поля конкретной записи.
//COUNT() — это агрегатная функция (aggregate function). Вместо того чтобы вернуть сами записи, она возвращает одно число — сколько записей подошло под условие. Salesforce вообще не тратит время на подгрузку самих полей записей, просто считает, сколько их.
//SELECT — просто COUNT(), без аргументов внутри скобок. Это специальная форма, которую Salesforce распознаёт и сразу отдаёт результат как одно целое число (Integer), а не список — поэтому мы даже не оборачиваем это в List<...>, присваиваем прямо в Integer.
