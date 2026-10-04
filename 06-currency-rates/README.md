# 06 · Currency Rates (scheduled integration with history)

## Business scenario

An international sales team quotes deals in several currencies and needs **up-to-date exchange rates inside Salesforce**, plus the ability to look up **what the rate was on a given day**. Rates should refresh automatically every day, and every API response should be logged for audit and troubleshooting.

## How it works

```
CurrencyRatesScheduler (Schedulable, daily)
 └─ @future(callout=true) getApi(baseCurrency)      callouts are not allowed directly in scheduled context
      └─ CurrencyRatesService.getRates(baseCurrency)
           ├─ API key from Custom Metadata (Currency_Setting__mdt)
           ├─ GET callout:ExchangeRate_Auth/v6/<key>/latest/<base>
           ├─ JSON.deserializeUntyped → Map<String, Decimal>
           ├─ insert Currency_Rate_Log__c   (raw JSON, status, timestamp, base currency)
           └─ bulk insert Currency_Rate__c  (one per currency, lookup to the log)

currencyWidget (LWC)
 ├─ base currency combobox (values read from picklist metadata)
 ├─ latest rates   ─► CurrencyRatesLogi.getCurrencyRatesCalculator(selectedCurrency)
 └─ date picker    ─► CurrencyRatesCalculator.sendLogToLWC(date, selectedCurrency)
                       └─ recalculates cross rates: rate / baseRate
```

## Data model

| Object | Key fields |
|--------|-----------|
| `Currency_Rate_Log__c` | `Base_Currency__c` (picklist), `Response_JSON__c`, `Status__c`, `Update_DateTime__c` |
| `Currency_Rate__c` | `Currency_Code__c`, `Rate__c`, `Currency_Rate_Log__c` (lookup) |
| `Currency_Setting__mdt` | `Api_Key__c` |

## Components

| Type | Name | Purpose |
|------|------|---------|
| Apex | `CurrencyRatesService` | Callout, parsing, logging and bulk insert of rates |
| Apex | `CurrencyRatesScheduler` | Daily job; reuses the last base currency, defaults to USD |
| Apex | `CurrencyRatesCalculator` | Picklist options, cross-rate recalculation, historical lookup by date (`DAY_ONLY`) |
| Apex | `CurrencyRatesLogi` | Latest log + rates recalculated for the selected currency |
| Apex | `CurrencyDisplayWrapper` | DTO returned to the LWC (rates, timestamp, status) |
| Tests | `CurrencyRatesServiceTest`, `CurrencyRatesCalculatorTest` | Callout mock, log/rate creation, recalculation |
| LWC | `currencyWidget` | Currency selector, date picker, `lightning-datatable` of rates, last update info |

## Org setup required

- Named Credential `ExchangeRate_Auth` → `https://v6.exchangerate-api.com`
- Custom objects and Custom Metadata Type listed above, with your own API key in a metadata record
- Schedule the job, e.g. `System.schedule('Currency Rates Daily', '0 0 7 * * ?', new CurrencyRatesScheduler());`

## What I learned

- Combining Schedulable and `@future(callout=true)` to run callouts on a schedule
- Untyped JSON parsing for dynamic keys (currency codes)
- Integration logging pattern: store the raw response plus parsed child records
- Bulk DML (one insert for all rates) to stay within governor limits
- Reading picklist values from schema describe for dynamic UI options
