/**
* @author Altimetrik
* @description
*    started on 11/28/2018
*    Test class for the afl_ArticleThumbVoteCtrl class
**/
@isTest
private class afl_ArticleThumbVoteCtrlTest {
	@isTest
    static void upsertThumbArticleVoteTest() {
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<String> fileList = new List<String>();
		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.upsertThumbArticleVote(knowledgeObject.Id, '', '', 'Test Description', true, false, false, fileList);
		Test.stopTest();
		
		afl_Article_Feedback__c[] afl = [SELECT Name FROM afl_Article_Feedback__c WHERE Knowledge_Article_Version_Id__c =: knowledgeObject.Id LIMIT 1];
		System.assert(!afl.isEmpty());
		System.assertEquals(1, afl.size(), 'There should be a thumbs up');
	}

	@isTest
    static void getVoteTest() {
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		String kavId = (String) knowledgeObject.get('Id');

		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.getVote(kavId);
		Map<String,Object> mResult = (Map<String,Object>)JSON.deserializeUntyped(response.jsonResponse);
		Test.stopTest();

		System.assertEquals('true', mResult.get('vote'), 'The record returned should be a vote');
	}

	@isTest
    static void voteCountsTestLike() {
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<String> fileList = new List<String>();
		afl_LightningResponse upsertRec = afl_ArticleThumbVoteCtrl.upsertThumbArticleVote(knowledgeObject.Id, '', '', 'Test Description', true, false, false, fileList);

		Test.startTest();
		Map<String, Integer> result = afl_ArticleThumbVoteCtrl.voteCounts(knowledgeObject.Id);
		Test.stopTest();

		System.assertEquals(1, result.get('Likes'), 'There should be one positive vote');
	}

	@isTest
    static void voteCountsTestDislike() {
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<String> fileList = new List<String>();
		afl_LightningResponse upsertRec = afl_ArticleThumbVoteCtrl.upsertThumbArticleVote(knowledgeObject.Id, '', '', 'Test Description', false, false, false,fileList);

		Test.startTest();
		Map<String, Integer> result = afl_ArticleThumbVoteCtrl.voteCounts(knowledgeObject.Id);
		Test.stopTest();

		System.assertEquals(1, result.get('Dislikes'), 'There should be one negative vote');
	}

	@isTest
    static void upsertFeedbackWithAttachment() {
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<String> fileToAttach = afl_TestDataFactory.createFileAttachment();
		Test.startTest();
		afl_LightningResponse response = afl_ArticleThumbVoteCtrl.upsertThumbArticleVote(knowledgeObject.Id, '', '', 'Test Description', true, false, false, fileToAttach);
		Test.stopTest();
		
		Id aflId = [SELECT Id FROM afl_Article_Feedback__c WHERE Knowledge_Article_Version_Id__c =: knowledgeObject.Id LIMIT 1].Id;
		ContentDocumentLink[] insertedFile = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: aflId];
		
		System.assertEquals(1, insertedFile.size(), 'There should be an inserted attachment');
	}
	
	@isTest
	static void upsertOnlyVoteLike(){
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<SObject> knowledgeObjectList = new List<SObject>();
		knowledgeObjectList.add(knowledgeObject);
				
		Id recordId = knowledgeObject.Id;
		Boolean isLiked = True;
		Boolean isSameVote = False;
		Boolean hasNoRate = False;
		
		Test.startTest();
		Map<String, Integer> result = afl_ArticleThumbVoteCtrl.voteCounts(knowledgeObject.Id);
		System.assertEquals(Null, result.get('Likes'), 'Result should be null');
		Boolean voteResult = afl_ArticleThumbVoteCtrl.upsertOnlyVote(recordId, isLiked, isSameVote, hasNoRate);
		result = afl_ArticleThumbVoteCtrl.voteCounts(knowledgeObject.Id);
		Test.stopTest();
		
		System.assertEquals(True, voteResult, 'Upsert only vote should return True');
		System.assertEquals(1, result.get('Likes'), 'There should be one positive vote');
	}

	@isTest
	static void upsertOnlyVoteDislike(){
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<SObject> knowledgeObjectList = new List<SObject>();
		knowledgeObjectList.add(knowledgeObject);
		
		Id recordId = knowledgeObject.Id;
		Boolean isLiked = False;
		Boolean isSameVote = False;
		Boolean hasNoRate = False;
		
		Test.startTest();
		Map<String, Integer> result = afl_ArticleThumbVoteCtrl.voteCounts(knowledgeObject.Id);
		System.assertEquals(Null, result.get('Dislikes'), 'Result should be null');
		Boolean voteResult = afl_ArticleThumbVoteCtrl.upsertOnlyVote(recordId, isLiked, isSameVote, hasNoRate);
		result = afl_ArticleThumbVoteCtrl.voteCounts(knowledgeObject.Id);
		Test.stopTest();
		
		System.assertEquals(True, voteResult, 'Upsert only vote should return True');
		System.assertEquals(1, result.get('Dislikes'), 'There should be one negative vote');
	}	

	@isTest
	static void upsertOnlyVoteSameVote(){
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<SObject> knowledgeObjectList = new List<SObject>();
		knowledgeObjectList.add(knowledgeObject);
		
		Id recordId = knowledgeObject.Id;
		Boolean isLiked = False;
		Boolean isSameVote = True;
		Boolean hasNoRate = False;
		
		Test.startTest();
		Boolean voteResult = afl_ArticleThumbVoteCtrl.upsertOnlyVote(recordId, isLiked, isSameVote, hasNoRate);
		Test.stopTest();
		
		System.assertEquals(False, voteResult, 'Upsert only vote should return False');		
	}
	
	@isTest
	static void upsertOnlyVoteHasNoRate(){
		SObject knowledgeObject = afl_TestDataFactory.createKnowledgeArticle();
		List<SObject> knowledgeObjectList = new List<SObject>();
		knowledgeObjectList.add(knowledgeObject);
		
		Id recordId = knowledgeObject.Id;
		Boolean isLiked = False;
		Boolean isSameVote = False;
		Boolean hasNoRate = True;
		
		Test.startTest();
		Boolean voteResult = afl_ArticleThumbVoteCtrl.upsertOnlyVote(recordId, isLiked, isSameVote, hasNoRate);
		Test.stopTest();
		System.assertEquals(False, voteResult, 'Upsert only vote should return False');
	}
}