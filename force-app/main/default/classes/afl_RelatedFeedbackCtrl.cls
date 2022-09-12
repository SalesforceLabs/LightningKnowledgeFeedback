/**
* @author Altimetrik
* @description Front Controller for Article Feedback Related List
**/
public with sharing class afl_RelatedFeedbackCtrl {
    
    /*
    * Retrieves all the Feedback left in the Knowledge Article
    * @param kavId
    * @return afl_LightningResponse
    */
    @AuraEnabled(cacheable=true)
	public static afl_LightningResponse getRelatedFeedback(String kavId) {
		try {
			// Check FLS
			afl_ArticleFeedbackSecurityHandler.canAccess(Schema.SObjectType.afl_Article_Feedback__c.getSobjectType());
			
            String knowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;
            String query = 'SELECT VersionNumber, ArticleNumber, PublishStatus, KnowledgeArticleId FROM ' + knowledgeObject + ' WHERE Id = \'' + kavId + '\' WITH SECURITY_ENFORCED LIMIT 1';
            List<SObject> sObjList = Database.query(query);

            List<afl_Article_Feedback__c> afList = new List<afl_Article_Feedback__c>();

            if (!sObjList.isEmpty()) {
				SObject sObj = sObjList[0];
				String masterVersionId = (String) sObj.get('KnowledgeArticleId');
				Integer versionNumber = (Integer) sObj.get('VersionNumber');
				String articleNumber = (String) sObj.get('ArticleNumber');

                afList = [
                    SELECT Id, Name, Feedback_Source__c, Feedback_Status__c, Feedback_Reason__c, Assigned_To__r.Name
                    FROM afl_Article_Feedback__c 
                    WHERE Knowledge_kav_article_Id__c =:masterVersionId 
                    AND Article_Number__c =:articleNumber
                    AND Article_Version__c =:versionNumber
                    WITH SECURITY_ENFORCED
                    ORDER BY CreatedDate DESC
                ];
            }
			afl_LightningResponse response = new afl_LightningResponse();
            response.jsonResponse = JSON.serialize(afList);
            return response;
        } catch (Exception e) {
			return new afl_LightningResponse(e);
		}
    }
}