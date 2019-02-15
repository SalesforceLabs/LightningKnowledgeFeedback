/**
 * @author Altimetrik
 * @description
 *    started on 07/12/2018
 *    Test class for the ArticleFeedbackSecurityHandler trigger
 **/
@isTest
private class afl_ArticleFeedbackSecurityHandler_Test {
	public static testMethod void testSecurityEnabled() {
		Profile[] profileList = [
		   	SELECT Id, Name
			FROM Profile
			WHERE Name = 'System Administrator' OR
			Name = 'Standar User'
			LIMIT 2
		];

		Map<Id,String> profileMap = new Map<Id,String>();

		for (Profile p : profileList) {
			profileMap.put(p.id, p.Name);
		}

		List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

		if (profileMap.containsKey(UserInfo.getProfileId()) && profileMap.get(UserInfo.getProfileId()) == 'System Administrator') {
			for (Profile p : profileList) {
				u[0].profileId = p.id;
				UPDATE u;

				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.SObjectType), Case.SObjectType.getDescribe().isAccessible());
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.SObjectType), Case.SObjectType.getDescribe().isCreateable());
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.SObjectType), Case.SObjectType.getDescribe().isUpdateable());
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isDeletable(Case.SObjectType), Case.SObjectType.getDescribe().isDeletable());
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());

				if (Case.SObjectType.getDescribe().isAccessible()) {
					afl_ArticleFeedbackSecurityHandler.canAccess(Case.SObjectType);
				} else {
					try {
						afl_ArticleFeedbackSecurityHandler.canAccess(Case.SObjectType);
						System.assert(false);
					} catch (SecurityException e) {}
				}

				if (Case.SObjectType.getDescribe().isCreateable()) {
					afl_ArticleFeedbackSecurityHandler.canCreate(Case.SObjectType);
				} else {
					try {
						afl_ArticleFeedbackSecurityHandler.canCreate(Case.SObjectType);
						System.assert(false);
					} catch (SecurityException e) {}
				}

				if (Case.SObjectType.getDescribe().isUpdateable()) {
					afl_ArticleFeedbackSecurityHandler.canUpdate(Case.SObjectType);
				} else {
					try {
						afl_ArticleFeedbackSecurityHandler.canUpdate(Case.SObjectType);
						System.assert(false);
					} catch (SecurityException e) {}
				}

				if (Case.SObjectType.getDescribe().isDeletable()) {
					afl_ArticleFeedbackSecurityHandler.canDelete(Case.SObjectType);
				} else {
					try {
						afl_ArticleFeedbackSecurityHandler.canDelete(Case.SObjectType);
						System.assert(false);
					} catch (SecurityException e) {}
				}

				if (Case.subject.getDescribe().isAccessible()) {
					afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
				} else {
					try {
						afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
						System.assert(false);
					} catch (SecurityException e) {}
				}

				if (Case.subject.getDescribe().isCreateable()) {
					afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
				} else {
					try {
						afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
						System.assert(false);
					} catch (SecurityException e) {}
				}

				if (Case.subject.getDescribe().isUpdateable()) {
					afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
				} else {
					try {
						afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);
						System.assert(false);
					} catch (SecurityException e) {}
				}
			}
		}
	}

	public static testMethod void testSecurityDisabled() {
		afl_ArticleFeedbackSecurityHandler.securityEnabled = false;
		Profile[] profileList = [
			SELECT Id, Name
			FROM Profile
			WHERE Name = 'System Administrator' OR
			Name = 'Standar User'
			LIMIT 2
		];

		Map<Id,String> profileMap = new Map<Id,String>();

		for (Profile p : profileList) {
			profileMap.put(p.id, p.Name);
		}

		List<User> u = [
			SELECT Id, profileId
			FROM User
			WHERE Id =: UserInfo.getUserId()
			LIMIT 1
		];

		if (profileMap.containsKey(UserInfo.getProfileId()) && profileMap.get(UserInfo.getProfileId()) == 'System Administrator') {
			for (Profile p : profileList) {
				u[0].profileId = p.id;
				UPDATE u;

				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isDeletable(Case.SObjectType), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isAccessible(Case.subject), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isCreateable(Case.subject), true);
				System.assertEquals(afl_ArticleFeedbackSecurityHandler.isUpdateable(Case.subject), true);

				afl_ArticleFeedbackSecurityHandler.canAccess(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canCreate(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canUpdate(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canDelete(Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.canAccess(Case.subject);
				afl_ArticleFeedbackSecurityHandler.canCreate(Case.subject);
				afl_ArticleFeedbackSecurityHandler.canUpdate(Case.subject);

				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
				fieldList.add( Case.subject);
				afl_ArticleFeedbackSecurityHandler.toString(fieldList);

				List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
				objectTypeList.add( Case.SObjectType);
				afl_ArticleFeedbackSecurityHandler.toString(objectTypeList);
			}
		}
	}

	public static testMethod void testGetKAVPermissions() {
		// Create the Knowledge Article
		SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();

		System.Test.startTest();
		Boolean result = afl_ArticleFeedbackSecurityHandler.getKAVPermissions();
		System.assertEquals (true,result);
		System.Test.stopTest();
	}

	public static testMethod void testIsGuestUser() {
		SObject kavObj = afl_TestDataFactory.createKnowledgeArticle();
		User testUser = afl_TestDataFactory.createStandardUser();

		System.runAs(testUser) {
			System.Test.startTest();
			Boolean result = afl_ArticleFeedbackSecurityHandler.isGuestUser();
			System.assertEquals(false, result);
			System.Test.stopTest();
		}
	}

	public static testMethod void testFormatReplace() {
		String value = '{0}';
		List<String> lstStr = new List<String> {'value1'};
		System.Test.startTest();
		String result = afl_ArticleFeedbackSecurityHandler.formatReplace(value, lstStr);
		System.assertEquals('value1', result);
		System.Test.stopTest();
	}
}
