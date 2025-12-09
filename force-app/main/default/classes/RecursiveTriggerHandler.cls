//Static variable which is set to true by default which is used to avoid recursion on triggers
//Used in : CM_DoNotSendCorrespondance_ValidationRule
public class RecursiveTriggerHandler {
	public static Boolean isFirstTime = true;
    
     public static void afterUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
         system.debug('afterrr updateee - ');
        List<FieldMapping> mappings = new List<FieldMapping>{
        new FieldMapping('Phone', 'Phone_Number__c'),
        new FieldMapping('Email', 'Consultant_Email__c'),
       // new FieldMapping('Name', 'RFP_Primary_Consultant_s__c'),
        new FieldMapping('MailingAddress', 'Consultant_Address__c'),
        new FieldMapping('MailingCity', 'Consultant_Firm_Loc__c')       
    	};

        Set<Id> updatedContactIds = new Set<Id>();
		system.debug('newList - '+newList);
        // Identify contacts where mapped fields have changed
        for (Contact c : newList) {
            Contact oldC = oldMap.get(c.Id);
			 if (c.FirstName != oldC.FirstName ||
                 c.LastName  != oldC.LastName) 
             {
                 updatedContactIds.add(c.Id);
                 continue;
             }
            for (FieldMapping m : mappings) {
                Object newVal = c.get(m.sourceField);
                Object oldVal = oldC.get(m.sourceField);
				system.debug('newVal - '+newVal);
                system.debug('oldVal - '+oldVal);
                if (newVal != oldVal) {
                    updatedContactIds.add(c.Id);
                    break;
                }
            }
        }
		system.debug('updatedContactIds - '+updatedContactIds);
        if (updatedContactIds.isEmpty()) return;

        // Fetch opportunities linked via PrimaryConsultant__c
        List<Opportunity> relatedOpps = [
            SELECT Id, Sales_Stage_Medical__c,PrimaryConsultant__c
            FROM Opportunity
            WHERE PrimaryConsultant__c IN :updatedContactIds
            AND Sales_Stage_Medical__c != 'Notified'
        ];
		system.debug('relatedOpps - '+relatedOpps);
        if (relatedOpps.isEmpty()) return;

        Map<Id, Opportunity> relatedOppsMap = new Map<Id, Opportunity>();
        for (Opportunity opp : relatedOpps) {
            relatedOppsMap.put(opp.Id, opp);
        }

        Set<Id> oppIds = relatedOppsMap.keySet();


        // Fetch Strategy Memo records for these opportunities
        List<Strategy_Memo__c> memos = [
            SELECT Id, Membership_Activity__c
            FROM Strategy_Memo__c
            WHERE Membership_Activity__c IN :oppIds
        ];
		system.debug('memos - '+memos);
        if (memos.isEmpty()) return;

        Map<Id, Contact> newMap = new Map<Id, Contact>(newList);
        List<Strategy_Memo__c> memosToUpdate = new List<Strategy_Memo__c>();

        for (Strategy_Memo__c memo : memos) {
            Opportunity opp = relatedOppsMap.get(memo.Membership_Activity__c);
            Contact con = newMap.get(opp.PrimaryConsultant__c);
            if (con == null) continue;
			if (String.isNotBlank(con.LastName)) {
                memo.RFP_Primary_Consultant_s__c =
                (String.isNotBlank(con.Salutation) ? con.Salutation + ' ' : '') +
                (String.isNotBlank(con.FirstName)  ? con.FirstName  + ' ' : '') +
                (String.isNotBlank(con.MiddleName) ? con.MiddleName + ' ' : '') +
                con.LastName;
            }
            for (FieldMapping m : mappings) {
                Object val = con.get(m.sourceField);

                // OPTION B → Skip if null
                if (val == null) continue;

                // Type-safe assignment
                if (val instanceof Boolean) memo.put(m.targetField, (Boolean) val);
                else if (val instanceof Date) memo.put(m.targetField, (Date) val);
                else if (val instanceof Datetime) memo.put(m.targetField, (Datetime) val);
                else if (val instanceof Decimal) memo.put(m.targetField, (Decimal) val);
                else memo.put(m.targetField, val);
            }

            memosToUpdate.add(memo);
        }
		system.debug('memosToUpdate - '+memosToUpdate);
        if (!memosToUpdate.isEmpty()) {
            update memosToUpdate;
        }
    }
    public class FieldMapping {
        public String sourceField;
        public String targetField;
    
        public FieldMapping(String sourceField, String targetField) {
            this.sourceField = sourceField;
            this.targetField = targetField;
        }
	}
}