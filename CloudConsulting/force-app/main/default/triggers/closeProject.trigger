trigger closeProject on Project__c (before update){
    List <Id> projectsIds = new List <Id>();
    for(Project__c pr : Trigger.new){
        //Verifica que cambia a estado completed
        if (pr.Status__c == 'Completed' && 
        (Trigger.oldMap == null || Trigger.oldMap.get(pr.Id).Status__c != 'Completed')){
            //verifica fecha de cierre
            if (pr.EndDate__c == Date.today()){
                projectsIds.add(pr.Id);               
            } else {
                pr.EndDate__c.addError('You cannot close a project with a close date different from the current date.');
            }
        }
    }
    
    List<Task__c> tasks= [SELECT Id, Status__c, Project_Resource__r.Project__c 
                          FROM Task__c 
                          WHERE Project_Resource__r.Project__c IN :projectsIds];
    
    // Iterar sobre las tareas y verificar si todas están en estado "terminado"
    Map<Id, Boolean> projectTaskMap = new Map<Id, Boolean>();
    for (Task__c task : tasks) {
        if (task.Status__c == 'In Progress' || task.Status__c == 'Not Started' || task.Status__c == Null) {
            projectTaskMap.put(task.Project_Resource__r.Project__c, false);
        } else if (!projectTaskMap.containsKey(task.Project_Resource__r.Project__c)) {
            projectTaskMap.put(task.Project_Resource__r.Project__c, true);
        }
    } 
    
    List<Id> uncompletedProjects = new List <Id>();
    for (Id prId : projectTaskMap.KeySet()){
        if(projectTaskMap.get(prId)){
            //El proyecto debe actualizar su estado
        }else{
            uncompletedProjects.add(prId);
        }
    }

    // Si hay proyectos que no cumplen, evitar que se actualice el estado
    if (uncompletedProjects.size() > 0) {
        for (Project__c project : Trigger.new) {
            if (uncompletedProjects.contains(project.Id)) {
                project.Status__c.addError('The project cannot be completed until all tasks are finished.');
            }
        }
    }
    
}