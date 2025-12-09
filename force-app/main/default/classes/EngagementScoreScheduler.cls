/*
*********************************************************
Trigger Name    : EngagementScoreScheduler
Created Date       : Feb 27, 2025
@description       : This scheduler triggers the batch class weekly or monthly once.
@author            : Satheesh Chandrasekar
Modification Log:
Ver   Date         Author                               Modification
1.0   27-02-2025   Satheesh Chandrasekar           		Initial Version

*********************************************************
*/
public class EngagementScoreScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        try {
            /* ---------------Weekly run - Start------------------------------- */
            // Get the current date (end date)
           /* Date endDate = Date.today();
            endDate = endDate.addDays(-1);
            
            // Calculate the start date (6 days before the end date)
            Date startDate = endDate.addDays(-6);*/
            
             Date endDate = Date.today().toStartofWeek(); // Sunday
            // Calculate the start date (6 days before the end date)
            Date startDate = endDate.addDays(-6);
             system.debug('start Date : '+startDate+'End Date : '+ endDate);
            
          
            // Call the EngagementScoreProcessor with the startDate and endDate
            EngagementScoreProcessor.processEngagementScores(
                'Activity_Date__c',
                startDate,
                endDate,
                null,
                'Scheduled'
            ); 
            /* ---------------Weekly run - End------------------------------- */
        } catch (Exception e) {
            System.debug('Scheduler Failed: ' + e.getMessage());
           // sendFailureNotification(e);
        }
    }
    /*
    // 🔹 Method to send failure notification
    private void sendFailureNotification(Exception e) {
        // Fetch email from Custom Label
        String emailRecipients = System.Label.Batch_Error_Notification_Email; // Custom Label Name
        
        if (String.isBlank(emailRecipients)) {
            System.debug('⚠️ No email recipient found in custom label.');
            return; // Exit if no email is set
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Email recipients (Add required recipients)
        // mail.setToAddresses(new String[]{'satheesh.chandrasekar@crmit.com'});
        mail.setToAddresses(emailRecipients.split(',')); // Support multiple emails separated by comma
        
        mail.setSubject('🚨 Engagement Score Scheduler Failed');
        mail.setPlainTextBody(
            'An error occurred while executing the EngagementScoreScheduler.\n\n' +
            'Error Details: ' + e.getMessage() + '\n\n' +
            'Stack Trace: ' + e.getStackTraceString()
        );
        
        // Send email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
    }*/
}