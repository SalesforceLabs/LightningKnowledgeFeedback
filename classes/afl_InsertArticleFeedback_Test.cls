/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Test class for the Insert Article Feedback trigger
 **/
@isTest
private class afl_InsertArticleFeedback_Test {
	@isTest
    static void testTrigger() {
		// Creates Custom Article type
		String publishStatus = 'draft';

		// Create the Knowledge Article
        SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();

		// Requery the kavObj to get the KnowledgeArticleId on it that is created automatically
    	String q = 'SELECT KnowledgeArticleId, Title FROM KnowledgeArticleVersion WHERE Id = \'' + kavObj.get('Id') + '\' and PublishStatus = :publishStatus';
    	kavObj = (KnowledgeArticleVersion)Database.query(q);

		// Create hashtag custom setting
        afl_TestDataFactory.createHashtagCustomSetting('#TestHashtag');

    	System.Test.startTest();
    	FeedItem post = new FeedItem();
        post.Body = 'This is a test post to test the hashtag #TestHashtag';
       	post.Type = 'TextPost';
        post.ParentId = (String) kavObj.get('KnowledgeArticleId');
        INSERT post;

        String theTitle = (String) kavObj.get('Title');
        List<afl_Article_Feedback__c> afs = [
			SELECT Id, Article_Number__c, Article_Link__c, Article_Title__c, Record_Type__c 
			FROM afl_Article_Feedback__c 
			WHERE Article_Title__c =: theTitle
		];
        System.assertNotEquals(afs,null);
        System.Test.stopTest();
	}
}