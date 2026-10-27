# 07 · Equipment Checkout (Apex + LWC + Flow)

> **In short:** a small Salesforce app for lending office equipment to employees. It tracks who has which device, blocks double checkout, sets due dates automatically, and reminds people about overdue or maintenance returns.
>
> **What I built:**
> - **Data model:** `Equipment__c` and a `Checkout__c` junction object linked to Contacts with two Master-Detail fields
> - **Apex:** a bulkified trigger + handler (double-checkout validation, status sync), an `@AuraEnabled` controller, and unit tests
> - **LWC:** a searchable equipment catalog with a `LightningModal` employee picker, and a parent–child "My Equipment" panel
> - **Flow:** 5 Flows in Flow Builder, covering Screen Flows to issue and return equipment, a before-save Flow for the due date, an after-save Flow for maintenance tasks, and a daily Scheduled Flow for overdue checkouts
>
> *Mentor-guided practice project, built in a Developer Edition org (October 2026).*

## Business scenario

An office lends equipment to employees (laptops, monitors, headsets). The team tracks this in a spreadsheet and often finds out too late that a device is already taken, overdue, or needs maintenance. The goal is to run the whole lending cycle inside Salesforce:

1. **Issue** equipment to an employee, and never issue the same device twice.
2. **Keep the status in sync** automatically: *Available* → *In Use* → *Available*.
3. **Set a due date** based on the equipment type.
4. **Return** one or several items in a few clicks.
5. **Remind** people about overdue equipment, and ask for it back when it has to go to maintenance.

The same data model is used two ways: through Lightning Web Components backed by Apex, and through Flows built in Flow Builder. The idea was to compare when code fits better and when declarative automation does.

## Data model

```
Contact (employee) ──< Checkout__c >── Equipment__c
                    Master-Detail   Master-Detail
```

| Object | Key fields |
|--------|-----------|
| `Equipment__c` | `Name`, `Type__c` (Laptop / Monitor / Headset …), `Status__c` (Available / In Use / Maintenance) |
| `Contact` | `Active_Checkouts__c`, `Overdue_Checkouts__c` (Roll-Up Summary, COUNT of Checkouts) |
| `Checkout__c` (junction) | `Employee__c` (Master-Detail → Contact), `Equipment__c` (Master-Detail → Equipment__c), `Checkout_Date__c`, `Due_Date__c`, `Return_Date__c`, `Is_Overdue__c`, `Equipment_Name__c` |

A checkout with an empty `Return_Date__c` is an **open** checkout, meaning the device is still with the employee.

## How it works

### Apex: trigger + handler

```
CheckoutTrigger (before insert, after insert, after update)
 └─ CheckoutTriggerHandler
     ├─ preventDoubleCheckout()   before insert: one SOQL for all incoming records,
     │                            addError() if the equipment already has an open checkout
     ├─ markEquipmentInUse()      after insert:  Equipment.Status__c = 'In Use'
     └─ markEquipmentAvailable()  after update:  Return_Date__c changed from null → 'Available'
```

All three methods are bulkified. They collect Ids into a `Set`, run one query, and finish with one DML on a `Map` of records, so a batch of 200 checkouts behaves the same as a single one.

### Lightning Web Components

```
equipmentCatalog (App / Home page)
 ├─ @wire getAvailableEquipment, search by type (getter + filter)
 ├─ lightning-datatable with a "Check Out" row action
 ├─ employeeSelectModal (LightningModal) ─► returns the selected employee Id
 └─ checkoutEquipment() imperative call ─► toast ─► refreshApex

myEquipmentPanel (parent, App page)
 ├─ employee combobox (@wire getContacts)
 ├─ "Returned this session" counter
 └─ myCheckoutsList (child)
      ├─ @api contactId ─► @wire getMyCheckouts (reactive '$contactId')
      ├─ "Return" button per item (data-id) ─► returnEquipment() ─► refreshApex
      └─ dispatches the custom event "returned" ─► the parent updates its counter
```

`EquipmentController` methods use `WITH USER_MODE` / `WITH SECURITY_ENFORCED`, and DML errors are re-thrown as `AuraHandledException` so the UI shows a readable message (for example, the double-checkout error from the trigger).

### Flows (Flow Builder)

