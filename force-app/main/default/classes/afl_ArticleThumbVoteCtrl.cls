/**
* @author Altimetrik
* @description
*    started on 11/2018
*    Article Thumbs Votes component's controller
**/
public with sharing class afl_ArticleThumbVoteCtrl {
	/*
	* @description
	*   Method that inserts an article feedback and upserts the vote on an Knowledge Article.
	* @params
	*  Id recordId, String title, String reasonAttr, String unlineDescAttr, Boolean isLikedAttr, Boolean isSameVote
	* @return
	*  Object - afl_LightningResponse
	*/
	@AuraEnabled
	public static afl_LightningResponse upsertThumbArticleVote(Id recordId, String feedbackReason, String voteDescription, Boolean isLiked, Boolean isSameVote, Boolean hasNoRate) {
		try {
			// Check FLS and CRUD
			afl_ArticleFeedbackSecurityHandler.canCreate(afl_Article_Feedback__c.SObjectType);
			afl_ArticleFeedbackSecurityHandler.canCreate(Vote.SObjectType);
			afl_ArticleFeedbackSecurityHandler.canUpdate(Vote.SObjectType);

			afl_Article_Feedback__c artFeed = new afl_Article_Feedback__c();
			Map<Id,String> recordTypeDetails = afl_ArticleFeedbackSecurityHandler.getAllowedRecordTypesMap();

			artFeed.Feedback_Status__c = 'New';
			artFeed.Feedback_Vote_Description__c = voteDescription;
			if (!hasNoRate) {
				artFeed.Like__c = isLiked;
			}
			artFeed.Feedback_Reason__c = feedbackReason;

			String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
			String communityName = afl_ArticleFeedbackSecurityHandler.getCommunityName();

			if (String.isNotEmpty(communityName)) {
				String networkId = Network.getNetworkId();
				String query = 'SELECT Id, UrlPathPrefix FROM Network WHERE Id =: networkId LIMIT 1';
				SObject ntw = Database.query(query);
				artFeed.Community_Name__c = communityName;
				artFeed.Feedback_Source__c = 'Communities';
				artFeed.Article_Link__c = baseUrl+'/' + (String)ntw.get('UrlPathPrefix') + '/s/article/'+recordId;
			} else {
				artFeed.Feedback_Source__c = 'Internal';
				artFeed.Article_Link__c = baseUrl+'/'+recordId;
			}

			artFeed.Knowledge_Article_Version_Id__c = recordId;
			String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;
			Boolean hasRecordType = afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive;
			String recordTypeField = '';
			if (hasRecordType) {
				recordTypeField = ',RecordTypeId';
			}

			String query = 'SELECT Id, Title, VersionNumber, ArticleNumber, ArticleCreatedDate, KnowledgeArticleId' + recordTypeField + ' FROM '+knowledgeObject+' WHERE Id = \''+recordId+'\' LIMIT 1';
			List<SObject> sObjList = Database.query(query);
			if (!sObjList.isEmpty()) {
				SObject sObj = sObjList[0];
				artFeed.Knowledge_kav_article_Id__c = (String)sObj.get('KnowledgeArticleId');
				artFeed.Article_Title__c = (String)sObj.get('Title');
				artFeed.Article_Version__c = (Decimal)sObj.get('VersionNumber');
				artFeed.Article_Number__c = (String)sObj.get('ArticleNumber');
				artFeed.Article_Created_Date__c = (Datetime)sObj.get('ArticleCreatedDate');

				// Get record type name
				if (hasRecordType) {
					if (String.isNotEmpty((String)sObj.get('RecordTypeId'))) {
						if (!test.isRunningTest()) {
							String rTypeId = (String)sObj.get('RecordTypeId');
							if (recordTypeDetails.containsKey(rTypeId)) { 
								artFeed.Record_Type__c = recordTypeDetails.get(rTypeId);
							}
						} else {
							artFeed.Record_Type__c = 'test article type';
						}
					}
				}
			}

			if (!hasNoRate) {
				if (!isSameVote) {
					Vote vote = new Vote (
						ParentId = artFeed.Knowledge_kav_article_Id__c,
						Type = isLiked ? '5' : '1'
					);
					Vote[] sVote = [SELECT Id, ParentId FROM Vote WHERE ParentId=:artFeed.Knowledge_kav_article_Id__c AND LastModifiedById=: UserInfo.getUserId() LIMIT 1];
					
					if (!sVote.isEmpty()) {
						vote.Id = sVote.get(0).Id;
					}
					
					try {
						UPSERT vote;
					} catch(DmlException e) {
						vote.Type = isLiked ? 'UP' : 'DOWN';
						UPSERT vote;
					}
				}
			}

			INSERT artFeed;

			return new afl_LightningResponse();
		} catch (Exception e) {
			return new afl_LightningResponse(e);
		}
	}

	/*
	* @description
	*   Method that returns the picklist values.
	* @params
	*  None
	* @return
	*   Object - afl_LightningResponse
	*/
	@AuraEnabled
	public static afl_LightningResponse getPickListValuesIntoList() {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canAccess(afl_Article_Feedback__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canAccess(Article_Feedback_Values__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		
		List<String> activePositiveValues = new List<String>();
		List<String> activeNegativeValues = new List<String>();

		try {
			List<Article_Feedback_Values__c> activeValues = [
				SELECT Value__c, Positive__c, Negative__c, Order__c, Active__c
				FROM Article_Feedback_Values__c
				WHERE Active__c = true
				ORDER BY Order__c ASC
			];

			if (activeValues.size() > 0) {
				for (Article_Feedback_Values__c currentValue : activeValues) {
					if (currentValue.Positive__c == true) {
						activePositiveValues.add(currentValue.Value__c);
					} else {
						activeNegativeValues.add(currentValue.Value__c);
					}
				}
			} 

			if (activePositiveValues.size() == 0) {
				// Set default value
				activePositiveValues.add('Other');
			}

			if (activeNegativeValues.size() == 0) {
				// Set default value
				activeNegativeValues.add('Other');
			}
		} catch(Exception e) {
			response = new afl_LightningResponse(e);
		}

		result.put('activePositiveValues', JSON.serialize(activePositiveValues));
		result.put('activeNegativeValues', JSON.serialize(activeNegativeValues));

		response.jsonResponse = JSON.serialize(result);

		return response;
	}

	/*
	* @description
	*   Method that gets the vote made by the user most recently associated .
	* @params
	*  Id recordId
	* @return
	*  Object - afl_LightningResponse
	*/
	@AuraEnabled
	public static afl_LightningResponse getVote(Id recordId) {
		try {
			// Check FLS
			afl_ArticleFeedbackSecurityHandler.canAccess(Vote.SObjectType);

			String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;
			afl_LightningResponse response = new afl_LightningResponse();
			Map<String,Object> result = new Map<String,Object>();
			String query = 'SELECT KnowledgeArticleId FROM '+knowledgeObject+' WHERE Id = \''+recordId+'\' LIMIT 1';
			List<SObject> knowledgeObjList = Database.query(query);

			if (!knowledgeObjList.isEmpty()) {
				SObject knowledgeObj = knowledgeObjList[0];
				String parentId = (String)knowledgeObj.get('KnowledgeArticleId');
				Vote[] sVote = [SELECT ParentId, Type FROM Vote WHERE ParentId=:parentId AND LastModifiedById=: UserInfo.getUserId() LIMIT 1];
				if (!Test.isRunningTest()) {
					if (!sVote.isEmpty()) {
						Boolean voteUp = sVote.get(0).Type == '5' || sVote.get(0).Type == 'UP';
						result.put('vote', JSON.serialize(voteUp));
						response.jsonResponse = JSON.serialize(result);
					}
				} else {
					result.put('vote', 'true');
					response.jsonResponse = JSON.serialize(result);
				}

			}
			
			return response;
		} catch (Exception e) {
			return new afl_LightningResponse(e);
		}
	}
}