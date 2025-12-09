public with sharing class AccountEngagementPerformanceFetcher {
    
      @InvocableMethod
    public static List<Response> getPrompt(List<Request> requests) {
        Request input = requests[0];
        List<Response> responses = new List<Response>();
        Response output = new Response();
        responses.add(output);
        
        output.Prompt = 'Channel Performance Report for Account\n';
        
        
        Map<String, Map<String, Integer>> channelPerformance = new Map<String, Map<String, Integer>>();
        
        Map<String, Decimal> channelToScoreMap = new Map<String, Decimal>();
        
        list<Channel_Activity__c> channelWeightages =[SELECT Channel__r.Name, Per_Activity_Score__c, Activity_type__c FROM Channel_Activity__c];
        
        for (Channel_Activity__c act : channelWeightages) {
            //system.debug('act.Channel__c act.Activity_type__c'+act.Channel__c+'_'+act.Activity_type__c);
            channelToScoreMap.put(act.Channel__r.Name+'_'+act.Activity_type__c, act.Per_Activity_Score__c);
        }       
        for (AggregateResult ar : [ 
            SELECT Channel__c, Activity__c, COUNT(Id) total 
            FROM Engagement_Activity_Metrics__c 
            WHERE AccountId__c = :input.account.Id 
            GROUP BY Channel__c, Activity__c 
        ]) {
            String channel = (String) ar.get('Channel__c');
            String activity = (String) ar.get('Activity__c');
            Integer count = (Integer) ar.get('total');
            
            if (!channelPerformance.containsKey(channel)) {
                channelPerformance.put(channel, new Map<String, Integer>());
            }
            
            channelPerformance.get(channel).put(activity, count);
        }
        
        if (channelPerformance.isEmpty()) {
            output.Prompt += '\nNo engagement activities found for this account.';
        } else {
            
            for (String channel : channelPerformance.keySet()) {	
                Double totalWeight =0;
                output.Prompt += '\n' + channel + ':\n';
                Map<String, Integer> activities = channelPerformance.get(channel);
                for (String activity : activities.keySet()) {
                    output.Prompt += ' - ' + activity + ': ' + activities.get(activity) + '\n';
                    //system.debug(channel+'-'+activity);
                    totalWeight +=channelToScoreMap.get(channel+'_'+activity) * activities.get(activity);
                }
                output.Prompt += 'Channel Activity Score : '+totalWeight+'\n';
            }
        }
        
        return responses;
    }
    
    public class Request {
        @InvocableVariable(required=true)
        public Account account;
    }
    
    public class Response {
        @InvocableVariable
        public String Prompt;
    }

}