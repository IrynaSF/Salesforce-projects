import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getInvoiceData from '@salesforce/apex/LwcController.getInvoiceData';
import getRenderedTemplate from '@salesforce/apex/EmailTemplateController.getRenderedTemplate';
import sendEmail from '@salesforce/apex/SendEmailController.sendEmail';

export default class SendInvoiceModal extends NavigationMixin(LightningElement) {
    @api recordId;
    @track dataFromApex;
    @track toAddress = '';
    @track subject = '';
    @track body = '';

    @wire(getInvoiceData, { oppId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.dataFromApex = data;
            this.toAddress = data.contactEmail || '';
            this.loadTemplate();
        } else if (error) {
            console.error('getInvoiceData error:', JSON.stringify(error));
        }
    }

    loadTemplate() {
        getRenderedTemplate({
            developerName: 'Invoice_Email_Template',
            recordId: this.recordId
        })
        .then(result => {
            this.subject = result.subject;
            this.body = result.htmlBody;
        })
        .catch(error => {
            console.error('Template error:', JSON.stringify(error));
        });
    }

    handleToChange(event) {
        this.toAddress = event.target.value;
    }

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleBodyChange(event) {
        this.body = event.target.value;
    }

    handlePreview() {
        const docId = this.dataFromApex?.contentDocumentId;
        if (!docId) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: 'Please generate invoice first',
                variant: 'warning'
            }));
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: { pageName: 'filePreview' },
            state: {
                recordIds: docId,
                selectedRecordId: this.recordId
            }
        });
    }

    handleSend() {
        sendEmail({
            toAddress: this.toAddress,
            subject: this.subject,
            body: this.body,
            contentDocumentId: this.dataFromApex?.contentDocumentId || ''
        })
        .then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Invoice email sent!',
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

    handleCancel() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}