import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from "@salesforce/apex";
import getAvailableEmployeesByRole from "@salesforce/apex/assingTask.getAvailableEmployeesByRole";
import getHoursPendingByRole from "@salesforce/apex/assingTask.getHoursPendingByRole";
import assingTasks from "@salesforce/apex/assingTask.assingTasks";
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import ToastBreakLine from '@salesforce/resourceUrl/ToastBreakLine';
import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';

/*const columns = [
    { label: "Name", fieldName: "FN", type: "text" },
    { label: "LastName", fieldName: "LN", type: "text" },
    { label: "Requiered Hours", fieldName: "AllocatedHours", type: "number" }
    
  ];*/

  const cols = [
    { label: "Name", fieldName: "FirstName", type: "text" },
    { label: "LastName", fieldName: "LastName", type: "text" },
    { label: "Requiered Hours", fieldName: "RequieredHours", type: "number" },
    { label: "Allocated Hours", fieldName: "HoursAllocated", type: "number" },
    { label: "Task Hours", fieldName: "TaskHours", type: "number", editable: true },
    { label: "Task Name", fieldName: "TaskName", type: "text", editable: true }
    
  ];

export default class AssingTask extends LightningElement {
    @api role;
    @api recordId;
    //@api columns = [...cols].filter(col => col.fieldName != 'FirstName');
    @api columns = cols;
    update = 0;
    pending;

    renderedCallback() {
        
        loadStyle(this, ToastBreakLine)
        .then(() => console.log('Files loaded.'))
        .catch(error => console.log("Error " + error.body.message))

    }

    @api handleSave(event) {
      
        const inputsDates = JSON.stringify(
        event.detail.draftValues.slice().map((draft) => {
            let fields = {};
            console.log(draft);
            fields.Description__c = draft.TaskName;
            fields.EstimatedHours__c = draft.TaskHours;
            fields.Project_Resource__c = draft.prId;
            fields.Status__c = 'Not Started';
            return fields;
        })
      );

      console.log(inputsDates);

      assingTasks({ assingTaskJSON: inputsDates })
      .then(() => {
        const event = new ShowToastEvent({
          title: 'Assigned!',
          message: 'Successfully Assigned Resources',
          variant: 'success'
          });
          this.dispatchEvent(event);
          //this.update ++;
          this.template.querySelector("lightning-datatable").draftValues = [];
          this.update ++;
          return this.refresh();
      })
      .catch((error) => {
        console.log('CATCH ERROR-->');
        const event = new ShowToastEvent({
          title: 'ERROR',
          message: error.body.pageErrors[0].message,
          variant: 'Error',
          mode: 'sticky'
        });
        this.dispatchEvent(event);
      })
      .finally(() => {
        //this.template.querySelector("lightning-datatable").draftValues = [];
      });
    }

    /*@track resList;
    @wire(getAvailableEmployeesByRole, { roleName: "$role.Role__c", projectId: "$recordId" })
    resourceList(result, error) {
    if (result.data){
        
      this.resList = result.data.map((record) => {
        //record.FirstName = getFieldValue(record.data, "User__r.FirstName");
        console.log('record map -->', record);
        //console.log('record Id -->', record.Id);
        //console.log('record FN -->', record.FN);
        //console.log('record FN -->', getFieldValue(record.data, 'User__r.FirstName'));
        //record.FirstName = 
        return record
    });

    

    
    
      
      //console.log('resultado' + this.resList);
      //this.resList = result;
    }else if (result.error) {
      this.resList = undefined;
    }
    
}*/

@track resList;
    @wire(getAvailableEmployeesByRole, { roleName: "$role.Role__c", projectId: "$recordId"})
    resourceList(result, error) {
      console.log('result ' + result.data);
      this.resList = result;
    if (result.error) {
      console.log('result error ' + result.error);
      this.resList = undefined;
    }
    }

    @track hoursPendingToAssign;
    @wire(getHoursPendingByRole, {
      projectId: "$recordId",
      roleName: "$role.Role__c",
      current: "$update"    
    })
    hoursPending(result, error) {
      if (result.data) {
        this.hoursPendingToAssign = result.data[0].TaskHoursPending__c;
        this.pending = (this.hoursPendingToAssign !=0);
        console.log('Pendiente ' + this.pending);
      } else if (error) {
        this.hoursPendingToAssign = undefined;
      }
    }

async refresh() {
    await refreshApex(this.resList);  
    
        
  }
}