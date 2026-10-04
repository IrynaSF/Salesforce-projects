import { LightningElement,track } from 'lwc';
import findAccount from '@salesforce/apex/accountController.findAccount';
export default class AccountLWC extends LightningElement {
  
    //@track status это переменная, в которой будет храниться текст, показанный на экране.
    // это как "включить уведомления" для LWC: "если эта переменная изменится — сразу обнови экран"
    //Почему сначала пустая 
//До нажатия кнопки — status пустая, значит на странице ничего не написано под кнопкой.
//После нажатия — внутри .then() или .catch() мы записываем туда текст
//  (например 'Found: Dickenson plc'), и благодаря @track экран автоматически покажет этот текст.
    @track status;//Переменная с начальным значением 

   handleClick(){//Это метод (функция), который запускается, когда пользователь нажимает кнопку в HTML (потому что мы написали onclick={handleClick}).
   //Здесь мы вызываем Apex метод, который мы написали раньше. Он уходит на сервер Salesforce, выполняет SOQL запрос (ищет 'Dickenson plc'), 
   // //и возвращает результат — но не сразу, а через Promis
   console.log('Button clicked, calling Apex...');
    findAccount()
   
    .then(result => { console.log('Promise resolved, result:', result);
         this.status = 'Found:' + result.Name })//если метод нашел аккаунт (т.е не выбросил ошибку throw) срабатывет этот блок
    
         .catch(error => {  console.log('Promise rejected, error:', error);
        this.status = 'Account is not found' })//если метод не нашел аккаунт то срабатывает этот блок
    
        .finally(() => { console.log('Search completed') });//Этот блок срабатывает всегда — независимо от того, был ли успех (.then()) или ошибка (.catch()).
   }

}
//Точка перед .then()/.catch()/.finally() означает: "возьми то, что вернул предыдущий шаг (Promise), и вызови у него этот метод". Без точки JS не понял бы, что мы хотим обратиться именно к методу Promise,
//  а не создать что-то новое.