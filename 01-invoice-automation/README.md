# 01 · Invoice Automation

## Business scenario

A sales team closes deals in Salesforce but prepares invoices by hand in a separate tool, then emails them manually and updates the Opportunity stage when the customer answers. The goal was to cover the whole invoice cycle inside Salesforce:

1. **Generate** a branded A4 PDF invoice from an Opportunity with one click.
2. **Store** the PDF on the Opportunity as a File. Regenerating creates a new *version* of the same file instead of a duplicate.
3. **Send** the invoice to the Opportunity's primary contact from a pre-filled, editable email with the PDF attached.
4. **Process the reply**: when the customer answers *Approved* or *Rejected*, the Opportunity moves to *Closed Won* / *Closed Lost* automatically.

## How it works

```
Opportunity record page
 ├── Quick action "Generate Invoice" ──► generateInvoice (LWC)
 │                                       └─► InvoiceGenerator.generateInvoicePDF()
 │                                            ├─ renders Page.InvoicePDF (Visualforce → PDF)
 │                                            └─ inserts ContentVersion (new file or new version)
 │
 ├── Quick action "Send Invoice" ──────► sendInvoiceModal (LWC)
 │                                       ├─► LwcController.getInvoiceData()        contact + latest PDF
 │                                       ├─► EmailTemplateController.getRenderedTemplate()  subject/body
 │                                       ├─  "Preview Invoice" opens the PDF in the file previewer
 │                                       └─► SendEmailController.sendEmail()       email + PDF attachment
 │
 └── Customer replies "Approved" / "Rejected"
         └─► Email Service ► OrderConfirmationEmailHandler / OpportunityEmailHandler
              └─ finds Opportunity by invoice number in the subject, updates StageName
```

## Components

| Type | Name | Purpose |
|------|------|---------|
| Visualforce | `InvoicePDF`, `VisualInvoice` | Invoice templates rendered as PDF: company header, Bill To (primary contact), product table, Balance Due, running header/footer via CSS `@page` |
| Apex | `VisualController` | Standard-controller extension that loads Organization address, Opportunity, primary `OpportunityContactRole` and line items for the PDF |
| Apex | `InvoiceGenerator` | `@AuraEnabled` method that renders the page with `getContentAsPDF()` and saves or versions the file on the Opportunity |
| Apex | `GenerateInvoiceController` | Alternative generator using `FirstPublishLocationId` and `ReasonForChange` for versioning |
| Apex | `LwcController` | Returns recipient name/email, invoice number and latest PDF `ContentDocumentId` |
| Apex | `EmailTemplateController` | Renders the subject from an Email Template with merge fields and builds the HTML body from Opportunity data |
| Apex | `SendEmailController` | Sends the email with the latest PDF version attached; logs it as an activity |
| Apex | `InvoiceEmailController` | Earlier all-in-one version: builds a plain-text email and sends it with the attachment (used by the `sendInvoice` LWC) |
| Apex | `OrderConfirmationEmailHandler`, `OpportunityEmailHandler` | `Messaging.InboundEmailHandler` implementations that parse the reply and update the Opportunity stage |
| LWC | `generateInvoice` | Headless-style quick action with spinner, success/error state, toast, auto-close |
| LWC | `sendInvoiceModal` | Screen quick action: editable To/Subject, rich-text body, Preview and Send buttons |
| LWC | `sendInvoice`, `emailEditor`, `sendEmail` | Earlier/auxiliary versions of the email composer |
| Tests | `VisualTest`, `GenerateInvoiceTest`, `LwcTest`, `EmailTemplateTest`, `OrderConfirmationEmailHandlerTest` | Cover PDF controller, file versioning, data retrieval, template rendering and inbound email parsing |

## Org setup required

Included: Opportunity field `Invoice_Number__c` (Auto Number `INV-{000000}`). Configure in the org:

- Email Template `Invoice_Email_Template`
- Quick actions on Opportunity for `generateInvoice` and `sendInvoiceModal`
- Email Service pointing to `OrderConfirmationEmailHandler`
- Opportunities need a **primary** contact role and products (line items)

## What I learned

- Rendering Visualforce to PDF from Apex and controlling print layout with CSS paged media
- Working with Salesforce Files (`ContentVersion` → `ContentDocument` → `ContentDocumentLink`) and file versioning
- Building LWC quick actions (`lightning__RecordAction`, `CloseActionScreenEvent`, `NavigationMixin` file preview)
- Sending outbound email with attachments and processing inbound email with an Email Service
- Using `Test.isRunningTest()` to stub `getContentAsPDF()`, which is not supported in test context
