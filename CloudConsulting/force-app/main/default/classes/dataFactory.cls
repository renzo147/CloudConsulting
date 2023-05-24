@isTest
public with sharing class dataFactory {
	public static List<Project__c> createProjects(Integer numOfProjects, Date StartDate, Date EndDate) {
    /*Opportunity sampleOp = new Opportunity(
      Name = 'SampleOp',
      StageName = 'Closed Won',
      CloseDate = Date.today()
    );
    insert sampleOp;*/
    List<Project__c> projects = new List<Project__c>();
    for (Integer p = 0; p < numOfProjects; p++) {
      Project__c pro = new Project__c(
        Name = 'Project' + p,
        //Opportunity__c = sampleOp.Id,
        Status__c = 'Pre Kickoff',
        StartDate__c = StartDate,
        EndDate__c = EndDate
      );
      projects.add(pro);
    }
    insert projects;
    return projects;
  }
    
  public static List<Project_Line_Item__c> createProjectLineItems(
    List<Project__c> projects,
    List<String> newRoles
  ) {
    List<Project_Line_Item__c> proLineItems = new List<Project_line_Item__c>();
    for (Project__c pro : projects) {
      for (String role : newRoles) {
        Project_Line_Item__c newPLI = new Project_Line_Item__c(
          Project__c = pro.Id,
          Role__c = role,
          HoursPerRole__c = 50,
          HoursAllocated__c = 0
        );
        proLineItems.add(newPLI);
      }
    }
    insert proLineItems;
    return proLineItems;
  }
    
  public static User createUser(
    Integer resourceIndex,
    Id profileId,
    UserRole role
  ) {
    User resource = new User(
      lastName = 'testUser' + resourceIndex,
      Username = 'test' + resourceIndex + '@pivots.com',
      email = 'test' + resourceIndex + '@pivotstest.com',
      alias = 'Alias' + resourceIndex,
      CommunityNickname = 'Nick' + resourceIndex,
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'GMT',
      ProfileId = profileId,
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      UserRole = role
    );
    return resource;
  }
  
   
  public static List<User> createBulkUsers(
    List<Project__c> projects,
    Integer numOfResources
  ) {
    Integer index = 0;
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    List<UserRole> roles = [SELECT Id, Name FROM UserRole WHERE Name = 'Developer'];
      //OR Name ='Consultant' OR Name = 'Architect' OR Name = 'Project Manager'
    List<User> resources = new List<User>();
    for (Project__c pro : projects) {
      for (Integer r = 1; r <= numOfResources; r++) {
        //Integer roleIndex = math.mod(roles.size(), r);
        User newUser = dataFactory.createUser(
          index++,
          profileId.Id,
          roles.get(0)
        );
        resources.add(newUser);
      }
    }
    insert resources;
    return resources;
  }
    
  public static List<Project_Resources__c> createResourceProjects(
    List<Project__c> projects,
    List<User> resources,
    Integer numOfResources,
    Date startDate,
    Date endDate
  ) {
    List<Project_Resources__c> resPros = new List<Project_Resources__c>();
    Integer ResourceIndex = 0;
    for (Project__c pro : projects) {
      //pro.SquadLead__c = resources.get(ResourceIndex).Id;
      for (Integer r = 0; r < numOfResources; r++) {
        User res = resources.get(ResourceIndex);
        ResourceIndex++;
        Project_Resources__c newResPro = new Project_Resources__c(
          Project__c = pro.Id,
          User__c = res.Id,
          //HoursAllocated__c = 50,
          RequieredHours__c = 10,
          StartDate__c = startDate,
      	  EndDate__c = endDate
        );
          System.debug('ResPros ' + newResPro);
        resPros.add(newResPro);
      }
    }
      System.debug('ResPros ' + resPros);
    //update projects;
    insert resPros;
    return resPros;
  }
    
  public static Project_Resources__c createSingleResourceProject(
    Id projectId,
    Id pli,
    Id resourceId,
    Date startDate,
    Date endDate,
    Integer requieredHours
  ) {
    Project_Resources__c newResPro = new Project_Resources__c(
      Project__c = projectId,
      User__c = resourceId,
      Project_Line_Item__c = pli,
      //HoursAllocated__c = 50,
      RequieredHours__c = requieredHours,
      StartDate__c = startDate,
      EndDate__c = endDate
    );
    System.debug('PR ' + newResPro);
    insert newResPro;
    return newResPro;
  }
    
  public static Project_Resources__c createSingleResourceProjectNull(
    Id projectId,
    Id pli,
    Id resourceId
  ) {
    Project_Resources__c newResPro = new Project_Resources__c(
      Project__c = projectId,
      User__c = resourceId,
      Project_Line_Item__c = pli,
      //HoursAllocated__c = 50,
      RequieredHours__c = 0
      
    );
    System.debug('PR NULL ' + newResPro);
    insert newResPro;
    return newResPro;
  }
    
  public static List<Task__c> createTasks(
    List<Project_Resources__c> resPros,
    Integer numOfTasks
  ) {
    Map<Id, List<Project_Resources__c>> resProsByProjectId = new Map<Id, List<Project_Resources__c>>();
    for (Project_Resources__c RP : resPros) {
      if (resProsByProjectId.containsKey(RP.Project__c)) {
        resProsByProjectId.get(RP.Project__c).add(RP);
      } else {
        resProsByProjectId.put(
          RP.Project__c,
          new List<Project_Resources__c>{ RP }
        );
      }
    }
    Map<Id, Project__c> projectsById = new Map<Id, Project__c>(
      [
        SELECT Id, SquadLead__c
        FROM Project__c
        WHERE Id IN :resProsByProjectId.keySet()
      ]
    );
    Set<Id> squadLeadsIds = new Set<Id>();
    for (Project__c pro : projectsById.values()) {
      squadLeadsIds.add(pro.SquadLead__c);
    }
    Map<Id, User> squadLeads = new Map<Id, User>(
      [SELECT Id FROM USER WHERE Id IN :squadLeadsIds]
    );
    List<Task__c> allTasks = new List<Task__c>();
    for (Project_Resources__c resPro : resPros) {
      List<Task__c> tasks = new List<Task__c>();
      for (Integer t = 0; t < numOfTasks; t++) {
        Task__c task = new Task__c(
          Description__C = 'TaskTest' + t,
          EstimatedHours__c = 1,
          Project_Resource__c = resPro.Id,
          Status__c = 'Not Started',
          EndDate__c = Date.today()
          
        );
        tasks.add(task);
      }
      User squadLead = squadLeads.get(
        projectsById.get(resPro.Project__c).SquadLead__c
      );
      /*System.runAs(squadLead) {
        insert tasks;
      }*/
        insert tasks;
        System.debug('Tasks ' + tasks);
      allTasks.addAll(tasks);
    }
    return allTasks;
  }
    
  public static Task__c createTask(
    Project_Resources__c resPro,
    Integer estimated,
    String description
  ){
      Task__c task = new Task__c(
          Description__C = description,
          EstimatedHours__c = estimated,
          Project_Resource__c = resPro.Id,
          Status__c = 'Not Started',
          EndDate__c = Date.today()          
        );
      insert task;
      return task;
  }
}