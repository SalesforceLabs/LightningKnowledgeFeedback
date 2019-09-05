/**
* @author Altimetrik
* @description
*    started on 11/28/2018
*    Test class for the afl_ArticleThumbVoteCtrl class
**/

@isTest
private class afl_ArticleThumbVoteCtrlTest {
	@isTest
    static void upsertThumbArticleVoteTest() {
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.upsertThumbArticleVote(knowledgeObject.Id, '', 'Test Description', true, false, false);
		Test.stopTest();
		
		afl_Article_Feedback__c[] afl = [SELECT Name FROM afl_Article_Feedback__c WHERE Knowledge_Article_Version_Id__c =: knowledgeObject.Id LIMIT 1];
		System.assert(!afl.isEmpty());
		System.assertEquals(1, afl.size(), 'There should be a thumbs up');
	}

	@isTest
    static void getPickListValuesIntoList_NoValues_Test() {
		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.getPickListValuesIntoList();
		Map<String,Object> mResult = (Map<String,Object>) JSON.deserializeUntyped(response.jsonResponse);
		List<Object> positiveList = (List<Object>) JSON.deserializeUntyped((String) mResult.get('activePositiveValues'));
		List<Object> negativeList = (List<Object>) JSON.deserializeUntyped((String) mResult.get('activeNegativeValues'));
		Test.stopTest();

		System.assert(!positiveList.isEmpty());
		System.assert(!negativeList.isEmpty());
		System.assertEquals('Duplicate', (String) positiveList.get(0), 'The default value should match.');
		System.assertEquals('Duplicate', (String) negativeList.get(0), 'The default value should match.');
	}

	@isTest
    static void getPickListValuesIntoList_ExistingValues_Test() {
		// Insert test data
		afl_TestDataFactory.insertPicklistValues();

		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.getPickListValuesIntoList();
		Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.jsonResponse);
		List<Object> positiveList = (List<Object>) JSON.deserializeUntyped((String) result.get('activePositiveValues'));
		List<Object> negativeList = (List<Object>) JSON.deserializeUntyped((String) result.get('activeNegativeValues'));
		Test.stopTest();

		System.assert(!positiveList.isEmpty());
		System.assert(!negativeList.isEmpty());
		System.assertEquals('value3', (String) positiveList.get(0), 'The existing value should match.');
		System.assertEquals('value4', (String) negativeList.get(0), 'The existing value should match.');
	}

	@isTest
    static void getVoteTest() {
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		String kavId = (String) knowledgeObject.get('Id');

		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.getVote(kavId);
		Map<String,Object> mResult = (Map<String,Object>)JSON.deserializeUntyped(response.jsonResponse);
		Test.stopTest();

		System.assertEquals('true', mResult.get('vote'), 'The record returned should be a vote');
	}
}