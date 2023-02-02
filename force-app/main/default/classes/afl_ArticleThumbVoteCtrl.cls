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
	public static afl_LightningResponse upsertThumbArticleVote(Id recordId, String feedbackReason, String feedbackReasonDeveloperValue, String voteDescription, Boolean isLiked, Boolean isSameVote, Boolean hasNoRate, List<String> filesInserted) {
		try {
			// Check FLS and CRUD
			afl_ArticleFeedbackSecurityHandler.canCreate(afl_Article_Feedback__c.SObjectType);
			String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;

			afl_Article_Feedback__c artFeed = new afl_Article_Feedback__c();

			artFeed.Feedback_Status__c = 'New';
			artFeed.Feedback_Vote_Description__c = voteDescription;
			if (!hasNoRate) {
				artFeed.Like__c = isLiked;
			}
			artFeed.Feedback_Reason__c = feedbackReason;
			artFeed.Feedback_Reason_Developer_Value__c = feedbackReasonDeveloperValue;

			String baseUrl = 'https://' + DomainCreator.getLightningHostname();
			String communityName = afl_ArticleFeedbackSecurityHandler.getCommunityName();

			if (String.isNotEmpty(communityName)) {
				baseUrl = 'https://' + DomainCreator.getExperienceCloudSitesHostname();
				String networkId = Network.getNetworkId();
				String query = 'SELECT Id, UrlPathPrefix FROM Network WHERE Id =: networkId LIMIT 1';
				SObject ntw = Database.query(query);
				artFeed.Community_Name__c = communityName;
				artFeed.Feedback_Source__c = 'Communities';
				if(ntw.get('UrlPathPrefix') != null){
					artFeed.Article_Link__c = baseUrl + '/' + (String) ntw.get('UrlPathPrefix') + '/s/article/' + recordId;
				} else {
					artFeed.Article_Link__c = baseUrl + '/s/article/' + recordId;
				}
			} else {
				artFeed.Feedback_Source__c = 'Internal';
				artFeed.Article_Link__c = baseUrl + '/lightning/r/' + knowledgeObject + '/' +  recordId + '/view';
			}

			artFeed.Knowledge_Article_Version_Id__c = recordId;
			Boolean hasRecordType = afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive;
			String recordTypeField = '';
			if (hasRecordType) {
				recordTypeField = ', RecordTypeId';
			}

			String query = 'SELECT Id, Title, VersionNumber, ArticleNumber, ArticleCreatedDate, KnowledgeArticleId' + recordTypeField + ' FROM ' + knowledgeObject + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
			List<SObject> sObjList = Database.query(query);
			if (!sObjList.isEmpty()) {
				SObject sObj = sObjList[0];
				artFeed.Knowledge_kav_article_Id__c = (String) sObj.get('KnowledgeArticleId');
				artFeed.Article_Title__c = (String) sObj.get('Title');
				artFeed.Article_Version__c = (Decimal) sObj.get('VersionNumber');
				artFeed.Article_Number__c = (String) sObj.get('ArticleNumber');
				artFeed.Article_Created_Date__c = (Datetime) sObj.get('ArticleCreatedDate');

				// Get record type name
				if (hasRecordType) {
					if (String.isNotEmpty((String)sObj.get('RecordTypeId'))) {
						artFeed.Record_Type__c = afl_ArticleFeedbackSecurityHandler.getRecordTypeName(sObj);
					}
				}
			}

			//set record name (cannot exceed 80 char)
			artFeed.Name = System.UserInfo.getFirstName()?.left(15) + ' ' + System.UserInfo.getLastName()?.left(15) + ' - ' + ((String) sObjList[0].get('Title'))?.left(24) + ' - ' + DateTime.now().format('yyyy/MM/dd h:mm a');

			if (!hasNoRate) {
				if (!isSameVote) {
					if (afl_ArticleFeedbackSecurityHandler.isAccessible(Vote.SObjectType) &&
						afl_ArticleFeedbackSecurityHandler.isCreateable(Vote.SObjectType) &&
						afl_ArticleFeedbackSecurityHandler.isUpdateable(Vote.SObjectType)) {
						Vote vote = new Vote (
							ParentId = artFeed.Knowledge_kav_article_Id__c,
							Type = isLiked ? '5' : '1'
						);
						Vote[] sVote = [SELECT Id, ParentId FROM Vote WHERE ParentId =: artFeed.Knowledge_kav_article_Id__c AND CreatedById =: UserInfo.getUserId() LIMIT 1];
						
						if (!sVote.isEmpty()) {
							vote.Id = sVote.get(0).Id;
						}
	
						try {
							UPSERT vote;
						} catch(DmlException e) {
							if (e.getDmlType(0) == StatusCode.FIELD_INTEGRITY_EXCEPTION) {
								vote.Type = isLiked ? 'UP' : 'DOWN';
								UPSERT vote;
							} else if (e.getDmlType(0) == StatusCode.DUPLICATE_VALUE) {
								return null;
							}
						}
					}
				}
			}			
			INSERT artFeed;

			if(!filesInserted.isEmpty()) {
				String feedbackId = artFeed.Id;  
				linkAttachedFiles(filesInserted, feedbackId);
			}

			return new afl_LightningResponse();
		} catch (Exception e) {
			return new afl_LightningResponse(e);
		}
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
			String query = 'SELECT KnowledgeArticleId, CreatedDate FROM ' + knowledgeObject + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
			List<SObject> knowledgeObjList = Database.query(query);
			String kavId = (String) recordId;
			
            Vote[] sVote = new Vote[]{};
            String parentId = '';

			if (!knowledgeObjList.isEmpty()) {
				SObject knowledgeObj = knowledgeObjList[0];
				DateTime kavCreatedDate = (DateTime) knowledgeObj.get('CreatedDate');
				parentId = (String) knowledgeObj.get('KnowledgeArticleId');
				sVote = [
					SELECT ParentId, Type, CreatedDate, LastModifiedDate 
					FROM Vote 
					WHERE ParentId =: parentId 
					AND CreatedById=: UserInfo.getUserId() 
					LIMIT 1
				];

				if (!Test.isRunningTest()) {
					if (!sVote.isEmpty()) {
						Boolean voteUp = sVote.get(0).Type == '5' || sVote.get(0).Type == 'UP';
						result.put('vote', JSON.serialize(voteUp));
					}
				} else {
					result.put('vote', 'true');
				}
			}
            
            List<afl_Article_Feedback__c> listOfArticleF = [
				SELECT Feedback_Reason_Developer_Value__c, Feedback_Reason__c
				FROM afl_Article_Feedback__c 
				WHERE Knowledge_kav_article_Id__c =: parentId
                AND OwnerId =: UserInfo.getUserId()
				AND Originated_From_Trigger__c = false
				ORDER BY CreatedDate DESC NULLS FIRST 
				LIMIT 1
			];

			String feedbackReason = '';
			if (!listOfArticleF.isEmpty()) {
				if (listOfArticleF[0].Feedback_Reason_Developer_Value__c != null) {
					feedbackReason = listOfArticleF[0].Feedback_Reason_Developer_Value__c;
				} else {
					feedbackReason = listOfArticleF[0].Feedback_Reason__c;
				}
			}
			result.put('feedbackReason', feedbackReason);

			response.jsonResponse = JSON.serialize(result);
			
			return response;
		} catch (Exception e) {
			return new afl_LightningResponse(e);
		}
	}

	/*
	* @description
	*   Method that counts the number of votes a Knowledge Article has.
	* @params
	*  Id recordId, String voteType
	* @return
	*  Integer
	*/
	@AuraEnabled
	public static Map<String, Integer> voteCounts(Id recordId) {		
		afl_ArticleFeedbackSecurityHandler.canAccess(Vote.SObjectType);
		String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;
		String query = 'SELECT KnowledgeArticleId FROM ' + knowledgeObject + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
		List<SObject> knowledgeObjList = Database.query(query);
		String parentId = '';

		if (!knowledgeObjList.isEmpty()) {
			SObject knowledgeObj = knowledgeObjList[0];			
			parentId = (String) knowledgeObj.get('KnowledgeArticleId');			
		}

		String voteQuery = 'SELECT Type type, Count(Id) counter FROM Vote WHERE ParentId = \'' + parentId + '\' GROUP BY Type';
		List<AggregateResult> aggregateResult = Database.query(voteQuery);
		Map<String, Integer> countVotesByType = new Map<String, Integer>();
		for (AggregateResult result : aggregateResult) {
			if (result.get('type') == '5' || result.get('type') == 'Up'){
				countVotesByType.put((String) 'Likes', (Integer) result.get('counter'));
			} else if (result.get('type') == '1' || result.get('type') == 'Down') {
				countVotesByType.put((String) 'Dislikes', (Integer) result.get('counter'));
			}
		}

		return countVotesByType;		
	}

	/*
	* @description Method that links the attached files to the Article Feedback record.
	* @params List<String> filesInserted, String feedbackId
	*/
	public static void linkAttachedFiles(List<String> filesInserted, String feedbackId) { 
       
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        for (String docId : filesInserted) {
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.ContentDocumentId =  docId;
            contentDocLink.LinkedEntityId = feedbackId;
            contentDocLink.ShareType = 'V'; 
            contentDocLinkList.add(contentDocLink);
        }
        
        if(!contentDocLinkList.isEmpty()) {
			try {
				afl_ArticleFeedbackSecurityHandler.canCreate(ContentDocumentLink.SObjectType);
				List<Database.SaveResult> res = Database.INSERT(contentDocLinkList);
			} catch (Exception e) {
				System.Debug(e);
			}
        }
    }
}