public with sharing class ChildEmplManagerTriggerHandler {

    // Method for our trigger that renames children automatically on creation
      public static void renameChildren(List<Child__c> newChildren) {
 
        // returns a single number: how many records matched the condition.
        Integer existingCount = [SELECT COUNT() FROM Child__c];//*** 
        for (Integer i = 0; i < newChildren.size(); i++) {
            newChildren[i].Name = 'ChildTest' + (existingCount + i + 1); // existingCount: how many records were already in the database before this insert; i: index of the current record in this batch; + 1: since i starts at 0, add one so numbering looks human (1, 2, 3...) rather than (0, 1, 2...)
        }
    }

    

    // Method that finds managers with specific access rights (access to the Salary field)
      public static void findManagersWithSalaryAccess() {

        // Get FieldPermissions where ParentId is the Id of the Permission Set (or Profile) with Read access to Salary.
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

    // Loop: for (Type variable : collection)
    for (PermissionSetAssignment permission : assignments) {
        System.debug('Manager with Salary access: ' + permission.AssigneeId + ' - ' + permission.Assignee.Name);
    }
    }
}
//* The FieldPermissions object stores values in its Field (plain text) field in the "ObjectName.FieldName" format; this is just the convention
// Salesforce uses to record which field is meant inside the system table. We simply compare: "is there a string exactly equal to this text".
//** Assignee.Name (in SELECT, WITHOUT quotes) is a REAL relationship through a Lookup
// Here the dot means: "PermissionSetAssignment has a Lookup field Assignee (pointing to User); take the Name field of the related User record". This is a real relationship traversal between objects, like what we did before (e.g. parent.ChildrenLeads__r in the LWC).
// Key difference: in quotes it's just a text match; without quotes, as a field name in SELECT/WHERE, it's a real relationship through a Lookup.
//*** What COUNT() is in SOQL
// A regular SOQL query (SELECT Id, Name FROM ...) returns a list of records (List<sObject>), each row containing all requested fields of a record.
// COUNT() is an aggregate function. Instead of returning the records, it returns one number: how many records matched. Salesforce doesn't load the fields at all, it just counts.
// SELECT with plain COUNT(), no arguments. Salesforce recognizes this special form and returns the result as a single Integer rather than a list, so we don't wrap it in List<...> but assign it straight to an Integer.
