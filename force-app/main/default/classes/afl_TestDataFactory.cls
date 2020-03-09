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
		List<RecordType> allRecordTypes = afl_ArticleFeedbackSecurityHandler.allRecordTypes;
		if (allRecordTypes != null && allRecordTypes.size() > 0){
			kavObj.put('RecordTypeId', allRecordTypes[0].Id);
		}
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
	*	Creates a given User
	* @params
	*	String profile name
	* @return
	*	User
	*/
	public static User createUser(Boolean isAdmin) {
		// Create user for test
		Profile prof = [
			SELECT Id 
			FROM Profile 
			WHERE UserType = 'Standard' 
			AND PermissionsCustomizeApplication =: isAdmin 
			AND PermissionsModifyAllData =: isAdmin
			AND PermissionsManageCases = true
			ORDER BY CreatedDate ASC 
			LIMIT 1
		];

		User testUser = new User(
			Alias = 'newUser',
			Email='newuser@testorg.com',
			EmailEncodingKey='UTF-8',
			LastName='Testing',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			ProfileId = prof.Id,
			TimeZoneSidKey='America/Los_Angeles',
			UserName = String.valueOf(Crypto.getRandomInteger()) + 'myusername@testorg.com');

		return testUSer;
	}

	/*
	* @description
	*	Creates picklist values
	* @params
	*	None
	* @return
	*	None
	*/
	public static void insertPicklistValues() {
		// Insert test data
		List<Article_Feedback_Values__c> valuesToInsert = new List<Article_Feedback_Values__c>();
		
		valuesToInsert.add(createPicklistValue('value1', true, false, 1, 0));
		valuesToInsert.add(createPicklistValue('value2', false, true, 0, 1));
		valuesToInsert.add(createPicklistValue('value3', true, false, 0, 0));
		valuesToInsert.add(createPicklistValue('value4', false, true, 0, 0));

		INSERT valuesToInsert;
	}

	/*
	* @description
	*	Creates picklist values
	* @params
	*	String, Boolean, Boolean, Integer, Boolean
	* @return
	*	Article_Feedback_Values__c with value
	*/
	static Article_Feedback_Values__c createPicklistValue(String sValue, Boolean isPositive, Boolean isNegative, Integer orderPositive, Integer orderNegative) {
		Article_Feedback_Values__c result = new Article_Feedback_Values__c(
			Value__c = sValue, 
			Positive__c = isPositive, 
			Negative__c = isNegative,
			OrderPositive__c = orderPositive,
			OrderNegative__c = orderNegative
		);

		return result;
	}
}