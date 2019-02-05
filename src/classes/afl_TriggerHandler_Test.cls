/**
* @author Altimetrik
* @description
*    started on 02/04/2019
*    Test class for afl_TriggerHandler
**/
@isTest
private with sharing class afl_TriggerHandler_Test {
	static testMethod void testHandlerWrapper() {
		afl_TriggerHandler.HandlerWrapper result = new afl_TriggerHandler.HandlerWrapper();
		
		afl_Knowledge_feedback__c customObject = new afl_Knowledge_feedback__c();
		INSERT customObject;
		
		Map<Id,String> recordTypeDetails = new Map<Id,String>();
		recordTypeDetails.put(customObject.Id, 'test');
		
		Map<String,String> mapLanguages = new Map<String,String>();
		mapLanguages.put('testKey', 'test');
		
		Test.startTest();
		result.KnowledgeFeedback = customObject;
		result.HasRecordType = true;
		result.RecordTypeField = 'RecordTypeFieldTest';
		result.KnowledgeObject = 'KnowledgeObjectTest';
		result.RecordTypeDetails = recordTypeDetails;
		result.MapLanguages = mapLanguages;
		result.PubStatus = 'PubStatusTest';
		result.CommunitiesAvailable = true;
		result.CommName = 'CommNameTest';
		Test.stopTest();
		
		System.assertEquals(customObject, result.KnowledgeFeedback, 'The customs objects should be the same');
		System.assertEquals(true, result.HasRecordType, 'HasRecordType value should be true');
		System.assertEquals('RecordTypeFieldTest', result.RecordTypeField, 'RecordTypeField value should be "RecordTypeFieldTest"');
		System.assertEquals('KnowledgeObjectTest', result.KnowledgeObject, 'KnowledgeObject value should be "KnowledgeObjectTest"');
		System.assertEquals(recordTypeDetails, result.RecordTypeDetails, 'The maps should be the same');
		System.assertEquals(mapLanguages, result.MapLanguages, 'The maps should be the same');
		System.assertEquals('PubStatusTest', result.PubStatus, 'PubStatus value should be "PubStatusTest"');
		System.assertEquals(true, result.CommunitiesAvailable, 'CommunitiesAvailable value should be true');
		System.assertEquals('CommNameTest', result.CommName, 'HasRecordType value should be "CommNameTest"');
	}
	
	static testMethod void testHandleTriggerValues() {
		Test.startTest();
		afl_TriggerHandler.HandlerWrapper result = afl_TriggerHandler.handleTriggerValues();
		Test.stopTest();
		
		System.debug('result: ' + result);
		
		System.assertEquals(result.KnowledgeFeedback.Hashtag__c, '#ArticleFeedback', 'Hashtag should be "#ArticleFeedback"');
		System.assertEquals(result.PubStatus, 'draft', 'Status should be "draft"');
	}
}
