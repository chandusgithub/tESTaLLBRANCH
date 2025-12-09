public with sharing class TaskActivityHistoryHelper {
    public static void processActivityHistoryRecords(
        Set<Id> taskIds,
        Map<Id, Task> newTaskMap,
        Map<Id, Task> oldTaskMap,
        Boolean isUpdate
    ) {
        List<Activity_History__c> activityHistories = new List<Activity_History__c>();
        Map<Id, List<Id>> taskContactMap = new Map<Id, List<Id>>();
        
        // Get additional contacts from TaskRelation
        for (TaskRelation tr : [
            SELECT TaskId, RelationId FROM TaskRelation WHERE TaskId IN :taskIds AND Relation.Type = 'Contact'
        ]) {
            if (!taskContactMap.containsKey(tr.TaskId)) {
                taskContactMap.put(tr.TaskId, new List<Id>());
            }
            taskContactMap.get(tr.TaskId).add(tr.RelationId);
        }
        
        // Generate unique keys to fetch existing Activity History records
        Set<String> historyKeys = new Set<String>();
        for (Task t : newTaskMap.values()) {
            List<Id> contacts = new List<Id>();
            
            if (t.WhoId != null) contacts.add(t.WhoId);
            if (taskContactMap.containsKey(t.Id)) {
                for (Id cId : taskContactMap.get(t.Id)) {
                    if (!contacts.contains(cId)) contacts.add(cId);
                }
            }
            
            for (Id cId : contacts) {
                historyKeys.add(t.Id + '_' + t.Status + '_' + cId);
            }
        }
        system.debug('historyKeys'+historyKeys);
        
        // Fetch existing Activity History records
        Map<String, Activity_History__c> existingHistories = new Map<String, Activity_History__c>();
        for (Activity_History__c ah : [
            SELECT Id, Unique_Key_with_ContactId__c FROM Activity_History__c 
            WHERE Unique_Key_with_ContactId__c IN :historyKeys
        ]) {
            system.debug('existingHistory'+ah.Unique_Key_with_ContactId__c);
            existingHistories.put(ah.Unique_Key_with_ContactId__c, ah);
        } 
        
        // Fetch Channel Activity scores
        Map<String, Channel_Activity__c> channelScores = new Map<String, Channel_Activity__c>();
        for (Channel_Activity__c ca : [
            SELECT Id, Unique_Key__c, Per_Activity_Score__c, Activity_Type__c
            FROM Channel_Activity__c 
            WHERE Channel__r.Channel_Category__c = 'Task'
        ]) {
            channelScores.put(ca.Unique_Key__c, ca);
        }
        
        // Generate new Activity History records if needed
        for (Task t : newTaskMap.values()) {
            List<Id> contactIds = new List<Id>();
            if (t.WhoId != null) contactIds.add(t.WhoId);
            if (taskContactMap.containsKey(t.Id)) {
                for (Id cId : taskContactMap.get(t.Id)) {
                    if (!contactIds.contains(cId)) contactIds.add(cId);
                }
            }
            
            // Update check - only proceed if status changed or new contact added
            Boolean runCheck = true;
            if (isUpdate && oldTaskMap.containsKey(t.Id)) {
                Task oldT = oldTaskMap.get(t.Id);
                Boolean statusChanged = oldT.Status != t.Status;
                Boolean contactAdded = oldT.WhoCount != t.WhoCount;
                
                /*    Integer oldCount = 0;
if (oldT.WhoId != null) oldCount++;
if (taskContactMap.containsKey(t.Id)) oldCount += taskContactMap.get(t.Id).size();

contactAdded = contactIds.size() > oldCount;*/
                runCheck = statusChanged || contactAdded;
            }
            
            if (!runCheck) continue;
            
            for (Id cId : contactIds) {
                String uniqueKey = t.Id + '_' + t.Status + '_' + cId;
                if (!existingHistories.containsKey(uniqueKey)) {
                    String channelKey = 'Task_' + t.Type + '_' + t.Status;
                    if (!channelScores.containsKey(channelKey)) {
                        continue; // skip if no matching channel activity
                    }
                    system.debug('unique_key->'+uniqueKey);
                    system.debug('unique_keycondition->'+(!existingHistories.containsKey(uniqueKey)));
                    
                    Decimal score = channelScores.get(channelKey).Per_Activity_Score__c;
                    
                    /*  Integer d = t.ActivityDate.day();
Integer mo = t.ActivityDate.month();
Integer yr = t.ActivityDate.year();
DateTime DT = DateTime.newInstance(yr, mo, d);*/
                    Activity_History__c ah = new Activity_History__c(
                        Channel_Category__c = 'Task',
                        Channel__c = t.Type,
                        Activity__c = t.Status, 
                        Contact__c = cId,
                        Connected_Object_Lookup_Id__c = t.Id,
                        Activity_Date__c = DateTime.newInstance(t.ActivityDate.year(), t.ActivityDate.month(), t.ActivityDate.day()), 
                        Activity_Score__c = score
                    );
                    activityHistories.add(ah);
                }
            }
        }
        
        
        // presentTime=presentTime.addhours(TimeConversions.getCurrentUserTZOffsetFromEastern(userId));        
        //presentDate = Datetime.valueOf((t.ActivityDate).addhours(TimeConversions.getCurrentUserTZOffsetFromEastern(t.ownerId))).date();
        
        if (!activityHistories.isEmpty()) {
            insert AS USER activityHistories;
        }
    }
}