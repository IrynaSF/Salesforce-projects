import { LightningElement, track, wire } from 'lwc';
import getWeather from '@salesforce/apex/WeatherController.getWeather';

export default class WeatherWidget extends LightningElement {
    @track cityInput = '';
    @track weatherData;
    @track errorMessage = '';

    weatherWireResult;

    handleCityChange(event) {
        this.cityInput = event.target.value;
    }

    @wire(getWeather, { cityInput: '$cityInput' })
    wiredWeather(result) {
        this.weatherWireResult = result; 
        const { error, data } = result; 
        if (data) {
            this.weatherData = data;
            this.errorMessage = '';
        } else if (error) {
            console.error('Error retrieving weather:', error);
            this.errorMessage = 'Failed to retrieve weather data';
        }
    }


    get weatherDescription() {
        if (this.weatherData && this.weatherData.weather && this.weatherData.weather[0]) {
            return this.weatherData.weather[0].description;
        }
        return '';
    }
}