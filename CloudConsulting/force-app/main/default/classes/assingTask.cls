public with sharing class assingTask {

    public class UserWrapper{
        @AuraEnabled
        public String prId { get; set;}
        @AuraEnabled
        public String FirstName { get; set;}
        @AuraEnabled
        public String LastName{ get; set;} 
        @AuraEnabled
        public Decimal RequieredHours{ get; set;} 
        @AuraEnabled
        public Decimal HoursAllocated{ get; set;} 
        
    }  
    
     //List of available employees by role
 /*@AuraEnabled(cacheable=true)
 public static List <AggregateResult> getAvailableEmployeesByRole (String roleName, String projectId){

        List<AggregateResult> resources = 
        [
            SELECT  User__c Id, 
                    User__r.FirstName FN, 
                    User__r.LastName LN,                      
                    SUM(RequieredHours__c) AllocatedHours
                    FROM Project_Resources__c 
                    WHERE Project__c = : projectId
                    AND Project_Line_Item__r.Role__c = : roleName
                    GROUP BY    User__c, 
                                User__r.FirstName, 
                                User__r.LastName 
                                
        ];

        return resources;
        
 }*/

  //List of the roles with pending time to be assigned for tasks
  @AuraEnabled(cacheable=true)
  public static List <Project_Line_Item__c> getRolesWhithoutAssignment (Id projectId) {
   List<Project_Line_Item__c> rolesWithoutAssignment =
                   [
                   SELECT Id, Role__c, HoursPending__c, HoursPerRole__c, HoursAllocated__c 
                   FROM Project_Line_Item__c 
                   WHERE Project__c = : projectId
                   AND TaskHoursPending__c > 0     
                   ];
         
   return rolesWithoutAssignment; 
 }

 @AuraEnabled(cacheable=true)
 public static List <Project_Line_Item__c> getHoursPendingByRole (Id projectId, String roleName) {
   List <Project_Line_Item__c> hoursPending = 
                   [
                   SELECT TaskHoursPending__c
                   FROM Project_Line_Item__c
                   WHERE Project__c = : projectId
                   //AND HoursPending__c > 0
                   AND Role__c = : roleName
                   ];
               
   return hoursPending; 
 }

 @AuraEnabled(cacheable=true)
 public static List <UserWrapper> getAvailableEmployeesByRole (String roleName, String projectId){

        System.debug('Rol ' + roleName);
        System.debug('Project Id ' + projectId);
        List<Project_Resources__c> resources = 
        [
            SELECT  User__c, 
                    User__r.FirstName, 
                    User__r.LastName,                      
                    RequieredHours__c,
                    HoursAllocated__c,
                    StartDate__c
                    FROM Project_Resources__c 
                    WHERE Project__c = : projectId
                    AND Project_Line_Item__r.Role__c = : roleName
                    
                                
        ];
        System.debug('Resource ' + resources[0]);
        List<UserWrapper> resourcesChild = new List<UserWrapper>();
                    
            
                for(Project_Resources__c childIns : resources) {

                    UserWrapper rchild = new UserWrapper();
   
                    rchild.prId = childIns.Id;
                    rchild.FirstName = childIns.User__r.FirstName;
                    rchild.LastName= childIns.User__r.LastName;
                    rchild.RequieredHours= childIns.RequieredHours__c;
                    rchild.HoursAllocated= childIns.HoursAllocated__c;
                    if(rchild.RequieredHours>rchild.HoursAllocated){                
                    resourcesChild.add(rchild);
                    }

             }
             System.debug('Resource Child ' + resourcesChild[0]);  
        return resourcesChild;
        
 }

 @AuraEnabled
 public static void assingTasks(String assingTaskJSON){

   List<Task__c> allTask = (List<Task__c>) JSON.deserialize(assingTaskJSON, List<Task__c>.class);

   Set<Id> prTask = New Set<Id>();
   for(Task__c aTask : allTask){
    System.debug('debug ' + aTask);
    prTask.add(aTask.Project_Resource__c);
   }
   System.debug('Set ID ' + prTask);
   
   /*List<Project_Resources__c> prDates =
                        [
                        SELECT StartDate__c
                        FROM Project_Resources__c
                        WHERE Id IN: prTask
                        ];

    for(Project_Resources__c aTask : prDates){
        System.debug('Dates ' + aTask);
    }*/

    Map<Id,Project_Resources__c> prDatesMap = New Map<Id,Project_Resources__c>([
        SELECT  StartDate__c,
                RequieredHours__c,
                HoursAllocated__c
        FROM Project_Resources__c
        WHERE Id IN: prTask
        ]);

    System.debug('Dates Map ' + prDatesMap);

    //Integer rou = Math.round(100/49);
    //Integer rest = Math.mod(100, 97);
    //System.debug('Round ' + rou);
    //System.debug('Rest ' + rest);

    for(Task__c aTask : allTask){
        
        
        Integer allocated = Integer.valueOf(prDatesMap.get(aTask.Project_Resource__c).HoursAllocated__c);
        Integer estimated = Integer.valueOf(aTask.EstimatedHours__c);
                
        Integer cAllocated = Math.round(allocated/10);
        aTask.StartDate__c = prDatesMap.get(aTask.Project_Resource__c).StartDate__c + cAllocated;
        Integer cEstimated = Math.round(aTask.EstimatedHours__c/10);
        aTask.EndDate__c = aTask.StartDate__c + cEstimated;    
        aTask.WorkedHours__c = 0;  
            
               
        //aTask.StartDate__c = prDatesMap.get(aTask.Project_Resource__c).StartDate__c;        
    }

    for(Task__c aTask : allTask){
        System.debug('debug date' + aTask);       
    }
    
   insert allTask;
   
   
 }

}