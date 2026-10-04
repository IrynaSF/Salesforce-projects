import { LightningElement, track } from 'lwc';
import getChildrenByParent from '@salesforce/apex/ParentsLeadController.getChildrenByParent';
export default class ParentsLeadLwc extends LightningElement {

    
   @track status = '';// An empty string '' means nothing is shown yet. If we set text right away, the user would see it before clicking the button
   @track children = []; // the list is hidden until a search
   @track hasChildren = false ;// flag that shows the list once children are loaded

   // For pagination
   @track currentPage = 0;
   @track totalChildren = 0;
   @track pageSize = 5;
   
   columns = [
        { label: 'First Name', fieldName: 'First_Name__c' },
        { label: 'Last Name', fieldName: 'Last_Name__c'} ,
        { label: 'Email', fieldName: 'Email__c', type: 'email' },
        { label: 'Phone', fieldName: 'Phone__c', type: 'phone' },
   ];

 get displayRange() {
    const start = this.currentPage * this.pageSize + 1;
    const end = Math.min((this.currentPage + 1) * this.pageSize, this.totalChildren);
    return `Shown ${start}-${end} of ${this.totalChildren}`;
}
get totalPages() {
    return Math.ceil(this.totalChildren / this.pageSize);
}

    // ==== Handler when a parent is selected ====
    async handleParentChange(event) {
        this.selectedParentId = event.detail.recordId;
        this.currentPage = 0;  // reset to the first page when a new parent is selected
        await this.loadChildren();  // call the shared logic (see below)
    }
get pageNumbers() {
    const pages = [];
    for (let i = 1; i <= this.totalPages; i++) {
        pages.push({
            number: i,
            cssClass: i - 1 === this.currentPage ? 'slds-text-title_bold' : ''
        });
    }
    return pages;
}
    // ==== Next button handler ====
  async handleNextPage() {
    if ((this.currentPage + 1) * this.pageSize < this.totalChildren) {
        this.currentPage++;
        await this.loadChildren();
    }
}

async handlePreviousPage() {
    if (this.currentPage > 0) {
        this.currentPage--;
        await this.loadChildren();
        
    }
}
async handlePageClick(event) {
    this.currentPage = Number(event.currentTarget.dataset.page) - 1;
    await this.loadChildren();
}
    // ==== Shared, reusable Apex call logic (extracted from the old handleClick) ====
    async loadChildren() {
        if (!this.selectedParentId) {
            this.children = [];
            this.status = 'Please select a parent first';
            
            return;
        }

        const result = await getChildrenByParent({
            parentId: this.selectedParentId,
            pageNumber: this.currentPage,
            
        });

         this.children = result.children;
        this.totalChildren = result.totalCount;
        this.pageSize = result.pageSize;
       this.status = 'Found: ' + this.totalChildren + ' children';

        
    }
   
}