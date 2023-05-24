public class Workload {
    @AuraEnabled(cacheable=true)
    public static list<Project_Resources__c> getProject (){
        Id uId = UserInfo.getUserId();
        List<Project_Resources__c> projects = [SELECT Id,
                                               			Project__c,
                                                       Project__r.Name,
                                                       Name,
                                                       User__c
                                              FROM Project_Resources__c
                                              WHERE User__c =: uId];
        System.debug(projects.get(0).Project__r.Name);
        return projects;   
        
    }
    
	@AuraEnabled(cacheable=true)
    public static list<Task__c> getTask (Id projectResourceId){
        List<Task__c> tasks= [SELECT Id,
                                      Status__c,
                                      Description__c,
                                      StartDate__c,
                                      EndDate__c,
                                      EstimatedHours__c,
                                      WorkedHours__c,
                              			Project_Resource__c
                                FROM Task__c
                                WHERE Project_Resource__c =: projectResourceId
                             	ORDER BY Project_Resource__c];
        System.debug(tasks.get(0).Description__c);
        return tasks;
    } 
    
    @AuraEnabled(cacheable=false)
    public static Task__c updateWorkedHours (Id taskId, Boolean completed, Integer workedHours){
        system.debug(taskId);
        Task__c task = [SELECT Id,
                                Status__c,
                                Description__c,
                                StartDate__c,
                                EndDate__c,
                                EstimatedHours__c,
                                WorkedHours__c,
                                Project_Resource__c
                        FROM Task__c
                       	WHERE Id =: taskId];
        
        task.Status__c = completed == true ? 'Completed': 'In Progress';
        task.WorkedHours__c += workedHours;
        
        update task;
        
        return task;
    }
}