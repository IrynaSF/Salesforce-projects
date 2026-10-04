trigger EmployeeManagerTrigger on Employee__c (before insert) {
    ChildEmplManagerTriggerHandler.findManagersWithSalaryAccess();
}
