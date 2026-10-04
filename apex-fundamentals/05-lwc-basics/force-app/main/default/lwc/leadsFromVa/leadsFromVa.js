import { LightningElement,track } from 'lwc';
import getVirginiaLeads from '@salesforce/apex/LeadsFromVaController.getVirginiaLeads'

export default class LeadsFromVa extends LightningElement {

    //Пишем наши перенные
@track status = ''; //переменная для хранения текста
@track leads = [];  // пустой массив, в который мы сами записываем данные внутри третьего .then() после того как Apex вернул результат.
@track hasLeads = false; // просто булево значение (true/false), которое контролирует видимость блока lwc:if={hasLeads} в HTML.
// Когда данные загружены — мы пишем this.hasLeads = true, и HTML сам реагирует на это изменение.

handleLoad() { //Объявление метода — он запустится, когда пользователь нажмёт кнопку - (имя метода выбрали потому что в HTML написано onclick={handleLoad})

this.status = 'Loading...'; //показываем пользователю, что процесс начался, пока мы ждём ответа от сервера.(Наш <p>{status}</p> в HTML )

//Вызываем Apex метод — он уходит на сервер, делает SOQL запрос, ищет лидов из Вирджинии. Возвращает Promise — не сразу данные, а "обещание", что данные придут позже.
getVirginiaLeads()

//Принимаем список лидов, который вернул Apex.
//Срабатывает, когда Apex ответил успешно. rawLeads — это список лидов, которые вернул Apex (в "сыром", необработанном виде).
.then(rawLeads => { //rawLeads - сырые лиды
    console.log('Received leads:', rawLeads.length);//Выводим в консоль количество полученных лидов — просто для проверки, что данные реально пришли.
    return rawLeads;
})

//Передаем список дальше
    .then(leads => { //leads потому что мы их обрабатываем сдесь 
                // Второй .then принимает данные из предыдущего блока
                //map() проходит по каждому лиду в списке, и для каждого создаёт новый объект — результат сохраняется в formattedLeads (новый массив, оригинал leads не трогается).

                const formattedLeads = leads.map(lead => {
                    return {
                        //...lead — копируем все существующие поля этого лида (Id, FirstName, LastName, Status) через spread
                        ...lead, 
                        fullName: `${lead.FirstName} ${lead.LastName}`//**добавляем** новое поле, соединяя имя и фамилию через **template literal** (строка с `` и${}`).
                    };
                })
                
                // Передаём новый, отформатированный список (с добавленным fullName у каждого лида) дальше, в следующий .then()
                return formattedLeads;
        })

        //Получает formattedLeads — отформатированный список лидов (с добавленным полем fullName), который вернул второй .then().
           .then(formattedLeads => {
            //Записываем готовый список в @track leads — благодаря реактивности, HTML автоматически обновится, и for:each={leads} начнёт показывать данные.
    this.leads = formattedLeads;
    ///Переключаем "флаг" в true — это включает видимость блока <template lwc:if={hasLeads}> в HTML, который раньше был скрыт.
    this.hasLeads = true;
    //Обновляем текст статуса — теперь он показывает точное количество найденных лидов
    this.status = 'Found ' + formattedLeads.length + ' leads from Virginia'; 
})
      
        .catch(error => { this.status = 'Error: ' + error.body.message })
        .finally(() => {console.log('Loading completed') })
}

}
//Template literals (шаблонные литералы) — это синтаксис для создания строк в JavaScript, которые заключаются в обратные кавычки (``) вместо одинарных или двойных.
// // Они значительно упрощают работу со строками, предоставляя две ключевые возможности: внедрение выражений и многострочность.