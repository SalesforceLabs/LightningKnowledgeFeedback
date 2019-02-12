/**
* @author Altimetrik
* @description
*    started on 02/04/2019
*    Test class for afl_TriggerHandler
**/
@isTest
private with sharing class afl_TriggerHandler_Test {
	static testMethod void testHandleTriggerInsertion_FeedItem() {
		Test.startTest();
		// afl_TriggerHandler.handleTriggerInsertion('FeedItem');
		Test.stopTest();

		// afl_Knowledge_feedback__c kf = afl_Knowledge_feedback__c.getOrgDefaults();

		// System.assertEquals(kf.Hashtag__c, '#ArticleFeedback', 'Hashtag should be "#ArticleFeedback"');
	}
}