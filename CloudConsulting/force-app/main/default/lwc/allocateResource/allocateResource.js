import { LightningElement, api, track, wire } from "lwc";
import getAvailableEmployeesByRole from "@salesforce/apex/resourcesAllocation.getAvailableEmployeesByRole";
import getHoursPendingByRole from "@salesforce/apex/resourcesAllocation.getHoursPendingByRole";
import allocateResources from "@salesforce/apex/resourcesAllocation.allocateResources";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import calculateWorkingDays from "@salesforce/apex/resourcesAllocation.calculateWorkingDays";
import { refreshApex } from "@salesforce/apex";

/* 
* How to use lightning-datatable
https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation

* How to use on save and draft
https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_table_inline_edit

*/

const columns = [
    { label: "Name", fieldName: "FirstName" },
    { label: "LastName", fieldName: "LastName" },
    { label: "Rate", fieldName: "Rate__c", type: "currency" },
    { label: "Assigned", fieldName: "notAvailableDates__c", type: "text", initialWidth: 200, wrapText: true },
    { label: "Available Days", fieldName: "availableDays__c", type: "number" },
    {
      label: "Start Date",
      fieldName: "startDate",
      type: "date-local",
      editable: true
    },
    {
      label: "End Date",
      fieldName: "endDate",
      type: "date-local",
      editable: true
    }
  ];

  /*function getBusinessDatesCount(startDate, endDate) {
    let count = 0;
    const curDate = new Date(startDate.getTime());
    while (curDate <= endDate) {
        const dayOfWeek = curDate.getDay();
        if(dayOfWeek !== 0 && dayOfWeek !== 6) count++;
        curDate.setDate(curDate.getDate() + 1);
    }
    alert(count);
    return count;
  };*/

export default class AllocateResource extends LightningElement {

    saveDraftValues = [];
    isCssLoaded = false;
    @api role;
    @api recordId;
    @api columns = columns;
    update = 0;
    pending;
    
    getBusinessDatesCount(startDate, endDate) {
      let count = 0;
      const curDate = new Date(startDate.getTime());
      while (curDate <= endDate) {
          const dayOfWeek = curDate.getDay();
          if(dayOfWeek !== 0 && dayOfWeek !== 6) count++;
          curDate.setDate(curDate.getDate() + 1);
      }
      return count;
    }

    @track resList;
    @wire(getAvailableEmployeesByRole, { roleName: "$role.Role__c", projectId: "$recordId" })
    resourceList(result, error) {
      this.resList = result;
    if (result.error) {
      this.resList = undefined;
    }
    }

        
    @api handleSave(event) {
      
      const inputsDates = JSON.stringify(
      event.detail.draftValues.slice().map((draft) => {
          let fields = {};
          fields.User__c = draft.Id;
          fields.Project__c = this.recordId;
          fields.Project_Line_Item__c = this.role.Id;
          fields.StartDate__c = draft.startDate;
          fields.EndDate__c = draft.endDate;

          console.log('Antes Dias Habiles Front ' + this.workingDays);
          //let startDate = new Date( Date.parse(draft.startDate) );
          let startDate = new Date( Date.parse(draft.startDate + ' 06:00:00 GMT') );
          console.log('Start ' + draft.startDate);
          console.log('Start ' + startDate);
          //let endDate = new Date( Date.parse(draft.endDate) );
          let endDate = new Date( Date.parse(draft.endDate + ' 06:00:00 GMT') );
          console.log('End ' + draft.endDate);
          console.log('End ' + endDate);
          this.workingDays = this.getBusinessDatesCount(startDate,endDate);
          console.log('Despues Dias Habiles Front ' + this.workingDays);
          //fields.RequieredHours__c = Math.ceil((Date.parse(draft.endDate)-Date.parse(draft.startDate)+1) / (1000 * 3600 * 24))*8;
          fields.RequieredHours__c =  this.workingDays * 10;
          
          console.log(typeof draft.endDate);
          console.log('Equal1 ' + (draft.endDate==''));
          console.log('Equal2 ' + (draft.endDate==null));
          console.log('Equal3 ' + (draft.endDate==""));
          console.log('Equal4 ' + (draft.endDate==undefined));
          if(fields.StartDate__c == null || fields.EndDate__c == null || fields.StartDate__c == "" || fields.EndDate__c == ""){
            console.log('ENTRE');
            const event = new ShowToastEvent({
            title: 'ERROR!',
            message: 'No Date Field can be NULL',
            variant: 'Error'
            });
            this.dispatchEvent(event);
          }
          return fields;
        })
      );

      

      console.log(inputsDates);
      allocateResources({ allocationJSON: inputsDates })
      .then(() => {
        const event = new ShowToastEvent({
          title: 'Assigned!',
          message: 'Successfully Assigned Resources',
          variant: 'success'
          });
          this.dispatchEvent(event);
          this.template.querySelector("lightning-datatable").draftValues = [];
          this.update ++;
          return this.refresh();
      })
      .catch((error) => {
        console.log('CATCH ERROR-->');
        const event = new ShowToastEvent({
          title: 'ERROR',
          message: error.body.pageErrors[0].message,
          variant: 'Error'
        });
        this.dispatchEvent(event);
      })
      .finally(() => {
        //this.template.querySelector("lightning-datatable").draftValues = [];
      });
    }

    @api handleClick(event) {
      this.template.querySelector("lightning-datatable").draftValues = [];
    }

    @track hoursPendingToAssign;
    @wire(getHoursPendingByRole, {
      projectId: "$recordId",
      roleName: "$role.Role__c",
      current: "$update"    
    })
    hoursPending(result, error) {
      if (result.data) {
        this.hoursPendingToAssign = result.data[0].HoursPending__c;
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