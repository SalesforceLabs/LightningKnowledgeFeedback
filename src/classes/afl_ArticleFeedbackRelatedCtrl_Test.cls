/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Test class for the Article Feedback Related Controller class
 **/
@isTest
private class afl_ArticleFeedbackRelatedCtrl_Test {

	static testMethod void testTrigger() {

		// creates dummy Article Feedback objects
		afl_Article_Feedback__c afeedback = new afl_Article_Feedback__c();
        afeedback.Feedback_Status__c = 'New';
        afeedback.Article_Title__c = 'Test Article Title';
        afeedback.Article_Number__c = '00001';
        afeedback.Article_Type__c = 'Test Article Type';
        afeedback.Article_Version__c = 1;
        afeedback.Internal_Notes__c = 'Test notes 1';

        afl_Article_Feedback__c afeedback2 = new afl_Article_Feedback__c();
        afeedback2.Feedback_Status__c = 'New';
        afeedback2.Article_Title__c = 'Test Article Title';
        afeedback2.Article_Number__c = '00001';
        afeedback2.Article_Type__c = 'Test Article Type';
        afeedback2.Article_Version__c = 1;
        afeedback2.Internal_Notes__c = 'Test notes 2';

		insert afeedback;
        insert afeedback2;

        PageReference pageRef = Page.afl_ArticleFeedbackPage;

    	System.Test.startTest();
        	Test.setCurrentPage(pageRef);
            ApexPages.CurrentPage().getparameters().put('id', afeedback.id);
            ApexPages.StandardController sc = new ApexPages.standardController(afeedback);
            afl_ArticleFeedbackRelatedCtrl afsc = new afl_ArticleFeedbackRelatedCtrl(sc);
            System.assertNotEquals(afsc.records,null);
        System.Test.stopTest();
	}
}
