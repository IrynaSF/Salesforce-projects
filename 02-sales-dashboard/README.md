# 02 · Sales Dashboard

## Business scenario

Sales managers want a quick view of **which customers actually brought revenue** without building reports. The same component should work in two places:

- **As an app tab**: a list of all accounts with Closed Won deals, total won amount per account, search by name and pagination.
- **On an Account record page**: only that account's won deals.

From any deal the user can open a modal with the **products sold** in it.

## How it works

```
salesDashboard (LWC)
 ├─ recordId present?  ── yes ─► SalesDashboardController.getAccountData(accountId)
 │                      └─ no ──► SalesDashboardController.getAllAccountsData()
 │                                  └─ Accounts WHERE Id IN (won Opportunities)
 │                                     + child subquery of Closed Won Opportunities
 │                                     → List<AccountWrapper> with totalClosedAmount
 ├─ search box  → client-side filter of accounts by name
 ├─ pagination  → 10 accounts per page (getter-based slicing)
 └─ row action "Preview Products" → getProducts(opportunityId) → modal with lightning-datatable
```

## Components

| Type | Name | Purpose |
|------|------|---------|
| Apex | `SalesDashboardController` | Three `@AuraEnabled(cacheable=true)` methods; inner `AccountWrapper` class aggregates won amount per account |
| Apex | `SalesDashboardControllerTest` | Test data factory for accounts, opportunities, pricebook entries and line items; covers both modes |
| LWC | `salesDashboard` | Dual-mode UI (tab vs record page via `recordId`), search, pagination, datatable row actions, modal |

## What I learned

- Designing one LWC for several Lightning page contexts using `@api recordId`
- Parent-child (relationship) subqueries and semi-join `WHERE Id IN (SELECT …)`
- Wrapper classes to shape data for the UI
- `lightning-datatable` with row actions, and mapping nested fields (`Product2.Name`) for display
- Async/await with imperative Apex calls and error handling
