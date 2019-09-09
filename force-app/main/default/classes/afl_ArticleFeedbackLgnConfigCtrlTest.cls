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
		response1 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value1');
		// Create both a positive picklist value
		response2 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value2');
		// Create both a negative picklist value
		response3 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value3');
		// Try to create values that will fail because they already exist
		response4 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value1');
		response5 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value2');
		response6 = afl_ArticleFeedbackLgnConfigCtrl.addNewPicklistValue('value3');
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

		// There should be 12 created records because three failed
		System.assertEquals(12, nCreatedValues, 'There should be 12 new values created.');
	}

	@isTest
    static void savePicklistOrderTest() {
		// Insert test data
		afl_TestDataFactory.insertPicklistValues();

		// Prevent creation of default picklist values
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		af.defaultPicklistValuesInserted__c = true;
		UPSERT af;

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,List<String>> valuesMap = new Map<String,List<String>>();
		List<String> positiveValues = new List<String>();
		List<String> negativeValues = new List<String>();

		positiveValues.add('value3');
		positiveValues.add('value1');
		negativeValues.add('value4');
		negativeValues.add('value2');

		valuesMap.put('allPositiveValues', positiveValues);
		valuesMap.put('allNegativeValues', negativeValues);

		String valuesJSON = JSON.serialize(valuesMap);

		Test.startTest();
		response = afl_ArticleFeedbackLgnConfigCtrl.savePicklistOrder(valuesJSON);

		Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.jsonResponse);

		List<Article_Feedback_Values__c> updatedValues = [
			SELECT Value__c, OrderPositive__c, OrderNegative__c
			FROM Article_Feedback_Values__c
			ORDER BY Value__c ASC
		];

		for (Article_Feedback_Values__c afv : updatedValues) {
			System.debug('Value__c: ' + afv.Value__c);
			System.debug('OrderPositive__c: ' + afv.OrderPositive__c);
			System.debug('OrderNegative__c: ' + afv.OrderNegative__c);
		}

		Test.stopTest();

		System.assertEquals('SUCCESS', result.get('status'), 'The operation should be succesful.');
		System.assertEquals(1, updatedValues.get(0).OrderPositive__c, 'The order number should match');
		System.assertEquals(1, updatedValues.get(1).OrderNegative__c, 'The order number should match');
		System.assertEquals(0, updatedValues.get(2).OrderPositive__c, 'The order number should match');
		System.assertEquals(0, updatedValues.get(3).OrderNegative__c, 'The order number should match');
	}

	@isTest
	static void deleteValueTest() {
		// Insert test data
		afl_TestDataFactory.insertPicklistValues();

		List<String> deleteValues = new List<String>{'value3', 'value2'};
		Test.startTest();
		afl_LightningResponse response = afl_ArticleFeedbackLgnConfigCtrl.deleteValues(deleteValues);

		List<Article_Feedback_Values__c> deletedValues = [
			SELECT Value__c
			FROM Article_Feedback_Values__c
			WHERE Value__c = 'value3' OR Value__c = 'value2'
		];
		Test.stopTest();

		System.assertEquals(0, deletedValues.size(), 'The values should have been deleted.');
	}
}