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
		// afl_ArticleFeedbackSecurityHandler.canAccess(Article_Feedback_Configuration__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String, String>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if (String.isNotEmpty(af.Hashtag__c)) {
				result.put('hashtag', af.Hashtag__c);
			}

			// Retrieve config record
			

			response.jsonResponse = JSON.serialize(result);
		} catch(Exception e) {
			response = new afl_LightningResponse(e);
		}

		return response;
	}

	/*
	* @description
	*	Method that adds a picklist value to Article_Feedback_Values__c 
	* @params
	*	String with picklist value, Boolean with positive, Boolean with negative 
	* @return
	*	None
	*/
	@auraEnabled
	public static afl_LightningResponse addPicklistValue(String value, String type) {
	// public static afl_LightningResponse addPicklistValue(String value) {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canAccess(Article_Feedback_Values__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canCreate(Article_Feedback_Values__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		// List<Article_Feedback_Values__c> newValues = new List<Article_Feedback_Values__c>();

		// if (type == 'bothOption') {
		// 	newValues.add(createNewFeedbackValue(value, true, false));
		// 	newValues.add(createNewFeedbackValue(value, false, true));
		// } else if (type == 'positiveOption') {
		// 	newValues.add(createNewFeedbackValue(value, true, false));
		// } else {
		// 	newValues.add(createNewFeedbackValue(value, false, true));
		// }

		// try {
		// 	INSERT newValues;
		// 	result.put('status', 'SUCCESS');
		// } catch(Exception e) {
		// 	response = new afl_LightningResponse(e);
		// 	result.put('status', 'FAILED');
		// 	System.debug(e);
		// }
		result.put('status', 'SUCCESS');
		response.jsonResponse = JSON.serialize(result);

		return response;
	}
	
	/*
	* @description
	*	Method that creates a new instance of Article_Feedback_Values__c
	* @params
	*	String with picklist value, Boolean with positive value, Boolean with negative value
	* @return
	*	None
	*/
	public static Article_Feedback_Values__c createNewFeedbackValue(String value, Boolean positive, Boolean negative) {
		Article_Feedback_Values__c newValue = new Article_Feedback_Values__c(
			Value__c = value, 
			Positive__c = positive,
			Negative__c = negative,
			Active__c = false,
			Order__c = 0
		);
	
		return newValue;
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
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canCreate(afl_Article_Feedback__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canUpdate(afl_Article_Feedback__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if (String.isNotEmpty(value) && value != null) {
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