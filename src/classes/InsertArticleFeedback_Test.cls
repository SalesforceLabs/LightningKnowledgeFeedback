/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Test class for the Insert Article Feedback trigger
 **/
@isTest
private class InsertArticleFeedback_Test {

	static testMethod void testTrigger() {
		// creates Custom Article type
		string publishStatus = 'draft';
		Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
		List<String> kavNames = new List<String>();

		for (String s : gd.keySet()) {
          if (s.contains('__kav')) {
            kavNames.add(s);
          }
        }

        String default_language = [SELECT LanguageLocaleKey FROM Organization limit 1].LanguageLocaleKey;
        String objType = kavNames.get(0);
	    SObject kavObj;
	    kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
	    kavObj.put('Title','Foo Foo Foo!!!'+String.valueOf(Crypto.getRandomInteger()));
	    kavObj.put('UrlName', 'foo-foo-foo'+String.valueOf(Crypto.getRandomInteger()));
	    kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
	    kavObj.put('Language', default_language);
	    insert kavObj;

	    // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
    	String q = 'select KnowledgeArticleId, Title from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
    	kavObj = (KnowledgeArticleVersion)Database.query(q);

    	//creates a Custom Setting at the organization level
		Knowledge_Feedback__c setting= new Knowledge_Feedback__c();
		setting.Hashtag__c = '#TestHashtag';
		insert setting;

    	System.Test.startTest();
        	FeedItem post = new FeedItem();
            post.Body = 'This is a test post to test the hashtag #TestHashtag';
           	post.Type = 'TextPost';
            post.ParentId = (String)kavObj.get('KnowledgeArticleId');
            insert post;
            String theTitle = (String)kavObj.get('Title');
            List<Article_Feedback__c> afs = [select id, Article_Number__c, Article_Link__c, Article_Title__c, Article_Type__c from Article_Feedback__c where Article_Title__c =: theTitle ];
            System.assertNotEquals (afs,null);
        System.Test.stopTest();
	}

     public static testMethod void testSecurityEnabled() {
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){
            for (Profile p : profileList) {
                u[0].profileId = p.id;
                update u;
                System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.sObjectType), Case.sObjectType.getDescribe().isAccessible());
                System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.sObjectType), Case.sObjectType.getDescribe().isCreateable());
                System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.sObjectType), Case.sObjectType.getDescribe().isUpdateable());
                System.assertEquals(ArticleFeedbackSecurityHandler.isDeletable(Case.sObjectType), Case.sObjectType.getDescribe().isDeletable());
                System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
                System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
                System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());

                if (Case.sObjectType.getDescribe().isAccessible())
                    ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
                else
                    try {
                        ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isCreateable())
                    ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
                else
                    try {
                        ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isUpdateable())
                    ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
                else
                    try {
                        ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isDeletable())
                    ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
                else
                    try {
                        ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isAccessible())
                    ArticleFeedbackSecurityHandler.canAccess(Case.subject);
                else
                    try {
                        ArticleFeedbackSecurityHandler.canAccess(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isCreateable())
                    ArticleFeedbackSecurityHandler.canCreate(Case.subject);
                else
                    try {
                        ArticleFeedbackSecurityHandler.canCreate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isUpdateable())
                    ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
                else
                    try {
                        ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}
            }
        }
    }

    public static testMethod void testSecurityDisabled() {
        ArticleFeedbackSecurityHandler.securityEnabled = false;
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ) {
            for (Profile p : profileList) {
                u[0].profileId = p.id;
                update u;
                System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.sObjectType), true);
                System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.sObjectType), true);
                System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.sObjectType), true);
                System.assertEquals(ArticleFeedbackSecurityHandler.isDeletable(Case.sObjectType), true);
                System.assertEquals(ArticleFeedbackSecurityHandler.isAccessible(Case.subject), true);
                System.assertEquals(ArticleFeedbackSecurityHandler.isCreateable(Case.subject), true);
                System.assertEquals(ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), true);

                ArticleFeedbackSecurityHandler.canAccess(Case.sObjectType);
                ArticleFeedbackSecurityHandler.canCreate(Case.sObjectType);
                ArticleFeedbackSecurityHandler.canUpdate(Case.sObjectType);
                ArticleFeedbackSecurityHandler.canDelete(Case.sObjectType);
                ArticleFeedbackSecurityHandler.canAccess(Case.subject);
                ArticleFeedbackSecurityHandler.canCreate(Case.subject);
                ArticleFeedbackSecurityHandler.canUpdate(Case.subject);

                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                fieldList.add( Case.subject );
                ArticleFeedbackSecurityHandler.toString(fieldList);

                List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
                objectTypeList.add( Case.sObjectType );
                ArticleFeedbackSecurityHandler.toString(objectTypeList);
            }
        }
    }

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