| Flow | Type | What it does |
|------|------|--------------|
| **Issue Equipment** | Screen Flow (input: Contact `recordId`) | Pick an equipment type (picklist choice set) → Data Table of *Available* equipment of that type (single select) → confirmation screen → creates `Checkout__c` → shows the calculated due date. A screen validation rule stops the user when nothing of that type is available; a Fault Path shows `$Flow.FaultMessage` (for example, the trigger's double-checkout error). |
| **Return Equipment** | Screen Flow (input: Contact `recordId`) | Gets the employee's open checkouts → Decision: nothing to return? → multi-select Data Table → Loop + Assignment set `Return_Date__c = TODAY` and collect the records → **one** Update Records outside the loop → "Returned: N item(s)". Fault Path to an error screen. |
| **Checkout Set Due Date** | Record-Triggered, **before save**, on create | Decision on `Equipment__r.Type__c`: Laptop 14 days, Monitor 30 days, others 7 days → formula `Checkout_Date__c + daysToAdd` → `$Record.Due_Date__c`. No extra DML because the record is changed before it is saved. |
| **Equipment Maintenance Notify** | Record-Triggered, **after save**, on update of `Equipment__c` | Runs only when `Status__c` changes to *Maintenance*. Finds the open checkout of that device and creates a Task for the employee's owner: *"Return the equipment: it is being sent for maintenance"*. |
| **Checkout Overdue Check** | **Scheduled** Flow, daily | For open checkouts not yet flagged: if `Due_Date__c < TODAY`, it creates a reminder Task (with a formula subject) and sets `Is_Overdue__c = true`, so each overdue checkout gets only one reminder. |

Flow metadata is in [`force-app/main/default/flows`](force-app/main/default/flows) (Return Equipment, Checkout Set Due Date, Equipment Maintenance Notify, Checkout Overdue Check).

The Apex trigger and the Flows work together. For example, when a user issues equipment through the Screen Flow, the trigger still blocks double checkout and sets *In Use*, and the before-save Flow sets the due date.

## Components

| Type | Name | Purpose |
|------|------|---------|
| Trigger | `CheckoutTrigger` | Thin trigger; delegates to the handler by context |
| Apex | `CheckoutTriggerHandler` | Double-checkout validation, equipment status sync |
| Apex | `EquipmentController` | `@AuraEnabled` API for the LWCs: available equipment, checkout, return, my checkouts, contacts |
| Tests | `CheckoutTriggerHandlerTest`, `EquipmentControllerTest` | `@TestSetup` data, positive and negative cases (double checkout, returning a deleted record, null input) |
| LWC | `equipmentCatalog` | Catalog with search and a Check Out action |
| LWC | `employeeSelectModal` | `LightningModal` that returns the chosen employee |
| LWC | `myEquipmentPanel` / `myCheckoutsList` | Parent–child pair: `@api` property down, custom event up |
| Flow | 5 Flows | See the table above |

## Screenshots

### Employee (Contact) page
Roll-up summary fields **Active Checkouts** / **Overdue Checkouts**, a warning shown when the employee has overdue equipment, **Issue Equipment** / **Return Equipment** buttons that launch the Screen Flows, and the Tasks created by the automation.

![Contact page](screenshots/contact-page.png)

### Issue Equipment (Screen Flow)
| Step 1: pick an equipment type | Flow Builder: lookup, Loop to count available items, Data Table |
|---|---|
| ![Issue flow: pick type](screenshots/issue-flow-pick-type.png) | ![Issue flow builder, part 1](screenshots/flow-builder-issue-1.png) |

Flow Builder, part 2: confirmation, **Create Checkout** with a **Fault Path** to an error screen, and the result screen with the due date

![Issue flow builder, part 2](screenshots/flow-builder-issue-2.png)

### Return Equipment (Screen Flow)
| Multi-select the open checkouts to return | Flow Builder: Decision, Loop + Assignment, **one** Update outside the loop, Fault Path |
|---|---|
| ![Return flow: select checkouts](screenshots/return-flow-select.png) | ![Return flow builder](screenshots/flow-builder-return.png) |

### Background automation
| Equipment set to *Maintenance* creates a "return the equipment" Task | Record-Triggered (after save) Flow behind it |
|---|---|
| ![Maintenance task](screenshots/maintenance-task.png) | ![Maintenance notify flow](screenshots/flow-builder-maintenance-notify.png) |

Daily **Scheduled Flow**: open checkouts past their due date get a reminder Task and are flagged *Is Overdue*

![Overdue check flow](screenshots/flow-builder-overdue-check.png)

### Lightning Web Components
| Equipment Catalog: search by type, Check Out per row | `LightningModal` to pick the employee |
|---|---|
| ![Equipment Catalog](screenshots/lwc-equipment-catalog.png) | ![Select Employee modal](screenshots/lwc-select-employee-modal.png) |

## What I learned

- Modeling a many-to-many relationship with a junction object and two Master-Detail fields
- Writing a bulk-safe trigger + handler: `Set`/`Map` collections, one query and one DML per context, `addError()`, comparing `Trigger.oldMap` with `Trigger.new`
- Surfacing trigger validation errors in the UI through `AuraHandledException` (LWC) and Fault Paths (Flow)
- LWC composition: `LightningModal`, parent → child through `@api`, child → parent through custom events, `refreshApex` after imperative calls
- Choosing the right Flow type: before-save for field updates on the same record, after-save for related records, Scheduled for time-based checks, Screen Flows for guided user input
- Keeping DML out of loops in Flow (collect in a Loop, then one Update Records)
- Writing Apex tests with `@TestSetup`, `Test.startTest()` / `Test.stopTest()`, and negative-path assertions
