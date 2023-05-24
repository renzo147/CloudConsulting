@isTest
public class WorkloadTest {
	
    @testSetup
    static void createDataTest(){
       
       
       // Creo un Project , un Project line Item y un Proyect Resource
       Project__c proyecto = new Project__c(Name = 'TestProject', ProjectManager__c = UserInfo.getUserId(), Status__c = 'Pre Kickoff', QuantityHours__c = 10, StartDate__c = Date.today(), EndDate__c = Date.today() + 3, Amount__c = 1000, SquadLead__c= UserInfo.getUserId());    
       Insert proyecto;
       Project_Line_Item__c pli = new Project_Line_Item__c(Name= 'pliTest', HoursPerRole__c= 50 , Role__c= 'Developer', Project__c= proyecto.Id);
       insert pli; 
       Project_Resources__c prResource = new Project_Resources__c(Project_Line_Item__c= pli.Id, RequieredHours__c= 10, User__c= UserInfo.getUserId() , Project__c= proyecto.Id, StartDate__c = Date.today(), EndDate__c = Date.today() + 1);        
       insert prResource;
        
       // creo tarea asociada al recurso
       
       Task__c task = new Task__c(
            Status__c = 'In Progress',
            Description__c = 'Test Task',
            StartDate__c = Date.today(),
            EndDate__c = Date.today()+ 1,
            EstimatedHours__c = 5,
            WorkedHours__c = 0,
            Project_Resource__c = prResource.Id
        );
        insert task;
	 
    }
    
    
    @isTest
    static void testGetProject() {
		
        // Llamar al método getProject() y verificar que devuelve los registros correctos
        Test.startTest();
        List<Project_Resources__c> proResource = Workload.getProject();
        Test.stopTest();
		
        List<Project__c> pr =[SELECT Id FROM Project__c WHERE Name = 'TestProject'];
        System.debug(proResource);
        System.debug(pr);
        System.assertEquals(1, proResource.size());
        System.assertEquals(proResource[0].Project__c, pr[0].Id);
        
    }

    @isTest
    static void testGetTask() {
		
        List<Project_Resources__c> prResource = [SELECT Id FROM Project_Resources__c WHERE Project__r.Name= 'TestProject'];
        System.debug(prResource + 'id del recurso de prueba');
        
        // Llamar al método getTask() con el ID del registro de Project_Resources__c y verificar que devuelve los registros correctos
        Test.startTest();
        List<Task__c> taskFromMethod = Workload.getTask(prResource[0].Id);
        Test.stopTest();
		
        List<Task__c> task = [SELECT Id, Status__c FROM Task__c WHERE Description__c= 'Test Task'];
        System.assertEquals(1, taskFromMethod.size());
        System.assertEquals(task[0].Id, taskFromMethod[0].Id);
        System.assertEquals(task[0].Status__c, taskFromMethod[0].Status__c);
        
    }

    @isTest
    static void testUpdateWorkedHours() {
        
        //Obtengo la tarea de prueba para actualizarla mediante el metodo
        List<Task__c> TaskToUpdate =[SELECT Id FROM Task__c WHERE Description__c = 'Test Task'];

        // Llamar al método updateWorkedHours() y verificar que el registro se actualiza correctamente
        Test.startTest();
        Task__c updatedTask = Workload.updateWorkedHours(TaskToUpdate[0].Id, true, 3);
        Test.stopTest();

        System.assertEquals('Completed', updatedTask.Status__c);
        System.assertEquals(3, updatedTask.WorkedHours__c);
    }
    
    @isTest
    static void closeProject() {
        List<Project__c> prToClose = [SELECT Id FROM Project__c WHERE Name = 'TestProject'];
    
        Test.startTest();
        try {
            prToClose[0].Status__c = 'Completed';
            update prToClose;
        } catch(DmlException e) {
            System.debug(e);
            System.assert(e.getMessage().contains('You cannot close a project with a close date different from the current date.'), 'El mensaje de error no es el esperado');
        }
    
        try {
            prToClose[0].Status__c = 'Completed';
            prToClose[0].EndDate__c = Date.today();
            update prToClose;
        } catch(DmlException e2) {
            System.debug(e2);
            System.assert(e2.getMessage().contains('The project cannot be completed until all tasks are finished.'), 'El mensaje de error no es el esperado');
        }
    
        try {
            List<Task__c> task = [SELECT Id FROM Task__c WHERE Description__c = 'Test Task'];  
            Workload.updateWorkedHours(task[0].Id, True, 10);
            prToClose[0].Status__c = 'Completed';
            prToClose[0].EndDate__c = Date.today();
            update prToClose;
            System.assertEquals('Completed', task[0].Status__c);
            System.assertEquals('Completed', prToClose[0].Status__c);
        } catch(Exception e3) {
            System.debug(e3 + 'No esperaba fallo aqui');
        }
    
        Test.stopTest();
    }


}