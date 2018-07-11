/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Trigger on the after insert event of a feedback item
 **/
trigger InsertArticleFeedback on FeedItem (after insert) {
    if(ArticleFeedbackSecurityHandler.isCreateable(Article_Feedback__c.sObjectType)) {

		try {
	        Boolean communitiesAvailable = false;
			Boolean hasRecordType = ArticleFeedbackSecurityHandler.checkForSchemaFieldActive('RecordTypeId');
			Map<Id,String> recordTypeDetails = ArticleFeedbackSecurityHandler.getAllowedRecordTypesMap();
	        Knowledge_feedback__c kf = Knowledge_feedback__c.getOrgDefaults();

	        // if (String.isEmpty(kf.Hashtag__c)){
	        //     kf.Hashtag__c = '#ArticleFeedback';
	        //     upsert kf;
	        // }

	        if (String.isNotEmpty(kf.Hashtag__c) ) {
				// String netId = '';
		        String commName = ArticleFeedbackSecurityHandler.getCommunityName();
		        Map<String,String> mapLanguages = new Map<String,String>();
		        List<Article_Feedback__c> lstAfd = new list<Article_Feedback__c>();
		        Set<Id> setIds = new Set<Id>();
		        Map<String,KnowledgeArticleVersion> mKav = new Map<String,KnowledgeArticleVersion>();
	            Schema.DescribeFieldResult fieldResult = KnowledgeArticleVersion.Language.getDescribe();
	            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

                for (Schema.PicklistEntry picklistEntry : picklistValues) {
	                mapLanguages.put(picklistEntry.getValue(),picklistEntry.getLabel());
	            }
	            String pubStatus = 'Online';

	            if (Test.isRunningTest()){
	                pubStatus = 'draft';
                    hasRecordType = true;
	            }

	            for (FeedItem f : trigger.new) {
	                String parentId = f.parentId;
	                if ( parentId.startsWith('kA') && f.Type == 'TextPost' && f.Body.containsIgnoreCase(kf.Hashtag__c) ){
	                    setIds.add(f.ParentId);
	                }
	            }

	            if(!setIds.isEmpty()) {
	                String q = 'select KnowledgeArticleId, CreatedDate, ArticleNumber, Title, VersionNumber, Language, LastPublishedDate, LastModifiedById from KnowledgeArticleVersion where PublishStatus = \'' + pubStatus + '\'' + ' and KnowledgeArticleId IN :setIds';
	                List<KnowledgeArticleVersion> kavs = Database.query(q);
	                for(KnowledgeArticleVersion kav : kavs) {
	                    mKav.put(kav.KnowledgeArticleId, kav);
	                }
	            }

	            for (FeedItem f : trigger.new) {
	                String parentId = f.parentId;

                    if (mkav.containsKey(parentId)) {
	                    KnowledgeArticleVersion kav = mkav.get(parentId);
	                    Article_Feedback__c afd = new Article_Feedback__c();
	                    afd.Article_Number__c = kav.ArticleNumber;
	                    afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + kav.KnowledgeArticleId;
	                    afd.Article_Title__c = kav.Title;
						afd.Article_Type__c = '';

                        if (hasRecordType) {
                            sObject obj = (sObject)kav;
                            if(!test.isRunningTest()) {
                             String rTypeId = String.valueOf(obj.get('RecordTypeId'));
							 if (recordTypeDetails.containsKey(rTypeId))
								afd.Article_Type__c = recordTypeDetails.get(rTypeId);
                            } else {
                                afd.Article_Type__c = 'test article type';
                            }
						}

                        afd.Article_Version__c = kav.VersionNumber;
	                    afd.Feedback__c = f.Body;
	                    afd.Feedback_Status__c = 'New';
	                    afd.Language__c = mapLanguages.get(kav.Language);
	                    afd.Last_Published_Date__c = kav.LastPublishedDate;
	                    afd.Last_Published_By__c = kav.LastModifiedById;
	                    afd.Article_Created_Date__c = kav.CreatedDate;
	                    afd.Parent_FeedItem__c = f.Id;

	                    if(communitiesAvailable) {
	                        if(String.isEmpty(Network.getNetworkId())) {
	                            afd.Feedback_Source__c = 'Internal';
	                        }
	                        else{
	                            afd.Feedback_Source__c = 'Communities';
	                            afd.Community_Name__c = commName;
	                        }
	                    }
	                    else{
	                        afd.Feedback_Source__c = 'Internal';
	                    }
	                    lstAfd.add(afd);
	                }
	            }
	            insert lstAfd;
	        }
		}
        catch (System.Exception e) {
			String errorStr = '\n getTypeName : '+e.getTypeName()+
			'\n getCause : '+e.getCause()+
			'\n getMessage : '+e.getCause()+
			'\n getLineNumber : '+e.getLineNumber()+
			'\n getStackTraceString : '+e.getStackTraceString()+
			'\n getTypeName : '+e.getTypeName();
			system.debug('\n====== InsertArticleFeedback Exception :\n'+  errorStr);
		}
    }
}
