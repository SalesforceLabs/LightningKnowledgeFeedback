/**
 * @author Altimetrik
 * @description
 *    started on 07/10/2018
 *    Test class for the Insert Article Feedback trigger made from Ligthning Knowledge
 **/
@isTest
public class afl_InsertLgtnArticleFeedback_Test {
    static testMethod void testTrigger() {
        string publishStatus = 'draft';

        // Create the Knowledge Article
        SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();

        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
    	String q = 'select KnowledgeArticleId, Title from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
    	kavObj = (KnowledgeArticleVersion)Database.query(q);

        // Create hashtag custom setting
        afl_TestDataFactory.createHashtagCustomSetting('#TestHashtag');

        System.Test.startTest();
        	FeedItem f = new FeedItem();
            f.Body = 'test';
            f.ParentId = (String)kavObj.get('KnowledgeArticleId');
            insert f;
            FeedComment fc = new FeedComment();
            fc.CommentBody = 'This is a test post to test the hashtag #TestHashtag';
            fc.CommentType = 'TextComment';
            fc.FeedItemId = f.Id;
            insert fc;
            String theTitle = (String)kavObj.get('Title');
            List<afl_Article_Feedback__c> afs = [select id, Article_Number__c, Article_Link__c, Article_Title__c, Record_Type__c from afl_Article_Feedback__c where Article_Title__c =: theTitle ];
            System.assertNotEquals (afs,null);
        System.Test.stopTest();
    }
}