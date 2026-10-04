# Archive: earlier iterations

Earlier versions kept to show how the solutions evolved. They are not used by the featured projects.

| Component | Superseded by | Notes |
|-----------|---------------|-------|
| `InvoicePDFController`, `InvoiceController`, `GenerateInvoiceAction`, `InvController` | `VisualController` + `InvoiceGenerator` in [01-invoice-automation](../01-invoice-automation) | First attempts at the invoice PDF controller. `InvoiceController` adds CRUD checks and `WITH SECURITY_ENFORCED`; `InvController` generates and attaches the PDF from a Visualforce button page. |
| Pages `InvoicePage`, `invoiccccc`, `VisualController`, `GeneralInvoiceButton` | `InvoicePDF`, `VisualInvoice` | Layout experiments: repeating header/footer with `display: table-header-group` vs CSS `position: running()`. |
| `RatesLogi` | `CurrencyRatesLogi` in [06-currency-rates](../06-currency-rates) | Identical earlier copy. |
| `HolidayWrapper`, `HolidayFlat` | n/a | Wrappers for the Calendarific public-holidays API experiment (see [flows](../flows)). |
