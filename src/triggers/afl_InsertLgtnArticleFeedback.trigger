/**
* @author Altimetrik
* @description
*    started on 07/09/2018
*    Trigger for adding for the feeds left from Ligthning Knowledge articles.
**/
trigger afl_InsertLgtnArticleFeedback on FeedComment (after insert) {
    if (afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.sObjectType)) {
        // Handle trigger insertion
        afl_TriggerHandler.handleTriggerInsertion('FeedComment', trigger.new);
    }
}
