# Flow Automation (Flow Builder)

Declarative automation built with record-triggered Flows before moving on to Apex. The Flow metadata is in [`force-app/main/default/flows`](force-app/main/default/flows), together with the `Lead.Product__c` field used by the lead-conversion flow.

| Flow | Trigger | Logic |
|------|---------|-------|
| **Set Lead Rating Based on Source** | Lead, *before save*, on create | Decision on `LeadSource`: *Web* → Rating **Hot**, *Phone Inquiry* → **Warm**, anything else → **Cold**. Uses before-save fast field updates (no extra DML). |
| **Auto-fill Website from Email** | Lead, *before save*, on create, when Email is not null | Formula extracts the domain after `@` and sets `Website = "www." + domain`. |
| **Create Task for New Contact** | Contact, *after save*, on create | Creates a **High** priority *Call* task for the contact owner, related to the contact's Account, with a reminder at 10:00 three days after creation (DateTime formula). |
| **Add Product to Opportunity on Lead Conversion** | Lead, *after save*, on update, when `IsConverted = true` and a converted Opportunity exists | Looks up the Product by the code stored on the lead (`Product__c`), finds its active Pricebook Entry, and if found creates an Opportunity Product (quantity 1) on the converted Opportunity. |

Other flows in the org (draft or experimental): `Generate_Invoice_Screen_Flow` (screen flow prototype for the [invoice project](../01-invoice-automation)) and `Calendarific` (HTTP callout to a public-holidays API).

## Skills practised

- Before-save vs after-save record-triggered flows and when to use each
- Entry conditions, Decision elements, Get/Create/Update Records
- Formula resources (text parsing, DateTime calculation)
- Null-checks on lookups before creating related records
