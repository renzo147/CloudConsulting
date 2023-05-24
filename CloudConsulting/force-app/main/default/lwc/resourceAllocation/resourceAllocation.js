import { LightningElement, track , api, wire} from 'lwc';
import getTask from '@salesforce/apex/Workload.getTask';
import { refreshApex } from "@salesforce/apex";

const columns = [
    { label: 'Task', fieldName: 'task' },
    { label: 'Status', fieldName: 'status'},
    { label: 'Estimated hours', fieldName: 'estimatedHours', type: 'number'},
    { label: 'Recorded hours', fieldName: 'recordedHours', type: 'number'},
    { type: "button", label: 'Actions', initialWidth: 100, 
        typeAttributes: {
            label: {fieldName: 'buttonLabel'},
            disabled: false,
            value: 'taskId',
            variant:'Brand'
        },
        cellAttributes: {
            class: {
                fieldName: 'status',
                expression: 'if({status} === " In Progress", "slds-show", "slds-hide")'
            },
            'data-task-id': { fieldName: 'taskId' }
        }
    }
];
export default class ResourceAllocation extends LightningElement {

    @track columns = columns;
    @api projectResourceId = ''; 
    @track taskData = []; 
    @track currentTask = {};
    @track taskDataToRefresh = []; 
    change = 0;
    @track counTask = '';
    @track completedTask = false;
   
    get thereAreTask (){

        return this.taskData.length == 0 && !this.completedTask;
    }

    get thereAreTaskToDo (){
        return this.taskData.length > 0;
    }

    @wire( getTask , { projectResourceId : '$projectResourceId', current: '$change'})
    taskList(result){
        if(result.data){
            console.log('Sí hay data de task');
            let newData = [];
            this.completedTask = result.data.length > 0;

            for(var i=0 ; i<result.data.length ; i++){
                
                let wh = result.data[i].WorkedHours__c == undefined ? 0 : result.data[i].WorkedHours__c;
                console.log(wh);
                let bl = result.data[i].Status__c == 'Not Started' ? 'Iniciar' : 'Registrar';
            //    bl = result.data[i].Status__c == 'Completed' ? ;
                if(result.data[i].Status__c != 'Completed'){
                    let t = {
                        taskId: result.data[i].Id,
                        task: result.data[i].Description__c,
                        status: result.data[i].Status__c,
                        estimatedHours: result.data[i].EstimatedHours__c,
                        recordedHours: wh,
                        buttonLabel: bl
                    };
                    
                    newData.push(t);
                    this.completedTask = false;
                } 

            /*    if(newData.estimatedHours == newData.recordedHours){
                    newData.status = 'Completed';

                }*/
            }
            this.taskData = newData;

            this.counTask = this.taskData.length;

        }else if (result.error){
            this.taskData = undefined;
            console.log('Error task data')
        }
    }

    handleRowAction(event) {
        
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        this.currentTask = event.detail.row;
        
        const modal = this.template.querySelector("c-modal-Popup");
        modal.show();
    }

    handleRecord(event){
        console.log('nada que ver');
        console.log(event);
        console.log(event.detail);
        this.taskDataToRefresh = [];
        console.log(this.taskData.length);

        for(let i=0; i<this.taskData.length ; i++){
            console.log('Entra for');
            console.log(this.taskData[i].taskId + ' vs ' + event.detail.Id);
            if(this.taskData[i].taskId == event.detail.Id){

                console.log('Este es el Task');
                this.taskData[i].recordedHours = event.detail.WorkedHours__c;
                this.taskData[i].status = event.detail.Status__c;
                this.taskData[i].buttonLabel = 'Registrar';
            }
            let ts = {
                taskId: this.taskData[i].taskId,
                task: this.taskData[i].task,
                status: this.taskData[i].status,
                estimatedHours: this.taskData[i].estimatedHours,
                recordedHours: this.taskData[i].recordedHours,
                buttonLabel:  this.taskData[i].buttonLabel
            };
      

            this.taskDataToRefresh.push(ts);
            this.change ++;


        }
        console.log('Finaliza proceso');
        console.log(this.taskDataToRefresh[0]);
        this.taskData = this.taskDataToRefresh;
        return this.refresh();
        this.template.querySelector('c-modal-popup').taskId = taskId;
    }

    async refresh() {
        await refreshApex(this.taskDataToRefresh);  
        await refreshApex(this.taskData);  
    }
}