import { LightningElement } from 'lwc';

export default class FynkciaStrelka extends LightningElement {
connectedCallback(){
    // Обычные функции (Function Expression)

const plus1 = function(a, b) {
return a + b;
};
console.log('Function Expression adds two numbers:', plus1(5, 3));

//Стрелочные функции (Arrow Functions)
const plus2 = (a, b) => a + b;

console.log('Arrow Functions adds two numbers:', plus2(5, 3));
}

}