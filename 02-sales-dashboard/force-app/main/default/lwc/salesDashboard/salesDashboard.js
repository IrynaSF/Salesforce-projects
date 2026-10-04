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
     @track isModalOpen = false;     // Флаг для модального окна
    selectedOppId;                 // ID выбранной Opportunity
    @track products = [];          // Список товаров
    currentPage = 1;  // Текущая страница пагинации
    @track filteredAccounts = [];
    opportunityColumns = COLUMNS;
      columns = COLUMNS;
 productColumns = PRODUCT_COLUMNS;            
// 2. Помечаем метод как async
   
async connectedCallback() {
        console.log('--- Начало работы connectedCallback ---');


        try {
            if (this.recordId) {
                console.log('Загрузка данных для конкретного ID: ' + this.recordId);
                // 3. Вызываем Apex через await
                // Передаем параметры в виде объекта
                this.accountsData= await getAccountData({ accountId: this.recordId});
                this.filteredAccounts = this.accountsData;
                console.log('Данные записи успешно получены:', this.accountsData);
            } else {
                console.log('recordId не найден. Загрузка общего списка...');
                this.accountsData = await getAllAccountsData()
                this.filteredAccounts = this.accountsData;
                console.log('Общий список успешно получен. Количество записей: ' + this.accountsData.length);
            }
        } catch (error) {
            // 4. Обрабатываем ошибки (например, проблемы с правами доступа или сервером)
            this.error = error;
            console.error('Произошла ошибка при вызове Apex:', error);
        } finally {
            console.log('--- Завершение выполнения connectedCallback ---');
        }
    }
async handleShowProducts(event) {
    console.log('--- Начало handleShowProducts ---');


    try {
        // Шаг 1: Достаем Id из атрибута data-id элемента, на который нажали
        const oppId = event.detail.row.Id;
        console.log('Выбранный Opportunity ID:', oppId);


        // Шаг 2: Вызываем Apex метод getProducts и ждем результат (await)
        // Передаем oppId в объект параметров
        console.log('Запрос товаров с сервера...');


       const rawProducts = await getProducts({ opportunityId: oppId });
this.products = rawProducts.map(item => ({ ...item, productName: item.Product2.Name }));


        console.log('Товары успешно загружены:', this.products);


        // Шаг 3: Открываем модальное окно
        this.isModalOpen = true;
        console.log('Модальное окно открыто');


    } catch (error) {
        // Обработка ошибок, если Apex вернул ошибку или сеть недоступна
        console.error('Произошла ошибка при загрузке товаров:', error);
    }
}
handleCloseModal() {
  this.isModalOpen = false;
}
get isTabMode() {
    return !this.recordId;
}
handleSearch(event) {
//1. Достать введённый текст из события — event.target.value
const searchValue = event.target.value;
     console.log('Достаем введенный текст из события');
       // 2. Фильтруем оригинальный массив и ЗАПИСЫВАЕМ результат
    // Мы берем исходные данные (this.accountsData) и результат фильтрации
    // кладем в свойство, которое привязано к интерфейсу (this.filteredAccounts)
    this.filteredAccounts = this.accountsData.filter(acc =>
        acc.accountName.toLowerCase().includes(searchValue)
    );


    console.log('Список обновлен, найдено элементов:', this.filteredAccounts.length);
}
get pagedAccounts() {
    const start = (this.currentPage - 1) * 10;
    const end =this.currentPage * 10;
    return this.filteredAccounts.slice(start, end);
}
// Переход на следующую страницу
handleNextPage() {
    // Рассчитываем индекс последней страницы
    // Math.ceil округляет результат деления в большую сторону
    const maxPage = Math.ceil(this.filteredAccounts.length / 10);


    if (this.currentPage < maxPage) {
        this.currentPage += 1;
        console.log('Переход на страницу:', this.currentPage);
    } else {
        console.log('Это последняя страница, дальше нельзя');
    }
}




// Переход на предыдущую страницу
handlePrevPage() {
    if (this.currentPage > 1) {
        this.currentPage -= 1;
        console.log('Переход на страницу:', this.currentPage);
    } else {
        console.log('Вы на первой странице, назад нельзя');
    }
}


 
}