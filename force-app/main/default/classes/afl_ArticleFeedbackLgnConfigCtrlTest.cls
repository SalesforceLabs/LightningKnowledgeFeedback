/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Test class for the Article Feedback Configuration Controller class
**/
@isTest
private class afl_ArticleFeedbackLgnConfigCtrlTest {
	@isTest
    static void getCurrentPrefixTest() {
		Test.startTest();
		afl_ArticleFeedbackLgnConfigCtrl ctrl = new afl_ArticleFeedbackLgnConfigCtrl();
		Test.stopTest();

		System.assertNotEquals('', ctrl.currentPrefix, 'There should be a prefix set.');
	}

	@isTest
    static void getInitialDataTest() {
		// Create test data
		afl_Knowledge_feedback__c kf = afl_Knowledge_feedback__c.getOrgDefaults();

		if (String.isEmpty(kf.Hashtag__c)) {
			kf.Hashtag__c = '#ArticleFeedback';
			UPSERT kf;
		}

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,Object> result = new Map<String,Object>();
		Test.startTest();
		response = afl_ArticleFeedbackLgnConfigCtrl.getInitialData();
		result = (Map<String,Object>) JSON.deserializeUntyped(response.jsonResponse);
		Test.stopTest();

		System.assertEquals(result.get('hashtag'), '#ArticleFeedback');
	}

	@isTest
    static void getPicklistValuesTest() {
		// Insert test data
		afl_TestDataFactory.insertPicklistValues();

		Map<String,List<String>> result = new Map<String,List<String>>();
		Test.startTest();
		result = afl_ArticleFeedbackLgnConfigCtrl.getPicklistValues();
		Test.stopTest();

		List<String> activePositiveValues = result.get('activePositiveValues');
		List<String> activeNegativeValues = result.get('activeNegativeValues');
		List<String> allPositiveValues = result.get('allPositiveValues');
		List<String> allNegativeValues = result.get('allNegativeValues');
		List<String> allPicklistValues = result.get('allPicklistValues');

		System.assertEquals(1, activePositiveValues.size(), 'There should be 1 record in the list');
		System.assertEquals(1, activeNegativeValues.size(), 'There should be 1 record in the list');
		System.assertEquals(2, allPositiveValues.size(), 'There should be 2 records in the list');
		System.assertEquals(2, allNegativeValues.size(), 'There should be 2 records in the list');
		System.assertEquals(4, allPicklistValues.size(), 'There should be 4 records in the list');

		System.assertEquals('value1', activePositiveValues.get(0), 'The name of the value should match');
		System.assertEquals('value2', activeNegativeValues.get(0), 'The name of the value should match');
		System.assertEquals('value3', allPositiveValues.get(1), 'The name of the value should match');
		System.assertEquals('value4', allNegativeValues.get(1), 'The name of the value should match');
	}

	@isTest
    static void updateHashtagValueTest() {
		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,Object> result = new Map<String,Object>();

		Test.startTest();
		response = afl_ArticleFeedbackLgnConfigCtrl.updateHashtagValue('#TestHashtag');
		result = (Map<String,Object>) JSON.deserializeUntyped(response.jsonResponse);
		
		Test.stopTest();

		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		System.assertEquals('#TestHashtag', af.Hashtag__c, 'The hashtag should be the same as the one setted earlier.');
		System.assertEquals('SUCCESS', result.get('status'), 'The operation should be succesful.');
	}

	@isTest
    static void addNewPicklistValueTest() {
		afl_LightningResponse response1 = new afl_LightningResponse();
		afl_LightningResponse response2 = new afl_LightningResponse();
		afl_LightningResponse response3 = new afl_LightningResponse();
		afl_LightningResponse response4 = new afl_LightningResponse();
		afl_LightningResponse response5 = new afl_LightningResponse();
		afl_LightningResponse response6 = new afl_LightningResponse();

		Test.startTest();
		// Create both negative and positive picklist values
		response1 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value1', 'bothOption');
		// Create both a positive picklist value
		response2 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value2', 'positiveOption');
		// Create both a negative picklist value
		response3 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value3', 'negativeOption');
		// Try to create values that will fail because they already exist
		response4 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value1', 'bothOption');
		response5 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value2', 'positiveOption');
		response6 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value3', 'negativeOption');
		Test.stopTest();

		Map<String,Object> result1 = (Map<String,Object>) JSON.deserializeUntyped(response1.jsonResponse);
		Map<String,Object> result2 = (Map<String,Object>) JSON.deserializeUntyped(response2.jsonResponse);
		Map<String,Object> result3 = (Map<String,Object>) JSON.deserializeUntyped(response3.jsonResponse);
		Map<String,Object> result4 = (Map<String,Object>) JSON.deserializeUntyped(response4.jsonResponse);
		Map<String,Object> result5 = (Map<String,Object>) JSON.deserializeUntyped(response5.jsonResponse);
		Map<String,Object> result6 = (Map<String,Object>) JSON.deserializeUntyped(response6.jsonResponse);

		// Query the created picklist values
		Integer nCreatedValues = [SELECT Count() FROM Article_Feedback_Values__c];

		System.assertEquals('SUCCESS', result1.get('status'), 'The operation should be succesful.');
		System.assertEquals('SUCCESS', result2.get('status'), 'The operation should be succesful.');
		System.assertEquals('SUCCESS', result3.get('status'), 'The operation should be succesful.');
		System.assertEquals('DUPLICATED', result4.get('status'), 'The operation should fail because of the duplicated value.');
		System.assertEquals('DUPLICATED', result5.get('status'), 'The operation should fail because of the duplicated value.');
		System.assertEquals('DUPLICATED', result6.get('status'), 'The operation should fail because of the duplicated value.');

		// There should be only 4 created records because one failed
		System.assertEquals(4, nCreatedValues, 'There should be 4 new values created.');
	}

	@isTest
    static void savePicklistOrderTest() {
		// Insert test data
		afl_TestDataFactory.insertPicklistValues();

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,List<String>> valuesMap = new Map<String,List<String>>();
		List<String> positiveValues = new List<String>();
		List<String> negativeValues = new List<String>();

		positiveValues.add('value3');
		negativeValues.add('value4');

		valuesMap.put('activePositiveValues', positiveValues);
		valuesMap.put('activeNegativeValues', negativeValues);

		String valuesJSON = JSON.serialize(valuesMap);

		Test.startTest();
		response = afl_ArticleFeedbackLgnConfigCtrl.savePicklistOrder(valuesJSON);
		Test.stopTest();

		Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.jsonResponse);

		List<Article_Feedback_Values__c> updatedValues = [
			SELECT Value__c 
			FROM Article_Feedback_Values__c 
			WHERE Active__C = true
			ORDER BY Value__C ASC
		];

		System.assertEquals('SUCCESS', result.get('status'), 'The operation should be succesful.');
		System.assertEquals('value3', updatedValues.get(0).Value__c, 'The values name should match');
		System.assertEquals('value4', updatedValues.get(1).Value__c, 'The values name should match');
	}
}