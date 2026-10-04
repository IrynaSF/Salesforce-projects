# Salesforce Developer Portfolio

Hands-on Salesforce projects built in a Developer Edition org between January and September 2026. Each project solves a realistic business scenario end to end: data model, Apex back end, Lightning Web Components UI, automation, and unit tests.

**Stack:** Apex · SOQL/SOSL · Lightning Web Components · Visualforce · Flow Builder · Batch & Schedulable Apex · REST callouts · Named Credentials · Custom Metadata Types · Inbound Email Services · Apex unit testing with `HttpCalloutMock`

---

## Featured projects

| # | Project | What it does | Key techniques |
|---|---------|--------------|----------------|
| 01 | [Invoice Automation](01-invoice-automation) | Generates a branded PDF invoice from an Opportunity, stores it as a versioned File, emails it to the primary contact, and closes the deal automatically when the customer replies *Approved* / *Rejected*. | Visualforce `renderAs="pdf"`, `ContentVersion`, LWC quick actions, `Messaging.SingleEmailMessage`, `Messaging.InboundEmailHandler` |
| 02 | [Sales Dashboard](02-sales-dashboard) | One LWC that works both as an app tab (all accounts with Closed Won revenue) and on an Account record page, with search, pagination and a product drill-down modal. | Wrapper classes, parent-child SOQL, `lightning-datatable` row actions, async/await Apex calls |
| 03 | [Scheduled Jobs Manager](03-scheduled-jobs-manager) | Lets a user start/stop a nightly job that creates follow-up Opportunities for yesterday's Closed Won deals, plus a monitor of all scheduled jobs in the org. | `Schedulable`, `System.schedule`, `CronTrigger`, dynamic CRON from UI input, duplicate-job protection |
| 04 | [Batch Data Quality Suite](04-batch-data-quality) | Six batch jobs that clean and flag CRM data (stale opportunities, missing lead sources, uncontacted leads…) and one generic scheduler that can run any of them from an LWC. | `Database.Batchable`, `Type.forName` for dynamic instantiation, reusable scheduler, batch testing |
| 05 | [Weather Widget](05-weather-widget) | LWC that shows live weather for any city using the OpenWeatherMap REST API. | HTTP callouts, Named Credential, Custom Metadata for API settings, typed JSON wrapper, `HttpCalloutMock` |
| 06 | [Currency Rates](06-currency-rates) | Daily import of exchange rates from ExchangeRate-API into Salesforce, rate history log, cross-rate calculator, and an LWC with base-currency picker and historical date lookup. | Callouts + DML logging, `@future(callout=true)`, Schedulable, untyped JSON parsing, `@wire` with reactive params |

Also included:

- **[Flow Automation](flows)**: record-triggered Flows built in Flow Builder (lead rating, website auto-fill, task creation, product on lead conversion), included as Flow metadata.
- **[Apex Fundamentals](apex-fundamentals)**: smaller exercises on Apex syntax, SOQL/DML, triggers and handler pattern, sharing model, and core LWC concepts (`@api`, `@track`, `@wire`, promises, pagination).
- **[Archive](archive)**: earlier iterations of the invoice and currency projects, kept to show how the solutions evolved.

---

## Repository structure

```
.
├── 01-invoice-automation/        each project is an SFDX package directory
│   ├── README.md                 business scenario, design, components
│   └── force-app/main/default/
│       ├── classes/              Apex classes + tests
│       ├── lwc/                  Lightning Web Components
│       ├── objects/              custom objects and fields
│       ├── pages/                Visualforce pages
│       └── triggers/
├── 02-sales-dashboard/
├── ...
├── apex-fundamentals/            learning exercises grouped by topic
├── flows/                        Flow Builder automation
├── archive/                      earlier iterations
└── sfdx-project.json             lists every project as a package directory
```

## Deploying

The source was retrieved from a Developer Edition org: Apex classes, triggers, Visualforce pages, LWCs, custom objects and fields, Custom Metadata Types and Flows. Org-specific configuration is **not** included and is listed in each project's README: Custom Metadata *records* (they hold API keys), Named Credentials, Email Templates, Email Services, quick actions and static resources.

```bash
sf org login web --alias my-dev-org

# deploy a single project
sf project deploy start --source-dir 05-weather-widget/force-app --target-org my-dev-org

# the fundamentals share one data model, deploy it first
sf project deploy start --source-dir apex-fundamentals/00-data-model/force-app --target-org my-dev-org
```

> **Security note:** no credentials are stored in this repository. API keys are read at runtime from Custom Metadata records (`Weather_Setting__mdt`, `Currency_Setting__mdt`) that are configured in the org and not committed here. Endpoints are resolved through Named Credentials (`callout:...`).
