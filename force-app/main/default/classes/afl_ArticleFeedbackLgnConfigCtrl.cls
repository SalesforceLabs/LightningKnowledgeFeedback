/**
* @author Altimetrik
* @description
*    started on 08/06/2018
*    Front Controller for Article Feedback project setup page
**/
public with sharing class afl_ArticleFeedbackLgnConfigCtrl {
	public String currentPrefix {get; private set;}

	public afl_ArticleFeedbackLgnConfigCtrl() {
		getCurrentNamespace();
	}

	/*
    * @description
    *    Logic to resolve namespace prefix
    * @return
    *    String with namespace prefix
    */
    private void getCurrentNamespace() {
		String prefix = afl_ArticleFeedbackLgnConfigCtrl.class.getName().substringBefore('afl_ArticleFeedbackLgnConfigCtrl');
        prefix = String.isBlank(prefix) ? 'c' : prefix.substringBefore('.');
        currentPrefix = prefix;
    }

	/*
	* @description
	*	Method that gets the data from the afl_Knowledge_feedback__c object
	* @params
	*	None
	* @return
	*	JSON - values
	*/
	@auraEnabled
	public static afl_LightningResponse getInitialData() {
		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,Object> result = new Map<String,Object>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if (String.isNotEmpty(af.Hashtag__c)) {
				result.put('hashtag', af.Hashtag__c);
			}
			result.put('triggersEnabled', af.Chatter_triggers_enabled__c);

			response.jsonResponse = JSON.serialize(result);
		} catch(Exception e) {
			response = new afl_LightningResponse(e);
		}

		return response;
	}

	/*
	* @description
	*	Method that updates the Hashtag value of the afl_Knowledge_feedback__c object
	* @params
	*	None
	* @return
	*	None
	*/
	@auraEnabled
	public static afl_LightningResponse updateHashtagValue(String hashtag, Boolean triggerEnabled) {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canCreate(afl_Article_Feedback__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canUpdate(afl_Article_Feedback__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canAccess(afl_Knowledge_feedback__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if (String.isNotEmpty(hashtag) && hashtag != null) {
				af.Hashtag__c = hashtag;
				af.Chatter_triggers_enabled__c = triggerEnabled;
				UPSERT af;
				result.put('status', 'SUCCESS');
			}
		} catch(Exception e) {
			response = new afl_LightningResponse(e);
			result.put('status', 'FAILED');
		}
		response.jsonResponse = JSON.serialize(result);

		return response;
	}
}