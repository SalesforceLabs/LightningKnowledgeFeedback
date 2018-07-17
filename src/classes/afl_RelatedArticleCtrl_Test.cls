/**
 * @author Altimetrik
 * @description
 *    started on 07/17/2018
 *    Test Class for the afl_RelatedArticleCtrl class
 **/
@isTest
public with sharing class afl_RelatedArticleCtrl_Test {

    /*
    Description: Check for the fields returned by method that return some compact layout data
    */
    static testMethod void testGetCompactLayout() {
        SObject kavObj = TestDataFactory.createKnowledgeArticle();
        System.Test.StartTest();
        Map<String,Object> result = afl_RelatedArticleCtrl.getCompactLayoutData(kavObj.Id,new Map<String,Object>());
        System.Test.StopTest();
        system.assertEquals('English',result.get('articleLanguage') ,'The language returned by CompactLayoutData is not the same as at the beginning');
        system.assertEquals(0,result.get('articleVersion') ,'The article version is not the expected');
    }

    /*
    Description: Check for the related article returned by the loadKAVId method
    */
    static testMethod void testloadKAVId() {
        string publishStatus = 'draft';
        SObject kavObj = TestDataFactory.createKnowledgeArticle();
        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = 'select KnowledgeArticleId, Title, ArticleNumber from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion)Database.query(q);

        afl_LightningResponse response = new afl_LightningResponse();
        System.Test.StartTest();
        FeedItem f = new FeedItem();
        f.Body = 'test';
        f.ParentId = (String)kavObj.get('KnowledgeArticleId');
        insert f;
        afl_Article_Feedback__c afd = new afl_Article_Feedback__c();
        afd.Article_Number__c = (String)kavObj.get('ArticleNumber');
        afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String)kavObj.get('KnowledgeArticleId');
        afd.Article_Title__c = (String)kavObj.get('Title');
        afd.Knowledge_Article_Version_Id__c = (String)kavObj.get('Id');
        afd.Article_Type__c = '';
        insert afd;
        response = afl_RelatedArticleCtrl.loadKAVId(afd.Id);
        System.Test.StopTest();
        System.assertEquals('SUCCESS', response.state, 'State should be SUCCESS ');

    }


}
