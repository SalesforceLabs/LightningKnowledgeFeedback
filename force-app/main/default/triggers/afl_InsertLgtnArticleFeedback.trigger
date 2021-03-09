/**
* @author Altimetrik
* @description
*    started on 07/09/2018
*    Trigger for adding for the feeds left from Ligthning Knowledge articles.
**/
trigger afl_InsertLgtnArticleFeedback on FeedComment (after insert) {
    afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
    // Only execute trigger if checkbox is enabled and also if there is not a hashtag configured
    // which means that the user has not configured it yet so the trigger should be executed by default.
    if (af.Chatter_triggers_enabled__c || String.isEmpty(af.Hashtag__c)) {
        afl_TriggerHandler.handleTriggerInsertion('FeedComment', trigger.new);
    }
}
   