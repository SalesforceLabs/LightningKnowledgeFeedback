/**
* @author Altimetrik
* @description
*    started on 07/09/2018
*    Trigger for adding for the feeds left from Ligthning Knowledge articles.
**/
trigger afl_InsertLgtnArticleFeedback on FeedComment (after insert) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Set<String> keySet = gd.keySet();
    for (String key : keySet) {
        Schema.SObjectType objectType = gd.get(key);
        if (key.endsWith('kav')&& objectType.getDescribe().isAccessible()) {
            if (afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.SObjectType)) {
                // Handle trigger insertion
                afl_TriggerHandler.handleTriggerInsertion('FeedComment', trigger.new);
            }          
        }
    }
}
   