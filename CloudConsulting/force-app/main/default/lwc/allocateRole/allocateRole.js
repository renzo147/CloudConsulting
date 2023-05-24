import { LightningElement, api, wire } from "lwc";
import getRolesWhithoutAssignment from "@salesforce/apex/resourcesAllocation.getRolesWhithoutAssignment";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import STARTDATE_FIELD from '@salesforce/schema/Project__c.StartDate__c';
import ENDDATE_FIELD from '@salesforce/schema/Project__c.EndDate__c';
import STATUS_FIELD from '@salesforce/schema/Project__c.Status__c';
import PROJECTMANAGER_FIELD from '@salesforce/schema/Project__c.ProjectManager__r.Name';
import PROJECTMANAGERID_FIELD from '@salesforce/schema/Project__c.ProjectManager__c';

import Id from '@salesforce/user/Id';

const fields = [STARTDATE_FIELD, ENDDATE_FIELD, STATUS_FIELD, PROJECTMANAGER_FIELD, PROJECTMANAGERID_FIELD];

export default class AllocateRole extends LightningElement {
    @api recordId;
    rolesWithoutAssignment;
    @api userId = Id;

    @wire(getRecord, { recordId: '$recordId', fields })
    project;

    get startDate() {
      return getFieldValue(this.project.data, STARTDATE_FIELD);
    }

    get endDate() {
      return getFieldValue(this.project.data, ENDDATE_FIELD);
    }

    get statusField() {
      return getFieldValue(this.project.data, STATUS_FIELD);
    }

    get projectManager() {
      return getFieldValue(this.project.data, PROJECTMANAGER_FIELD);
    }

    get projectManagerId() {
      return getFieldValue(this.project.data, PROJECTMANAGERID_FIELD);
    }

    get isProjectManager(){      
      return this.projectManagerId == this.userId;
    }

    get isPreKickOff(){      
      return this.statusField == 'Pre Kickoff';
    }

    get isVisible(){   
        
      return this.isProjectManager && this.isPreKickOff;
    }

    @wire(getRolesWhithoutAssignment, { projectId: "$recordId" })
    roles(result, error) {
    if (result) {
      this.rolesWithoutAssignment = result;
      console.log(
        "RolesWhitoutAssignment are: ",
        this.rolesWithoutAssignment
      );
    } else if (error) {
      this.rolesWithoutAssignment = undefined;
      
    }
  }

}