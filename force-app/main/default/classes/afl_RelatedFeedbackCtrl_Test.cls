/**
* @author Altimetrik
* @description Test class for the afl_RelatedFeedbackCtrl class
**/
@isTest
private class afl_RelatedFeedbackCtrl_Test {
    @isTest
    static void getRelatedFeedbackTest() {
        SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		String kavId = (String) knowledgeObject.get('Id');
		afl_LightningResponse upsertRec = afl_ArticleThumbVoteCtrl.upsertThumbArticleVote(kavId, '', '', 'Test Description', true, false, false);

        Test.startTest();
		afl_LightningResponse response = afl_RelatedFeedbackCtrl.getRelatedFeedback(kavId);
		List<Object> lResult = (List<Object>)JSON.deserializeUntyped(response.jsonResponse);
		Test.stopTest();

		System.assertEquals(1, lResult.size(), 'There should be 1 related feedback');
    }
}
