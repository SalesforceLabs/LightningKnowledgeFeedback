/**
 * @author Altimetrik
 * @description
 *    started on 07/10/2018
 *    Test class for the Insert Article Feedback trigger made from Ligthning Knowledge
 **/
@isTest
private class afl_InsertLgtnArticleFeedback_Test {
    @isTest
    static void testTrigger() {
        String publishStatus = 'draft';

        // Create the Knowledge Article
        SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();

        // Requery the kavObj to get the KnowledgeArticleId on it that is created automatically
    	String q = 'SELECT KnowledgeArticleId, Title FROM KnowledgeArticleVersion WHERE Id = \'' +kavObj.get('Id')+  '\' AND PublishStatus = :publishStatus';
    	kavObj = (KnowledgeArticleVersion)Database.query(q);

        // Create hashtag custom setting
        afl_TestDataFactory.createHashtagCustomSetting('#TestHashtag');

        System.Test.startTest();
    	FeedItem f = new FeedItem();
        f.Body = 'test';
        f.ParentId = (String) kavObj.get('KnowledgeArticleId');
        INSERT f;

        FeedComment fc = new FeedComment();
        fc.CommentBody = 'This is a test post to test the hashtag #TestHashtag';
        fc.CommentType = 'TextComment';
        fc.FeedItemId = f.Id;
        INSERT fc;

        String theTitle = (String) kavObj.get('Title');
        List<afl_Article_Feedback__c> afs = [
            SELECT Id, Article_Number__c, Article_Link__c, Article_Title__c, Record_Type__c 
            FROM afl_Article_Feedback__c 
            WHERE Article_Title__c =: theTitle];
        System.assertEquals(afs.get(0).Article_Title__c, theTitle, 'The titles should match');
        System.Test.stopTest();
    }
}