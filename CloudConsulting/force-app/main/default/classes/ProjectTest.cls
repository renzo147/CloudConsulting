@isTest
private class ProjectTest {

    @testSetup
    static void createDataTest() {  
        
        List<User> usuario = [SELECT Id, Name FROM User WHERE Id = '005Dp000001WSTC'];
        List<User> usuario1 = [SELECT Id, Name FROM User WHERE Id = '005Dp000001WSSs'];
        
        System.debug(usuario);
    	
        List<Project__c> projectsToInsert = new List<Project__c>();
        List<Project_Line_Item__c> pliToInsert = new List<Project_Line_Item__c>();
        List<Project_Resources__c> resourcesToInsert = new List<Project_Resources__c>();
          
        Project__c pr1 = new Project__c(Name = 'Without Profit', ProjectManager__c = UserInfo.getUserId(), Status__c = 'Pre Kickoff', QuantityHours__c = 20, StartDate__c = Date.today(), EndDate__c = Date.today() + 1);        
        projectsToInsert.add(pr1);
        
        Project__c pr2 = new Project__c(Name = 'Without Hours Allocated',ProjectManager__c = UserInfo.getUserId(),Status__c = 'Pre Kickoff',QuantityHours__c = 20,StartDate__c = Date.today(),EndDate__c = Date.today() + 1,Amount__c = 1000);    
        projectsToInsert.add(pr2);
        
        Project__c pr3 = new Project__c(Name = 'Invalid Start Date', ProjectManager__c = UserInfo.getUserId(), Status__c = 'Pre Kickoff', QuantityHours__c = 20, StartDate__c = Date.today() + 1, EndDate__c = Date.today() + 2);        
        projectsToInsert.add(pr3);
        
        Project__c pr4 = new Project__c(Name = 'Without Squad Lead',ProjectManager__c = UserInfo.getUserId(),Status__c = 'Pre Kickoff',QuantityHours__c = 10,StartDate__c = Date.today(), EndDate__c = Date.today() + 1, Amount__c = 1000);    
        projectsToInsert.add(pr4);
        
        Project__c pr5 = new Project__c(Name = 'Without Squad Lead allocated',ProjectManager__c = UserInfo.getUserId(),Status__c = 'Pre Kickoff',QuantityHours__c = 10,StartDate__c = Date.today(), EndDate__c = Date.today()+1, Amount__c = 1000, SquadLead__c= usuario[0].Id);    
        projectsToInsert.add(pr5);
        
        Project__c pr6 = new Project__c(Name = 'Correct Project', ProjectManager__c = UserInfo.getUserId(), Status__c = 'Pre Kickoff', QuantityHours__c = 10, StartDate__c = Date.today(), EndDate__c = Date.today() + 3, Amount__c = 1000, SquadLead__c= usuario[0].Id);    
        projectsToInsert.add(pr6);
        
        insert projectsToInsert;
        
        Project_Line_Item__c pli = new Project_Line_Item__c(Name= 'pliTest', 	HoursPerRole__c= 10, Role__c= 'Developer', Project__c= pr4.Id);
        pliToInsert.add(pli);
        
        Project_Line_Item__c pli2 = new Project_Line_Item__c(Name= 'pliTest2', 	HoursPerRole__c= 10, Role__c= 'Developer', Project__c= pr5.Id);
		pliToInsert.add(pli2);   
        
        Project_Line_Item__c pli3 = new Project_Line_Item__c(Name= 'pliTest3', 	HoursPerRole__c= 50 , Role__c= 'Developer', Project__c= pr6.Id);
        pliToInsert.add(pli3);
        
        insert pliToInsert;
        
        Project_Resources__c prResource = new Project_Resources__c(Project_Line_Item__c= pli.Id, RequieredHours__c= 10, User__c= UserInfo.getUserId(), Project__c= pr4.Id, StartDate__c = Date.today(), EndDate__c = Date.today() + 1);
        
		insert prResource;
        
        Project_Resources__c prResource2 = new Project_Resources__c(Project_Line_Item__c= pli2.Id, RequieredHours__c= 10, User__c= usuario1[0].Id , Project__c= pr5.Id, StartDate__c = Date.today(), EndDate__c = Date.today()+1);
        
        insert prResource2;
        
        Project_Resources__c prResource3 = new Project_Resources__c(Project_Line_Item__c= pli3.Id, RequieredHours__c= 10, User__c= usuario[0].Id , Project__c= pr6.Id, StartDate__c = Date.today(), EndDate__c = Date.today() + 1);
        
        insert prResource3;
        
    
    }

    @isTest
    static void updateProjectsTest() {
        
        // Obtener los registros que se van a actualizar
        List<Project__c> projectsToUpdate = [SELECT Id, Name, Status__c FROM Project__c WHERE Status__c = 'Pre Kickoff'];

        // Actualizar los registros y verificar que se lance una excepción
        Test.startTest();
        
        	List<Project__c> projects = new List<Project__c>();
        
        	for(Project__c p : projectsToUpdate){
            	p.Status__c = 'In Progress';
              	projects.add(p);           
          	}
        	Database.SaveResult[] updatedResults = Database.update(projects, false);
        System.debug('Milena aprenda ' + updatedResults[0]);
        
        Test.stopTest();
  		
        List<String> expectedMessage = new List<String> {'The project cannot start without generating profit.','The hours allocated for the project are insufficient.','You cannot start a project with a date different than current date','You must assign a Squad Lead','The squad lead has not been allocated to this project'};	
		Integer i = 0; 
        
        for(Database.SaveResult result : updatedResults) {
        	if(result.isSuccess()){
            	System.assert(result.isSuccess(), 'El registro no se pudo actualizar');
            } else{ 
                
            	for(Database.Error error : result.getErrors()) {
            		System.assertEquals(expectedMessage[i], error.getMessage());               	
                	System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', String.valueOf(error.getStatusCode()));
                    i++;
                }
             }
		}
     
    }
    
    @isTest
    static void noChangeInProgress() {
        List<Project__c> Project = [SELECT Id, Status__c, Amount__c FROM Project__c WHERE Name = 'Correct Project'];
        System.debug(Project + ' sin actualizar');
        Project[0].Status__c = 'In Progress';
        update Project;
        
        Test.startTest();
        
        List<Project__c> PrInProgress = [SELECT Id, Status__c, Amount__c FROM Project__c WHERE Name = 'Correct Project'];
        
        try {
            PrInProgress[0].Amount__c = 7500;
            update PrInProgress;
            System.assert(false, 'Se esperaba que se genere un mensaje de error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Updates are not allowed while the project is in progress.'), 'El mensaje de error no es el esperado');
        }
        
        Test.stopTest();
    }
          
}