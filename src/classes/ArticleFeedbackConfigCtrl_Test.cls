/**
 * @author Altimetrik
 * @description
 *    started on 07/12/2018
 *    Test class for the ArticleFeedbackConfigCtrl class
 **/
@isTest
public class ArticleFeedbackConfigCtrl_Test {

	static testMethod void test_config() {
        Knowledge_Feedback__c setting = new Knowledge_Feedback__c();
        setting.Hashtag__c = '#TestHashtag';
        insert setting;

        System.Test.startTest();
            System.assertNotEquals(null,setting);
            ArticleFeedbackConfigCtrl ctr = new ArticleFeedbackConfigCtrl();
            ctr.edit();
            ctr.csObj.HashTag__c ='#MyTestHashtag';
            ctr.save();
            setting = Knowledge_Feedback__c.getOrgDefaults();
            system.assertEquals('#MyTestHashtag',setting.Hashtag__c);
            ctr.cancel();
        System.Test.stopTest();
    }
}
