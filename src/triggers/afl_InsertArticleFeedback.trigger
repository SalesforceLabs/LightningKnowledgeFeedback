/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Trigger on the after insert event of a feedback item
**/
trigger afl_InsertArticleFeedback on FeedItem (after insert) {
    if (afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.sObjectType)) {
        // Handle trigger insertion
        afl_TriggerHandler.handleTriggerInsertion('FeedItem', trigger.new);
    }
}