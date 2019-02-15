/**
 * @author Altimetrik
 * @description
 *    started on 07/17/2018
 *    Test Class for the afl_RelatedArticleCtrl class
 **/
@isTest
private with sharing class afl_RelatedArticleCtrl_Test {
    /*
        Description: Check for the fields returned by method that return some compact layout data
    */
    static testMethod void testGetCompactLayout() {
        SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();
        System.Test.StartTest();
        Map<String,Object> result = afl_RelatedArticleCtrl.getCompactLayoutData(kavObj.Id,new Map<String,Object>());
        System.Test.StopTest();

        System.assertEquals('English',result.get('articleLanguage') ,'The language returned by CompactLayoutData is not the same as at the beginning');
        System.assertEquals(0,result.get('articleVersion') ,'The article version is not the expected');
    }

    /*
        Description: Check for the related article returned by the loadKAVId method
    */
    static testMethod void testloadKAVId() {
        String publishStatus = 'draft';
        SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();
        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = 'select KnowledgeArticleId, Title, ArticleNumber from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion) Database.query(q);

        afl_LightningResponse response = new afl_LightningResponse();
        System.Test.StartTest();
        FeedItem f = new FeedItem();
        f.Body = 'test';
        f.ParentId = (String)kavObj.get('KnowledgeArticleId');
        INSERT f;

        afl_Article_Feedback__c afd = new afl_Article_Feedback__c();
        afd.Article_Number__c = (String)kavObj.get('ArticleNumber');
        afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String)kavObj.get('KnowledgeArticleId');
        afd.Article_Title__c = (String)kavObj.get('Title');
        afd.Knowledge_Article_Version_Id__c = (String)kavObj.get('Id');
        afd.Record_Type__c = '';
        INSERT afd;

        response = afl_RelatedArticleCtrl.loadKAVId(afd.Id);
        System.Test.StopTest();

        System.assertEquals('SUCCESS', response.state, 'State should be SUCCESS');
    }

    /*
        Description: Check for the related article returned by the loadKAVId method
    */
    static testMethod void testloadKAVId_TriggerFlow() {
        String publishStatus = 'draft';
        SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();
        // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
        String q = 'select KnowledgeArticleId, Title, ArticleNumber from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
        kavObj = (KnowledgeArticleVersion) Database.query(q);

        afl_LightningResponse response = new afl_LightningResponse();
        System.Test.StartTest();
        FeedItem f = new FeedItem();
        f.Body = 'test';
        f.ParentId = (String) kavObj.get('KnowledgeArticleId');
        INSERT f;

        afl_Article_Feedback__c afd = new afl_Article_Feedback__c();
        afd.Article_Number__c = (String) kavObj.get('ArticleNumber');
        afd.Article_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (String) kavObj.get('KnowledgeArticleId');
        afd.Article_Title__c = (String) kavObj.get('Title');
        afd.Knowledge_Article_Version_Id__c = (String) kavObj.get('Id');
        afd.Record_Type__c = '';
        afd.Originated_From_Trigger__c = true;
        INSERT afd;

        response = afl_RelatedArticleCtrl.loadKAVId(afd.Id);
        System.Test.StopTest();

        System.assertEquals('SUCCESS', response.state, 'State should be SUCCESS');
    }

    /*
        Description: Check for the related article returned by the loadKAVId method
    */
    static testMethod void testloadKAVId_BlankKavId() {
        afl_LightningResponse response = new afl_LightningResponse();

        System.Test.StartTest();
        response = afl_RelatedArticleCtrl.loadKAVId('');
        System.Test.StopTest();

        System.assertEquals('ERROR', response.state, 'State should be ERROR');
    }

    /*
        Description: Check for the related article returned by the loadKAVId method without a KnowledgeArticleVersion
    */
    static testMethod void testloadKAVId_QueryException() {
        afl_LightningResponse response = new afl_LightningResponse();

        System.Test.StartTest();
        afl_Article_Feedback__c afd = new afl_Article_Feedback__c();
        INSERT afd;

        response = afl_RelatedArticleCtrl.loadKAVId(afd.Id);
        System.Test.StopTest();

        System.assertEquals('ERROR', response.state, 'State should be ERROR');
    }

    /*
        Description: Check that FLS is enforced with a standard user
    */
    static testMethod void testloadKAVId_noFLS() {
        afl_LightningResponse response = new afl_LightningResponse();
        User testUser = afl_TestDataFactory.createStandardUser();

        System.runAs(testUser) {
            System.Test.StartTest();
            afl_Article_Feedback__c afd = new afl_Article_Feedback__c(
                Knowledge_Article_Version_Id__c = 'testId'
            );
            INSERT afd;

            try {
                response = afl_RelatedArticleCtrl.loadKAVId(afd.Id);
            } catch (Exception e) {
                response.state = 'ERROR';
                response.error = 'An error ocurred while retrieving the information, the related article was not found.';
            }
            System.Test.StopTest();

            System.assertEquals('ERROR', response.state, 'State should be ERROR');
        }
    }

    /*
        Description: Test scenario where Article feedback did not come from trigger
    */
    static testMethod void testloadKAVId_wrongKavId() {
        afl_LightningResponse response = new afl_LightningResponse();

        System.Test.StartTest();
        afl_Article_Feedback__c afd = new afl_Article_Feedback__c(
            Knowledge_Article_Version_Id__c = 'ka12345678abcdefgh'
        );
        INSERT afd;

        response = afl_RelatedArticleCtrl.loadKAVId(afd.Id);
        System.Test.StopTest();

        System.assertEquals('ERROR', response.state, 'State should be ERROR');
    }
}
