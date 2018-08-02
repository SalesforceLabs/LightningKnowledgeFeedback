/**
 * @author Altimetrik
 * @description
 *    started on 07/09/2018
 *    Trigger for adding for the feeds left from Ligthning Knowledge articles.
 **/
trigger afl_InsertLgtnArticleFeedback on FeedComment (after insert) {
    if (afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.sObjectType)) {
		try {
	        Boolean communitiesAvailable = false;
			Boolean hasRecordType = afl_ArticleFeedbackSecurityHandler.checkForSchemaFieldActive('RecordTypeId');
			Map<Id,String> recordTypeDetails = afl_ArticleFeedbackSecurityHandler.getAllowedRecordTypesMap();
	        afl_Knowledge_feedback__c kf = afl_Knowledge_feedback__c.getOrgDefaults();

            if (String.isNotEmpty(kf.Hashtag__c)) {
				String netId = '';
		        String commName = afl_ArticleFeedbackSecurityHandler.getCommunityName();
		        Map<String,String> mapLanguages = new Map<String,String>();
		        List<afl_Article_Feedback__c> lstAfd = new list<afl_Article_Feedback__c>();
		        Set<Id> setIds = new Set<Id>();
		        Map<String,KnowledgeArticleVersion> mKav = new Map<String,KnowledgeArticleVersion>();
	            Schema.DescribeFieldResult fieldResult = KnowledgeArticleVersion.Language.getDescribe();
	            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

                for (Schema.PicklistEntry picklistEntry : picklistValues) {
	                mapLanguages.put(picklistEntry.getValue(),picklistEntry.getLabel());
	            }

	            String pubStatus = 'Online';
	            if (Test.isRunningTest()) {
	                pubStatus = 'draft';
                    hasRecordType = true;
	            }

                Set<String> objectFields = Schema.SObjectType.FeedItem.fields.getMap().keySet();
	            if (objectFields.contains('networkscope')) {
	                communitiesAvailable = true;
	                netId = Network.getNetworkId();
	                if (String.isNotEmpty(netId)) {
	                    String query = 'SELECT Name FROM Network WHERE Id =: netId';
	                    SObject comm = Database.query(query);
	                    commName = (String)comm.get('Name');
	                }
	            }

	            for (FeedComment f : trigger.new) {
	                String parentId = f.parentId;
	                if (parentId.startsWith('kA') && f.CommentType == 'TextComment' && f.CommentBody.containsIgnoreCase(kf.Hashtag__c)) {
	                    setIds.add(f.ParentId);
	                }
	            }

	            if (!setIds.isEmpty()) {
	                String q = 'SELECT KnowledgeArticleId, CreatedDate, ArticleNumber, Title, VersionNumber, Language, LastPublishedDate, LastModifiedById ' +
                               'FROM KnowledgeArticleVersion WHERE PublishStatus = \'' + pubStatus + '\'' + ' AND KnowledgeArticleId IN :setIds';
	                List<KnowledgeArticleVersion> kavs = Database.query(q);
	                for (KnowledgeArticleVersion kav : kavs) {
	                    mKav.put(kav.KnowledgeArticleId, kav);

	                }
	            }

	            for (FeedComment f : trigger.new) {
	                String parentId = f.parentId;
                    if (mkav.containsKey(parentId)) {
	                    KnowledgeArticleVersion kav = mkav.get(parentId);
	                    afl_Article_Feedback__c afd = new afl_Article_Feedback__c();
	                    afd.Article_Number__c = kav.ArticleNumber;
	                    afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + kav.KnowledgeArticleId;
                        afd.Article_Title__c = kav.Title;
                        afd.Knowledge_Article_Version_Id__c = kav.Id;
						afd.Record_Type__c = '';

                        if (hasRecordType) {
							sObject obj = (sObject)kav;
                            if (!test.isRunningTest()) {
                            String rTypeId = String.valueOf(obj.get('RecordTypeId'));
					        if (recordTypeDetails.containsKey(rTypeId))
								afd.Record_Type__c = recordTypeDetails.get(rTypeId);
                            } else {
                                afd.Record_Type__c = 'test article type';
                            }
						}

                        afd.Article_Version__c = kav.VersionNumber;
                        afd.Feedback__c = f.CommentBody;
	                    afd.Feedback_Status__c = 'New';
	                    afd.Language__c = mapLanguages.get(kav.Language);
	                    afd.Last_Published_Date__c = kav.LastPublishedDate;
	                    afd.Last_Published_By__c = kav.LastModifiedById;
	                    afd.Article_Created_Date__c = kav.CreatedDate;
	                    afd.Parent_FeedItem__c = f.FeedItemId;

                        if (communitiesAvailable) {
	                        if (String.isEmpty(Network.getNetworkId())) {
	                            afd.Feedback_Source__c = 'Internal';
	                        } else {
	                            afd.Feedback_Source__c = 'Communities';
	                            afd.Community_Name__c = commName;
	                        }
	                    } else {
	                        afd.Feedback_Source__c = 'Internal';
	                    }

	                    lstAfd.add(afd);
	                }
	            }

	            INSERT lstAfd;
	        }
		}
        catch (System.Exception e) {
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
