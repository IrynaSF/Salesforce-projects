# Apex & LWC Fundamentals

Shorter exercises written while learning the platform, grouped by topic. They are smaller than the [featured projects](../README.md#featured-projects), but they show the building blocks those projects rely on. Code comments are detailed on purpose: they were my study notes.

| Folder | Topics | Examples |
|--------|--------|----------|
| [00-data-model](00-data-model/force-app/main/default/objects) | Custom objects and Custom Metadata Types used by the exercises; relationship modeling: lookup, master-detail, roll-up summary (`Course__c.Total_Lessons__c`), many-to-many through a junction object (`JunctionMany__c`) | `Employee__c` → `Department__c`, `Lesson__c` → `Course__c`, `ChildrenLead__c` → `ParentsLead__c`, `Invoice_Line_Item__c` → `New_Invoice__c` |
| [01-apex-basics](01-apex-basics/force-app/main/default/classes) | Variables and constants, `if/else`, ternary operator, `try/catch/throw`, simple service class with a test, wrapper class | `PeremenKonstant`, `IfElse`, `TernerniiOperator`, `TryCatchThrow`, `GreetingService` + test |
| [02-soql-dml](02-soql-dml/force-app/main/default/classes) | SOQL filters and aggregates, parent-to-child and child-to-parent queries, SOSL global search, insert/update, partial-success DML with `Database.insert(records, false)` and `Database.SaveResult` error handling | `HighValueOpportunities`, `globalSearch`, `ParentChilds`, `DepartmentEmployee`, `CourseLessonsCount`, `UpdateChilds`, `DatabaseErrorHandling` |
| [03-triggers](03-triggers/force-app/main/default) | Order of execution, before/after context, `Trigger.new` / `Trigger.old` comparison, logic-less triggers with handler classes | `EmployeeTrigger`, `ChildTrigger` → `ChildEmplManagerTriggerHandler`, `OldNewTrigger` → `OldNewHandler` + test |
| [04-sharing-model](04-sharing-model/force-app/main/default) | `with sharing` vs `without sharing`, record visibility for a restricted user, `System.runAs` in tests, comparing both modes side by side in an LWC | `WithSharingHandler`, `WithoutSharingHandler`, `TestWithWithoutClass`, `withWithoutSharingLWC` |
| [05-lwc-basics](05-lwc-basics/force-app/main/default) | `@api` parent-child communication, `@track` reactivity and filtering, `@wire` vs imperative Apex, promise chains (`.then/.catch`), `AuraHandledException`, Custom Metadata in LWC, server-side pagination (`LIMIT`/`OFFSET` with page size from Custom Metadata), `lightning-record-picker`, `fetch()` from LWC | `accountCardApi` / `accountListApi`, `trackContactFilter`, `wireOpportunityList`, `leadsFromVa`, `trainingLWC`, `parentsLeadLwc`, `lwcCostomerMetadata`, `externalApiCall` |

All custom objects used in these exercises are in `00-data-model`; deploy it before the other folders.
