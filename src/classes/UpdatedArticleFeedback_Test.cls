/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Test class for the UpdateArticleFeedback trigger
 **/

@isTest
private class UpdatedArticleFeedback_Test{

	static testMethod void testTrigger() {

        // creates dummy KnowledgeArticleVersion
        string publishStatus = 'draft';
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();

        List<String> kavNames = new List<String>();
        for (String s : gd.keySet()) {
          if (s.contains('__kav')) {
            kavNames.add(s);
          }
        }

        String default_language = [SELECT LanguageLocaleKey FROM Organization limit 1].LanguageLocaleKey;
        String objType = kavNames.get(0);
        SObject kavObj;
        kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
        kavObj.put('Title','Foo Foo Foo!!!'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('UrlName', 'foo-foo-foo'+String.valueOf(Crypto.getRandomInteger()));
        kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
        kavObj.put('Language', ArticleFeedbackSecurityHandler.getValidLanguagePicklistValue(objType));
        insert kavObj;

        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = 'select KnowledgeArticleId, Title from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion)Database.query(q);

        // creates dummy FeedItem
        FeedItem post = new FeedItem();
        post.Body = 'This is a test post';
        post.Type = 'TextPost';
        post.ParentId = (String)kavObj.get('KnowledgeArticleId');
        insert post;

		// creates dummy Article Feedback object
		Article_Feedback__c afeedback = new Article_Feedback__c();
        afeedback.Feedback_Status__c = 'New';
        afeedback.Article_Title__c = 'Test Article Title';
        afeedback.Article_Number__c = '00001';
        afeedback.Internal_Notes__c = 'Test notes';
        afeedback.Article_Feed_Update__c = '';
        afeedback.Parent_FeedItem__c = post.Id;
		insert afeedback;

    	System.Test.startTest();
        	afeedback.Article_Feed_Update__c = 'Test update';
            update afeedback;
            System.assertEquals (afeedback.Article_Feed_Update__c ,'Test update');
        System.Test.stopTest();
	}
}
