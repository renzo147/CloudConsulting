public with sharing class assingTaskTrigger {

    public static List <Task__c> taskRejected = new List <Task__c>();

    public static List <Task__c> validateTask (List <Task__c> taskList ){
        
        Set <String> projectResourcesIds = new Set <String>();
        
        for(Task__c prTask : taskList){
            projectResourcesIds.add(prTask.Project_Resource__c);
        }

        Map<Id, Project_Resources__c> taskMap = New Map<Id, Project_Resources__c>([SELECT
                                                    RequieredHours__c,
                                                    HoursAllocated__c
                                                    FROM Project_Resources__c
                                                    WHERE Id IN : projectResourcesIds]);

        for(Task__c prTask : taskList){
            Decimal requiered = taskMap.get(prTask.Project_Resource__c).RequieredHours__c;
            Decimal allocated = taskMap.get(prTask.Project_Resource__c).HoursAllocated__c;
            Decimal pending = requiered - allocated;
            if(prTask.EstimatedHours__c > pending){
                taskRejected.add(prTask);
            }else if(prTask.EstimatedHours__c < 0){
                taskRejected.add(prTask);
            }else if(prTask.EstimatedHours__c == NULL){
                taskRejected.add(prTask);
            }else if(prTask.Description__c == '' || prTask.Description__c == NULL){
                taskRejected.add(prTask);
            }
        }

        return taskRejected;
    }
}