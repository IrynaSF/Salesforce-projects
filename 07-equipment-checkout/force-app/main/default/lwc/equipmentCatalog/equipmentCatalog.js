import { LightningElement, wire } from 'lwc';
import getAvailableEquipment from '@salesforce/apex/EquipmentController.getAvailableEquipment';
import checkoutEquipment from '@salesforce/apex/EquipmentController.checkoutEquipment'; //Apex method that creates a checkout
import { refreshApex } from '@salesforce/apex'; //Re-fetches data for @wire.
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //Toast message shown at the top of the screen; we set the title,
//message and variant.

//New imports
import getContacts from '@salesforce/apex/EquipmentController.getContacts';
import EmployeeSelectModal from 'c/employeeSelectModal';

export default class EquipmentCatalog extends LightningElement {
    
    searchKey = '';//The text the user typed in the search field.
    @wire(getAvailableEquipment)//Wire the Apex method to the property.
    equipment;

    //Second wire: loads contacts when the catalog loads
    @wire(getContacts)
    contacts;

    //Datatable columns
    columns = [
        {label: 'Equipment Name', fieldName: 'Name'},
        {label: 'Type', fieldName: 'Type__c'},
        {
            label:'Action', // column label
            type: 'button', // column type
            typeAttributes:{ 
                label: 'Check Out', // button text in each row
                name: 'checkout', // internal action name
                variant: 'brand'// button style
            }

        },
    ];

 //handleRowAction runs when the "Check Out" button in a row is clicked. It gets the equipment Id,
 //  opens the employee picker and calls checkoutEquipment in the Apex controller.
 //On success it shows a success toast and refreshes data with refreshApex. On error
 //it shows a toast with the error message.
    async handleRowAction(event) { //row action handler
   const equipmentId = event.detail.row.Id //Id of the equipment in the clicked row

   //open the modal and wait until it is closed
   const employeeId = await EmployeeSelectModal.open({

    size: 'small',
    label: 'Select Employee',
    options: this.employeeOptions
   })

   //Cancel or X clicked: no checkout
   if (!employeeId){
    return;
   }
    try {
        await checkoutEquipment({ equipmentId: equipmentId, employeeId: employeeId}); //Imperative Apex call

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Equipment checked out successfully.',
                variant: 'success'
            })
        );

        await refreshApex(this.equipment); //Refresh the list of available equipment.
    } catch (error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            })
        );
    }
}
//Stores what the user typed in the search field.
handleSearchChange(event) { //Runs on every change of the search field (onchange={handleSearchChange} in HTML).
    this.searchKey = event.target.value; //event.target.value is the current text of the field.
//store the field text in the property
}

get filteredEquipment() {
    if (!this.equipment.data) { //Data has not arrived yet: return an empty array so the template does not break.
        return [];
    }
    if (!this.searchKey) { //Empty search: show everything
        return this.equipment.data;
    }
    const key = this.searchKey.toLowerCase(); //Lower-case the search text for a case-insensitive match.
    return this.equipment.data.filter( //filter() builds a new list with matching records only; the original list is not changed.
//return the new list to the template.
        (item) => item.Type__c.toLowerCase().includes(key) //does the type contain the search text?
    );
    }

    //Getter: the modal combobox expects { label, value }, while Apex returns contacts as { Id, Name }
    get employeeOptions() {
        if(!this.contacts.data){
            return [];
        }
        return this.contacts.data.map(
            (contacts) => ({label: contacts.Name, value: contacts.Id})
        )
    
}
}

