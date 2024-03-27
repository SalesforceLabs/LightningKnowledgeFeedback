/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Trigger on the after insert event of a feedback item
**/
trigger afl_InsertArticleFeedback on FeedItem (after insert) {
    afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
    // Only execute trigger if checkbox is enabled and also if there is not a hashtag configured
    // which means that the user has not configured it yet so the trigger should be executed by default.
    if (af.Chatter_triggers_enabled__c || String.isEmpty(af.Hashtag__c)) {
        afl_TriggerHandler.handleTriggerInsertion('FeedItem', trigger.new);   
    }
}