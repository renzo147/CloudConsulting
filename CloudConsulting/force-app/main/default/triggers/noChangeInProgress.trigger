trigger noChangeInProgress on Project__c (before update) {
    for (Project__c project : Trigger.new) {
        if (project.In_Progress__c && project.Status__c != 'Completed') {
            // Throw an error to prevent updates
            project.addError('Updates are not allowed while the project is in progress.');
        }
    }
}