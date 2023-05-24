import { LightningElement , api, track } from 'lwc';
import updateWorkedHours from '@salesforce/apex/Workload.updateWorkedHours';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const CSS_CLASS = "modal-hidden";

export default class ModalPopup extends LightningElement {
    showModal = false;
    @api task = {};
    @track inputValue;
    @track isSelected = false;
    defaultQuantity = 0;

    @api show(){
        this.inputValue = 0;
        this.isSelected = false;
        this.showModal = true;
    }

    handleDialogClose(){
        this.showModal = false;
    }

    handleInputChange(event){
        this.inputValue = event.target.value;
        console.log(this.inputValue);
    }

    handleButtonClick(){
        console.log('Id: ' + this.task.taskId);
        console.log('Completed:' + this.isSelected);
        console.log('Input: ' + this.inputValue);
        if(this.isSelected == true || this.inputValue > 0){

            updateWorkedHours({taskId: this.task.taskId , completed: this.isSelected, workedHours: this.inputValue})
            .then(result =>{
                console.log('Se actualizaron las horas');
                console.log(result);
                const event = new CustomEvent('taskupdated' , { detail: result});
                this.dispatchEvent(event);
                
                const eventT = new ShowToastEvent({
                    title: 'Registrado',
                    message: 'Has registrado cambios en tu tarea con éxito',
                    variant: 'success',
                    duration: 5000
                });
                this.dispatchEvent(eventT);
                this.showModal = false;
            })
            .catch(error =>{
                console.log('Falló la actualización');
                console.log(error);
            })

        } else {
            this.showModal = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Debes registrar horas o marcar como completada la tarea',
                variant: 'error',
                duration: 5000
            });
            this.dispatchEvent(event);
        }
        
    }

    handleCheckboxChange(event) {
        this.isSelected = event.target.checked;
        // Hacer algo con el estado seleccionado del checkbox
        if(this.isSelected){
            console.log('Seleccionado');
        } else {
            console.log('Deseleccionado');
        }
    }
    handleInputFocus(event) {
        event.target.value = '';
    }

    handleInputBlur(event) {
        if (event.target.value === '') {
            event.target.value = this.defaultQuantity;
        }
    }
}