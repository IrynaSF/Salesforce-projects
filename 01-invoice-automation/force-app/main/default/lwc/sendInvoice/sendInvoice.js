import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInvoiceEmailData from '@salesforce/apex/InvoiceEmailController.getInvoiceEmailData';
import sendInvoiceEmail from '@salesforce/apex/InvoiceEmailController.sendInvoiceEmail';

export default class SendInvoice extends LightningElement {
    @api recordId;
    
    emailSubject = '';
    emailBody = '';
    recipientName = '';
    recipientEmail = '';
    pdfUrl = '';
    
    isLoading = true;
    isSending = false;
    hasError = false;
    errorMessage = '';
    
    @wire(getInvoiceEmailData, { opportunityId: '$recordId' })
    wiredData({ data, error }) {
        this.isLoading = false;
        
        if (data) {
            this.emailSubject = data.emailSubject;
            this.emailBody = data.emailBody;
            this.recipientName = data.recipientName;
            this.recipientEmail = data.recipientEmail;
            this.pdfUrl = data.pdfUrl;
            this.hasError = false;
        } else if (error) {
            this.hasError = true;
            this.errorMessage = error.body ? error.body.message : 'Unknown error occurred';
            this.showToast('Error', this.errorMessage, 'error');
        }
    }
    
    handleEmailBodyChange(event) {
        this.emailBody = event.target.value;
    }
    
    handlePreview() {
        if (this.pdfUrl) {
            window.open(this.pdfUrl, '_blank');
        } else {
            this.showToast(
                'Warning', 
                'Invoice PDF not found. Please click "Generate Invoice" first.', 
                'warning'
            );
        }
    }
    
    handleSend() {
        if (!this.emailBody) {
            this.showToast('Error', 'Email body cannot be empty.', 'error');
            return;
        }
        
        this.isSending = true;
        
        sendInvoiceEmail({ 
            opportunityId: this.recordId, 
            emailBody: this.emailBody 
        })
            .then(result => {
                this.showToast('Success!', result, 'success');
                this.closeModal();
            })
            .catch(error => {
                this.isSending = false;
                const errorMsg = error.body ? error.body.message : 'Unknown error occurred';
                this.showToast('Error', errorMsg, 'error');
            });
    }
    
    handleCancel() {
        this.closeModal();
    }
    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    
    get canSend() {
        return !this.isSending && 
               this.emailBody && 
               this.recipientEmail;
    }
}