//@track нужен, чтобы LWC следил за переменной и автоматически обновлял страницу при её изменении
import { LightningElement, track} from 'lwc';

export default class ExternalApiCall  extends LightningElement {

    //Пишем наши переменные
 @track status;
 @track userData;
 @track hasData;

handleClick(){
this.status = 'Fetching data...';

fetch('https://jsonplaceholder.typicode.com/users/1')
    .then(response => response.json()) //response.json() возвращает новый Promise — потому что парсинг JSON (превращение "сырого" текста ответа в JavaScript объект) — это тоже асинхронная операция,
    // требующая времени. стрелочная функция response => response.json() автоматически возвращает результат — этот новый Promise передаётся следующему .then() в цепочке.
    //Второй .then(data => {...}) — дожидается, пока этот Promise выполнится, и получает уже готовые, распарсенные данные в параметр data.
    
    .then(data => {
        this.userData = data;//Записываем полученные данные в нашу @track переменную userData
        this.hasData = true;//Переключаем "флаг" в true — это включает видимость блока <template lwc:if={hasData}> в HTML 
        this.status = 'Data loaded successfully!';
    })
    .catch(error => {
        this.status = 'Error: ' + error.message;
    })
    .finally(() => {
        console.log('Fetch completed');
    });

}
}
















// добавить т сайт как Trusted Site
//Setup → поиск  CSP Trusted Sites
//New  CSP Trusted Sites
//Нажимаем кнопку "New Trusted URL" (видно справа сверху таблицы)
//Trusted Site Name — например RestCountries
//Trusted Site URL — https://restcountries.com
//Отмечаем Active
//В разделе Context — отмечаем Connect-src (ставим галочку)
//Save