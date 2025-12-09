@isTest
private with sharing class AccountEngagementPerformanceFetcherTest {

    @isTest
    static void testGetPromptWithActivities() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Subtype__c = 'Prospect',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId()
        );
        insert testAccount;

        // Create Engagement_Activity_Metrics__c records
        List<Engagement_Activity_Metrics__c> activities = new List<Engagement_Activity_Metrics__c>{
            new Engagement_Activity_Metrics__c(AccountId__c = testAccount.Id, Channel__c = 'Email - Account Specific', Activity__c = 'Open'),
            new Engagement_Activity_Metrics__c(AccountId__c = testAccount.Id, Channel__c = 'Onsite meeting at UHG', Activity__c = 'Attended'),
            new Engagement_Activity_Metrics__c(AccountId__c = testAccount.Id, Channel__c = 'Phone Conversations - Account Specific', Activity__c = 'Completed')
            //new Engagement_Activity_Metrics__c(AccountId__c = testAccount.Id, Channel__c = 'SMS', Activity__c = 'Opened'),
            //new Engagement_Activity_Metrics__c(AccountId__c = testAccount.Id, Channel__c = 'SMS', Activity__c = 'Opened')
        };
        insert activities;

        // Prepare Invocable Request
        AccountEngagementPerformanceFetcher.Request request = new AccountEngagementPerformanceFetcher.Request();
        request.account = testAccount;
        List<AccountEngagementPerformanceFetcher.Request> requestList = new List<AccountEngagementPerformanceFetcher.Request>{ request };

        // Call the method
        Test.startTest();
        List<AccountEngagementPerformanceFetcher.Response> result = AccountEngagementPerformanceFetcher.getPrompt(requestList);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size());
        String prompt = result[0].Prompt;
        System.debug('Prompt:\n' + prompt);

        System.assert(prompt.contains('Channel Performance Report for Account'));
        System.assert(prompt.contains('Email'));
       
    }

    @isTest
    static void testGetPromptWithNoActivities() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Subtype__c = 'Prospect',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId()
        );
        insert testAccount;

        // No Engagement_Activity_Metrics__c created

        // Prepare Invocable Request
        AccountEngagementPerformanceFetcher.Request request = new AccountEngagementPerformanceFetcher.Request();
        request.account = testAccount;
        List<AccountEngagementPerformanceFetcher.Request> requestList = new List<AccountEngagementPerformanceFetcher.Request>{ request };

        // Call the method
        Test.startTest();
        List<AccountEngagementPerformanceFetcher.Response> result = AccountEngagementPerformanceFetcher.getPrompt(requestList);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size());
        String prompt = result[0].Prompt;
        System.debug('Prompt:\n' + prompt);

        System.assert(prompt.contains('No engagement activities found for this account.'));
    }
}