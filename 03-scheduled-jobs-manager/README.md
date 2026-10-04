# 03 · Scheduled Jobs Manager

## Business scenario

After a deal is won, the sales team wants a **follow-up opportunity** for repeat business with the same customer, created automatically every day. Admins should be able to start or stop this automation **from the UI** (no Developer Console) and see **all scheduled jobs** running in the org.

## How it works

**Follow-up scheduler**

```
opportSchedulerLWC
 ├─ shows job status (NOT STARTED / WAITING / …)
 ├─ user picks a time (e.g. 08:00) → "Launch"
 │    └─ OpportSchedulerController.startScheduledJob("08:00")
 │         ├─ validates input, blocks duplicate jobs (CronTrigger lookup)
 │         └─ System.schedule(name, "0 00 08 * * ?", new OpportSchedulerClass())
 └─ "Stop" → abortScheduledJob() → System.abortJob()

OpportSchedulerClass (Schedulable), runs daily:
 └─ finds Opportunities Closed Won YESTERDAY
    └─ bulk-inserts "Follow-up: <name>" Opportunities (Prospecting, close date +90 days)
```

Design note: the query uses `CloseDate = YESTERDAY` rather than `LAST_N_DAYS:30`. Because the job runs daily, a 30-day window would pick up the same deals again and create duplicates. Filtering on yesterday guarantees exactly one follow-up per won deal.

**Jobs monitor**

`scheduledJobsMonitorLWC` lists every active (`WAITING`) `CronTrigger` in the org with job name, next fire time, times triggered and CRON expression, sorted by next run.

## Components

| Type | Name | Purpose |
|------|------|---------|
| Apex | `OpportSchedulerClass` | `Schedulable` job that creates follow-up Opportunities in bulk |
| Apex | `OpportSchedulerController` | Start/stop/status API for the LWC; builds CRON from a time string |
| Apex | `ScheduledJobsMonitorController` | Returns active scheduled jobs from `CronTrigger` |
| LWC | `opportSchedulerLWC` | Time picker (combobox), Launch / Stop buttons, live status |
| LWC | `scheduledJobsMonitorLWC` | Table of active scheduled jobs |
| Tests | `OpportSchedulerClassTest`, `OpportSchedulerControllerTest`, `ScheduledJobsMonitorControllerTest` | Cover job execution, validation branches, duplicate protection and abort |

## What I learned

- Schedulable Apex, CRON expressions and the `CronTrigger` / `CronJobDetail` objects
- Exposing admin operations safely to an LWC (validation, idempotency, clear messages)
- Testing scheduled jobs with `Test.startTest()` / `Test.stopTest()`
