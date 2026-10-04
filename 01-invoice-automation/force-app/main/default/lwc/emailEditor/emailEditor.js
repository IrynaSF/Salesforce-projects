import { LightningElement, api, track } from 'lwc';
import getRenderedTemplate from '@salesforce/apex/EmailTemplateController.getRenderedTemplate';

export default class EmailEditor extends LightningElement {
    @api templateName;
    @api recordId;

    @track subject = '';
    @track htmlBody = '';
    @track isLoading = true;

    connectedCallback() {
        console.log('EmailEditor start. templateName =', this.templateName, 'recordId =', this.recordId);
        if (this.templateName && this.recordId) {
            this.loadTemplate();
        }
    }

    async loadTemplate() {
        try {
            const result = await getRenderedTemplate({
                developerName: this.templateName,
                recordId: this.recordId
            });
            this.subject = result.subject;
            this.htmlBody = result.htmlBody;
        } catch (error) {
            console.error('❌ Ошибка рендера шаблона:', error);
        } finally {
            this.isLoading = false;
        }
    }

    handleBodyChange(event) {
        this.htmlBody = event.target.value;
    }
}