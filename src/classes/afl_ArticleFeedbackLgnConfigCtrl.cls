/**
 * @author Altimetrik
 * @description
 *    started on 08/06/2018
 *    Front Controller for Article Feedback project setup page
 **/
public with sharing class afl_ArticleFeedbackLgnConfigCtrl {

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
		Map<String,String> result = new Map<String, String>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if(String.isNotEmpty(af.Hashtag__c)) {
				result.put('hashtag', af.Hashtag__c);
				response.jsonResponse = JSON.serialize(result);
			}
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
	public static afl_LightningResponse updateHashtagValue(String value) {
		//Check FLS
		afl_ArticleFeedbackSecurityHandler.canCreate(afl_Article_Feedback__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canUpdate(afl_Article_Feedback__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String, String>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if(String.isNotEmpty(value) && value != null){
				af.Hashtag__c = value;
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
