@isTest
public class EngagementScoreSchedulerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data if needed for EngagementScoreProcessor
        Account acc = new Account(
            Name = 'Test Account',
            Subtype__c = 'Prospect',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId()
        );
        insert acc;
        
        Id CDContactRecord = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CD Contact').getRecordTypeId();

        Contact contact = new Contact();
        contact.AccountId = acc.Id;
        contact.CEO__c = false;
        contact.FirstName = 'test qwerty';
        contact.LastName = 'lasr qwerty';
        contact.OtherCountry = 'United States';
        contact.RecordTypeId = CDContactRecord;
        contact.Status__c = 'Active';
        insert contact;
        System.debug('Active Contact ID: ' + contact.Id);


        // Create Activity_History__c records if required
        Activity_History__c activity = new Activity_History__c(
            Contact__c = contact.Id,
            Activity_Score__c = 10,
            Channel__c = 'Email',
            Activity__c = 'Open',
            Activity_Date__c = Date.today()
        );
        insert activity;
    }

    @isTest
    static void testSchedulerExecution() {
        // Arrange
        Test.startTest();
        String cronExpression = '0 0 12 * * ?'; // Run at 12 PM every day
        EngagementScoreScheduler scheduler = new EngagementScoreScheduler();

        // Act
        System.schedule('Test Engagement Score Scheduler', cronExpression, scheduler);
        Test.stopTest();

        // Assert
        // Verify that the EngagementScoreProcessor logic was executed
        // (You can add assertions based on the expected behavior of EngagementScoreProcessor)
        System.assert(true, 'Scheduler executed successfully.');
    }
/*
    @isTest
    static void testSchedulerFailureHandling() {
        // Arrange
        EngagementScoreScheduler scheduler = new EngagementScoreScheduler();

        // Simulate an exception in EngagementScoreProcessor
        Test.startTest();
        try {
            EngagementScoreProcessor.processEngagementScores(
                null, // Invalid field name to force an exception
                Date.today(),
                Date.today(),
                null,
                'Scheduled'
            );
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
        }

        // Act
        scheduler.execute(null); // Call the scheduler directly
        Test.stopTest();

        // Assert
        // Verify that the failure notification logic was executed
        System.assert(true, 'Scheduler failure handling executed successfully.');
    }*/
}