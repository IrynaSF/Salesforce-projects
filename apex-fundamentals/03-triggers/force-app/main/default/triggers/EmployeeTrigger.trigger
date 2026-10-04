trigger EmployeeTrigger on Employee__c  (before insert, after insert) {
 // ========================================
// ORDER OF EXECUTION при сохранении Employee__c
// ========================================
// Шаг 1: Загрузка исходной записи (для insert — создаётся "пустая" в памяти)
// Шаг 2: Наложение новых значений полей (Name, Department__c и т.д.)
// Шаг 3: Проверка форматов, длины полей, внешних ключей (Lookup/Master-Detail)
//        — если бы Department__c был невалидным, тут упало бы (FIELD_INTEGRITY_EXCEPTION)
// Шаг 4: Before-Flow (если настроен) — у нас его нет
//****  Шаги 1-4 не пишутся  в коде вообще, они происходят автоматически, внутри самого Salesforce, ещё до того, как  триггер вообще начинает выполняться.
//================================================================================================
// Шаг 5: BEFORE TRIGGERS — мы вписываем код сюда, ветка isBefore
 if (Trigger.isBefore && Trigger.isInsert) {

// Шаг 6: Validation Rules — тут проверяется наш ISBLANK(Name)
// Шаг 7: Duplicate Rules — если бы были настроены
// Шаг 8: Запись СОХРАНЯЕТСЯ в БД, появляется Id
    
System.debug('BEFORE INSERT: we are processing ' + Trigger.new.size() + ' records. Id Not yet.');

 }

// Шаг 9: AFTER TRIGGERS — мы вписываем код сюда, ветка isAfter
if (Trigger.isAfter && Trigger.isInsert) {
 
    // Шаг 10+: Assignment/Workflow/Flow/Sharing Rules — у нас не настроены
// Финал: Commit — всё окончательно фиксируется в базе
for (Employee__c emp : Trigger.new) {
    System.debug('AFTER INSERT: запись сохранена, Id = ' + emp.Id + ', Name = ' + emp.Name);
}

}

}
///
////Employee__c testEmp = new Employee__c();
//testEmp.Name = 'Trigger Test';
//insert testEmp;
