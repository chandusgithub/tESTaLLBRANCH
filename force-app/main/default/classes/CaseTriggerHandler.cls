public class CaseTriggerHandler {
    
    public static void updateUtilization(id userId, string comments){
        
        Map<String, String> params = new Map<String, String>();
        params.put('UserId',userId);
        params.put('IssueCreated',comments);
        Flow.Interview.Utilization_Metric_Flow utilizationFlow = new Flow.Interview.Utilization_Metric_Flow(params);
        utilizationFlow.start();           
        
    }
    
    

    
    //Added by Vignesh  -- CR 3795 
/*    public static void restrictTaskOwnerUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        
        Set<Id> caseIdsToCheck = new Set<Id>();
        Map<Id, Id> caseOwnerMap = new Map<Id, Id>();
        
        for (Case newCase : newCases) {
            Case oldCase = oldCaseMap.get(newCase.Id);
            if (oldCase != null && newCase.OwnerId != oldCase.OwnerId) {
                caseIdsToCheck.add(newCase.Id);
                caseOwnerMap.put(newCase.Id, newCase.OwnerId);
            }
        }
        
         if (caseIdsToCheck.isEmpty()) {
            return; 
        }
        
        List<Task> tasksToUpdate = [SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId IN :caseIdsToCheck AND Status NOT IN ('Completed', 'Closed')];
        
        Map<String,String> mapOfTaskWithOwnerId = new Map<String,String>();
        
        for(Task updateTask : tasksToUpdate){
            if(!mapOfTaskWithOwnerId.containsKey(updateTask.Id)){
                mapOfTaskWithOwnerId.put(updateTask.Id,updateTask.OwnerId);
            }
        }
        
        updateTaskOwner(mapOfTaskWithOwnerId);
    }


    @future
    public static void updateTaskOwner(Map<String,String> mapOfTaskOwner){
        Map<String,String> mapOfTaskWithOwnerId = mapOfTaskOwner;
        List<Task> tasksToUpdate = new List<Task>();
        
        for(Id taskId : mapOfTaskWithOwnerId.keySet()){
            Task toTaskUpdate = new Task();
            toTaskUpdate.Id = taskId;
            toTaskUpdate.OwnerId = mapOfTaskWithOwnerId.get(taskId);
            tasksToUpdate.add(toTaskUpdate);
        }
        update tasksToUpdate;
    }  */
   
}