public with sharing class CurrencyDisplayWrapper {

    @AuraEnabled
    public Map<String, Decimal> rates;
    @AuraEnabled
    public DateTime updateDateTime;
    @AuraEnabled
    public String status;
}
