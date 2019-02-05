/**
* @author Altimetrik
* @description
*    started on 07/09/2018
*    Trigger for adding for the feeds left from Ligthning Knowledge articles.
**/
trigger afl_InsertLgtnArticleFeedback on FeedComment (after insert) {
    if (afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.sObjectType)) {
        try {
            // Get values to be used in trigger
            afl_TriggerHandler.HandlerWrapper handlerWrapper = afl_TriggerHandler.handleTriggerValues();
            
            List<afl_Article_Feedback__c> lstAfd = new list<afl_Article_Feedback__c>();
            Set<Id> setIds = new Set<Id>();
            Map<String,sObject> mKav = new Map<String,sObject>();
            
            for (FeedComment f : trigger.new) {
                String parentId = f.parentId;
                if (parentId.startsWith('kA') && f.CommentType == 'TextComment' && f.CommentBody.containsIgnoreCase(handlerWrapper.KnowledgeFeedback.Hashtag__c)) {
                    setIds.add(f.ParentId);
                }
            }
            
            if (!setIds.isEmpty()) {
                String q = 'SELECT KnowledgeArticleId, CreatedDate, ArticleNumber, Title, VersionNumber, Language, LastPublishedDate, LastModifiedById' + handlerWrapper.RecordTypeField +
                ' FROM ' + handlerWrapper.KnowledgeObject + ' WHERE PublishStatus = \'' + handlerWrapper.PubStatus + '\'' + ' AND KnowledgeArticleId IN :setIds';
                List<sObject> kavs = Database.query(q);
                for (sObject kav : kavs) {
                    mKav.put((String)kav.get('KnowledgeArticleId'), kav);
                    
                }
            }
            
            for (FeedComment f : trigger.new) {
                String parentId = f.parentId;
                if (mkav.containsKey(parentId)) {
                    SObject kav = mkav.get(parentId);
                    afl_Article_Feedback__c afd = new afl_Article_Feedback__c();
                    afd.Article_Number__c = (String)kav.get('ArticleNumber');
                    afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' +  (String)kav.get('KnowledgeArticleId');
                    afd.Article_Title__c = (String)kav.get('Title');
                    afd.Knowledge_Article_Version_Id__c = (String)kav.get('Id');
                    
                    if (!Test.isRunningTest()) {
                        if (handlerWrapper.HasRecordType) {
                            String rTypeId = String.valueOf(kav.get('RecordTypeId'));
                            if (handlerWrapper.RecordTypeDetails.containsKey(rTypeId)) {
                                afd.Record_Type__c = handlerWrapper.RecordTypeDetails.get(rTypeId);
                            }
                        }
                    }  else {
                        afd.Record_Type__c = 'test article type';
                    }
                    
                    afd.Article_Version__c = (Decimal)kav.get('VersionNumber');
                    afd.Feedback__c = f.CommentBody;
                    afd.Feedback_Status__c = 'New';
                    afd.Language__c = handlerWrapper.MapLanguages.get((String)kav.get('Language'));
                    afd.Last_Published_Date__c = (Datetime)kav.get('LastPublishedDate');
                    afd.Last_Published_By__c = (String)kav.get('LastModifiedById');
                    afd.Article_Created_Date__c = (Datetime)kav.get('CreatedDate');
                    afd.Parent_FeedItem__c = f.FeedItemId;
                    
                    if (handlerWrapper.CommunitiesAvailable) {
                        if (String.isEmpty(Network.getNetworkId())) {
                            afd.Feedback_Source__c = 'Internal';
                        } else {
                            afd.Feedback_Source__c = 'Communities';
                            afd.Community_Name__c = handlerWrapper.CommName;
                        }
                    } else {
                        afd.Feedback_Source__c = 'Internal';
                    }
                    
                    lstAfd.add(afd);
                }
            }
            
            if (lstAfd.size() > 0) {
                INSERT lstAfd;
            }
        } catch (System.Exception e) {
            String errorStr = '\n getTypeName: ' + e.getTypeName() +
            '\n getCause: ' + e.getCause() +
            '\n getMessage: ' + e.getCause() +
            '\n getLineNumber: ' + e.getLineNumber() +
            '\n getStackTraceString: ' + e.getStackTraceString() +
            '\n getTypeName: ' + e.getTypeName();
            System.debug('\n====== InsertArticleFeedbackComment Exception :\n' +  errorStr);
        }
    }
}
