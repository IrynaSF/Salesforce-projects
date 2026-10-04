# 04 · Batch Data Quality Suite

## Business scenario

CRM data degrades over time: leads stay uncontacted, opportunities pass their close date, accounts have no active deals, contacts miss key fields. The business needs **regular, automated clean-up and flagging** that can process any number of records within governor limits, and an admin-friendly way to **schedule** these jobs.

## Batch jobs

| Batch class | Finds | Action |
|-------------|-------|--------|
| `AccountSummaryBatch` | Accounts with no open Opportunities | Description → *No Active Deals - Follow Up Need* |
| `ContactDepartmentBatch` | Contacts with empty Department | Department → *Needs Review* |
| `LeadEngagementBatch` | Leads in *Open - Not Contacted* | Status → *Working - Contacted* |
| `OpportunityPipelineBatch` | Open Opportunities past their close date | Description → *Overdue - Needs Attention* |
| `LeadSourceBatch` | Leads without Lead Source | Lead Source → *Other* |
| `OpportunityAtRiskBatch` | Open Opportunities with no activity in 30+ days | Description → *At Risk* |

## Generic scheduling

Instead of writing one scheduler per batch, a single **universal scheduler** receives the batch class name and instantiates it dynamically:

```apex
Type batchType = Type.forName(batchClassName);
Database.Batchable<sObject> batch = (Database.Batchable<sObject>) batchType.newInstance();
Database.executeBatch(batch, 200);
```

| Class / LWC | Purpose |
|-------------|---------|
| `UniversalBatchScheduler` | `Schedulable` that runs any batch by name |
| `BatchSchedulerController` + `batchSchedulerManager` (LWC) | Pick a batch and a time from comboboxes, Launch / Stop, live status with `refreshApex` |
| `BatchSchedulerUniversal` + `ControllerBatchScheduler` + `batchLWC` | Reusable card configured through `@api batchName` / `@api cronTime` in Lightning App Builder; one card per batch, each job named after its batch |
| `DataQualityScheduler` | Schedules two jobs in code: Lead Source every Monday 9:00, At-Risk every Friday 10:00 |

## Tests

Every batch and scheduler has its own test class that creates test records, runs the job inside `Test.startTest()` / `Test.stopTest()`, and asserts the result.

## What I learned

- `Database.Batchable` lifecycle (`start` → `execute` per chunk → `finish`) and chunk size
- Selective SOQL with date literals (`TODAY`, `LAST_N_DAYS:30`) and anti-joins (`NOT IN`)
- Dynamic class instantiation with `Type.forName` to keep schedulers generic
- Configurable LWCs via `@api` properties exposed in the `js-meta.xml`
