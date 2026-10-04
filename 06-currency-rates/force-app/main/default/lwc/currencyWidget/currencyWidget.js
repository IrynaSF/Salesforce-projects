import { LightningElement, wire } from 'lwc';
import getCurrencyRatesCalculator from '@salesforce/apex/CurrencyRatesLogi.getCurrencyRatesCalculator';
import getBaseCurrencyOptions from '@salesforce/apex/CurrencyRatesCalculator.getBaseCurrencyOptions';
import sendLogToLWC from '@salesforce/apex/CurrencyRatesCalculator.sendLogToLWC';
export default class CurrencyWidget extends LightningElement {

    //Шаг 1: здесь мы объявляем реактивные переменные класса, с которыми будем работать во всём компоненте

    selectedCurrency = 'USD';//переменная, которая хранит текущую выбранную пользователем валюту
    currencyRates;//Здесь будет храниться результат пересчёта
    updateDateTime;//Сюда попадёт дата и время последнего обновления курсов
    status;//Сюда попадёт статус последнего обновления 
    selectedDate;//Сюда попадёт выбранная пользователем дата из календаря
    calendarRates;
    calendarUpdateDateTime;
    calendarStatus;

columns = [
    { label: 'Currency', fieldName: 'code' },
    { label: 'Rate', fieldName: 'rate', type: 'number', cellAttributes: { alignment: 'left' } }
];

    //Шаг 2: используем декоратор @wire для вызова метода Apex и получения данных о курсах валют

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
    //Шаг 3: создаём метод, который будет вызываться при изменении выбранной валюты пользователем. 
    //Этот метод обновляет переменную selectedCurrency, что в свою очередь вызывает повторный вызов метода Apex через декоратор @wire.
    
   handleCurrencyChange(event) {
    this.selectedCurrency = event.detail.value;
}
//Шаг 4: создаём массив с доступными валютами, который будет использоваться в шаблоне для отображения выпадающего списка.

@wire(getBaseCurrencyOptions) rawCurrencyOptions;

get currencyOptions() {
    return (this.rawCurrencyOptions?.data || []).map(code => ({ label: code, value: code }));
}


//Шаг 5: создаём геттер, который будет возвращать массив объектов с кодами валют и их курсами относительно выбранной пользователем валюты.
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