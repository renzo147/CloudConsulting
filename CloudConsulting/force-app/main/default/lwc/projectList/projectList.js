import { LightningElement , wire , api , track} from 'lwc';
import getProject from '@salesforce/apex/Workload.getProject';

export default class ProjectList extends LightningElement {
    
    @track projectData = [];

    @wire( getProject)
    projectList(result){
        console.log('culaquier cosa');
        if(result.data){
            this.projectData = result.data;
            console.log(this.projectData);
            console.log('Sí hay lista de proyectos');
            
        } else if (result.error){
            this.projectData = undefined;
            console.log('Error task data')
        }
    } 


}