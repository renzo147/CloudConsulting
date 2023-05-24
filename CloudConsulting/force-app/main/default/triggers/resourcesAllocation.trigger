trigger resourcesAllocation on Project_Resources__c (before insert) {
    List <Project_Resources__c> resourcesRejected = resourcesAllocationTrigger.validateResources(Trigger.new);

    //https://salesforce.stackexchange.com/questions/237042/adderror-on-an-object-in-a-trigger-is-only-displaying-one-of-the-errors-in-objec

    Set<Id> resourcesRejectedId = New Set<Id>();
    for(Project_Resources__c rr : resourcesRejected ){
        resourcesRejectedId.add(rr.User__c);
    }

    List <User> resourcesRejectedName =
                        [
                        SELECT Name
                        FROM User
                        WHERE Id IN : resourcesRejectedId
                        ];

    Map<Id, User> resourcesRejectedMap = New Map<Id,User>(resourcesRejectedName);
    if (resourcesRejected.size()>0){
    System.debug('Trigger ' + resourcesRejected[0].RequieredHours__c);
    System.debug('Equal ' + (resourcesRejected[0].RequieredHours__c == -1));
    
    }
    System.debug('Size ' + (resourcesRejected.size()>0));
    String[] problems = new String[0];
    if (resourcesRejected.size()>0){
        System.debug('A ' + resourcesRejected[0].RequieredHours__c);
    if(resourcesRejected[0].RequieredHours__c == 5){
        System.debug('1');
        //for(Project_Resources__c rRejected : resourcesRejected){
        //    rRejected.adderror('Allocated hours exceed pending');
        
        resourcesRejected[0].addError('Allocated hours exceed pending');
        
        
    }else{
        System.debug('2');
        for(Project_Resources__c rRejected : resourcesRejected){                 
            
            problems.add('You Can not Allocate the resource ' 
                            + resourcesRejectedMap.get(rRejected.User__c).Name
                            + ' on the indicated date ' 
                            + rRejected.StartDate__c + ' - ' 
                            + rRejected.EndDate__c
                            //+ '\n'
                            );            
            
        }

        resourcesRejected[0].addError(String.join(problems,'\n///'));
                      
   }


    /*if (resourcesRejected.size()>0){
    System.debug('2');
    for(Project_Resources__c rRejected : resourcesRejected){                 
        
        problems.add('You Can not Allocate the resource ' 
                        + resourcesRejectedMap.get(rRejected.User__c).Name
                        + ' on the indicated date ' 
                        + rRejected.StartDate__c + ' - ' 
                        + rRejected.EndDate__c
                        //+ '\n'
                        );            
        
    }

    resourcesRejected[0].addError(String.join(problems,'\n///'));
                  
    }*/
}

}