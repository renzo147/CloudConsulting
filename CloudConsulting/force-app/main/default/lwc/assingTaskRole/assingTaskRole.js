import { LightningElement, api, wire, track } from "lwc";
import getRolesWhithoutAssignment from "@salesforce/apex/assingTask.getRolesWhithoutAssignment";
import { createRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Project__c.Status__c';
import SQUADLEAD_FIELD from '@salesforce/schema/Project__c.SquadLead__r.Name';
import SQUADLEADID_FIELD from '@salesforce/schema/Project__c.SquadLead__c';
import Id from '@salesforce/user/Id';

const fields = [STATUS_FIELD, SQUADLEAD_FIELD, SQUADLEADID_FIELD];

export default class AllocateRole extends LightningElement {
    @api recordId;
    @api userId = Id;

    rolesWithoutAssignment;

    @wire(getRecord, { recordId: '$recordId', fields })
    project;

    get statusField() {
      return getFieldValue(this.project.data, STATUS_FIELD);
    }

    get squadLead() {
      return getFieldValue(this.project.data, SQUADLEAD_FIELD);
    }

    get squadLeadId() {
      return getFieldValue(this.project.data, SQUADLEADID_FIELD);
    }

    get isSquadLead(){      
      return this.squadLeadId == this.userId;
    }

    get isInProgress(){      
      return this.statusField == 'In Progress';
    }

    get isVisible(){   
      
      return this.isSquadLead && this.isInProgress;
    }

    @wire(getRolesWhithoutAssignment, { projectId: "$recordId" })
    roles(result, error) {
    if (result) {
      this.rolesWithoutAssignment = result;      
    } else if (error) {
      this.rolesWithoutAssignment = undefined;
      
    }
  }

  

}