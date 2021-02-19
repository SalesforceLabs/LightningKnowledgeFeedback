/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Trigger on the after insert event of a feedback item
**/
trigger afl_InsertArticleFeedback on FeedItem (after insert) {
    afl_TriggerHandler.handleTriggerInsertion('FeedItem', trigger.new);   
}