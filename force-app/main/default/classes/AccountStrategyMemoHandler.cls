public class AccountStrategyMemoHandler {

    public static void updateStrategyMemos(List<Account> newList, Map<Id, Account> oldMap) {
    /**********************************************
     * 1. Define ALL Account → Strategy Memo mappings
     **********************************************/
    List<FieldMapping> mappings = new List<FieldMapping>{
        new FieldMapping('BusinessPressures__c',                     'Business_Pressures__c'),
        new FieldMapping('Comments__c',                              'Business_Overview__c'),
        new FieldMapping('PotentialCompellingEvent__c',              'Potential_Compelling_Event__c'),
        new FieldMapping('OurPotentialUniqueBusinessValue__c',       'Unique_Business_Value__c'),
        new FieldMapping('KeyRiskstoourUBV__c',                      'Key_Risks_to_our_UBV__c'),
        new FieldMapping('OutcomeDrivers__c',                        'Outcome_Drivers__c'),
        new FieldMapping('ApproachStrategy__c',                      'Approach_Strategy__c'),
        new FieldMapping('Surest_Last_Action_Taken__c',              'Surest_Last_Action_Taken__c'),
        new FieldMapping('Surest_Next_Action_to_be_Taken__c',        'Surest_Next_Action_to_be_Taken__c'),
        new FieldMapping('Surest_Approach_Strategy__c',              'Surest_Approach_Strategy__c'),
        new FieldMapping('Surest_Network_Constraints__c',            'Surest_Netwok__c'),
        new FieldMapping('Surest_Comments__c',                       'Surest_Comments__c'),
        new FieldMapping('Network_Contracting_Issue_Other__c',       'Network_Contracting_Issue_Other__c'),
  		new FieldMapping('Private_Equity_Relationship__c',           'Private_Equity_Relationship__c'),
        //new FieldMapping('CVGAccount__c.Name',                       'CVG_Association__c'),
        new FieldMapping('Coveted_Account__c',                       'Coveted_Account_SVP__c'),
        new FieldMapping('Web_Address__c',                           'Website_URL__c'),
        new FieldMapping('Primary_Situs_State__c',                   'Primary_Situs_State__c'),
        new FieldMapping('BillingAddress',                           'Address__c'),
        new FieldMapping('BillingCity',                              'Headquarters_City__c'),
        new FieldMapping('Health_Plan_Manager_Industry__c',          'Health_Plan_Manager_Industry__c'),
        new FieldMapping('AnnualRevenue__c',                         'Annual_Revenue__c'),
        new FieldMapping('X2nd_Blues_Bid_Comments__c',                'Bidding_Blue_Plans__c'),
        new FieldMapping('Eligible_for_2nd_Blues_Bid__c',             'Eligible_for_second_Blues_bid__c')
    };


    /**********************************************
     * 2. Detect Accounts where ANY mapped field changed
     **********************************************/
    Set<Id> changedAccIds = new Set<Id>();

    for (Account accNew : newList) {
        Account accOld = oldMap.get(accNew.Id);

        for (FieldMapping m : mappings) {
            if (accNew.get(m.accountField) != accOld.get(m.accountField)) {
                changedAccIds.add(accNew.Id);
                break; // one changed field is enough
            }
        }
    }
	System.debug('changedAccIds List --> '+changedAccIds);
    if (changedAccIds.isEmpty()) return;


    /**********************************************
     * 3. Fetch related Opportunities where Medical Stage != 'Notified'
     **********************************************/
    List<Opportunity> oppList = [
        SELECT Id, AccountId
        FROM Opportunity
        WHERE AccountId IN :changedAccIds
        AND Sales_Stage_Medical__c != 'Notified'
    ];
        
    if (oppList.isEmpty()) return;

    Set<Id> oppIds = new Set<Id>();
    for (Opportunity o : oppList) oppIds.add(o.Id);


    /**********************************************
     * 4. Fetch Strategy Memo records for those Opps
     **********************************************/
    List<Strategy_Memo__c> memoList = [
        SELECT Id, Membership_Activity__c
        FROM Strategy_Memo__c
        WHERE Membership_Activity__c IN :oppIds
    ];

    if (memoList.isEmpty()) return;


    /**********************************************
     * 5. Prepare Account lookup for memo updates
     **********************************************/
    Map<Id, Account> accMap = new Map<Id, Account>(newList);


    /**********************************************
     * 6. Update all mapped fields from Account → Memo
     **********************************************/
    List<Strategy_Memo__c> memosToUpdate = new List<Strategy_Memo__c>();

    // Build quick lookup: OpportunityId → AccountId
    Map<Id, Id> oppToAcc = new Map<Id, Id>();
    for (Opportunity o : oppList) {
        oppToAcc.put(o.Id, o.AccountId);
    }

    for (Strategy_Memo__c memo : memoList) {

        Id accId = oppToAcc.get(memo.Membership_Activity__c);
        if (accId == null) continue;

        Account acc = accMap.get(accId);
        if (acc == null) continue;

        // Apply all mapped fields
        for (FieldMapping m : mappings) {
            //memo.put(m.memoField, acc.get(m.accountField));
            Object val = acc.get(m.accountField);
        	if (val == null) {
                continue; // do not update field
            }

            if (val instanceof Boolean) {
                Boolean boolVal = (Boolean) val;
                memo.put(m.memoField, boolVal != null ? boolVal : false);
            }
            else if (val instanceof Date) {
                memo.put(m.memoField, (Date) val);
            }
            else if (val instanceof Datetime) {
                memo.put(m.memoField, (Datetime) val);
            }
        	else if (val instanceof Decimal) {
                memo.put(m.memoField, String.valueOf(val));
            }
        	else {
                memo.put(m.memoField, val);
            }
        }

        memosToUpdate.add(memo);
    }
       System.debug('memosToUpdate --> '+memosToUpdate);

    if (!memosToUpdate.isEmpty()) {
        update memosToUpdate;
    }
}


/**********************************************
 * Helper Class for Field Mapping
 **********************************************/
    public class FieldMapping {
        public String accountField;
        public String memoField;
    
        public FieldMapping(String accFld, String memoFld) {
            accountField = accFld;
            memoField = memoFld;
        }
    }
}