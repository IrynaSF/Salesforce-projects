import { LightningElement, track, wire } from 'lwc';
import getAccountsList from '@salesforce/apex/macroTaskController.getAccountsList';

export default class MacroTask extends LightningElement {

    //Реактивная переменная — хранит текст статуса. 
    // Начальное значение пустая строка. Когда меняется — LWC автоматически обновляет <p>{status}</p> на странице.
@track status = '';

//Реактивная переменная — хранит список аккаунтов.
//  Начальное значение пустой массив []. Когда сюда попадут данные — for:each в HTML автоматически 
// отрисует список на странице.
@track accounts = [];

//Говорит LWC: "вызови Apex метод getAccountsList и результат положи в переменную wiredAccounts".
@wire(getAccountsList) wiredAccounts;
    

     handleLoad(){
        // Синхронный вывод сообщения в консоль браузера
        console.log('Message: the button was pressed');

        //Меняет переменную status и LWC мгновенно обновляет текст на странице.
        this.status = 'Loading accounts...'

  setTimeout(() => {

    this.status = 'Accounts loaded!'

    //Берём данные которые @wire уже загрузил заранее и кладём их в accounts. 
    // Как только accounts получает данные — for:each в HTML автоматически рисует список аккаунтов на
    //  странице.
    this.accounts = this.wiredAccounts.data;
            console.log('Background process completed');
        }, 3000);

     }
    } 
    //Порядок в стеке:
//Пользователь нажал кнопку → handleLoad попадает в Call Stack
//Выполняется console.log — в консоли появляется сообщение
//Выполняется this.status = 'Loading accounts...' — на странице появляется текст
//JS встречает setTimeout — передаёт его браузеру и не ждёт
//handleLoad завершается и удаляется из стека
//Через 3 секунды браузер кладёт колбэк в Macrotask Queue
//Event Loop берёт его и выполняет — список аккаунтов появляется на странице