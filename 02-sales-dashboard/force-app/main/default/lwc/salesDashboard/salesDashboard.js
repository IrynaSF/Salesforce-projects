import { LightningElement, api, track } from 'lwc';
import getAllAccountsData from '@salesforce/apex/SalesDashboardController.getAllAccountsData';
import getAccountData from '@salesforce/apex/SalesDashboardController.getAccountData';
import  getProducts from '@salesforce/apex/SalesDashboardController.getProducts';


const ACTIONS = [
    { label: 'Preview Products', name: 'preview' }
];
const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency' },
    { type: 'action', typeAttributes: { rowActions: ACTIONS } }
];
const PRODUCT_COLUMNS= [


{ label: 'Product Name', fieldName: 'productName', type: 'text' },


 { label: 'Quantity', fieldName: 'Quantity', type: 'number' },


{ label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },


 { label: 'Total Price', fieldName: 'TotalPrice', type: 'currency' }];


export default class SalesDashboard extends LightningElement {
    @api recordId;
    @track accountsData;
     @track isModalOpen = false;     // Flag for the modal window
    selectedOppId;                 // ID of the selected Opportunity
    @track products = [];          // List of products
    currentPage = 1;  // Current pagination page
    @track filteredAccounts = [];
    opportunityColumns = COLUMNS;
      columns = COLUMNS;
 productColumns = PRODUCT_COLUMNS;            
// 2. Mark the method as async
   
async connectedCallback() {
        console.log('--- connectedCallback started ---');


        try {
            if (this.recordId) {
                console.log('Loading data for a specific ID: ' + this.recordId);
                // 3. Call Apex with await
                // Pass parameters as an object
                this.accountsData= await getAccountData({ accountId: this.recordId});
                this.filteredAccounts = this.accountsData;
                console.log('Record data received successfully:', this.accountsData);
            } else {
                console.log('recordId not found. Loading the full list...');
                this.accountsData = await getAllAccountsData()
                this.filteredAccounts = this.accountsData;
                console.log('Full list received successfully. Number of records: ' + this.accountsData.length);
            }
        } catch (error) {
            // 4. Handle errors (e.g. access rights or server issues)
            this.error = error;
            console.error('An error occurred while calling Apex:', error);
        } finally {
            console.log('--- connectedCallback finished ---');
        }
    }
async handleShowProducts(event) {
    console.log('--- handleShowProducts started ---');


    try {
        // Step 1: get the Id of the clicked row
        const oppId = event.detail.row.Id;
        console.log('Selected Opportunity ID:', oppId);


        // Step 2: call the Apex method getProducts and wait for the result (await)
        // Pass oppId in the parameters object
        console.log('Requesting products from the server...');


       const rawProducts = await getProducts({ opportunityId: oppId });
this.products = rawProducts.map(item => ({ ...item, productName: item.Product2.Name }));


        console.log('Products loaded successfully:', this.products);


        // Step 3: open the modal window
        this.isModalOpen = true;
        console.log('Modal window opened');


    } catch (error) {
        // Error handling in case Apex returned an error or the network is unavailable
        console.error('An error occurred while loading products:', error);
    }
}
handleCloseModal() {
  this.isModalOpen = false;
}
get isTabMode() {
    return !this.recordId;
}
handleSearch(event) {
//1. Get the entered text from the event: event.target.value
const searchValue = event.target.value;
     console.log('Getting the entered text from the event');
       // 2. Filter the original array and STORE the result
    // We take the source data (this.accountsData) and put the filtered result
    // into the property bound to the UI (this.filteredAccounts)
    this.filteredAccounts = this.accountsData.filter(acc =>
        acc.accountName.toLowerCase().includes(searchValue)
    );


    console.log('List updated, items found:', this.filteredAccounts.length);
}
get pagedAccounts() {
    const start = (this.currentPage - 1) * 10;
    const end =this.currentPage * 10;
    return this.filteredAccounts.slice(start, end);
}
// Go to the next page
handleNextPage() {
    // Calculate the index of the last page
    // Math.ceil rounds the division result up
    const maxPage = Math.ceil(this.filteredAccounts.length / 10);


    if (this.currentPage < maxPage) {
        this.currentPage += 1;
        console.log('Going to page:', this.currentPage);
    } else {
        console.log('This is the last page, cannot go further');
    }
}




// Go to the previous page
handlePrevPage() {
    if (this.currentPage > 1) {
        this.currentPage -= 1;
        console.log('Going to page:', this.currentPage);
    } else {
        console.log('You are on the first page, cannot go back');
    }
}


 
}