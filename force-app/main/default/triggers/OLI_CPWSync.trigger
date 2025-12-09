trigger OLI_CPWSync on OpportunityLineItem (before update, before insert, after insert, after update, after delete, after undelete) {
    Set<Id> oppIds = new Set<Id>();
    if(Trigger.isBefore){
     System.debug('>>> OLI_CPWSync Trigger Fired');
     for (OpportunityLineItem oli : Trigger.new) {
            if (oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
        }
    }

    if (Trigger.isDelete) {
        for (OpportunityLineItem oli : Trigger.old) {
            if (oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
        }
    }

    // if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {

    // Ensure non-empty and call handler
    if (!oppIds.isEmpty()) {
        System.debug('>>> Trigger fired for OpportunityLineItems. Calling OLI_CPWHandler.syncCPWFields');
        OLI_CPWHandler.syncCPWFields(oppIds);
    }
}