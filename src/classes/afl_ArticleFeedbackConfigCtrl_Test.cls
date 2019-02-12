/**
* @author Altimetrik
* @description
*    started on 07/12/2018
*    Test class for the afl_ArticleFeedbackConfigCtrl class
**/
@isTest
public class afl_ArticleFeedbackConfigCtrl_Test {
	static testMethod void test_config() {
		afl_Knowledge_Feedback__c setting = new afl_Knowledge_Feedback__c();
		setting.Hashtag__c = '#TestHashtag';
		INSERT setting;
		
		System.Test.startTest();
		System.assertNotEquals(null,setting);
		afl_ArticleFeedbackConfigCtrl ctr = new afl_ArticleFeedbackConfigCtrl();
		ctr.edit();
		ctr.csObj.HashTag__c ='#MyTestHashtag';
		ctr.save();
		setting = afl_Knowledge_Feedback__c.getOrgDefaults();
		system.assertEquals('#MyTestHashtag',setting.Hashtag__c);
		ctr.cancel();
		System.Test.stopTest();
	}
}