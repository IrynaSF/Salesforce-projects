# Salesforce Developer Portfolio

Hands-on Salesforce projects built in a Developer Edition org during mentor-guided training (2026). Each project solves a realistic business scenario end to end: data model, Apex back end, Lightning Web Components UI, automation, and unit tests. Every project folder has a README with screenshots from the org.

**Stack:** Apex · SOQL · Triggers · Lightning Web Components · Flow Builder (Screen, Record-Triggered, Scheduled) · Schedulable Apex · REST callouts · Named Credentials · Custom Metadata Types · Apex unit testing with `HttpCalloutMock`

---

## Projects

| Project | What it does | Key techniques |
|---------|--------------|----------------|
| [Equipment Checkout](07-equipment-checkout) | Lends office equipment to employees: blocks double checkout, keeps equipment status in sync, sets due dates by type, flags overdue items and asks for returns before maintenance. Built on one data model with LWC + Apex and with Flows. | Junction object (2× Master-Detail), Roll-Up Summary fields, bulkified trigger + handler, `LightningModal`, parent–child LWC events, Screen / before-save / after-save / Scheduled Flows, Fault Paths |
| [Currency Rates](06-currency-rates) | Scheduled import of exchange rates from ExchangeRate-API with a response log, cross-rate calculation, and an LWC with a base-currency picker and historical date lookup. | Callouts + DML logging, `@future(callout=true)`, Schedulable, Named Credential, untyped JSON parsing, `@wire` with reactive params |
| [Weather Widget](05-weather-widget) | Home-page LWC that shows live weather for any city using the OpenWeatherMap REST API. | HTTP callouts, Named Credential, Custom Metadata for API settings, typed JSON wrapper, `HttpCalloutMock` |
| [Sales Dashboard](02-sales-dashboard) | One LWC that works as an app tab (accounts with Closed Won revenue) and on an Account record page, with search, pagination and a product drill-down. | Wrapper classes, parent-child SOQL, `lightning-datatable` row actions, async/await Apex calls |

---

## Repository structure

```
.
├── 02-sales-dashboard/          each project is an SFDX package directory
│   ├── README.md                summary, business scenario, design, screenshots
│   ├── screenshots/
│   └── force-app/main/default/
│       ├── classes/             Apex classes + tests
│       ├── lwc/                 Lightning Web Components
│       ├── objects/             custom objects and fields
│       └── triggers/
├── 05-weather-widget/
├── 06-currency-rates/
├── 07-equipment-checkout/
└── sfdx-project.json            lists every project as a package directory
```

## Deploying

The source was retrieved from a Developer Edition org. Org-specific configuration is **not** included and is listed in each project's README: Custom Metadata *records* (they hold API keys), Named Credentials and static resources.

```bash
sf org login web --alias my-dev-org

# deploy a single project
sf project deploy start --source-dir 05-weather-widget/force-app --target-org my-dev-org
```

> **Security note:** no credentials are stored in this repository. API keys are read at runtime from Custom Metadata records (`Weather_Setting__mdt`, `Currency_Setting__mdt`) that are configured in the org and not committed here. Endpoints are resolved through Named Credentials (`callout:...`).
