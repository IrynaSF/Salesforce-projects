import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmail from '@salesforce/apex/SendEmailController.sendEmail';

export default class SendEmail extends LightningElement {
    // ← НЕТ @track toAddress здесь!
    _toAddress = '';
    @track currentSubject = '';
    @track currentBody = '';

    @api
    set toAddress(value) {
        console.log('toAddress setter called with:', value);
        this._toAddress = value || '';
    }
    get toAddress() { return this._toAddress || ''; }

    @api
    set subject(value) { this.currentSubject = value || ''; }
    get subject() { return this.currentSubject; }

    @api
    set body(value) { this.currentBody = value || ''; }
    get body() { return this.currentBody; }

    handleChange(event) {
        const field = event.target.name;
        if (field === 'toAddress') this._toAddress = event.target.value;
        if (field === 'subject') this.currentSubject = event.target.value;
        if (field === 'body') this.currentBody = event.target.value;
    }

    @api
    handleSend() {
        console.log('Sending to:', this._toAddress);
        
        sendEmail({
            toAddress: this._toAddress,
            subject: this.currentSubject,
            body: this.currentBody
        })
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Email sent!',
                variant: 'success'
            }));
            this.dispatchEvent(new CustomEvent('closemodal'));
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Unknown error',
                variant: 'error'
            }));
        });
    }
}