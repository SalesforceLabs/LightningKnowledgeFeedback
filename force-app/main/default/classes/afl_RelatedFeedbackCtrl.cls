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
    @AuraEnabled
	public static afl_LightningResponse getRelatedFeedback(String kavId) {
		try {
			// Check FLS
			afl_ArticleFeedbackSecurityHandler.isAccessible(Schema.SObjectType.afl_Article_Feedback__c.getSobjectType());
			
            List<afl_Article_Feedback__c> afList = [
                SELECT Id, Name, Feedback_Source__c, Feedback_Status__c, Feedback_Reason__c, Assigned_To__r.Name
                FROM afl_Article_Feedback__c 
                WHERE Knowledge_Article_Version_Id__c = :kavId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
            ];

			afl_LightningResponse response = new afl_LightningResponse();
            response.jsonResponse = JSON.serialize(afList);
            return response;
        } catch (Exception e) {
			return new afl_LightningResponse(e);
		}
    }
}
