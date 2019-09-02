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
		Map<String,String> result = new Map<String, String>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if (String.isNotEmpty(af.Hashtag__c)) {
				result.put('hashtag', af.Hashtag__c);
			}

			// Retrieve picklist values
			Map<String,List<String>> picklistValues = getPicklistValues();
			result.put('allPositiveValues', JSON.serialize(picklistValues.get('allPositiveValues')));
			result.put('allNegativeValues', JSON.serialize(picklistValues.get('allNegativeValues')));
			result.put('allPicklistValues', JSON.serialize(picklistValues.get('allPicklistValues')));

			response.jsonResponse = JSON.serialize(result);
		} catch(Exception e) {
			response = new afl_LightningResponse(e);
		}

		return response;
	}

	/*
	* @description
	*	Method that adds retrieves picklist values from Article_Feedback_Values__c 
	* @params
	*	None
	* @return
	*	Map with active and inactive values
	*/
	public static Map<String,List<String>> getPicklistValues() {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canAccess(Article_Feedback_Values__c.SObjectType);

		Map<String,List<String>> result = new Map<String,List<String>>();
		List<String> allPositiveValues = new List<String>();
		List<String> allNegativeValues = new List<String>();
		List<String> allPicklistValues = new List<String>();

		List<Article_Feedback_Values__c> existingValues = [
			SELECT Value__c, Positive__c, Negative__c, OrderPositive__c, OrderNegative__c
			FROM Article_Feedback_Values__c
			ORDER BY Value__c ASC
		];

		if (existingValues.size() > 0) {
			for(Integer i=0; i<existingValues.size(); i++){
				allPicklistValues.add(existingValues[i].Value__c);
				for (Article_Feedback_Values__c currentValue : existingValues) {
					if(currentValue.OrderPositive__c == i && currentValue.Positive__c == true){
						allPositiveValues.add(currentValue.Value__c);
					}
					if (currentValue.OrderNegative__c == i && currentValue.Negative__c == true) {
						allNegativeValues.add(currentValue.Value__c);
					}
				}
			}
		}

		allPicklistValues.sort();

		result.put('allPositiveValues', allPositiveValues);
		result.put('allNegativeValues', allNegativeValues);
		result.put('allPicklistValues', allPicklistValues);

		return result;
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
	public static afl_LightningResponse updateHashtagValue(String hashtag) {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canCreate(afl_Article_Feedback__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canUpdate(afl_Article_Feedback__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		try {
			if (String.isNotEmpty(hashtag) && hashtag != null) {
				af.Hashtag__c = hashtag;
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

	/*
	* @description
	*	Method that adds a picklist value to Article_Feedback_Values__c 
	* @params
	*	String with picklist value, Boolean with positive, Boolean with negative 
	* @return
	*	None
	*/
	@auraEnabled
	public static afl_LightningResponse addNewPicklistValue(String picklistValue) {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canAccess(Article_Feedback_Values__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canCreate(Article_Feedback_Values__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		List<Article_Feedback_Values__c> newValues = new List<Article_Feedback_Values__c>();

		List<Article_Feedback_Values__c> existingValues = [
			SELECT Value__c
			FROM Article_Feedback_Values__c 
			WHERE Value__c =: picklistValue
		];

		if (existingValues.size() > 0) {
			result.put('status', 'DUPLICATED');
		} else {
			newValues.add(createNewFeedbackValue(picklistValue));
			try {
				UPSERT newValues;
				result.put('status', 'SUCCESS');
				
			} catch(Exception e) {
				response = new afl_LightningResponse(e);
				result.put('status', 'FAILED');
			}
		}
		
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
	public static Article_Feedback_Values__c createNewFeedbackValue(String picklistValue) {
		Article_Feedback_Values__c newValue = new Article_Feedback_Values__c(
			Value__c = picklistValue, 
			Positive__c = false,
			Negative__c = false
		);
	
		return newValue;
	}

	/*
	* @description
	*	Method that adds retrieves picklist values from Article_Feedback_Values__c 
	* @params
	*	None
	* @return
	*	Map with active and inactive values
	*/
	@auraEnabled
	public static afl_LightningResponse savePicklistOrder(String savedValuesJSON) {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canAccess(Article_Feedback_Values__c.SObjectType);
		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		Map<String,Object> savedValues = (Map<String,Object>) System.JSON.deserializeUntyped(savedValuesJSON);

		List<Object> allPositive = (List<Object>) savedValues.get('allPositiveValues');
		List<Object> allNegative = (List<Object>) savedValues.get('allNegativeValues');

		List<String> allPositiveValues = new List<String>();
		List<String> allNegativeValues = new List<String>();

		for(Object currentValue : allPositive){
			allPositiveValues.add((String)currentValue);
		}

		for(Object currentValue : allNegative){
			allNegativeValues.add((String)currentValue);
		}
		List<Article_Feedback_Values__c> allValues = [
			SELECT Value__c, Positive__c, Negative__c, OrderPositive__c, OrderNegative__c
			FROM Article_Feedback_Values__c
		];

		for(Article_Feedback_Values__c currentValue : allValues){
			currentValue.Positive__c = false;
			currentValue.Negative__c = false;
			if(allPositiveValues.contains(currentValue.Value__c)){
				currentValue.Positive__c = true;
				currentValue.OrderPositive__c = allPositiveValues.indexOf(currentValue.Value__c);
			}
			if(allNegativeValues.contains(currentValue.Value__c)){
				currentValue.Negative__c = true;
				currentValue.OrderNegative__c = allNegativeValues.indexOf(currentValue.Value__c);
			}
		}

		try{
			update allValues;
		} catch(Exception e) {
			response = new afl_LightningResponse(e);
			result.put('status', 'FAILED');
		}

		result.put('status', 'SUCCESS');
		response.jsonResponse = JSON.serialize(result);

		return response;
	}

	/*
	* @description
	*	Method that deletes picklist values from Article_Feedback_Values__c 
	* @params
	*	List with values to delete
	* @return
	*	Map with active and inactive values
	*/
	@auraEnabled
	public static afl_LightningResponse deleteValues(List<String> deleteValuesList){
		afl_LightningResponse response = new afl_LightningResponse();
		List<Article_Feedback_Values__c> valuesToDelete = [
			SELECT Value__c 
			FROM Article_Feedback_Values__c 
			WHERE Value__c IN :deleteValuesList
		];
		delete valuesToDelete;
		response.jsonResponse = JSON.serialize(valuesToDelete);
		return response;
	}

}