import { LightningElement } from 'lwc';

export default class Peremennie extends LightningElement {
    //Шаг 1. Обьявляем переменную без значения для того чтобы посмотреть что происходит на каждом этапе.
    //Этап 1: переменная есть - значения нет - смотрим что происходит в console.log
    //Этап 2: даем значения - смотрим что изменилось
myString; // Строка - текст, заключенный в кавычки
myNumber; //Число - числовые значения (целые или с плавающей точкой
myBoolean; //Логический тип- логический переключатель, принимающий значения true (истина) или false (ложь)В LWC часто используется для отображения или скрытия блоков в HTML через директиву lwc:if.
myArray; //Массив - упорядоченный список элементов. В шаблонах LWC списки обычно перебираются с помощью директивы for:each или iterator.
account;//Object - Объект - сложный тип данных, содержащий пары «ключ:значение»

//Пишем наш метод чтобы вложить потом в него значения, используем connectedCallback() т.к. он позволяет увидеть сразу что происходит в консоли
connectedCallback(){
    //Этап 1. Смотрим что происходит в console.log с переменными БЕЗ значений
    console.log('Переменная myString без значения:', this.myString);
    console.log('Переменная myNumber без значения:', this.myNumber);
    console.log('Переменная myBoolean без значения:', this.myBoolean);
    console.log('Переменная myArray без значения:', this.myArray);
    console.log('Переменная account без значения:', this.account);
    //Этап 2. Вкладываем значения в наши переменные и смотрим что получаеться
    // используем this, this = доступ к переменным и методам своего класса(ссылка на текущий класс)
//Без this → JS не знает где искать переменную
//С this   → JS берёт из класса 
 this.myString = 'Salesforce';
 this.myNumber = 25;
 this.myBoolean = true; 
 this.myArray = ['Test1', 'Test2', 'Test3'];
 this.account = { Name: 'Acme', Industry: 'Technology' };
 //Этап 2. Смотрим что происходит в console.log с переменными после того как мы вложили значения
     console.log('Переменная myString с значениями:', this.myString);
    console.log('Переменная myNumber с значениями:', this.myNumber);
    console.log('Переменная myBoolean с значениями:', this.myBoolean);
    console.log('Переменная myArray с значениями:', this.myArray);
    console.log('Переменная account с значениями:', this.account);
}



}