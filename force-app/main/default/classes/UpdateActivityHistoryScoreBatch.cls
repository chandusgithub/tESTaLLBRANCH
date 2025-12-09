global class UpdateActivityHistoryScoreBatch implements Database.Batchable<SObject> {
    private Date startDate;
    private Date endDate;
    
    // Constructor to accept date range
    public UpdateActivityHistoryScoreBatch(Date startDate, Date endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    // Query activity history records within the date range
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Contact__c, Channel_Category__c, Channel__c, Activity__c, Connected_Object_Lookup_Id__c FROM Activity_History__c ' +
                       'WHERE Activity_Date__c >= :startDate AND Activity_Date__c <= :endDate';
        return Database.getQueryLocator(query);
    }
    
    // Process each batch of records
    global void execute(Database.BatchableContext bc, List<Activity_History__c> activityHistoryList) {
        Map<String, Channel_Activity__c> channelActivityByUniqueKey = new Map<String, Channel_Activity__c>();
		List<Activity_History__c>updatedActivityHistoryList = new List<Activity_History__c>();
        // Fetch Channel Activity records
        for (Channel_Activity__c ca : [
            SELECT Id, Unique_Key__c, Per_Activity_Score__c, Parent_Channel_Activity_Weightage__c, Activity_Type__c
            FROM Channel_Activity__c
        ]) {
            channelActivityByUniqueKey.put(ca.Unique_Key__c, ca);
        }
        
        // Update activity history records based on Channel Activity Score
        for (Activity_History__c activity : activityHistoryList) {
            if(channelActivityByUniqueKey.containsKey(activity.Channel_Category__c + '_' + activity.Channel__c + '_' + activity.Activity__c)){
                Activity_History__c activityHistoryIns=new Activity_History__c();
                activityHistoryIns.Id=activity.Id;
                activityHistoryIns.Activity_Score__c = channelActivityByUniqueKey.containsKey(activity.Channel_Category__c + '_' + activity.Channel__c + '_' + activity.Activity__c) ? 
                    										channelActivityByUniqueKey.get(activity.Channel_Category__c + '_' + activity.Channel__c + '_' + activity.Activity__c).Per_Activity_Score__c : 0;
                

                updatedActivityHistoryList.add(activityHistoryIns);
            }
        }
        
        // Perform bulk update
        if (!updatedActivityHistoryList.isEmpty()) {
            update updatedActivityHistoryList;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed.');
    }
}