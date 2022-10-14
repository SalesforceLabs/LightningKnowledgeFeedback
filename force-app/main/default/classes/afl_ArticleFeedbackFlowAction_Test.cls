/**
* @author Altimetrik
* @description started on 10/2022 - Test class for the afl_ArticleFeedbackFlowAction class
**/
@isTest
public with sharing class afl_ArticleFeedbackFlowAction_Test {
    @isTest
    static void getKavTest() {
        afl_ArticleFeedbackFlowAction flowAction = new afl_ArticleFeedbackFlowAction();
        SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		String kavId = (String) knowledgeObject.get('Id');

        List<afl_ArticleFeedbackFlowAction.Request> requestList = new List<afl_ArticleFeedbackFlowAction.Request>();
        afl_ArticleFeedbackFlowAction.Request req = new afl_ArticleFeedbackFlowAction.Request();
        req.kavId = kavId;
        requestList.add(req);

        Test.startTest();
        List<afl_ArticleFeedbackFlowAction.Response> response = afl_ArticleFeedbackFlowAction.getKav(requestList);
        Test.stopTest();
        System.assertEquals(1, response.size(), 'Response List of size 1 should be returned');
    }
}