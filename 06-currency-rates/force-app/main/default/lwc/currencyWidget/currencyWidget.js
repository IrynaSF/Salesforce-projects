import { LightningElement, wire } from 'lwc';
import getCurrencyRatesCalculator from '@salesforce/apex/CurrencyRatesLogi.getCurrencyRatesCalculator';
import getBaseCurrencyOptions from '@salesforce/apex/CurrencyRatesCalculator.getBaseCurrencyOptions';
import sendLogToLWC from '@salesforce/apex/CurrencyRatesCalculator.sendLogToLWC';
export default class CurrencyWidget extends LightningElement {

    // Step 1: declare the reactive class properties used throughout the component

    selectedCurrency = 'USD';// holds the currency currently selected by the user
    currencyRates;// holds the recalculation result
    updateDateTime;// date and time of the last rates update
    status;// status of the last update
    selectedDate;// date selected by the user in the calendar
    calendarRates;
    calendarUpdateDateTime;
    calendarStatus;

columns = [
    { label: 'Currency', fieldName: 'code' },
    { label: 'Rate', fieldName: 'rate', type: 'number', cellAttributes: { alignment: 'left' } }
];

    // Step 2: use the @wire decorator to call the Apex method and get the currency rates

    @wire(getCurrencyRatesCalculator, { selectedCurrency: '$selectedCurrency' })
    wiredCurrencyRates({ error, data }) {
        if (data) {
            this.currencyRates = data.rates;
            this.updateDateTime = data.updateDateTime;
            this.status = data.status;
        } else if (error) {
            console.error('Error fetching currency rates:', error);
        }
    }
    // Step 3: a method called when the user changes the selected currency.
    // It updates selectedCurrency, which in turn re-runs the Apex method through @wire.
    
   handleCurrencyChange(event) {
    this.selectedCurrency = event.detail.value;
}
// Step 4: an array of available currencies used in the template for the dropdown.

@wire(getBaseCurrencyOptions) rawCurrencyOptions;

get currencyOptions() {
    return (this.rawCurrencyOptions?.data || []).map(code => ({ label: code, value: code }));
}


// Step 5: a getter that returns an array of objects with currency codes and their rates against the user's selected currency.
get displayRates() {
    if (this.selectedDate) {
        return this.formatRatesForTable(this.calendarRates);
    }
    return this.formatRatesForTable(this.currencyRates);
}


handleCalendarChange(event){
   this.selectedDate = event.detail.value;

}
@wire(sendLogToLWC, { isoDate: '$selectedDate', selectedCurrency: '$selectedCurrency' })
wiredCalendarRates({ error, data }) {
    if (data) {
        this.calendarRates = data.rates;
        this.calendarUpdateDateTime = data.updateDateTime;
        this.calendarStatus = data.status;
    } else if (error) {
        console.error(error);
    }
}


formatRatesForTable(ratesMap) {
    if (!ratesMap) {
        return [];
    }
    const allCurrencies = this.currencyOptions.map(option => option.value);
const filtered = allCurrencies.filter(code => code !== this.selectedCurrency);
const result = filtered.map(code => ({ code: code, rate: ratesMap[code] }));
    return result;      
} 
get displayInfo() {
    if (this.selectedDate) {
        return { updateDateTime: this.calendarUpdateDateTime, status: this.calendarStatus };
    }
    return { updateDateTime: this.updateDateTime, status: this.status };
} 
}