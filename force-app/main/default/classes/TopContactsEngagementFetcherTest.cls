@isTest
public with sharing class TopContactsEngagementFetcherTest {
    
    @isTest
    static void testGetPromptWithEngagedContacts() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Subtype__c = 'Prospect',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId()
        );
        insert testAccount;
        
        
          Id cdContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CD Contact').getRecordTypeId();
        
    
        
        // Create test contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact' + i, AccountId = testAccount.Id, RecordTypeId = cdContactRT,
            Status__c = 'Active'));
        }
        insert contacts;
        
        // Create engagement scores (latest one should be picked)
        List<Contact_Engagement_Score__c> scores = new List<Contact_Engagement_Score__c>();
        for (Integer i = 0; i < 3; i++) {
            scores.add(new Contact_Engagement_Score__c(
                Contact_Consultant__c = contacts[i].Id,
                Overall_Score__c = 50 + i,
                End_Date__c = Date.today().addDays(-i)
            ));
        }
        insert scores;
        
        // Create engagement activity metrics
        List<Engagement_Activity_Metrics__c> metrics = new List<Engagement_Activity_Metrics__c>();
        for (Integer i = 0; i < 3; i++) {
            metrics.add(new Engagement_Activity_Metrics__c(
                AccountId__c = testAccount.Id,
                ContactId__c = contacts[i].Id,
                Channel__c = 'Email - Account Specific', 
                Activity__c = 'Open'
            ));
            metrics.add(new Engagement_Activity_Metrics__c(
                AccountId__c = testAccount.Id,
                ContactId__c = contacts[i].Id,
                Channel__c = 'Onsite meeting at UHG', 
                Activity__c = 'Attended'
            ));
        }
        insert metrics;
        
        // Invoke the method
        TopContactsEngagementFetcher.Request request = new TopContactsEngagementFetcher.Request();
        request.account = testAccount;
        List<TopContactsEngagementFetcher.Response> responseList = TopContactsEngagementFetcher.getPrompt(new List<TopContactsEngagementFetcher.Request>{ request });
        
        // Assertions
        System.assertEquals(1, responseList.size());
        System.assert(responseList[0].Prompt.contains('Top Contacts Engagement Report'));
        System.assert(responseList[0].Prompt.contains('Email'));
        System.assert(responseList[0].Prompt.contains('Open'));
    }

    @isTest
    static void testGetPromptWithNoContacts() {
        Account account = new Account(
            Name = 'Test Account',
            Subtype__c = 'Prospect',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId()
        );
        insert account;
        

        TopContactsEngagementFetcher.Request req = new TopContactsEngagementFetcher.Request();
        req.account = account;

        List<TopContactsEngagementFetcher.Response> resp = TopContactsEngagementFetcher.getPrompt(new List<TopContactsEngagementFetcher.Request>{ req });

        System.assertEquals(1, resp.size());
        System.assert(resp[0].Prompt.contains('No engaged contacts'));
    }
}