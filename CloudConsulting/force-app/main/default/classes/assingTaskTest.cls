@isTest
public with sharing class assingTaskTest {

    @isTest
  static void checkInsert() {
      //List<String> newRoles = New List<String>{'Developer', 'Consultant', 'Project Manager', 'Architect'};
          List<String> newRoles = New List<String>{'Developer'};
    Integer numOfProjects = 1;
    Integer numOfResources = 1;
    List<Project__c> projects = dataFactory.createProjects(
      numOfProjects,
      Date.today(),
      Date.today().addDays(7)
    );
    System.debug('Projects ' + projects);
      
    List<Project__c> projects2 = dataFactory.createProjects(
      numOfProjects,
      Date.today().addDays(100),
      Date.today().addDays(120)
    );
    System.debug('Projects 2 ' + projects2);
      
    List<Project_Line_Item__c> pli = dataFactory.createProjectLineItems(
      projects,
      newRoles
    );
      System.debug(pli);
    
    List<Project_Line_Item__c> pli2 = dataFactory.createProjectLineItems(
      projects2,
      newRoles
    );
      
    List<User> resources = dataFactory.createBulkUsers(
      projects,
      numOfResources
    );
    System.debug(resources);
    
      
    Test.startTest();            
      
   	Project_Resources__c newRP = dataFactory.createSingleResourceProject(
      projects.get(0).Id,
      pli.get(0).Id,
      resources.get(0).Id,      
      Date.today().addDays(1),
      Date.today().addDays(2),
      10
    );
      
   Project_Resources__c rpInDB = [
      SELECT Id
      FROM Project_Resources__c
      WHERE Id = :newRP.Id
    ];
    System.assert(
      rpInDB != null,
      'permite asignar a un proyecto en fechas validas'
    );
    Boolean throwsError = false;
    try {
      newRP = dataFactory.createSingleResourceProject(
        projects.get(0).Id,
        pli.get(0).Id,
        resources.get(0).Id,
        Date.today(),
        Date.today().addDays(26),
        10
          
      );
        System.debug(newRP);
    } catch (Exception e) {
      throwsError = true;
    }
    System.assert(
      throwsError,
      'evita que asigne a un recurso a una fecha invalida'
    );
    
    throwsError = false;
    try {
      newRP = dataFactory.createSingleResourceProject(
        projects.get(0).Id,
        pli.get(0).Id,
        resources.get(0).Id,
        Date.today().addDays(5),
        Date.today().addDays(4),
        10
      );
        System.debug(newRP);
    } catch (Exception e) {
      throwsError = true;
    }
    System.assert(
      !throwsError,
      'evita que asigne fecha de inicio mayor a fecha de fin'
    );


     
    throwsError = false;
    try {
      newRP = dataFactory.createSingleResourceProject(
        projects.get(0).Id,
        pli.get(0).Id,
        resources.get(0).Id,
        Date.today().addDays(1),
        Date.today().addDays(4),
        10
      );
        System.debug(newRP);
    } catch (Exception e) {
      throwsError = true;
    }
    System.assert(
      !throwsError,
      'se superpone la fecha'
    );
     
    throwsError = false;
    try {
      newRP = dataFactory.createSingleResourceProject(
        projects.get(0).Id,
        pli.get(0).Id,
        resources.get(0).Id,
        Date.today(),
        Date.today().addDays(1),
        10
          
      );
        System.debug(newRP);
    } catch (Exception e) {
      throwsError = true;
    }
    System.assert(
      !throwsError,
      'fecha fin'
    );
      
    throwsError = false;
    try {
       newRP = dataFactory.createSingleResourceProject(
        projects.get(0).Id,
        pli.get(0).Id,
        resources.get(0).Id,
        Date.today(),
        Date.today().addDays(4),
        300
      );
        
    } catch (Exception e) {
      throwsError = true;
    }
    System.assert(
      !throwsError,
      'excede horas'
    );
      
    throwsError = false;
    try {
      newRP = dataFactory.createSingleResourceProjectNull(
        projects.get(0).Id,
        pli.get(0).Id,
        resources.get(0).Id
      );
        System.debug(newRP);
    } catch (Exception e) {
      throwsError = true;
    }
    System.assert(
      !throwsError,
      'fecha NULL'
    );
       
    
    Test.stopTest();
 }     
    
  @isTest
  static void checkInsert2() {
      //List<String> newRoles = New List<String>{'Developer', 'Consultant', 'Project Manager', 'Architect'};
          List<String> newRoles = New List<String>{'Developer'};
    Integer numOfProjects = 1;
    Integer numOfResources = 1;
    
    List<Project__c> projects2 = dataFactory.createProjects(
      numOfProjects,
      Date.today().addDays(100),
      Date.today().addDays(120)
    );
    
      
    
    List<Project_Line_Item__c> pli2 = dataFactory.createProjectLineItems(
      projects2,
      newRoles
    );
      
    List<User> resources = dataFactory.createBulkUsers(
      projects2,
      numOfResources
    );
    Test.startTest();  
    Boolean throwsError1 = false;
    try {
      Project_Resources__c newRP2 = dataFactory.createSingleResourceProject(
        projects2.get(0).Id,
        pli2.get(0).Id,
        resources.get(0).Id,
        Date.today().addDays(110),
        Date.today().addDays(111),
        100
          
      );
        System.debug(newRP2);
    } catch (Exception e) {
      throwsError1 = true;
    }
    System.assert(
      throwsError1,
      'evita que asigne horas de mas'
    );   
    Test.stopTest();
      
  }
       
  @isTest
    static void getAvailableEmployeesByRole() {
    List<String> newRoles = New List<String>{'Developer'};
    Integer numOfProjects = 1;
    Integer numOfResources = 3;
    List<Project__c> projects = dataFactory.createProjects(
      numOfProjects,
      Date.today().addDays(10),
      Date.today().addDays(30)
    );
    
    List<Project__c> projects2 = dataFactory.createProjects(
      numOfProjects,
      Date.today(),
      Date.today().addDays(30)
    );
    
    List<Project__c> projects3 = dataFactory.createProjects(
      numOfProjects,
      Date.today(),
      Date.today().addDays(40)
    );
    List<Project_Line_Item__c> pli = dataFactory.createProjectLineItems(
      projects,
      newRoles
    );
    
    List<Project_Line_Item__c> pli2 = dataFactory.createProjectLineItems(
      projects2,
      newRoles
    );
    
    List<Project_Line_Item__c> pli3 = dataFactory.createProjectLineItems(
      projects3,
      newRoles
    );
    
    List<User> resources = dataFactory.createBulkUsers(
      projects,
      numOfResources
    ); 
    
	  
    System.debug('Resources ' + resources.size());
        for(User rs : resources){
            System.debug('Resources ' + rs.LastName + ' ' + rs.UserRole.Name);
        }
    Project_Resources__c newRP = dataFactory.createSingleResourceProject(
      projects.get(0).Id,
      pli.get(0).Id,
      resources.get(0).Id,      
      Date.today().addDays(15),
      Date.today().addDays(16),
      10
    );
    
    Project_Resources__c newRP2 = dataFactory.createSingleResourceProject(
      projects2.get(0).Id,
      pli2.get(0).Id,
      resources.get(0).Id,      
      Date.today().addDays(5),
      Date.today().addDays(12),
      10
    );
    
    Project_Resources__c newRP3 = dataFactory.createSingleResourceProject(
      projects3.get(0).Id,
      pli3.get(0).Id,
      resources.get(0).Id,      
      Date.today().addDays(25),
      Date.today().addDays(35),
      10
    );
        
    Project_Resources__c newRP4 = dataFactory.createSingleResourceProject(
      projects3.get(0).Id,
      pli3.get(0).Id,
      resources.get(1).Id,      
      Date.today().addDays(5),
      Date.today().addDays(35),
      10
    );
        
    List <User> resourcesByRole = resourcesAllocation.getAvailableEmployeesByRole(null,
      projects.get(0).Id
    );       

        
    System.debug('Resources Size ' + resourcesByRole.size());
        
        for(User rs : resources){
            System.debug('Resources ' + rs.LastName + ' ' + rs.UserRole.Name);
        }
        
    Test.startTest();
    
        
    //List <User> resourcesByRole = resourcesAllocation.getAvailableEmployeesByRole('Developer',
    //  projects.get(0).Id
    //);
    	Test.stopTest();
    }  
    
    /*@isTest
    static void allocateResources() {
        String JsonString= '[{"User__c":"005Dp000001y1cQIAQ","Project__c":"a00Dp000009y0jXIAQ","Project_Line_Item__c":"a01Dp000002z3GlIAI","StartDate__c":"2023-05-08","EndDate__c":"2023-05-12","RequieredHours__c":50}]';
        resourcesAllocation.allocateResources(JsonString);
    }*/
    
    @isTest
    static void getHoursPendingByRole() {
        List<String> newRoles = New List<String>{'Developer'};
    Integer numOfProjects = 1;
    Integer numOfResources = 3;
    List<Project__c> projects = dataFactory.createProjects(
      numOfProjects,
      Date.today().addDays(10),
      Date.today().addDays(30)
    );
    List<Project_Line_Item__c> pli = dataFactory.createProjectLineItems(
      projects,
      newRoles
    );
        List <Project_Line_Item__c> hoursPending = resourcesAllocation.getHoursPendingByRole(projects.get(0).Id, newRoles[0]);
        List<Project_Line_Item__c> rolesWithoutAssignment = resourcesAllocation.getRolesWhithoutAssignment(projects.get(0).Id);
        List <Project_Line_Item__c> hoursPendingTask = assingTask.getHoursPendingByRole(projects.get(0).Id, newRoles[0]);
        List<Project_Line_Item__c> rolesWithoutAssignmentTask = assingTask.getRolesWhithoutAssignment(projects.get(0).Id);
    }
       
    
    @isTest
    static void assingTask() {
        List<String> newRoles = New List<String>{'Developer'};
        Integer numOfProjects = 1;
    Integer numOfResources = 2;
    List<Project__c> projects = dataFactory.createProjects(
      numOfProjects,
      Date.today().addDays(10),
      Date.today().addDays(30)
    );
        
    List<User> resources = dataFactory.createBulkUsers(
      projects,
      numOfResources
    ); 
        
    List<Project_Line_Item__c> pli = dataFactory.createProjectLineItems(
      projects,
      newRoles
    );
        
    List<Project_Resources__c> resPros = new List<Project_Resources__c>();
        
    Project_Resources__c newRP1 = dataFactory.createSingleResourceProject(
      projects.get(0).Id,
      pli.get(0).Id,
      resources.get(0).Id,      
      Date.today().addDays(10),
      Date.today().addDays(11),
      10
    );
        
    //resPros.add(newRP1);
        
    Project_Resources__c newRP2 = dataFactory.createSingleResourceProject(
      projects.get(0).Id,
      pli.get(0).Id,
      resources.get(1).Id,      
      Date.today().addDays(10),
      Date.today().addDays(11),
      10
    );
    
    //resPros.add(newRP2);
        
    /*List<Project_Resources__c> newRP = dataFactory.createResourceProjects(
      projects,
      resources,
      1,      
      Date.today().addDays(15),
      Date.today().addDays(16)      
    );*/
        /*System.debug('newRP ' + resPros.size());
      List<Task__c> testTasks = datafactory.createTasks(
       resPros,
       3
      );*/
        Test.startTest();
        
        Boolean throwsError = false;
    	try {
      	Task__c task1 = datafactory.createTask(
       	newRP1,
       	30,
        'TestTask'
      	);
        
    	} catch (Exception e) {
      	throwsError = true;
        }
        System.assert(
          throwsError,
          'menos horas'
        );
        
        throwsError = false;
    	try {
      	Task__c task1 = datafactory.createTask(
       	newRP1,
       	1,
        ''
      	);
        
    	} catch (Exception e) {
      	throwsError = true;
        }
        System.assert(
          !throwsError,
          'descripcion nula'
        );
        
        throwsError = false;
    	try {
      	Task__c task1 = datafactory.createTask(
       	newRP1,
       	NULL,
        'Null'
      	);
        
    	} catch (Exception e) {
      	throwsError = true;
        }
        System.assert(
          !throwsError,
          'horas nula'
        );
        
        throwsError = false;
    	try {
      	Task__c task1 = datafactory.createTask(
       	newRP1,
       	-1,
        'Negative'
      	);
        
    	} catch (Exception e) {
      	throwsError = true;
        }
        System.assert(
          !throwsError,
          'horas negativas'
        );
        Test.stopTest();
    }
    
    @isTest
    static void assingTaskWrapper() {
        List<String> newRoles = New List<String>{'Developer'};
        Integer numOfProjects = 1;
    Integer numOfResources = 2;
    List<Project__c> projects = dataFactory.createProjects(
      numOfProjects,
      Date.today().addDays(10),
      Date.today().addDays(30)
    );
        
    List<User> resources = dataFactory.createBulkUsers(
      projects,
      numOfResources
    ); 
        
    List<Project_Line_Item__c> pli = dataFactory.createProjectLineItems(
      projects,
      newRoles
    );
        
    List<Project_Resources__c> resPros = new List<Project_Resources__c>();
        
    Project_Resources__c newRP1 = dataFactory.createSingleResourceProject(
      projects.get(0).Id,
      pli.get(0).Id,
      resources.get(0).Id,      
      Date.today().addDays(10),
      Date.today().addDays(11),
      10
    );
        List <assingTask.UserWrapper> getAvailableEmployeesByRole = assingTask.getAvailableEmployeesByRole(
            'Developer', 
            projects.get(0).Id
        );
    }
    
    @isTest
    static void assingTaskInsert() {
        List<String> newRoles = New List<String>{'Developer'};
        Integer numOfProjects = 1;
    Integer numOfResources = 2;
    List<Project__c> projects = dataFactory.createProjects(
      numOfProjects,
      Date.today().addDays(10),
      Date.today().addDays(30)
    );
        
    List<User> resources = dataFactory.createBulkUsers(
      projects,
      numOfResources
    ); 
        
    List<Project_Line_Item__c> pli = dataFactory.createProjectLineItems(
      projects,
      newRoles
    );
        
    List<Project_Resources__c> resPros = new List<Project_Resources__c>();
        
    Project_Resources__c newRP1 = dataFactory.createSingleResourceProject(
      projects.get(0).Id,
      pli.get(0).Id,
      resources.get(0).Id,      
      Date.today().addDays(10),
      Date.today().addDays(11),
      10
    );
        Task__c instance = new Task__c();
        instance.Description__c = 'abc123';
        instance.StartDate__c = Date.today();
        instance.EndDate__c = Date.today().addDays(5);
        instance.EstimatedHours__c = 1;
        instance.Project_Resource__c = newRP1.Id;
        instance.Status__c = 'Not Started';
        
        List<Task__c> instanceList = new List<Task__c>();
        instanceList.add(instance);
        String myJSON = JSON.serialize(instance);
		String myJSONList = JSON.serialize(instanceList);
        
        assingTask.assingTasks(myJSONList);
    }
    
    @isTest
    static void allocateResources() {
        List<String> newRoles = New List<String>{'Developer'};
    Integer numOfProjects = 1;
    Integer numOfResources = 1;
    List<Project__c> projects = dataFactory.createProjects(
      numOfProjects,
      Date.today(),
      Date.today().addDays(7)
    );
        
       
    List<Project_Line_Item__c> pli = dataFactory.createProjectLineItems(
      projects,
      newRoles
    );
          
    List<User> resources = dataFactory.createBulkUsers(
      projects,
      numOfResources
    );
        Project_Resources__c instance = new Project_Resources__c();
        instance.User__c = resources.get(0).Id;
        instance.StartDate__c = Date.today();
        instance.EndDate__c = Date.today().addDays(5);
        instance.Project__c = projects.get(0).Id;
        instance.Project_Line_Item__c = pli.get(0).Id;
        instance.RequieredHours__c = 1;
        
        //String JsonString= '[{"User__c":"005Dp000001y1cQIAQ","Project__c":"a00Dp000009y0jXIAQ","Project_Line_Item__c":"a01Dp000002z3GlIAI","StartDate__c":"2023-05-08","EndDate__c":"2023-05-12","RequieredHours__c":50}]';
        List<Project_Resources__c> instanceList = new List<Project_Resources__c>();
        instanceList.add(instance);
        String myJSON = JSON.serialize(instance);
		String myJSONList = JSON.serialize(instanceList);
        resourcesAllocation.allocateResources(myJSONList);
    }
}