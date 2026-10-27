import {api} from 'lwc';
import LightningModal from 'lightning/modal';

export default class EmployeeSelectModal extends LightningModal {

    @api options; //employee options passed in from the catalog
    selectedEmployeeId; // the employee selected in the list

    //Next is disabled until an employee is selected
get isNextDisabled(){
    return !this.selectedEmployeeId;
}

//An employee was selected in the list
handleChange(event){
    this.selectedEmployeeId = event.detail.value;

}

//Cancel clicked
 handleCancel(){
    this.close();

 }

 //Next clicked: return the Id to the catalog
 handleNext(){
    this.close(this.selectedEmployeeId);
 }
}
