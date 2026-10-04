import { LightningElement } from 'lwc';

export default class Peremennie extends LightningElement {
    // Step 1. Declare variables without values to see what happens at each stage.
    // Stage 1: the variable exists but has no value: see what console.log shows
    // Stage 2: assign values: see what changed
myString; // String: text in quotes
myNumber; // Number: numeric values (integer or floating point)
myBoolean; // Boolean: a logical switch, true or false. In LWC often used to show or hide HTML blocks with the lwc:if directive.
myArray; // Array: an ordered list of items. In LWC templates lists are usually iterated with for:each or iterator.
account;// Object: a complex data type with key:value pairs

// Our method where we assign values; we use connectedCallback() because it lets us see what happens in the console right away
connectedCallback(){
    // Stage 1. See what console.log shows for variables WITHOUT values
    console.log('Variable myString without a value:', this.myString);
    console.log('Variable myNumber without a value:', this.myNumber);
    console.log('Variable myBoolean without a value:', this.myBoolean);
    console.log('Variable myArray without a value:', this.myArray);
    console.log('Variable account without a value:', this.account);
    // Stage 2. Assign values to our variables and see what we get
    // use this: this = access to the variables and methods of our own class (a reference to the current class)
// Without this → JS doesn't know where to look for the variable
// With this   → JS takes it from the class
 this.myString = 'Salesforce';
 this.myNumber = 25;
 this.myBoolean = true; 
 this.myArray = ['Test1', 'Test2', 'Test3'];
 this.account = { Name: 'Acme', Industry: 'Technology' };
 // Stage 2. See what console.log shows for the variables after assigning values
     console.log('Variable myString with a value:', this.myString);
    console.log('Variable myNumber with a value:', this.myNumber);
    console.log('Variable myBoolean with a value:', this.myBoolean);
    console.log('Variable myArray with a value:', this.myArray);
    console.log('Variable account with a value:', this.account);
}



}