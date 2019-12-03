/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Trigger on the after insert event of a feedback item
**/
trigger afl_InsertArticleFeedback on FeedItem (after insert) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Set<String> keySet = gd.keySet();
    for (String key : keySet) {
        Schema.SObjectType objectType = gd.get(key);
        if (key.endsWith('kav')&& objectType.getDescribe().isAccessible()) {
            if (afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.SObjectType)) {
                // Handle trigger insertion
                afl_TriggerHandler.handleTriggerInsertion('FeedItem', trigger.new);
            }
        }
    }    
}