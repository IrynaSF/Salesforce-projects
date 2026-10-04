import { LightningElement, track } from 'lwc';
import getChildrenByParent from '@salesforce/apex/ParentsLeadController.getChildrenByParent';
export default class ParentsLeadLwc extends LightningElement {

    
   @track status = '';// Пустая строка '' означает — пока ничего не показываем.Если бы мы сразу написали бы какой то текст то пользователь увдел бы его до того как нажал на кнопку
   @track children = []; //список скрыт до поиска
   @track hasChildren = false ;//пустой масив нам нужен для того чтобы потом вложить в него наших дитей

   //Для пагинации 
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
    return `Shown ${start}-${end} из ${this.totalChildren}`;
}
get totalPages() {
    return Math.ceil(this.totalChildren / this.pageSize);
}

    // ==== Метод при выборе родителя (ПЕРЕДЕЛАТЬ) ====
    async handleParentChange(event) {
        this.selectedParentId = event.detail.recordId;
        this.currentPage = 0;  // сброс на первую страницу при новом выборе родителя
        await this.loadChildren();  // вызов общей логики (см. ниже)
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
    // ==== Метод кнопки Next (НОВЫЙ) ====
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
    // ==== Общая, переиспользуемая логика вызова Apex (НОВЫЙ, вынесенный из старого handleClick) ====
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