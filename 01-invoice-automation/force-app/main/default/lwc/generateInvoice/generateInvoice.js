import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateInvoicePDF from '@salesforce/apex/InvoiceGenerator.generateInvoicePDF';

export default class GenerateInvoice extends LightningElement {
    @api recordId;
    
    isLoading = true;
    isSuccess = false;
    hasError = false;
    successMessage = '';
    errorMessage = '';
    
    connectedCallback() {
        this.generateInvoice();
    }
    
    generateInvoice() {
        generateInvoicePDF({ opportunityId: this.recordId })
            .then(result => {
                this.isLoading = false;
                this.isSuccess = true;
                this.successMessage = result;
                
                // Show success toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!',
                        message: result,
                        variant: 'success'
                    })
                );
                
                // Auto close after 2 seconds
                setTimeout(() => {
                    this.dispatchEvent(new CloseActionScreenEvent());
                }, 2000);
            })
            .catch(error => {
                this.isLoading = false;
                this.hasError = true;
                this.errorMessage = error.body ? error.body.message : error.message;
                
                // Show error toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: this.errorMessage,
                        variant: 'error'
                    })
                );
            });
    }
}