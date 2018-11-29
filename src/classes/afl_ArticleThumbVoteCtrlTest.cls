/**
 * @author Altimetrik
 * @description
 *    started on 11/28/2018
 *    Test class for the afl_ArticleThumbVoteCtrl class
 **/

@isTest
public class afl_ArticleThumbVoteCtrlTest {

	static testMethod void upsertThumbArticleVoteTest() {
		sObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.upsertThumbArticleVote(knowledgeObject.Id, '', 'Test Description', true, false);
		Test.stopTest();
		afl_Article_Feedback__c[] afl = [SELECT Name FROM afl_Article_Feedback__c WHERE Knowledge_Article_Version_Id__c =: knowledgeObject.Id LIMIT 1];
		System.assert(!afl.isEmpty());
		System.assertEquals(1, afl.size());
	}

	static testMethod void getPickListValuesIntoListTest() {
		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.getPickListValuesIntoList();
		Map<String, Object> mResult = (Map<String, Object>)JSON.deserializeUntyped(response.jsonResponse);
		List<Object> pickListValuesList = (List<Object>)JSON.deserializeUntyped((String)mResult.get('result'));
		Test.stopTest();
		Schema.DescribeFieldResult fieldResult = afl_Article_Feedback__c.Unlike_Reason__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		System.assert(!pickListValuesList.isEmpty());
		System.assertEquals(ple.size(), pickListValuesList.size());

	}

	static testMethod void getVoteTest() {
		sObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		String kavId = (String)knowledgeObject.get('Id');

		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.getVote(kavId);
		Map<String, Object> mResult = (Map<String, Object>)JSON.deserializeUntyped(response.jsonResponse);
		// Object value = (Object)JSON.deserialize(mResult.get('vote'), Boolean.class);
		Test.stopTest();
		System.assertEquals('true', mResult.get('vote'));

	}

}
