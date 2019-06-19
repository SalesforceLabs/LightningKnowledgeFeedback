/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Test class for the Article Feedback Configuration Controller class
**/
@isTest
private class afl_ArticleFeedbackLgnConfigCtrlTest {
	static testMethod void getInitialDataTest() {
		// Create test data
		afl_Knowledge_feedback__c kf = afl_Knowledge_feedback__c.getOrgDefaults();

		if (String.isEmpty(kf.Hashtag__c)) {
			kf.Hashtag__c = '#ArticleFeedback';
			UPSERT kf;
		}

		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,Object> result = new Map<String, Object>();
		Test.startTest();
		response = afl_ArticleFeedbackLgnConfigCtrl.getInitialData();
		result = (Map<String, Object>)JSON.deserializeUntyped(response.jsonResponse);
		Test.stopTest();

		System.assertEquals(result.get('hashtag'), '#ArticleFeedback');
	}

	static testMethod void updateHashtagValueTest() {
		afl_LightningResponse response = new afl_LightningResponse();
		Map<String,Object> result = new Map<String, Object>();

		Test.startTest();
		response = afl_ArticleFeedbackLgnConfigCtrl.updateHashtagValue('#TestHashtag');
		result = (Map<String, Object>)JSON.deserializeUntyped(response.jsonResponse);
		Test.stopTest();
		afl_Knowledge_feedback__c af = afl_Knowledge_feedback__c.getOrgDefaults();
		System.assertEquals(af.Hashtag__c, '#TestHashtag');
		System.assertEquals(result.get('status'), 'SUCCESS');
	}

	static testMethod void getCurrentPrefixTest() {
		Test.startTest();
		afl_ArticleFeedbackLgnConfigCtrl ctrl = new afl_ArticleFeedbackLgnConfigCtrl();
		Test.stopTest();

		System.assertNotEquals('', ctrl.currentPrefix);
	}
}