trigger EmployeeTrigger on Employee__c  (before insert, after insert) {
 // ========================================
// ORDER OF EXECUTION when saving Employee__c
// ========================================
// Step 1: Load the original record (for insert an "empty" one is created in memory)
// Step 2: Apply the new field values (Name, Department__c, etc.)
// Step 3: Validate formats, field lengths, foreign keys (Lookup/Master-Detail)
//        — if Department__c were invalid, it would fail here (FIELD_INTEGRITY_EXCEPTION)
// Step 4: Before-save Flow (if configured): we don't have one
//****  Steps 1-4 are not written in code at all; they happen automatically inside Salesforce before the trigger even starts.
//================================================================================================
// Step 5: BEFORE TRIGGERS: our code goes here, in the isBefore branch
 if (Trigger.isBefore && Trigger.isInsert) {

// Step 6: Validation Rules: our ISBLANK(Name) is checked here
// Step 7: Duplicate Rules: if configured
// Step 8: The record is SAVED to the database and gets an Id
    
System.debug('BEFORE INSERT: we are processing ' + Trigger.new.size() + ' records. Id Not yet.');

 }

// Step 9: AFTER TRIGGERS: our code goes here, in the isAfter branch
if (Trigger.isAfter && Trigger.isInsert) {
 
    // Step 10+: Assignment/Workflow/Flow/Sharing Rules: not configured here
// Final: Commit, everything is permanently saved to the database
for (Employee__c emp : Trigger.new) {
    System.debug('AFTER INSERT: record saved, Id = ' + emp.Id + ', Name = ' + emp.Name);
}

}

}
///
////Employee__c testEmp = new Employee__c();
//testEmp.Name = 'Trigger Test';
//insert testEmp;
