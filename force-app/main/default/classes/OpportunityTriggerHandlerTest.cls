@isTest
public class OpportunityTriggerHandlerTest {
    @isTest
    static void testPopulateSalesDebriefOnBeforeUpdate() {
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CD Membership Activity (Prospect or Aggregator)').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        
        Account account = new Account();
        account.Name = 'Opp Trigger Test Account';
        account.Subtype__c ='Prospect';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        insert account;
        
        Account account2 = new Account();
        account2.Name = 'Equity Healthcare';
        account2.Subtype__c ='Collaborative Ventures Group (CVG)';
        account2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Aggregator').getRecordTypeId();
        insert account2;
        
        Opportunity opp1 = new Opportunity(Name='Test Opp 1', AccountId = account.Id, RecordTypeId=oppRecordTypeId, Product_Type_Involved_in_Opp__c='Medical',
                                           Disposition_Medical__c='Sold', Does_this_Oppty_Risk_Involve_Exchanges__c = 'No', StageName = 'Closed',
                                           CloseDate = System.today());
        
        Opportunity opp2 = new Opportunity(Name='Test Opp 2', AccountId = account.Id, RecordTypeId=oppRecordTypeId, Product_Type_Involved_in_Opp__c='Vision', 
                                           Disposition_Vision__c='Sold', Does_this_Oppty_Risk_Involve_Exchanges__c = 'No', StageName = 'Closed', 
                                           CloseDate = System.today(), WillThrBeaRFP__c = 'Yes, RFP is Certain');
        
        oppList.add(opp1);
        oppList.add(opp2);
        
        insert oppList;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'Test Vision Product',
            Product_Line__c = 'Vision',
            Family = 'Specialty Products',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp2.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 100
        );
        insert oli;
    }
}