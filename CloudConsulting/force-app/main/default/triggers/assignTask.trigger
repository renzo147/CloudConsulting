trigger assignTask on Task__c (before insert) {
    List <Task__c> taskRejected = assingTaskTrigger.validateTask(Trigger.new);

    String[] problems = new String[0];
    if (taskRejected.size()>0){

        for(Task__c tRejected : taskRejected){                 
            if(tRejected.EstimatedHours__c < 0){
                problems.add('You Can not Assign the Task ' 
                + tRejected.Description__c
                + ' .Time can not be negative ');
            }else if(tRejected.EstimatedHours__c == NULL){
                problems.add('You Can not Assign the Task ' 
                + tRejected.Description__c
                + ' .Time can not be NULL ');
            }else if(tRejected.Description__c == '' || tRejected.Description__c == NULL){
                problems.add('You Can not Assign the Task ' 
                + tRejected.Description__c
                + ' .Description can not be empty ');
            }else{
                problems.add('You Can not Assign the Task ' 
                + tRejected.Description__c
                + ' .You should assing less hours ');
            }                                              
                                        
            
        }

        taskRejected[0].addError(String.join(problems,'\n'));
    
    }
}