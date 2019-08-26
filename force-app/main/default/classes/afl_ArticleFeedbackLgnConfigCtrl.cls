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

			// Retrieve picklist values
			Map<String,List<String>> picklistValues = getPicklistValues();
			result.put('activePositiveValues', JSON.serialize(picklistValues.get('activePositiveValues')));
			result.put('activeNegativeValues', JSON.serialize(picklistValues.get('activeNegativeValues')));
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
		List<String> activePositiveValues = new List<String>();
		List<String> activeNegativeValues = new List<String>();
		List<String> allPositiveValues = new List<String>();
		List<String> allNegativeValues = new List<String>();
		List<String> allPicklistValues = new List<String>();

		List<Article_Feedback_Values__c> existingValues = [
			SELECT Value__c, Positive__c, Negative__c, Order__c, Active__c
			FROM Article_Feedback_Values__c
			ORDER BY Value__c ASC
		];

		if (existingValues.size() > 0) {
			for (Article_Feedback_Values__c currentValue : existingValues) {
				if (currentValue.Positive__c == true) {
					allPositiveValues.add(currentValue.Value__c);
					allPicklistValues.add(currentValue.Value__c + ' (Positive)');
				} else {
					allNegativeValues.add(currentValue.Value__c);
					allPicklistValues.add(currentValue.Value__c + ' (Negative)');
				}
			}
		}

		List<Article_Feedback_Values__c> activeValues = [
			SELECT Value__c, Positive__c, Negative__c, Order__c, Active__c
			FROM Article_Feedback_Values__c
			WHERE Active__c = false
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

		allPicklistValues.sort();

		result.put('activePositiveValues', activePositiveValues);
		result.put('activeNegativeValues', activeNegativeValues);
		result.put('allPositiveValues', allPositiveValues);
		result.put('allNegativeValues', allNegativeValues);
		result.put('allPicklistValues', allPicklistValues);

		System.debug('result: ' + result);

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
	public static afl_LightningResponse addNewPicklistValue(String picklistValue, String reasonType) {
		// Check FLS
		afl_ArticleFeedbackSecurityHandler.canAccess(Article_Feedback_Values__c.SObjectType);
		afl_ArticleFeedbackSecurityHandler.canCreate(Article_Feedback_Values__c.SObjectType);

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,String> result = new Map<String,String>();
		List<Article_Feedback_Values__c> newValues = new List<Article_Feedback_Values__c>();

		if (reasonType == 'bothOption') {
			newValues.add(createNewFeedbackValue(picklistValue, true, false));
			newValues.add(createNewFeedbackValue(picklistValue, false, true));
		} else if (reasonType == 'positiveOption') {
			newValues.add(createNewFeedbackValue(picklistValue, true, false));
		} else {
			newValues.add(createNewFeedbackValue(picklistValue, false, true));
		}

		try {
			if (newValues.size() > 0) {
				UPSERT newValues;
				result.put('status', 'SUCCESS');
			}
		} catch(Exception e) {
			response = new afl_LightningResponse(e);
			result.put('status', 'FAILED');
			System.debug(e);
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
	public static Article_Feedback_Values__c createNewFeedbackValue(String picklistValue, Boolean positiveCheckbox, Boolean negativeCheckbox) {
		Article_Feedback_Values__c newValue = new Article_Feedback_Values__c(
			Value__c = picklistValue, 
			Positive__c = positiveCheckbox,
			Negative__c = negativeCheckbox,
			Active__c = false,
			Order__c = 0
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

		System.debug('savedValuesJSON: ' + savedValuesJSON);
		System.debug('savedValues: ' + savedValues);

		List<Object> activePositiveValues = (List<Object>) savedValues.get('activePositiveValues');
		List<Object> activeNegativeValues = (List<Object>) savedValues.get('activeNegativeValues');

		List<String> allValuesList = new List<String>();
		for (Object valueName : activePositiveValues) {
			allValuesList.add((String) valueName);
		}
	
		for (Object valueName : activeNegativeValues) {
			allValuesList.add((String) valueName);
		}

		System.debug('allValuesList: ' + allValuesList);

		if (allValuesList.size() > 0) {
			List<Article_Feedback_Values__c> valuesToUpdate = new List<Article_Feedback_Values__c>();
			List<Article_Feedback_Values__c> existingValues = [
				SELECT Value__c, Order__c, Positive__c, Negative__c, Active__c
				FROM Article_Feedback_Values__c
				WHERE Value__c IN : allValuesList
			];

			System.debug('existingValues: ' + existingValues);

			Map<String,Article_Feedback_Values__c> positiveValuesMap = new Map<String,Article_Feedback_Values__c>();
			Map<String,Article_Feedback_Values__c> negativeValuesMap = new Map<String,Article_Feedback_Values__c>();

			for (Article_Feedback_Values__c currentValue : existingValues) {
				if (currentValue.Positive__c == true) {
					positiveValuesMap.put(currentValue.Value__c, currentValue);
				} else {
					negativeValuesMap.put(currentValue.Value__c, currentValue);
				}
			}

			System.debug('activePositiveValues.size(): ' + activePositiveValues.size());
			System.debug('activePositiveValues: ' + activePositiveValues);
			System.debug('positiveValuesMap: ' + positiveValuesMap);

			for (Integer i = 0; i < activePositiveValues.size(); ++i) {
				System.debug('i: ' + i);
                Article_Feedback_Values__c updatedValue = positiveValuesMap.get((String) activePositiveValues.get(i));
				
				if (updatedValue.Active__c == false) {
					updatedValue.Active__c = true;
				}
				updatedValue.Order__c = i + 1;

				valuesToUpdate.add(updatedValue);
            }

			for (Integer i = 0; i < activeNegativeValues.size(); ++i) {
                Article_Feedback_Values__c updatedValue = negativeValuesMap.get((String) activeNegativeValues.get(i));
				
				if (updatedValue.Active__c == false) {
					updatedValue.Active__c = true;
				}
				updatedValue.Order__c = i + 1;

				valuesToUpdate.add(updatedValue);
            }

			if (valuesToUpdate.size() > 0) {
				try {
					UPDATE valuesToUpdate;
				} catch(Exception e) {
					response = new afl_LightningResponse(e);
					result.put('status', 'FAILED');
					System.debug(e);
				}
			}
		}

		System.debug('activePositiveValues: ' + activePositiveValues);
		System.debug('activeNegativeValues: ' + activeNegativeValues);

		result.put('status', 'SUCCESS');
		response.jsonResponse = JSON.serialize(result);

		return response;
	}
}