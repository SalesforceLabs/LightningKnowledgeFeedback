/**
* @author Altimetrik
* @description
*    started on 02/04/2019
*    Handler for triggers
**/
public with sharing class afl_TriggerHandler {
	/*
	* @description
	*	Handles the trigger values and inserts an Article Feedback if applicable
	* @params
	*	String with type of Feed, List of the trigger records.
	* @return
	*	void
	*/
	public static void handleTriggerInsertion(String type, List<SObject> triggerObjects) {
		if (!afl_ArticleFeedbackSecurityHandler.isVisibleKav()) {
			return;
		}

		if (!afl_ArticleFeedbackSecurityHandler.isCreateable(afl_Article_Feedback__c.SObjectType)) {
			return;
		}

		Set<Id> setIds = new Set<Id>();
		// Set customs settings
		if (afl_ArticleFeedbackSecurityHandler.isAccessible(Schema.SObjectType.afl_Knowledge_feedback__c.getSobjectType())) {
			afl_Knowledge_feedback__c kf = afl_Knowledge_feedback__c.getOrgDefaults();
			if (String.isEmpty(kf.Hashtag__c)) {
				kf.Hashtag__c = '#ArticleFeedback';
				if (afl_ArticleFeedbackSecurityHandler.isCreateable(Schema.SObjectType.afl_Knowledge_feedback__c.getSobjectType()) && afl_ArticleFeedbackSecurityHandler.isUpdateable(Schema.SObjectType.afl_Knowledge_feedback__c.getSobjectType())) {
					UPSERT kf;
				}
			}

			// Check that the post originates from a Knowledge Article
			if (type.equals('FeedItem')) {
				for (SObject sObj : triggerObjects) {
					FeedItem f = (FeedItem) sObj;
					String parentId = f.parentId;
					if (parentId.startsWith('kA') && (f.Type == 'TextPost' || f.Type == 'LinkPost') && f.Body.containsIgnoreCase(kf.Hashtag__c)) {
						setIds.add(f.ParentId);
					}
				}
			} else if (type.equals('FeedComment')) {
				for (SObject sObj : trigger.new) {
					FeedComment f = (FeedComment) sObj;
					String parentId = f.parentId;
					if (parentId.startsWith('kA') && f.CommentType == 'TextComment' && f.CommentBody.containsIgnoreCase(kf.Hashtag__c)) {
						setIds.add(f.ParentId);
					}
				}
			}
		}

		if (!setIds.isEmpty()) {
			Map<String,SObject> mKav = new Map<String,SObject>();

			// Set recordType flag and recordType query parameter
			Boolean hasRecordType = afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive;
			String recordTypeField = '';
			if (hasRecordType) {
				recordTypeField = ', RecordTypeId';
			}

			// Set IsMasterLanguage flag and IsMasterLanguage query parameter
			String masterLanguageField = '';
			if (afl_ArticleFeedbackSecurityHandler.isMasterLanguageActive) {
				masterLanguageField = ' AND IsMasterLanguage = true ';
			}

			// Set Knowledge object
			String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;

			// Set publication status
			String pubStatus = 'Online';
			if (Test.isRunningTest()) {
				pubStatus = 'draft';
			}

			// Get the article from the post's ParentId
			String query = 'SELECT KnowledgeArticleId, CreatedDate, ArticleNumber, Title, VersionNumber, Language, LastPublishedDate, LastModifiedById ' + recordTypeField +
			' FROM ' + knowledgeObject +
			' WHERE PublishStatus = \'' + pubStatus + '\'' + ' AND KnowledgeArticleId IN :setIds ' + masterLanguageField +
			' ORDER BY CreatedDate ASC';
			List<SObject> kavs = Database.query(query);

			for (SObject kav : kavs) {
				if (!mKav.containsKey((Id) kav.get('KnowledgeArticleId'))) {
					mKav.put((Id) kav.get('KnowledgeArticleId'), kav);
				}
			}

			// Get languages
			Map<String,String> mapLanguages = new Map<String,String>();
			Schema.DescribeFieldResult fieldResult = KnowledgeArticleVersion.Language.getDescribe();
			List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

			for (Schema.PicklistEntry picklistEntry : picklistValues) {
				mapLanguages.put(picklistEntry.getValue(),picklistEntry.getLabel());
			}

			// Set community availabilty and name
			String netId = '';
			Boolean communitiesAvailable = false;
			String commName = afl_ArticleFeedbackSecurityHandler.getCommunityName();
			Set<String> objectFields = Schema.SObjectType.FeedItem.fields.getMap().keySet();

			if (objectFields.contains('networkscope')) {
				communitiesAvailable = true;
				netId = Network.getNetworkId();

				if (String.isNotEmpty(netId)) {
					String networkQuery = 'SELECT Name FROM Network WHERE Id =: netId';
					SObject comm = Database.query(networkQuery);
					commName = (String) comm.get('Name');
				}
			}

			try {
				// Check object permissions
				if (afl_ArticleFeedbackSecurityHandler.isCreateable(Schema.SObjectType.afl_Article_Feedback__c.getSobjectType())) {
					List<afl_Article_Feedback__c> lstAfd = new List<afl_Article_Feedback__c>();
					for (SObject feed : triggerObjects) {
	                    String parentId = (String) feed.get('ParentId');

	                    if (mKav.containsKey(parentId)) {
	                        SObject kav = mKav.get(parentId);
								afl_Article_Feedback__c afd = new afl_Article_Feedback__c();

								afd.Article_Number__c = (String) kav.get('ArticleNumber');
								afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String) kav.get('KnowledgeArticleId');
								afd.Article_Title__c = (String) kav.get('Title');
								afd.Knowledge_Article_Version_Id__c = (String) kav.get('Id');

								if(hasRecordType) {
									afd.Record_Type__c = afl_ArticleFeedbackSecurityHandler.getRecordTypeName(kav);

								}

								// Set feedback from Feed Body and Id
								if (type.equals('FeedItem')) {
									afd.Feedback__c = (String) feed.get('Body');
									afd.Parent_FeedItem__c = (String) feed.get('Id');
								} else {
									afd.Feedback__c = (String) feed.get('CommentBody');
									afd.Parent_FeedItem__c = (String) feed.get('FeedItemId');
								}

								afd.Article_Version__c = (Decimal) kav.get('VersionNumber');
								afd.Feedback_Status__c = 'New';
								afd.Language__c = mapLanguages.get((String) kav.get('Language'));
								afd.Last_Published_Date__c = (Datetime) kav.get('LastPublishedDate');
								afd.Last_Published_By__c = (String) kav.get('LastModifiedById');
								afd.Article_Created_Date__c = (Datetime) kav.get('CreatedDate');
								
								afd.Originated_From_Trigger__c = true;

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

	                if (lstAfd.size() > 0) {
	                    INSERT lstAfd;
	                }
				}
			} catch (System.Exception e) {
	            String errorStr = '\n getTypeName : ' + e.getTypeName() +
	            '\n getCause: ' + e.getCause() +
	            '\n getMessage: ' + e.getCause() +
	            '\n getLineNumber: ' + e.getLineNumber() +
	            '\n getStackTraceString: ' + e.getStackTraceString() +
	            '\n getTypeName: ' + e.getTypeName();
	        }
		}
	}
}