/**
* @author Altimetrik
* @description
*    started on 02/04/2019
*    Handler for triggers
**/
public with sharing class afl_TriggerHandler {
	public afl_TriggerHandler() {
	}
	
	public class HandlerWrapper {
		public afl_Knowledge_feedback__c KnowledgeFeedback {get; set;}
		public Boolean HasRecordType {get; set;}
		public String RecordTypeField {get; set;}
		public String KnowledgeObject {get; set;}
		public Map<Id,String> RecordTypeDetails {get; set;}
		public Map<String,String> MapLanguages {get; set;}
		public String PubStatus {get; set;}
		public Boolean CommunitiesAvailable {get; set;}
		public String CommName {get; set;}
		
		public HandlerWrapper() {
		}
	}
	
	/*
	* @description
	*	Return the values needed for the triggers to operate
	* @params
	*	None
	* @return
	*	HandlerWrapper
	*/
	public static HandlerWrapper handleTriggerValues() {
		HandlerWrapper response = new HandlerWrapper();
		
		// Set customs settings
		afl_Knowledge_feedback__c kf = afl_Knowledge_feedback__c.getOrgDefaults();
		if (String.isEmpty(kf.Hashtag__c)) {
			kf.Hashtag__c = '#ArticleFeedback';
			UPSERT kf;
		}
		response.KnowledgeFeedback = kf;
		
		// Set recordType flag and recordType query parameter
		response.HasRecordType = afl_ArticleFeedbackSecurityHandler.isRecordTypeIdActive;
		response.RecordTypeField = '';
		if (response.HasRecordType) {
			response.RecordTypeField = ', RecordTypeId';
		}
		
		// Set Knowledge object
		response.KnowledgeObject = afl_ArticleFeedbackSecurityHandler.knowledgeObject;
		
		// Get allowed recordTypes
		response.RecordTypeDetails = afl_ArticleFeedbackSecurityHandler.getAllowedRecordTypesMap();
		
		// Get languages
		response.MapLanguages = new Map<String,String>();
		Schema.DescribeFieldResult fieldResult = KnowledgeArticleVersion.Language.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		
		for (Schema.PicklistEntry picklistEntry : picklistValues) {
			response.MapLanguages.put(picklistEntry.getValue(),picklistEntry.getLabel());
		}
		
		// Set publication status
		response.PubStatus = 'Online';
		if (Test.isRunningTest()) {
			response.PubStatus = 'draft';
		}
		
		// Set community availabilty and name
		String netId = '';
		response.CommunitiesAvailable = false;
		response.CommName = afl_ArticleFeedbackSecurityHandler.getCommunityName();
		Set<String> objectFields = Schema.SObjectType.FeedItem.fields.getMap().keySet();
		if (objectFields.contains('networkscope')) {
			response.CommunitiesAvailable = true;
			netId = Network.getNetworkId();
			if (String.isNotEmpty(netId)) {
				String query = 'SELECT Name FROM Network WHERE Id =: netId';
				SObject comm = Database.query(query);
				response.CommName = (String)comm.get('Name');
			}
		}
		
		return response;
	}
}
