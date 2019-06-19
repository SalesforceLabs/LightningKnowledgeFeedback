/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Test class for the UpdateArticleFeedback trigger
 **/

@isTest
private class afl_UpdatedArticleFeedback_Test{
	static testMethod void testTrigger() {
        // creates dummy KnowledgeArticleVersion
        String publishStatus = 'draft';

		// Create the Knowledge Article
        SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();

        // Requery the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = 'select KnowledgeArticleId, Title from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion)Database.query(q);

        // Creates dummy FeedItem
        FeedItem post = new FeedItem();
        post.Body = 'This is a test post';
        post.Type = 'TextPost';
        post.ParentId = (String) kavObj.get('KnowledgeArticleId');
        INSERT post;

		// Creates dummy Article Feedback object
		afl_Article_Feedback__c afeedback = new afl_Article_Feedback__c();
        afeedback.Feedback_Status__c = 'New';
        afeedback.Article_Title__c = 'Test Article Title';
        afeedback.Article_Number__c = '00001';
        afeedback.Internal_Notes__c = 'Test notes';
        afeedback.Article_Feed_Update__c = '';
        afeedback.Parent_FeedItem__c = post.Id;
		INSERT afeedback;

    	System.Test.startTest();
    	afeedback.Article_Feed_Update__c = 'Test update';
        update afeedback;
        System.assertEquals (afeedback.Article_Feed_Update__c ,'Test update');
        System.Test.stopTest();
	}
}