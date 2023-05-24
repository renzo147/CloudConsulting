trigger StartProjectManually on Project__c (before insert, before update) {
    for(Project__c proyecto : Trigger.new) {
        // Validar si el estado del proyecto ha cambiado a "En Progreso" 
        if (proyecto.Status__c == 'In Progress' && 
            (Trigger.oldMap == null || Trigger.oldMap.get(proyecto.Id).Status__c != 'In Progress')) {
                
            // Validar Fecha de inicio seteada
            if(proyecto.StartDate__c == Date.today()){
                
                // Validar balance
                if(proyecto.Amount__c > proyecto.Total_Cost__c){
                    
                    // Validar horas cubiertas
                    if(proyecto.QuantityHours__c <= proyecto.QuantityHoursAllocated__c){
                        
                        if(proyecto.SquadLead__c != null){ 
                            List<Project_Resources__c> SquadLead = [SELECT User__c FROM Project_Resources__c WHERE Project__c = :proyecto.Id];
                            Set<Id> userId = New Set<Id>();
                            for(Project_Resources__c sl : SquadLead ){
                                userId.add(sl.User__c);
                            }
                        
                            if(!userId.contains(proyecto.SquadLead__c)){
                                proyecto.SquadLead__c.addError('The squad lead has not been allocated to this project');
                            } else {
                                proyecto.In_Progress__c = True;
                                //El proyecto cumple verificaciones y se guarda en base de datos
                            }
                        } else {
                            proyecto.SquadLead__c.addError('You must assign a Squad Lead');
                        }
                    	
                    } else {
                        proyecto.QuantityHoursAllocated__c.addError('The hours allocated for the project are insufficient.');
                    }
                    
                } else {
                    proyecto.Amount__c.addError('The project cannot start without generating profit.');
                }
                
            } else {
                proyecto.StartDate__c.addError('You cannot start a project with a date different than current date');
            }
        }
    } 
}