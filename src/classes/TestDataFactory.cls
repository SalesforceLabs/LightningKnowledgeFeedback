/**
 * @author Altimetrik
 * @description
 *    started on 07/10/2018
 *    Data Factory Class that creates or updates information to be used in test classes
 **/
@isTest
public class TestDataFactory {

	/*
	* @description
	*	Creates a Knowledge Article object for testing purposes
	* @params
	*	None
	* @return
	*	sObject - Knowledge Article
	*/
	public static SObject createKnowledgeArticle() {
		// creates Custom Article type
		Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		List<String> kavNames = new List<String>();

		for (String s : gd.keySet()) {
          if (s.contains('__kav')) {
            kavNames.add(s);
          }
        }

        //String default_language = [SELECT LanguageLocaleKey FROM Organization limit 1].LanguageLocaleKey;
        String objType = kavNames.get(0);
	    SObject kavObj;
	    kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
		kavObj.put('Title','Foo Foo Foo!!!'+String.valueOf(Crypto.getRandomInteger()));
	    kavObj.put('UrlName', 'foo-foo-foo'+String.valueOf(Crypto.getRandomInteger()));
	    kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
	    kavObj.put('Language', ArticleFeedbackSecurityHandler.getValidLanguagePicklistValue(objType));

	    insert kavObj;
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
		//creates a Custom Setting at the organization level
		Knowledge_Feedback__c setting= new Knowledge_Feedback__c();
		setting.Hashtag__c = hashtag;
		insert setting;
	}
}