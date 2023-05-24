public with sharing class resourcesAllocation {

 
  //List of the roles with pending time to be assigned
  @AuraEnabled(cacheable=true)
  public static List <Project_Line_Item__c> getRolesWhithoutAssignment (Id projectId) {
   List<Project_Line_Item__c> rolesWithoutAssignment =
                   [
                   SELECT Id, Role__c, HoursPending__c, HoursPerRole__c, HoursAllocated__c 
                   FROM Project_Line_Item__c 
                   WHERE Project__c = : projectId
                   AND HoursPending__c > 0     
                   ];
         
   return rolesWithoutAssignment; 
 }

 //List of available employees by role
 @AuraEnabled(cacheable=true)
 public static List <User> getAvailableEmployeesByRole (String roleName, String projectId){
	System.debug('Project Id ' + projectId);
   //Find the project
   Project__c project =
                   [
                   SELECT Id, Name, StartDate__c, EndDate__c, Amount__c
                   FROM Project__c
                   WHERE Id = : projectId
                   ];

   //Find available users for the project
   List <User> resources = 
                   [
                   SELECT Id , FirstName, LastName, UserRole.Name, Rate__c,
                   (
                       SELECT StartDate__c, EndDate__c, Project__c 
                       FROM Project_Resources__r
                       //WHERE Project__c != : projectId
                       //WHERE (StartDate__c >=: project.StartDate__c AND StartDate__c <=: project.EndDate__c)
                       //OR (EndDate__c >=: project.StartDate__c AND EndDate__c <=: project.EndDate__c)
                       ORDER BY StartDate__c ASC
                   )
                   FROM User
                   WHERE UserRole.Name = : roleName
                   
                   ];
    
                   List <User> resourcesProject = 
                   [
                   SELECT Id , FirstName, LastName, UserRole.Name, Rate__c,
                   (
                       SELECT StartDate__c, EndDate__c, Project__c 
                       FROM Project_Resources__r
                       WHERE Project__c = : projectId
                       //WHERE (StartDate__c >=: project.StartDate__c AND StartDate__c <=: project.EndDate__c)
                       //OR (EndDate__c >=: project.StartDate__c AND EndDate__c <=: project.EndDate__c)
                       ORDER BY StartDate__c ASC
                   )
                   FROM User
                   WHERE UserRole.Name = : roleName
                   
                   ];
     
     System.debug('Resources ' + resources);
     System.debug('Resources Project ' + resourcesProject);
  Set<Id> resourcesProjectId = New Set<Id>();
  for(User pr: resourcesProject){
    if(!pr.Project_Resources__r.isEmpty()){
        resourcesProjectId.add(pr.Id);
    }
  }

  System.debug('Set Id Project ' + resourcesProjectId);
   
   Map<Id, Integer> sumAvailableDates = New Map<Id, Integer>();
   Integer totalProjectDays = project.StartDate__c.daysBetween(project.EndDate__c) + 1;
   Integer busyPeriod = 0;
   Integer aux = 0;
   for (User user : resources){
     if(!sumAvailableDates.containsKey(user.Id)){
       sumAvailableDates.put(user.Id, totalProjectDays);
     }
     if(!user.Project_Resources__r.isEmpty()){
       for (Integer i = 0; i < user.Project_Resources__r.size(); i++) {
         if(user.Project_Resources__r[i].StartDate__c >= project.StartDate__c && user.Project_Resources__r[i].StartDate__c <= project.EndDate__c && user.Project_Resources__r[i].EndDate__c >= project.EndDate__c){
           busyPeriod = user.Project_Resources__r[i].StartDate__c.daysBetween(project.EndDate__c) + 1;
           aux = sumAvailableDates.get(user.Id) - busyPeriod;
           sumAvailableDates.put(user.Id, aux);
         } else if(user.Project_Resources__r[i].StartDate__c <= project.StartDate__c && user.Project_Resources__r[i].EndDate__c <= project.EndDate__c && user.Project_Resources__r[i].EndDate__c >= project.StartDate__c){
           busyPeriod = project.StartDate__c.daysBetween(user.Project_Resources__r[i].EndDate__c) + 1;
           aux = sumAvailableDates.get(user.Id) - busyPeriod;
           system.debug(' Mapa : ' + sumAvailableDates.get(user.Id));
           system.debug(' Busy : ' + busyPeriod);
           system.debug(' Dias Libres : ' + aux);
           sumAvailableDates.put(user.Id, aux);
         } else if(user.Project_Resources__r[i].StartDate__c >= project.StartDate__c && user.Project_Resources__r[i].EndDate__c <= project.EndDate__c){
           busyPeriod = user.Project_Resources__r[i].StartDate__c.daysBetween(user.Project_Resources__r[i].EndDate__c) + 1;
           aux = sumAvailableDates.get(user.Id) - busyPeriod;
           sumAvailableDates.put(user.Id, aux);
         } else if(user.Project_Resources__r[i].StartDate__c <= project.StartDate__c && user.Project_Resources__r[i].EndDate__c >= project.EndDate__c){
           sumAvailableDates.put(user.Id, 0);
         }
         
       }   

     }
   }
   

   system.debug(' Mapa : ' + sumAvailableDates);

   Map<Id, List<String>> notAvailableDates = New Map<Id, List<String>>();
   String busyDates = '';
   for (User user : resources){
     /*if(!user.Project_Resources__r.isEmpty()){
         availableResources.add(user);
     }*/
     if(!notAvailableDates.containsKey(user.Id)){
       notAvailableDates.put(user.Id, New List<String>());
     }
     for (Integer i = 0; i < user.Project_Resources__r.size(); i++) {
       busyDates = 'From: ' 
                 + user.Project_Resources__r[i].StartDate__c.format() 
                 + ' To: ' 
                 + user.Project_Resources__r[i].EndDate__c.format();

       notAvailableDates.get(user.Id).add(busyDates);
     }
     
 }
   
   //List for available resources
   List<User> availableResources = New List<User>();

   for (User user : resources){
       /*if(user.Project_Resources__r.isEmpty()){
           availableResources.add(user);
       }*/
       if(!resourcesProjectId.contains(user.Id)){
       system.debug(' size : '+ notAvailableDates.get(user.Id).size());
       system.debug(' size : '+ notAvailableDates);
       user.availableDays__c = sumAvailableDates.get(user.Id);
       if(notAvailableDates.get(user.Id).size()==0){
         user.notAvailableDates__c = 'Not assigned';
         availableResources.add(user);
       } else {
       
         String str = String.join( notAvailableDates.get(user.Id), ' \n' );
         system.debug(' list values : '+ str);
         user.notAvailableDates__c = str;
         if(sumAvailableDates.get(user.Id)!=0) availableResources.add(user);
         
       }
      }
       
   }
       
   return availableResources;    
 }

 @AuraEnabled(cacheable=true)
 public static List <Project_Line_Item__c> getHoursPendingByRole (Id projectId, String roleName) {
   List <Project_Line_Item__c> hoursPending = 
                   [
                   SELECT HoursPending__c
                   FROM Project_Line_Item__c
                   WHERE Project__c = : projectId
                   //AND HoursPending__c > 0
                   AND Role__c = : roleName
                   ];
               
   return hoursPending; 
 }

 @AuraEnabled
 public static void allocateResources(String allocationJSON){

   List<Project_Resources__c> projectResources = (List<Project_Resources__c>) JSON.deserialize(allocationJSON, List<Project_Resources__c>.class);
   
   insert projectResources;
   
   
 }

/* @AuraEnabled(cacheable=true)
 public static Integer calculateWorkingDays(Date startDate, Date endDate){          
        
   Integer workingDays = 0;  
    
   for(integer i=0; i <= startDate.daysBetween(endDate); i++){  
       Date dt = startDate + i;  
       DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
       String dayOfWeek = currDate.format('EEEE');  
       if(dayOfWeek != 'Saturday' && dayOfWeek !='Sunday'){  
           workingDays ++;  
       }     
   }  
         
   System.debug('--Working days'+workingDays);  
   return workingDays;  
} 
*/
}