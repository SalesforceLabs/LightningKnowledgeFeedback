/**
* @author Altimetrik
* @description
*    started on 02/04/2019
*    Test class for afl_TriggerHandler
**/
@isTest
private with sharing class afl_TriggerHandler_Test {
	static testMethod void testHandleTriggerInsertion_FeedItem() {
		// Create knowledge article
		SObject article = afl_TestDataFactory.createKnowledgeArticle();

		Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		List<String> kavNames = new List<String>();

		for (String s : gd.keySet()) {
			if (s.contains('__ka')) {
					if (!s.contains('__kav')) {
					kavNames.add(s);
				}
			}
        }

		String objType = kavNames.get(0);

		String query = 'SELECT Id FROM ' + objType + ' LIMIT 1';
		SObject kavObj = Database.query(query);

		Test.startTest();
		FeedItem f = new FeedItem(
			Body = '#ArticleFeedback test',
			ParentId = (Id) kavObj.get('Id'),
			Type = 'TextPost'
		);

		INSERT f;
		Test.stopTest();

		afl_Article_Feedback__c feedback = [
			SELECT Article_Title__c, Feedback__c, Language__c, Originated_From_Trigger__c
			FROM afl_Article_Feedback__c
			LIMIT 1
		];

		System.assertEquals('#ArticleFeedback test', feedback.Feedback__c, 'The feedback should contain the Body of the FeedItem inserted');
		System.assert(feedback.Article_Title__c.contains('testTitle'), 'The title should contain "testTitle"');
		System.assert(feedback.Originated_From_Trigger__c, 'The feedback was created from the trigger so the flag should be true');
	}

	static testMethod void testHandleTriggerInsertion_FeedComment() {
		// Create knowledge article
		SObject article = afl_TestDataFactory.createKnowledgeArticle();

		Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		List<String> kavNames = new List<String>();

		for (String s : gd.keySet()) {
			if (s.contains('__ka')) {
					if (!s.contains('__kav')) {
					kavNames.add(s);
				}
			}
        }

		String objType = kavNames.get(0);

		String query = 'SELECT Id FROM ' + objType + ' LIMIT 1';
		SObject kavObj = Database.query(query);

		Test.startTest();
		FeedItem f1 = new FeedItem(
			Body = '#ArticleFeedback test',
			ParentId = (Id) kavObj.get('Id'),
			Type = 'TextPost'
		);

		INSERT f1;

		FeedComment f2 = new FeedComment(
			CommentBody = '#ArticleFeedback test',
			FeedItemId = f1.Id,
			CommentType = 'TextComment'
		);

		INSERT f2;
		Test.stopTest();

		afl_Article_Feedback__c feedback = [
			SELECT Article_Title__c, Feedback__c, Language__c, Originated_From_Trigger__c
			FROM afl_Article_Feedback__c
			ORDER BY CreatedDate DESC
			LIMIT 1
		];

		System.assertEquals('#ArticleFeedback test', feedback.Feedback__c, 'The feedback should contain the Body of the FeedComment inserted');
		System.assert(feedback.Article_Title__c.contains('testTitle'), 'The title should contain "testTitle"');
		System.assert(feedback.Originated_From_Trigger__c, 'The feedback was created from the trigger so the flag should be true');
	}
}