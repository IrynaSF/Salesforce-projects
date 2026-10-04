import { LightningElement,track,wire } from 'lwc';
import getAccountName from '@salesforce/apex/microTaskController.getAccountName';

export default class MicroTask extends LightningElement {
    @track status = '';
    
    @wire(getAccountName)
accountName;

     handleLoad(){
        // Синхронный вывод сообщения в консоль браузера
        console.log('Message: the button was pressed');

        //Итого порядок:
//Promise.resolve() — создаём выполненный Promise
//.then() — уходит в Microtask Queue
//JS заканчивает синхронный код (setTimeout регистрируется)
//Только потом JS берёт .then() из очереди и выполняет

        Promise.resolve().then(() => {
    this.status = this.accountName.data;
    console.log('The status has changed');
});

//Порядок
//JS видит setTimeout — передаёт его браузеру
//Браузер запускает таймер в фоне
//JS продолжает выполнять остальной код
//Через 3 секунды браузер кладёт функцию в Callback Queue
//Event Loop берёт её оттуда — но только когда Call Stack пуст и Microtask Queue пуста
//Только тогда выполняется console.log
     setTimeout(() => {
            console.log('Background process completed');
        }, 3000);

     }
}


//Сценарий:Компонент загружает данные аккаунта с сервера. 
// Пока данные грузятся — показывает "Loading...". Когда данные пришли — выводит имя аккаунта.