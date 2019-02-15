/**
 * @author Altimetrik
 * @description
 *    started on 07/10/2018
 *    Data Factory Class that creates or updates information to be used in test classes
 **/
@isTest
public class afl_TestDataFactory {
	/*
	* @description
	*	Creates a Knowledge Article object for testing purposes
	* @params
	*	None
	* @return
	*	SObject - Knowledge Article
	*/
	public static SObject createKnowledgeArticle() {
		// Creates Custom Article type
		Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		List<String> kavNames = new List<String>();

		for (String s : gd.keySet()) {
			if (s.contains('__kav')) {
				kavNames.add(s);
			}
        }

        String objType = kavNames.get(0);
	    SObject kavObj;
		afl_ArticleFeedbackSecurityHandler.canAccess(KnowledgeArticleVersion.SObjectType);
	    kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
		afl_ArticleFeedbackSecurityHandler.canAccess(Schema.getGlobalDescribe().get(objType));
		kavObj.put('Title', 'testTitle' + String.valueOf(Crypto.getRandomInteger()));
	    kavObj.put('UrlName', 'testUrlName' + String.valueOf(Crypto.getRandomInteger()));
	    kavObj.put('Summary', 'testSummary');
	    kavObj.put('Language', afl_ArticleFeedbackSecurityHandler.getValidLanguagePicklistValue(objType));
	    INSERT kavObj;

		return kavObj;
	}

	/*
	* @description
	*	Creates the hashtag for testing purposes
	* @params
	*	String - hashtag name
	* @return
	*	none
	*/
	public static void createHashtagCustomSetting(String hashtag) {
		// Creates a Custom Setting at the organization level
		afl_Knowledge_Feedback__c setting= new afl_Knowledge_Feedback__c();
		setting.Hashtag__c = hashtag;
		INSERT setting;
	}

	/*
	* @description
	*	Creates a standard User
	* @params
	*	void
	* @return
	*	none
	*/
	public static User createStandardUser() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User testUser = new User(
			Alias = 'testStd', Email = 'teststandarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName = 'Testing', LanguageLocaleKey='en_US',
			LocaleSidKey = 'en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='afl_test_user@testorg.com');
		INSERT testUser;

		return testUser;
	}
}
